// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'Japanese',
      'zhHant': 'Chinese (Traditional)',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': 'Japanese',
      'zhHant': 'Chinese',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => 'Learning';

  @override
  String get navLearningWords => 'Words in progress';

  @override
  String get navAllWords => 'All words';

  @override
  String get navQuiz => 'Flash quiz';

  @override
  String get navQuizShort => 'Quiz';

  @override
  String get navRegistration => 'Add word';

  @override
  String get navSettings => 'Settings';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String showingWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return 'Showing $_temp0';
  }

  @override
  String get addShort => '＋ Add';

  @override
  String get addWord => '＋ Add word';

  @override
  String get search => 'Search';

  @override
  String get menuWords => 'Words';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuWindow => 'Window';

  @override
  String get sidebarTitle => 'Vocabulary';

  @override
  String get sidebarSavedLocally => 'Saved on this Mac';

  @override
  String get posNoun => 'noun';

  @override
  String get posVerb => 'verb';

  @override
  String get posAdjective => 'adjective';

  @override
  String get posAdverb => 'adverb';

  @override
  String get posOther => 'other';

  @override
  String get posSeparator => '/';

  @override
  String get fieldWord => 'English word *';

  @override
  String get fieldIpa => 'Pronunciation (IPA)';

  @override
  String fieldMeaning(String language) {
    return 'Translation ($language) *';
  }

  @override
  String get fieldPartsOfSpeech => 'Part of speech (choose any)';

  @override
  String get fieldExampleEn => 'Example (English)';

  @override
  String fieldExampleTranslation(String language) {
    return 'Example ($language)';
  }

  @override
  String get manualInputHint => 'Enter manually';

  @override
  String registrationIntro(String language) {
    return 'Enter an English word to fill in its pronunciation, $language translation, examples and more from the dictionary.';
  }

  @override
  String get autoFill => 'Auto-fill';

  @override
  String get skipToManual => 'Skip and enter manually';

  @override
  String get fetchingDictionary => 'Looking up the dictionary...';

  @override
  String exampleTranslationFailed(String language) {
    return 'Couldn\'t get the $language translation of the example. You can enter it manually.';
  }

  @override
  String get exampleTranslationFailedShort =>
      'Couldn\'t translate the example (you can enter it manually)';

  @override
  String get registerButton => 'Add';

  @override
  String get registerShort => 'Add';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get noticeNotFound =>
      'Not found in the dictionary. You can enter it manually.';

  @override
  String noticeMeaningNotFound(String language) {
    return 'No $language translation was found in the dictionary (please enter it manually)';
  }

  @override
  String get noticeOnlyMeaningFound =>
      'No pronunciation or example was found (only the translation was filled in)';

  @override
  String errorDuplicate(String word) {
    return '\"$word\" is already in your word list.';
  }

  @override
  String get errorEmptyWord => 'Please enter an English word.';

  @override
  String get errorFetchFailed =>
      'Couldn\'t reach the dictionary. Please check your connection.';

  @override
  String errorRequiredFields(String language) {
    return 'The English word and translation are required.';
  }

  @override
  String get editWordTitle => 'Edit word';

  @override
  String get deleteThisWord => 'Delete this word';

  @override
  String get editEllipsis => 'Edit...';

  @override
  String get deleteEllipsis => 'Delete...';

  @override
  String deleteConfirmTitle(String word) {
    return 'Delete \"$word\"?';
  }

  @override
  String get deleteConfirmBody => 'This can\'t be undone.';

  @override
  String get deleteConfirmCancel => 'Cancel';

  @override
  String get deleteConfirmOk => 'Delete';

  @override
  String get noExample => 'No example';

  @override
  String get markLearned => 'Mark as learned';

  @override
  String showMeaningWithLanguage(String language) {
    return 'Show translation';
  }

  @override
  String get showMeaning => 'Show translation';

  @override
  String correctCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return 'Remembered $_temp0';
  }

  @override
  String get rememberedCheck => 'Learned';

  @override
  String get learningHint =>
      'Check a word to mark it as learned and remove it from this list. Click a card to edit it (right-click for more).';

  @override
  String get noWordsYet => 'No words yet.';

  @override
  String get learningEmpty =>
      'No words in progress.\nAdd some words to get started.';

  @override
  String sortOrderLabel(String order) {
    return 'Sort: $order';
  }

  @override
  String get sortSheetTitle => 'Sort';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortLearningFirst => 'Learning → Learned';

  @override
  String get sortLearnedFirst => 'Learned → Learning';

  @override
  String get sortMostCorrect => 'Most remembered';

  @override
  String get sortLeastCorrect => 'Least remembered';

  @override
  String get tableLearned => 'Learned';

  @override
  String get tableWord => 'Word';

  @override
  String get tableIpa => 'IPA';

  @override
  String get tablePartOfSpeech => 'Part of speech';

  @override
  String tableMeaning(String language) {
    return 'Translation';
  }

  @override
  String get tableExample => 'Example';

  @override
  String get tablePronunciation => 'Audio';

  @override
  String get showAnswer => 'Show answer';

  @override
  String get quizForgot => 'Forgot';

  @override
  String get quizRemembered => 'Remembered';

  @override
  String get quizForgotHint =>
      'Choosing \"Forgot\" moves the word back to your learning list';

  @override
  String get quizEmpty =>
      'No words to review yet.\nWords you mark as learned will show up here.';

  @override
  String get toLearningList => 'Go to learning list';

  @override
  String get quizDone => 'Review complete';

  @override
  String quizSummary(int ok, int forgot) {
    return 'Remembered $ok / Forgot $forgot';
  }

  @override
  String get quizContinue => 'Continue';

  @override
  String get quizForgotWordsHeader =>
      'Forgotten words (moved back to your learning list)';

  @override
  String quizDirectionFromEnglish(String language) {
    return 'English → $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return '$language → English';
  }

  @override
  String get sectionDisplay => 'Display';

  @override
  String get theme => 'Theme';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get cardLayout => 'Learning card layout';

  @override
  String get layoutTwoColumns => '2 columns (compact)';

  @override
  String get layoutOneColumn => '1 column (full width)';

  @override
  String get showIpa => 'Show pronunciation (IPA)';

  @override
  String get sectionQuiz => 'Quiz';

  @override
  String get sectionTranslation => 'Translation language';

  @override
  String get translationLanguageCaption =>
      'New words are translated into this language. Words you\'ve already added keep their translations.';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionSupport => 'Support';

  @override
  String get writeReview => 'Write a review on the App Store';

  @override
  String get sectionAuthorApps => 'More apps by the developer';

  @override
  String get getApp => 'Get';

  @override
  String get sectionInfo => 'About';

  @override
  String get version => 'Version';

  @override
  String get licenses => 'Licenses';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licenses',
      one: 'License',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed => 'Couldn\'t load the license information.';

  @override
  String get licenseAutoGenerated =>
      'This list is generated automatically at build time.';

  @override
  String get uiScale => 'Display size';

  @override
  String get exportDone => 'Exported';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataEllipsis => 'Export data...';

  @override
  String get importData => 'Import data';

  @override
  String get importDataEllipsis => 'Import data...';

  @override
  String get importDoneTitle => 'Import complete';

  @override
  String importAdded(int count) {
    return 'Added: $count';
  }

  @override
  String importUpdated(int count) {
    return 'Updated: $count';
  }

  @override
  String importUnchanged(int count) {
    return 'Unchanged: $count';
  }

  @override
  String importSkipped(int count) {
    return 'Skipped: $count';
  }

  @override
  String get importFailedTitle => 'Couldn\'t import';

  @override
  String get importErrorInvalidJson => 'The file couldn\'t be read as JSON.';

  @override
  String get importErrorInvalidFormat => 'The JSON format is invalid.';

  @override
  String get importErrorUnsupportedVersion =>
      'This file version isn\'t supported.';

  @override
  String get deeplKeyHint => 'Enter your DeepL API key';

  @override
  String deeplDescription(String language) {
    return 'With a DeepL API Free key, auto-fill also translates the English example into $language. Without one, the example translation is skipped.';
  }

  @override
  String get icloudSync => 'iCloud sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing...';

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get syncErrorNoICloud =>
      'iCloud isn\'t available. Sign in to iCloud Drive in Settings.';

  @override
  String get syncErrorNotCurrent =>
      'Sync was skipped because the latest data couldn\'t be downloaded from iCloud.';

  @override
  String get syncErrorUnsupported =>
      'iCloud sync isn\'t available on this platform.';

  @override
  String syncErrorFailed(String detail) {
    return 'Sync failed: $detail';
  }

  @override
  String get removeAds => 'Remove ads';

  @override
  String get proPurchasedCaption => 'You own Pro';

  @override
  String get priceUnavailable => 'Couldn\'t get the price';

  @override
  String oneTimePrice(String price) {
    return 'One-time purchase $price';
  }

  @override
  String get purchased => 'Purchased';

  @override
  String get purchase => 'Buy';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchaseFailed => 'Couldn\'t complete the purchase';

  @override
  String get restoreChecking => 'Checking…';

  @override
  String get restoreDone => 'Restored';

  @override
  String get restoreNotFound => 'No previous purchase found';

  @override
  String get restoreFailed => 'Couldn\'t restore';

  @override
  String get listenPronunciation => 'Listen';

  @override
  String get pronunciationShort => 'Audio';

  @override
  String get pronunciationTooltip =>
      'Check the pronunciation on Google Translate';

  @override
  String get pageLoadFailed =>
      'Couldn\'t load the page.\nCheck your connection and try again.';

  @override
  String get reload => 'Reload';
}
