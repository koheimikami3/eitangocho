// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日本語',
      'zhHant': '中国語(繁体字)',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日本語',
      'zhHant': '中国語',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => '学習中';

  @override
  String get navLearningWords => '学習中の単語';

  @override
  String get navAllWords => '全単語';

  @override
  String get navQuiz => 'フラッシュクイズ';

  @override
  String get navQuizShort => 'クイズ';

  @override
  String get navRegistration => '単語を登録';

  @override
  String get navSettings => '設定';

  @override
  String wordCount(int count) {
    return '$count語';
  }

  @override
  String showingWordCount(int count) {
    return '$count語を表示中';
  }

  @override
  String get addShort => '＋ 登録';

  @override
  String get addWord => '＋ 単語を登録';

  @override
  String get search => '検索';

  @override
  String get menuWords => '単語';

  @override
  String get menuEdit => '編集';

  @override
  String get menuWindow => 'ウィンドウ';

  @override
  String get sidebarTitle => '単語帳';

  @override
  String get sidebarSavedLocally => 'ローカル DB に保存済み';

  @override
  String get posNoun => '名詞';

  @override
  String get posVerb => '動詞';

  @override
  String get posAdjective => '形容詞';

  @override
  String get posAdverb => '副詞';

  @override
  String get posOther => 'その他';

  @override
  String get posSeparator => '・';

  @override
  String get fieldWord => '英単語 *';

  @override
  String get fieldIpa => '発音記号 (IPA)';

  @override
  String fieldMeaning(String language) {
    return '$language訳 *';
  }

  @override
  String get fieldPartsOfSpeech => '品詞(複数選択可)';

  @override
  String get fieldExampleEn => '英例文';

  @override
  String fieldExampleTranslation(String language) {
    return '$language例文';
  }

  @override
  String get manualInputHint => '手動で入力してください';

  @override
  String registrationIntro(String language) {
    return '英単語を入力すると、発音記号・$language訳・例文などを辞書から自動取得します。';
  }

  @override
  String get autoFill => '自動入力';

  @override
  String get skipToManual => 'スキップして手動で入力する';

  @override
  String get fetchingDictionary => '辞書データを取得中...';

  @override
  String exampleTranslationFailed(String language) {
    return '例文の$language訳を取得できませんでした。手動で入力できます。';
  }

  @override
  String get exampleTranslationFailedShort => '例文の翻訳に失敗しました(手動で入力できます)';

  @override
  String get registerButton => '登録する';

  @override
  String get registerShort => '登録';

  @override
  String get back => '戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get save => '保存';

  @override
  String get noticeNotFound => '辞書に見つかりませんでした。手動で入力できます。';

  @override
  String noticeMeaningNotFound(String language) {
    return '$language訳は辞書に見つかりませんでした(手動で入力してください)';
  }

  @override
  String get noticeOnlyMeaningFound => '発音記号・例文は辞書に見つかりませんでした(訳のみ自動入力)';

  @override
  String errorDuplicate(String word) {
    return '「$word」は既に登録されています。';
  }

  @override
  String get errorEmptyWord => '英単語を入力してください。';

  @override
  String get errorFetchFailed => '辞書データの取得に失敗しました。通信環境を確認してください。';

  @override
  String errorRequiredFields(String language) {
    return '英単語と$language訳は必須です。';
  }

  @override
  String get editWordTitle => '単語を編集';

  @override
  String get deleteThisWord => 'この単語を削除';

  @override
  String get editEllipsis => '編集...';

  @override
  String get deleteEllipsis => '削除...';

  @override
  String deleteConfirmTitle(String word) {
    return '「$word」を削除しますか?';
  }

  @override
  String get deleteConfirmBody => 'この操作は取り消せません。';

  @override
  String get deleteConfirmCancel => 'やめる';

  @override
  String get deleteConfirmOk => '削除する';

  @override
  String get noExample => '例文なし';

  @override
  String get markLearned => '学習済みにする';

  @override
  String showMeaningWithLanguage(String language) {
    return '$language訳を表示';
  }

  @override
  String get showMeaning => '訳を表示';

  @override
  String correctCount(int count) {
    return '覚えた $count回';
  }

  @override
  String get rememberedCheck => '覚えた';

  @override
  String get learningHint =>
      'チェックを入れると学習済みになり、このリストから消えます。カードをクリックすると編集できます(右クリックでメニュー)。';

  @override
  String get noWordsYet => '単語がまだありません。';

  @override
  String get learningEmpty => '学習中の単語はありません。\n単語を登録しましょう。';

  @override
  String sortOrderLabel(String order) {
    return '並び順: $order';
  }

  @override
  String get sortSheetTitle => '並び替え';

  @override
  String get sortNewest => '登録日が新しい順';

  @override
  String get sortOldest => '登録日が古い順';

  @override
  String get sortLearningFirst => '学習中 → 学習済み';

  @override
  String get sortLearnedFirst => '学習済み → 学習中';

  @override
  String get sortMostCorrect => '覚えた回数が多い順';

  @override
  String get sortLeastCorrect => '覚えた回数が少ない順';

  @override
  String get tableLearned => '学習済み';

  @override
  String get tableWord => '単語';

  @override
  String get tableIpa => '発音記号';

  @override
  String get tablePartOfSpeech => '品詞';

  @override
  String tableMeaning(String language) {
    return '$language訳';
  }

  @override
  String get tableExample => '例文';

  @override
  String get tablePronunciation => '発音';

  @override
  String get showAnswer => '答えを表示';

  @override
  String get quizForgot => '忘れていた';

  @override
  String get quizRemembered => '覚えている';

  @override
  String get quizForgotHint => '「忘れていた」を選ぶと学習中リストに戻ります';

  @override
  String get quizEmpty => '復習対象の単語がまだありません。\n単語を学習済みにするとここに表示されます。';

  @override
  String get toLearningList => '学習中リストへ';

  @override
  String get quizDone => '復習完了';

  @override
  String quizSummary(int ok, int forgot) {
    return '覚えている $ok語 / 忘れていた $forgot語';
  }

  @override
  String get quizContinue => '続ける';

  @override
  String get quizForgotWordsHeader => '忘れていた単語(学習中リストに戻りました)';

  @override
  String quizDirectionFromEnglish(String language) {
    return '英語 → $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return '$language → 英語';
  }

  @override
  String get sectionDisplay => '表示';

  @override
  String get theme => 'テーマ';

  @override
  String get appearanceLight => 'ライト';

  @override
  String get appearanceDark => 'ダーク';

  @override
  String get cardLayout => '学習中カードの並び';

  @override
  String get layoutTwoColumns => '2列(コンパクト)';

  @override
  String get layoutOneColumn => '1列(横幅いっぱい)';

  @override
  String get showIpa => '発音記号(IPA)を表示';

  @override
  String get sectionQuiz => 'クイズ';

  @override
  String get sectionTranslation => '訳の言語';

  @override
  String get translationLanguageCaption =>
      '新しく登録する単語の訳を、この言語で取得します。登録済みの単語の訳は変わりません。';

  @override
  String get sectionData => 'データ';

  @override
  String get sectionSupport => 'サポート';

  @override
  String get writeReview => 'App Store でレビューを書く';

  @override
  String get sectionAuthorApps => '作者の他のアプリ';

  @override
  String get getApp => '入手';

  @override
  String get sectionInfo => '情報';

  @override
  String get version => 'バージョン';

  @override
  String get licenses => 'ライセンス';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のライセンス',
      one: 'ライセンス',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed => 'ライセンス情報を読み込めませんでした。';

  @override
  String get licenseAutoGenerated => 'この一覧はビルド時に自動生成されます。';

  @override
  String get uiScale => '表示サイズ';

  @override
  String get exportDone => 'エクスポートしました';

  @override
  String get exportData => 'データを書き出す';

  @override
  String get exportDataEllipsis => 'データを書き出す...';

  @override
  String get importData => 'データを読み込む';

  @override
  String get importDataEllipsis => 'データを読み込む...';

  @override
  String get importDoneTitle => 'インポートが完了しました';

  @override
  String importAdded(int count) {
    return '追加 $count 件';
  }

  @override
  String importUpdated(int count) {
    return '更新 $count 件';
  }

  @override
  String importUnchanged(int count) {
    return '変更なし $count 件';
  }

  @override
  String importSkipped(int count) {
    return 'スキップ $count 件';
  }

  @override
  String get importFailedTitle => 'インポートできませんでした';

  @override
  String get importErrorInvalidJson => 'JSON として読み込めませんでした。';

  @override
  String get importErrorInvalidFormat => 'JSON の形式が不正です。';

  @override
  String get importErrorUnsupportedVersion => '対応していないバージョンのファイルです。';

  @override
  String get deeplKeyHint => 'DeepL API キーを入力';

  @override
  String deeplDescription(String language) {
    return 'DeepL API Free のキーを設定すると、自動入力時に英例文の$language訳を取得します。未設定の場合、例文の訳はスキップされます。';
  }

  @override
  String get icloudSync => 'iCloud 同期';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncing => '同期中...';

  @override
  String get neverSynced => 'まだ同期していません';

  @override
  String lastSynced(String time) {
    return '最終同期: $time';
  }

  @override
  String get syncErrorNoICloud =>
      'iCloud が利用できません。設定で iCloud Drive にサインインしてください。';

  @override
  String get syncErrorNotCurrent => 'iCloud から最新のデータを取得できなかったため、同期を見送りました。';

  @override
  String get syncErrorUnsupported => 'このプラットフォームでは iCloud 同期を利用できません。';

  @override
  String syncErrorFailed(String detail) {
    return '同期に失敗しました: $detail';
  }

  @override
  String get removeAds => '広告を非表示にする';

  @override
  String get proPurchasedCaption => 'Pro を購入済みです';

  @override
  String get priceUnavailable => '価格を取得できませんでした';

  @override
  String oneTimePrice(String price) {
    return '買い切り $price';
  }

  @override
  String get purchased => '購入済み';

  @override
  String get purchase => '購入';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get purchaseFailed => '購入できませんでした';

  @override
  String get restoreChecking => '確認中…';

  @override
  String get restoreDone => '復元しました';

  @override
  String get restoreNotFound => '購入履歴が見つかりません';

  @override
  String get restoreFailed => '復元できませんでした';

  @override
  String get listenPronunciation => '発音を聞く';

  @override
  String get pronunciationShort => '発音';

  @override
  String get pronunciationTooltip => 'Google 翻訳で発音を確認';

  @override
  String get pageLoadFailed => 'ページを読み込めませんでした。\n通信状況を確認してから、もう一度お試しください。';

  @override
  String get reload => '再読み込み';
}
