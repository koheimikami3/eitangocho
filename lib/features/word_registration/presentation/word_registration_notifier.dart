import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/domain/registration_error.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:eitangocho/utils/headword.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_registration_notifier.g.dart';

@riverpod
class WordRegistrationNotifier extends _$WordRegistrationNotifier {
  @override
  WordRegistrationState build() => const WordRegistrationState();

  /// 既に登録済みの単語なら、エラーを state に立てて true を返す。
  /// 単語帳として同じ単語が 2 件並ぶのは事故なので、登録させずに止める。
  Future<bool> _rejectIfDuplicate(String word) async {
    final existing = await ref.read(databaseProvider).wordDao.findByWord(word);
    // 破棄後は state に触らない(呼び出し側も続行させない)。
    if (!ref.mounted) return true;
    if (existing == null) return false;
    state = state.copyWith(error: RegistrationError.duplicate(existing.word));
    return true;
  }

  /// ステップ 1 の「自動入力」。取得成功・未収録なら form へ、失敗なら input に戻す。
  Future<void> autoFill(String rawWord) async {
    final word = normalizeHeadword(rawWord);
    if (word.isEmpty) {
      state = state.copyWith(error: const RegistrationError.emptyWord());
      return;
    }
    // 辞書を引く前に重複を弾く(登録できない単語のために通信しない)。
    if (await _rejectIfDuplicate(word)) return;
    state = state.copyWith(step: RegistrationStep.loading, error: null);
    try {
      final info = await ref.read(wordInfoProviderProvider).fetch(word);
      // fetch 中に画面を離れると自動破棄されるため、破棄後は state に触らない
      if (!ref.mounted) return;
      if (info == null) {
        state = state.copyWith(step: RegistrationStep.form, notFound: true);
        return;
      }
      // WordInfoProvider 抽象は翻訳失敗を返せないため、「英例文はあるのに
      // 和訳が空」をヒューリスティックに失敗とみなす(取得成功で空文字に
      // なることは実質ない)。辞書側(kaikki)の例文を採ったときは対訳が
      // 無いのでここに該当する。
      state = state.copyWith(
        step: RegistrationStep.form,
        fetched: info,
        notFound: false,
        selectedPartsOfSpeech: info.partsOfSpeech.toSet(),
        translationFailed:
            info.exampleEn.isNotEmpty && info.exampleTranslation.isEmpty,
      );
    } on WordInfoException {
      if (!ref.mounted) return;
      state = state.copyWith(
        step: RegistrationStep.input,
        error: const RegistrationError.fetchFailed(),
      );
    }
  }

  /// ステップ 1 の「スキップして手動で入力する」(空フォームへ)。
  void skipToManual() {
    state = state.copyWith(
      step: RegistrationStep.form,
      fetched: null,
      notFound: false,
      translationFailed: false,
      error: null,
    );
  }

  /// フォームの「戻る」(ステップ 1 へ。取得結果は破棄する)。
  void backToInput() {
    state = state.copyWith(
      step: RegistrationStep.input,
      fetched: null,
      notFound: false,
      translationFailed: false,
      error: null,
      selectedPartsOfSpeech: const {},
    );
  }

  void togglePartOfSpeech(PartOfSpeech pos) {
    final current = state.selectedPartsOfSpeech;
    state = state.copyWith(
      selectedPartsOfSpeech: current.contains(pos)
          ? (Set<PartOfSpeech>.from(current)..remove(pos))
          : (Set<PartOfSpeech>.from(current)..add(pos)),
      error: null,
    );
  }

  Future<bool> save({
    required String word,
    required String ipa,
    required String meaning,
    required String exampleEn,
    required String exampleTranslation,
  }) async {
    final headword = normalizeHeadword(word);
    if (headword.isEmpty || meaning.trim().isEmpty) {
      state = state.copyWith(error: const RegistrationError.requiredFields());
      return false;
    }
    // フォームでも英単語を書き換えられるため、保存時にも重複を見る
    // (ステップ 1 で弾いた単語に戻された場合もここで止まる)。
    if (await _rejectIfDuplicate(headword)) return false;

    // 自動取得できた並び(辞書の主用法が先頭)を保ち、手動で足した品詞は
    // 規定順で後ろに置く。チップのタップ順には依存させない。
    final partsOfSpeech = state.selectedPartsOfSpeech.isEmpty
        ? const [PartOfSpeech.other]
        : state.selectedPartsOfSpeech.ordered(
            basedOn: state.fetched?.partsOfSpeech ?? const [],
          );

    await ref
        .read(databaseProvider)
        .wordDao
        .insertWord(
          WordsCompanion(
            word: Value(headword),
            ipa: Value(ipa.trim()),
            meaning: Value(meaning.trim()),
            partsOfSpeech: Value(partsOfSpeech),
            exampleEn: Value(exampleEn.trim()),
            exampleTranslation: Value(exampleTranslation.trim()),
            // audioUrl はフォームに出さない。現在の辞書ソースは音声 URL を
            // 返さないため常に空になるが、経路だけ残している(docs/design.md)。
            audioUrl: Value(state.fetched?.audioUrl ?? ''),
          ),
        );
    // 登録単語数の節目でのレビュー依頼(条件は ReviewPrompter が判定する)。
    // macOS / iOS で共有するこの Notifier を呼び出し口にする。true を返すと
    // 呼び出し側がシートを閉じる(macOS は学習中リストへ切り替える)ので、
    // 依頼は ReviewConfig.promptDelay だけ待ってその後に出る。
    // 依頼の成否は登録に関係しないので待たない。
    unawaited(ref.read(reviewPrompterProvider).onWordRegistered());
    return true;
  }
}
