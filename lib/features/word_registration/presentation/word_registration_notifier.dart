import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_registration_notifier.g.dart';

@riverpod
class WordRegistrationNotifier extends _$WordRegistrationNotifier {
  @override
  WordRegistrationState build() => const WordRegistrationState();

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

    final partsOfSpeech = state.selectedPartsOfSpeech.isEmpty
        ? const {PartOfSpeech.other}
        : state.selectedPartsOfSpeech;

    await ref.read(databaseProvider).wordDao.insertWord(
      WordsCompanion(
        word: Value(word.trim()),
        ipa: Value(ipa.trim()),
        japanese: Value(japanese.trim()),
        partsOfSpeech: Value(partsOfSpeech.toList()),
        exampleEn: Value(exampleEn.trim()),
        exampleJa: Value(exampleJa.trim()),
      ),
    );
    return true;
  }
}
