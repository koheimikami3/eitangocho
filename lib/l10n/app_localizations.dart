import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// 訳の言語の名前(設定の選択肢)。language は TranslationLanguage.name
  ///
  /// In ja, this message translates to:
  /// **'{language, select, ja{日本語} zhHant{中国語(繁体字)} other{}}'**
  String translationLanguageName(String language);

  /// 訳の言語の短い名前(項目名・出題方向に差し込む)
  ///
  /// In ja, this message translates to:
  /// **'{language, select, ja{日本語} zhHant{中国語} other{}}'**
  String translationLanguageShortName(String language);

  /// No description provided for @navLearning.
  ///
  /// In ja, this message translates to:
  /// **'学習中'**
  String get navLearning;

  /// No description provided for @navLearningWords.
  ///
  /// In ja, this message translates to:
  /// **'学習中の単語'**
  String get navLearningWords;

  /// No description provided for @navAllWords.
  ///
  /// In ja, this message translates to:
  /// **'全単語'**
  String get navAllWords;

  /// No description provided for @navQuiz.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュクイズ'**
  String get navQuiz;

  /// タブバーの短いラベル
  ///
  /// In ja, this message translates to:
  /// **'クイズ'**
  String get navQuizShort;

  /// No description provided for @navRegistration.
  ///
  /// In ja, this message translates to:
  /// **'単語を登録'**
  String get navRegistration;

  /// No description provided for @navSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @wordCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}語'**
  String wordCount(int count);

  /// No description provided for @showingWordCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}語を表示中'**
  String showingWordCount(int count);

  /// ヘッダーの登録ボタン
  ///
  /// In ja, this message translates to:
  /// **'＋ 登録'**
  String get addShort;

  /// No description provided for @addWord.
  ///
  /// In ja, this message translates to:
  /// **'＋ 単語を登録'**
  String get addWord;

  /// No description provided for @search.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get search;

  /// macOS のメニュー名
  ///
  /// In ja, this message translates to:
  /// **'単語'**
  String get menuWords;

  /// macOS のメニュー名
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get menuEdit;

  /// macOS のメニュー名
  ///
  /// In ja, this message translates to:
  /// **'ウィンドウ'**
  String get menuWindow;

  /// No description provided for @sidebarTitle.
  ///
  /// In ja, this message translates to:
  /// **'単語帳'**
  String get sidebarTitle;

  /// No description provided for @sidebarSavedLocally.
  ///
  /// In ja, this message translates to:
  /// **'ローカル DB に保存済み'**
  String get sidebarSavedLocally;

  /// No description provided for @posNoun.
  ///
  /// In ja, this message translates to:
  /// **'名詞'**
  String get posNoun;

  /// No description provided for @posVerb.
  ///
  /// In ja, this message translates to:
  /// **'動詞'**
  String get posVerb;

  /// No description provided for @posAdjective.
  ///
  /// In ja, this message translates to:
  /// **'形容詞'**
  String get posAdjective;

  /// No description provided for @posAdverb.
  ///
  /// In ja, this message translates to:
  /// **'副詞'**
  String get posAdverb;

  /// No description provided for @posOther.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get posOther;

  /// 複数品詞を 1 つのバッジに並べるときの区切り
  ///
  /// In ja, this message translates to:
  /// **'・'**
  String get posSeparator;

  /// No description provided for @fieldWord.
  ///
  /// In ja, this message translates to:
  /// **'英単語 *'**
  String get fieldWord;

  /// No description provided for @fieldIpa.
  ///
  /// In ja, this message translates to:
  /// **'発音記号 (IPA)'**
  String get fieldIpa;

  /// language は translationLanguageShortName
  ///
  /// In ja, this message translates to:
  /// **'{language}訳 *'**
  String fieldMeaning(String language);

  /// No description provided for @fieldPartsOfSpeech.
  ///
  /// In ja, this message translates to:
  /// **'品詞(複数選択可)'**
  String get fieldPartsOfSpeech;

  /// No description provided for @fieldExampleEn.
  ///
  /// In ja, this message translates to:
  /// **'英例文'**
  String get fieldExampleEn;

  /// language は translationLanguageShortName
  ///
  /// In ja, this message translates to:
  /// **'{language}例文'**
  String fieldExampleTranslation(String language);

  /// No description provided for @manualInputHint.
  ///
  /// In ja, this message translates to:
  /// **'手動で入力してください'**
  String get manualInputHint;

  /// No description provided for @registrationIntro.
  ///
  /// In ja, this message translates to:
  /// **'英単語を入力すると、発音記号・{language}訳・例文などを辞書から自動取得します。'**
  String registrationIntro(String language);

  /// No description provided for @autoFill.
  ///
  /// In ja, this message translates to:
  /// **'自動入力'**
  String get autoFill;

  /// No description provided for @skipToManual.
  ///
  /// In ja, this message translates to:
  /// **'スキップして手動で入力する'**
  String get skipToManual;

  /// No description provided for @fetchingDictionary.
  ///
  /// In ja, this message translates to:
  /// **'辞書データを取得中...'**
  String get fetchingDictionary;

  /// No description provided for @exampleTranslationFailed.
  ///
  /// In ja, this message translates to:
  /// **'例文の{language}訳を取得できませんでした。手動で入力できます。'**
  String exampleTranslationFailed(String language);

  /// No description provided for @exampleTranslationFailedShort.
  ///
  /// In ja, this message translates to:
  /// **'例文の翻訳に失敗しました(手動で入力できます)'**
  String get exampleTranslationFailedShort;

  /// No description provided for @registerButton.
  ///
  /// In ja, this message translates to:
  /// **'登録する'**
  String get registerButton;

  /// No description provided for @registerShort.
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get registerShort;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @noticeNotFound.
  ///
  /// In ja, this message translates to:
  /// **'辞書に見つかりませんでした。手動で入力できます。'**
  String get noticeNotFound;

  /// No description provided for @noticeMeaningNotFound.
  ///
  /// In ja, this message translates to:
  /// **'{language}訳は辞書に見つかりませんでした(手動で入力してください)'**
  String noticeMeaningNotFound(String language);

  /// No description provided for @noticeOnlyMeaningFound.
  ///
  /// In ja, this message translates to:
  /// **'発音記号・例文は辞書に見つかりませんでした(訳のみ自動入力)'**
  String get noticeOnlyMeaningFound;

  /// No description provided for @errorDuplicate.
  ///
  /// In ja, this message translates to:
  /// **'「{word}」は既に登録されています。'**
  String errorDuplicate(String word);

  /// No description provided for @errorEmptyWord.
  ///
  /// In ja, this message translates to:
  /// **'英単語を入力してください。'**
  String get errorEmptyWord;

  /// No description provided for @errorFetchFailed.
  ///
  /// In ja, this message translates to:
  /// **'辞書データの取得に失敗しました。通信環境を確認してください。'**
  String get errorFetchFailed;

  /// No description provided for @errorRequiredFields.
  ///
  /// In ja, this message translates to:
  /// **'英単語と{language}訳は必須です。'**
  String errorRequiredFields(String language);

  /// No description provided for @editWordTitle.
  ///
  /// In ja, this message translates to:
  /// **'単語を編集'**
  String get editWordTitle;

  /// No description provided for @deleteThisWord.
  ///
  /// In ja, this message translates to:
  /// **'この単語を削除'**
  String get deleteThisWord;

  /// No description provided for @editEllipsis.
  ///
  /// In ja, this message translates to:
  /// **'編集...'**
  String get editEllipsis;

  /// No description provided for @deleteEllipsis.
  ///
  /// In ja, this message translates to:
  /// **'削除...'**
  String get deleteEllipsis;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'「{word}」を削除しますか?'**
  String deleteConfirmTitle(String word);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In ja, this message translates to:
  /// **'この操作は取り消せません。'**
  String get deleteConfirmBody;

  /// No description provided for @deleteConfirmCancel.
  ///
  /// In ja, this message translates to:
  /// **'やめる'**
  String get deleteConfirmCancel;

  /// No description provided for @deleteConfirmOk.
  ///
  /// In ja, this message translates to:
  /// **'削除する'**
  String get deleteConfirmOk;

  /// No description provided for @noExample.
  ///
  /// In ja, this message translates to:
  /// **'例文なし'**
  String get noExample;

  /// No description provided for @markLearned.
  ///
  /// In ja, this message translates to:
  /// **'学習済みにする'**
  String get markLearned;

  /// No description provided for @showMeaningWithLanguage.
  ///
  /// In ja, this message translates to:
  /// **'{language}訳を表示'**
  String showMeaningWithLanguage(String language);

  /// No description provided for @showMeaning.
  ///
  /// In ja, this message translates to:
  /// **'訳を表示'**
  String get showMeaning;

  /// No description provided for @correctCount.
  ///
  /// In ja, this message translates to:
  /// **'覚えた {count}回'**
  String correctCount(int count);

  /// 学習中カードのチェックの横の文言
  ///
  /// In ja, this message translates to:
  /// **'覚えた'**
  String get rememberedCheck;

  /// No description provided for @learningHint.
  ///
  /// In ja, this message translates to:
  /// **'チェックを入れると学習済みになり、このリストから消えます。カードをクリックすると編集できます(右クリックでメニュー)。'**
  String get learningHint;

  /// No description provided for @noWordsYet.
  ///
  /// In ja, this message translates to:
  /// **'単語がまだありません。'**
  String get noWordsYet;

  /// No description provided for @learningEmpty.
  ///
  /// In ja, this message translates to:
  /// **'学習中の単語はありません。\n単語を登録しましょう。'**
  String get learningEmpty;

  /// No description provided for @sortOrderLabel.
  ///
  /// In ja, this message translates to:
  /// **'並び順: {order}'**
  String sortOrderLabel(String order);

  /// No description provided for @sortSheetTitle.
  ///
  /// In ja, this message translates to:
  /// **'並び替え'**
  String get sortSheetTitle;

  /// No description provided for @sortNewest.
  ///
  /// In ja, this message translates to:
  /// **'登録日が新しい順'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ja, this message translates to:
  /// **'登録日が古い順'**
  String get sortOldest;

  /// No description provided for @sortLearningFirst.
  ///
  /// In ja, this message translates to:
  /// **'学習中 → 学習済み'**
  String get sortLearningFirst;

  /// No description provided for @sortLearnedFirst.
  ///
  /// In ja, this message translates to:
  /// **'学習済み → 学習中'**
  String get sortLearnedFirst;

  /// No description provided for @sortMostCorrect.
  ///
  /// In ja, this message translates to:
  /// **'覚えた回数が多い順'**
  String get sortMostCorrect;

  /// No description provided for @sortLeastCorrect.
  ///
  /// In ja, this message translates to:
  /// **'覚えた回数が少ない順'**
  String get sortLeastCorrect;

  /// No description provided for @tableLearned.
  ///
  /// In ja, this message translates to:
  /// **'学習済み'**
  String get tableLearned;

  /// No description provided for @tableWord.
  ///
  /// In ja, this message translates to:
  /// **'単語'**
  String get tableWord;

  /// No description provided for @tableIpa.
  ///
  /// In ja, this message translates to:
  /// **'発音記号'**
  String get tableIpa;

  /// No description provided for @tablePartOfSpeech.
  ///
  /// In ja, this message translates to:
  /// **'品詞'**
  String get tablePartOfSpeech;

  /// No description provided for @tableMeaning.
  ///
  /// In ja, this message translates to:
  /// **'{language}訳'**
  String tableMeaning(String language);

  /// No description provided for @tableExample.
  ///
  /// In ja, this message translates to:
  /// **'例文'**
  String get tableExample;

  /// No description provided for @tablePronunciation.
  ///
  /// In ja, this message translates to:
  /// **'発音'**
  String get tablePronunciation;

  /// No description provided for @showAnswer.
  ///
  /// In ja, this message translates to:
  /// **'答えを表示'**
  String get showAnswer;

  /// No description provided for @quizForgot.
  ///
  /// In ja, this message translates to:
  /// **'忘れていた'**
  String get quizForgot;

  /// No description provided for @quizRemembered.
  ///
  /// In ja, this message translates to:
  /// **'覚えている'**
  String get quizRemembered;

  /// No description provided for @quizForgotHint.
  ///
  /// In ja, this message translates to:
  /// **'「忘れていた」を選ぶと学習中リストに戻ります'**
  String get quizForgotHint;

  /// No description provided for @quizEmpty.
  ///
  /// In ja, this message translates to:
  /// **'復習対象の単語がまだありません。\n単語を学習済みにするとここに表示されます。'**
  String get quizEmpty;

  /// No description provided for @toLearningList.
  ///
  /// In ja, this message translates to:
  /// **'学習中リストへ'**
  String get toLearningList;

  /// No description provided for @quizDone.
  ///
  /// In ja, this message translates to:
  /// **'復習完了'**
  String get quizDone;

  /// No description provided for @quizSummary.
  ///
  /// In ja, this message translates to:
  /// **'覚えている {ok}語 / 忘れていた {forgot}語'**
  String quizSummary(int ok, int forgot);

  /// No description provided for @quizContinue.
  ///
  /// In ja, this message translates to:
  /// **'続ける'**
  String get quizContinue;

  /// No description provided for @quizForgotWordsHeader.
  ///
  /// In ja, this message translates to:
  /// **'忘れていた単語(学習中リストに戻りました)'**
  String get quizForgotWordsHeader;

  /// language は translationLanguageShortName
  ///
  /// In ja, this message translates to:
  /// **'英語 → {language}'**
  String quizDirectionFromEnglish(String language);

  /// language は translationLanguageShortName
  ///
  /// In ja, this message translates to:
  /// **'{language} → 英語'**
  String quizDirectionToEnglish(String language);

  /// No description provided for @sectionDisplay.
  ///
  /// In ja, this message translates to:
  /// **'表示'**
  String get sectionDisplay;

  /// No description provided for @theme.
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get theme;

  /// No description provided for @appearanceLight.
  ///
  /// In ja, this message translates to:
  /// **'ライト'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get appearanceDark;

  /// No description provided for @cardLayout.
  ///
  /// In ja, this message translates to:
  /// **'学習中カードの並び'**
  String get cardLayout;

  /// No description provided for @layoutTwoColumns.
  ///
  /// In ja, this message translates to:
  /// **'2列(コンパクト)'**
  String get layoutTwoColumns;

  /// No description provided for @layoutOneColumn.
  ///
  /// In ja, this message translates to:
  /// **'1列(横幅いっぱい)'**
  String get layoutOneColumn;

  /// No description provided for @showIpa.
  ///
  /// In ja, this message translates to:
  /// **'発音記号(IPA)を表示'**
  String get showIpa;

  /// No description provided for @sectionQuiz.
  ///
  /// In ja, this message translates to:
  /// **'クイズ'**
  String get sectionQuiz;

  /// No description provided for @sectionTranslation.
  ///
  /// In ja, this message translates to:
  /// **'訳の言語'**
  String get sectionTranslation;

  /// No description provided for @translationLanguageCaption.
  ///
  /// In ja, this message translates to:
  /// **'新しく登録する単語の訳を、この言語で取得します。登録済みの単語の訳は変わりません。'**
  String get translationLanguageCaption;

  /// No description provided for @sectionData.
  ///
  /// In ja, this message translates to:
  /// **'データ'**
  String get sectionData;

  /// No description provided for @sectionSupport.
  ///
  /// In ja, this message translates to:
  /// **'サポート'**
  String get sectionSupport;

  /// No description provided for @writeReview.
  ///
  /// In ja, this message translates to:
  /// **'App Store でレビューを書く'**
  String get writeReview;

  /// 日本語の画面でだけ出す
  ///
  /// In ja, this message translates to:
  /// **'作者の他のアプリ'**
  String get sectionAuthorApps;

  /// No description provided for @getApp.
  ///
  /// In ja, this message translates to:
  /// **'入手'**
  String get getApp;

  /// No description provided for @sectionInfo.
  ///
  /// In ja, this message translates to:
  /// **'情報'**
  String get sectionInfo;

  /// No description provided for @version.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get version;

  /// No description provided for @licenses.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get licenses;

  /// ライセンス種別を判別できなかったときの要約
  ///
  /// In ja, this message translates to:
  /// **'{count, plural, =1{ライセンス} other{{count} 件のライセンス}}'**
  String licenseCount(int count);

  /// No description provided for @licenseLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス情報を読み込めませんでした。'**
  String get licenseLoadFailed;

  /// No description provided for @licenseAutoGenerated.
  ///
  /// In ja, this message translates to:
  /// **'この一覧はビルド時に自動生成されます。'**
  String get licenseAutoGenerated;

  /// No description provided for @uiScale.
  ///
  /// In ja, this message translates to:
  /// **'表示サイズ'**
  String get uiScale;

  /// No description provided for @exportDone.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートしました'**
  String get exportDone;

  /// No description provided for @exportData.
  ///
  /// In ja, this message translates to:
  /// **'データを書き出す'**
  String get exportData;

  /// No description provided for @exportDataEllipsis.
  ///
  /// In ja, this message translates to:
  /// **'データを書き出す...'**
  String get exportDataEllipsis;

  /// No description provided for @importData.
  ///
  /// In ja, this message translates to:
  /// **'データを読み込む'**
  String get importData;

  /// No description provided for @importDataEllipsis.
  ///
  /// In ja, this message translates to:
  /// **'データを読み込む...'**
  String get importDataEllipsis;

  /// No description provided for @importDoneTitle.
  ///
  /// In ja, this message translates to:
  /// **'インポートが完了しました'**
  String get importDoneTitle;

  /// No description provided for @importAdded.
  ///
  /// In ja, this message translates to:
  /// **'追加 {count} 件'**
  String importAdded(int count);

  /// No description provided for @importUpdated.
  ///
  /// In ja, this message translates to:
  /// **'更新 {count} 件'**
  String importUpdated(int count);

  /// No description provided for @importUnchanged.
  ///
  /// In ja, this message translates to:
  /// **'変更なし {count} 件'**
  String importUnchanged(int count);

  /// No description provided for @importSkipped.
  ///
  /// In ja, this message translates to:
  /// **'スキップ {count} 件'**
  String importSkipped(int count);

  /// No description provided for @importFailedTitle.
  ///
  /// In ja, this message translates to:
  /// **'インポートできませんでした'**
  String get importFailedTitle;

  /// No description provided for @importErrorInvalidJson.
  ///
  /// In ja, this message translates to:
  /// **'JSON として読み込めませんでした。'**
  String get importErrorInvalidJson;

  /// No description provided for @importErrorInvalidFormat.
  ///
  /// In ja, this message translates to:
  /// **'JSON の形式が不正です。'**
  String get importErrorInvalidFormat;

  /// No description provided for @importErrorUnsupportedVersion.
  ///
  /// In ja, this message translates to:
  /// **'対応していないバージョンのファイルです。'**
  String get importErrorUnsupportedVersion;

  /// No description provided for @deeplKeyHint.
  ///
  /// In ja, this message translates to:
  /// **'DeepL API キーを入力'**
  String get deeplKeyHint;

  /// No description provided for @deeplDescription.
  ///
  /// In ja, this message translates to:
  /// **'DeepL API Free のキーを設定すると、自動入力時に英例文の{language}訳を取得します。未設定の場合、例文の訳はスキップされます。'**
  String deeplDescription(String language);

  /// No description provided for @icloudSync.
  ///
  /// In ja, this message translates to:
  /// **'iCloud 同期'**
  String get icloudSync;

  /// No description provided for @syncNow.
  ///
  /// In ja, this message translates to:
  /// **'今すぐ同期'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In ja, this message translates to:
  /// **'同期中...'**
  String get syncing;

  /// No description provided for @neverSynced.
  ///
  /// In ja, this message translates to:
  /// **'まだ同期していません'**
  String get neverSynced;

  /// No description provided for @lastSynced.
  ///
  /// In ja, this message translates to:
  /// **'最終同期: {time}'**
  String lastSynced(String time);

  /// No description provided for @syncErrorNoICloud.
  ///
  /// In ja, this message translates to:
  /// **'iCloud が利用できません。設定で iCloud Drive にサインインしてください。'**
  String get syncErrorNoICloud;

  /// No description provided for @syncErrorNotCurrent.
  ///
  /// In ja, this message translates to:
  /// **'iCloud から最新のデータを取得できなかったため、同期を見送りました。'**
  String get syncErrorNotCurrent;

  /// No description provided for @syncErrorUnsupported.
  ///
  /// In ja, this message translates to:
  /// **'このプラットフォームでは iCloud 同期を利用できません。'**
  String get syncErrorUnsupported;

  /// No description provided for @syncErrorFailed.
  ///
  /// In ja, this message translates to:
  /// **'同期に失敗しました: {detail}'**
  String syncErrorFailed(String detail);

  /// No description provided for @removeAds.
  ///
  /// In ja, this message translates to:
  /// **'広告を非表示にする'**
  String get removeAds;

  /// No description provided for @proPurchasedCaption.
  ///
  /// In ja, this message translates to:
  /// **'Pro を購入済みです'**
  String get proPurchasedCaption;

  /// No description provided for @priceUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'価格を取得できませんでした'**
  String get priceUnavailable;

  /// No description provided for @oneTimePrice.
  ///
  /// In ja, this message translates to:
  /// **'買い切り {price}'**
  String oneTimePrice(String price);

  /// No description provided for @purchased.
  ///
  /// In ja, this message translates to:
  /// **'購入済み'**
  String get purchased;

  /// No description provided for @purchase.
  ///
  /// In ja, this message translates to:
  /// **'購入'**
  String get purchase;

  /// No description provided for @restorePurchases.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get restorePurchases;

  /// No description provided for @purchaseFailed.
  ///
  /// In ja, this message translates to:
  /// **'購入できませんでした'**
  String get purchaseFailed;

  /// No description provided for @restoreChecking.
  ///
  /// In ja, this message translates to:
  /// **'確認中…'**
  String get restoreChecking;

  /// No description provided for @restoreDone.
  ///
  /// In ja, this message translates to:
  /// **'復元しました'**
  String get restoreDone;

  /// No description provided for @restoreNotFound.
  ///
  /// In ja, this message translates to:
  /// **'購入履歴が見つかりません'**
  String get restoreNotFound;

  /// No description provided for @restoreFailed.
  ///
  /// In ja, this message translates to:
  /// **'復元できませんでした'**
  String get restoreFailed;

  /// No description provided for @listenPronunciation.
  ///
  /// In ja, this message translates to:
  /// **'発音を聞く'**
  String get listenPronunciation;

  /// No description provided for @pronunciationShort.
  ///
  /// In ja, this message translates to:
  /// **'発音'**
  String get pronunciationShort;

  /// No description provided for @pronunciationTooltip.
  ///
  /// In ja, this message translates to:
  /// **'Google 翻訳で発音を確認'**
  String get pronunciationTooltip;

  /// No description provided for @pageLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'ページを読み込めませんでした。\n通信状況を確認してから、もう一度お試しください。'**
  String get pageLoadFailed;

  /// No description provided for @reload.
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get reload;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
