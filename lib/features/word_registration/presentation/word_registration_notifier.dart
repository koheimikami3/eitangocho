import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_registration_notifier.g.dart';

@riverpod
class WordRegistrationNotifier extends _$WordRegistrationNotifier {
  @override
  WordRegistrationState build() => const WordRegistrationState();

  /// ステップ 1 の「自動入力」。取得成功・未収録なら form へ、失敗なら input に戻す。
  Future<void> autoFill(String word) async {
    if (word.trim().isEmpty) {
      state = state.copyWith(errorMessage: '英単語を入力してください。');
      return;
    }
    state = state.copyWith(step: RegistrationStep.loading, errorMessage: null);
    try {
      final info = await ref.read(wordInfoProviderProvider).fetch(word);
      // fetch 中に画面を離れると自動破棄されるため、破棄後は state に触らない
      if (!ref.mounted) return;
      if (info == null) {
        state = state.copyWith(step: RegistrationStep.form, notFound: true);
        return;
      }
      // WordInfoProvider 抽象は翻訳失敗を返せないため、「キー設定済みかつ
      // 英例文ありなのに和訳が空」をヒューリスティックに失敗とみなす
      // (翻訳成功で空文字になることは実質ない)。
      final deeplKeySet =
          (await ref.read(settingsProvider.future)).deeplApiKey.isNotEmpty;
      if (!ref.mounted) return;
      state = state.copyWith(
        step: RegistrationStep.form,
        fetched: info,
        notFound: false,
        selectedPartsOfSpeech: info.partsOfSpeech.toSet(),
        translationFailed:
            deeplKeySet && info.exampleEn.isNotEmpty && info.exampleJa.isEmpty,
      );
    } on WordInfoException {
      if (!ref.mounted) return;
      state = state.copyWith(
        step: RegistrationStep.input,
        errorMessage: '辞書データの取得に失敗しました。通信環境を確認してください。',
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
      errorMessage: null,
    );
  }

  /// フォームの「戻る」(ステップ 1 へ。取得結果は破棄する)。
  void backToInput() {
    state = state.copyWith(
      step: RegistrationStep.input,
      fetched: null,
      notFound: false,
      translationFailed: false,
      errorMessage: null,
      selectedPartsOfSpeech: const {},
    );
  }

  void togglePartOfSpeech(PartOfSpeech pos) {
    final current = state.selectedPartsOfSpeech;
    state = state.copyWith(
      selectedPartsOfSpeech: current.contains(pos)
          ? (Set<PartOfSpeech>.from(current)..remove(pos))
          : (Set<PartOfSpeech>.from(current)..add(pos)),
      errorMessage: null,
    );
  }

  Future<bool> save({
    required String word,
    required String ipa,
    required String japanese,
    required String exampleEn,
    required String exampleJa,
  }) async {
    if (word.trim().isEmpty || japanese.trim().isEmpty) {
      state = state.copyWith(errorMessage: '英単語と日本語訳は必須です。');
      return false;
    }

    // 自動取得できた並び(辞書の主用法が先頭)を保ち、手動で足した品詞は
    // 規定順で後ろに置く。チップのタップ順には依存させない。
    final partsOfSpeech = state.selectedPartsOfSpeech.isEmpty
        ? const [PartOfSpeech.other]
        : state.selectedPartsOfSpeech.ordered(
            basedOn: state.fetched?.partsOfSpeech ?? const [],
          );

    await ref.read(databaseProvider).wordDao.insertWord(
      WordsCompanion(
        word: Value(word.trim()),
        ipa: Value(ipa.trim()),
        japanese: Value(japanese.trim()),
        partsOfSpeech: Value(partsOfSpeech),
        exampleEn: Value(exampleEn.trim()),
        exampleJa: Value(exampleJa.trim()),
        // audioUrl はフォームに出さず、自動取得できたときだけ保存する
        audioUrl: Value(state.fetched?.audioUrl ?? ''),
      ),
    );
    return true;
  }
}
