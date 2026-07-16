import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_registration_state.freezed.dart';

@freezed
abstract class WordRegistrationState with _$WordRegistrationState {
  const factory WordRegistrationState({
    @Default(<PartOfSpeech>{}) Set<PartOfSpeech> selectedPartsOfSpeech,
    String? errorMessage,
  }) = _WordRegistrationState;
}
