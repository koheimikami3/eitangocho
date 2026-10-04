// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日文',
      'zhHant': '繁體中文',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日文',
      'zhHant': '中文',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => '學習中';

  @override
  String get navLearningWords => '學習中的單字';

  @override
  String get navAllWords => '全部單字';

  @override
  String get navQuiz => '單字測驗';

  @override
  String get navQuizShort => '測驗';

  @override
  String get navRegistration => '新增單字';

  @override
  String get navSettings => '設定';

  @override
  String wordCount(int count) {
    return '$count 個單字';
  }

  @override
  String showingWordCount(int count) {
    return '顯示 $count 個單字';
  }

  @override
  String get addShort => '＋ 新增';

  @override
  String get addWord => '＋ 新增單字';

  @override
  String get search => '搜尋';

  @override
  String get menuWords => '單字';

  @override
  String get menuEdit => '編輯';

  @override
  String get menuWindow => '視窗';

  @override
  String get sidebarTitle => '單字本';

  @override
  String get sidebarSavedLocally => '已儲存在這台 Mac';

  @override
  String get posNoun => '名詞';

  @override
  String get posVerb => '動詞';

  @override
  String get posAdjective => '形容詞';

  @override
  String get posAdverb => '副詞';

  @override
  String get posOther => '其他';

  @override
  String get posSeparator => '、';

  @override
  String get fieldWord => '英文單字 *';

  @override
  String get fieldIpa => '音標 (IPA)';

  @override
  String fieldMeaning(String language) {
    return '$language翻譯 *';
  }

  @override
  String get fieldPartsOfSpeech => '詞性(可複選)';

  @override
  String get fieldExampleEn => '英文例句';

  @override
  String fieldExampleTranslation(String language) {
    return '$language例句';
  }

  @override
  String get manualInputHint => '請手動輸入';

  @override
  String registrationIntro(String language) {
    return '輸入英文單字，就會從字典自動取得音標、$language翻譯、例句等資訊。';
  }

  @override
  String get autoFill => '自動填入';

  @override
  String get skipToManual => '略過，改為手動輸入';

  @override
  String get fetchingDictionary => '正在查詢字典...';

  @override
  String exampleTranslationFailed(String language) {
    return '無法取得例句的$language翻譯，可以手動輸入。';
  }

  @override
  String get exampleTranslationFailedShort => '例句翻譯失敗（可以手動輸入）';

  @override
  String get registerButton => '新增';

  @override
  String get registerShort => '新增';

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get close => '關閉';

  @override
  String get save => '儲存';

  @override
  String get noticeNotFound => '字典裡找不到這個單字，可以手動輸入。';

  @override
  String noticeMeaningNotFound(String language) {
    return '字典裡找不到$language翻譯（請手動輸入）';
  }

  @override
  String get noticeOnlyMeaningFound => '字典裡找不到音標和例句（只自動填入翻譯）';

  @override
  String errorDuplicate(String word) {
    return '「$word」已經新增過了。';
  }

  @override
  String get errorEmptyWord => '請輸入英文單字。';

  @override
  String get errorFetchFailed => '無法取得字典資料，請確認網路連線。';

  @override
  String errorRequiredFields(String language) {
    return '英文單字和$language翻譯為必填。';
  }

  @override
  String get editWordTitle => '編輯單字';

  @override
  String get deleteThisWord => '刪除這個單字';

  @override
  String get editEllipsis => '編輯...';

  @override
  String get deleteEllipsis => '刪除...';

  @override
  String deleteConfirmTitle(String word) {
    return '要刪除「$word」嗎？';
  }

  @override
  String get deleteConfirmBody => '這個動作無法復原。';

  @override
  String get deleteConfirmCancel => '取消';

  @override
  String get deleteConfirmOk => '刪除';

  @override
  String get noExample => '沒有例句';

  @override
  String get markLearned => '標記為已學會';

  @override
  String showMeaningWithLanguage(String language) {
    return '顯示$language翻譯';
  }

  @override
  String get showMeaning => '顯示翻譯';

  @override
  String correctCount(int count) {
    return '記住 $count 次';
  }

  @override
  String get rememberedCheck => '學會了';

  @override
  String get learningHint => '勾選後會標記為已學會，並從這個清單移除。點一下卡片即可編輯（按右鍵開啟選單）。';

  @override
  String get noWordsYet => '還沒有單字。';

  @override
  String get learningEmpty => '目前沒有學習中的單字。\n來新增單字吧。';

  @override
  String sortOrderLabel(String order) {
    return '排序：$order';
  }

  @override
  String get sortSheetTitle => '排序';

  @override
  String get sortNewest => '新增日期（新到舊）';

  @override
  String get sortOldest => '新增日期（舊到新）';

  @override
  String get sortLearningFirst => '學習中 → 已學會';

  @override
  String get sortLearnedFirst => '已學會 → 學習中';

  @override
  String get sortMostCorrect => '記住次數（多到少）';

  @override
  String get sortLeastCorrect => '記住次數（少到多）';

  @override
  String get tableLearned => '已學會';

  @override
  String get tableWord => '單字';

  @override
  String get tableIpa => '音標';

  @override
  String get tablePartOfSpeech => '詞性';

  @override
  String tableMeaning(String language) {
    return '$language翻譯';
  }

  @override
  String get tableExample => '例句';

  @override
  String get tablePronunciation => '發音';

  @override
  String get showAnswer => '顯示答案';

  @override
  String get quizForgot => '忘記了';

  @override
  String get quizRemembered => '記得';

  @override
  String get quizForgotHint => '選擇「忘記了」會把單字移回學習中清單';

  @override
  String get quizEmpty => '還沒有要複習的單字。\n把單字標記為已學會後，就會出現在這裡。';

  @override
  String get toLearningList => '前往學習中清單';

  @override
  String get quizDone => '複習完成';

  @override
  String quizSummary(int ok, int forgot) {
    return '記得 $ok 個 / 忘記了 $forgot 個';
  }

  @override
  String get quizContinue => '繼續';

  @override
  String get quizForgotWordsHeader => '忘記的單字（已移回學習中清單）';

  @override
  String quizDirectionFromEnglish(String language) {
    return '英文 → $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return '$language → 英文';
  }

  @override
  String get sectionDisplay => '顯示';

  @override
  String get theme => '主題';

  @override
  String get appearanceLight => '淺色';

  @override
  String get appearanceDark => '深色';

  @override
  String get cardLayout => '學習中卡片的排列';

  @override
  String get layoutTwoColumns => '2 欄（精簡）';

  @override
  String get layoutOneColumn => '1 欄（滿版）';

  @override
  String get showIpa => '顯示音標（IPA）';

  @override
  String get sectionQuiz => '測驗';

  @override
  String get sectionTranslation => '翻譯語言';

  @override
  String get translationLanguageCaption => '新增單字時會以這個語言取得翻譯。\n已新增的單字翻譯不會改變。';

  @override
  String get sectionData => '資料';

  @override
  String get sectionSupport => '支援';

  @override
  String get writeReview => '在 App Store 撰寫評論';

  @override
  String get sectionAuthorApps => '開發者的其他 App';

  @override
  String get getApp => '取得';

  @override
  String get sectionInfo => '關於';

  @override
  String get version => '版本';

  @override
  String get licenses => '授權';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項授權',
      one: '授權',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed => '無法載入授權資訊。';

  @override
  String get licenseAutoGenerated => '這份清單會在建置時自動產生。';

  @override
  String get uiScale => '顯示大小';

  @override
  String get exportDone => '已匯出';

  @override
  String get exportData => '匯出資料';

  @override
  String get exportDataEllipsis => '匯出資料...';

  @override
  String get importData => '匯入資料';

  @override
  String get importDataEllipsis => '匯入資料...';

  @override
  String get importDoneTitle => '匯入完成';

  @override
  String importAdded(int count) {
    return '新增 $count 筆';
  }

  @override
  String importUpdated(int count) {
    return '更新 $count 筆';
  }

  @override
  String importUnchanged(int count) {
    return '未變更 $count 筆';
  }

  @override
  String importSkipped(int count) {
    return '略過 $count 筆';
  }

  @override
  String get importFailedTitle => '無法匯入';

  @override
  String get importErrorInvalidJson => '無法以 JSON 格式讀取這個檔案。';

  @override
  String get importErrorInvalidFormat => 'JSON 格式不正確。';

  @override
  String get importErrorUnsupportedVersion => '不支援這個版本的檔案。';

  @override
  String get deeplKeyHint => '輸入 DeepL API 金鑰';

  @override
  String deeplDescription(String language) {
    return '設定 DeepL API Free 的金鑰後，自動填入時會取得英文例句的$language翻譯。未設定時會略過例句翻譯。';
  }

  @override
  String get icloudSync => 'iCloud 同步';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncing => '同步中...';

  @override
  String get neverSynced => '尚未同步';

  @override
  String lastSynced(String time) {
    return '上次同步：$time';
  }

  @override
  String get syncErrorNoICloud => '無法使用 iCloud。請在「設定」中登入 iCloud 雲碟。';

  @override
  String get syncErrorNotCurrent => '無法從 iCloud 取得最新資料，因此暫不同步。';

  @override
  String get syncErrorUnsupported => '這個平台無法使用 iCloud 同步。';

  @override
  String syncErrorFailed(String detail) {
    return '同步失敗：$detail';
  }

  @override
  String get removeAds => '移除廣告';

  @override
  String get proPurchasedCaption => '已購買 Pro';

  @override
  String get priceUnavailable => '無法取得價格';

  @override
  String oneTimePrice(String price) {
    return '一次買斷 $price';
  }

  @override
  String get purchased => '已購買';

  @override
  String get purchase => '購買';

  @override
  String get restorePurchases => '回復購買項目';

  @override
  String get purchaseFailed => '無法完成購買';

  @override
  String get restoreChecking => '確認中…';

  @override
  String get restoreDone => '已回復';

  @override
  String get restoreNotFound => '找不到購買紀錄';

  @override
  String get restoreFailed => '無法回復';

  @override
  String get listenPronunciation => '聽發音';

  @override
  String get pronunciationShort => '發音';

  @override
  String get pronunciationTooltip => '在 Google 翻譯確認發音';

  @override
  String get pageLoadFailed => '無法載入頁面。\n請確認網路連線後再試一次。';

  @override
  String get reload => '重新載入';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String translationLanguageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日文',
      'zhHant': '繁體中文',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String translationLanguageShortName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ja': '日文',
      'zhHant': '中文',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get navLearning => '學習中';

  @override
  String get navLearningWords => '學習中的單字';

  @override
  String get navAllWords => '全部單字';

  @override
  String get navQuiz => '單字測驗';

  @override
  String get navQuizShort => '測驗';

  @override
  String get navRegistration => '新增單字';

  @override
  String get navSettings => '設定';

  @override
  String wordCount(int count) {
    return '$count 個單字';
  }

  @override
  String showingWordCount(int count) {
    return '顯示 $count 個單字';
  }

  @override
  String get addShort => '＋ 新增';

  @override
  String get addWord => '＋ 新增單字';

  @override
  String get search => '搜尋';

  @override
  String get menuWords => '單字';

  @override
  String get menuEdit => '編輯';

  @override
  String get menuWindow => '視窗';

  @override
  String get sidebarTitle => '單字本';

  @override
  String get sidebarSavedLocally => '已儲存在這台 Mac';

  @override
  String get posNoun => '名詞';

  @override
  String get posVerb => '動詞';

  @override
  String get posAdjective => '形容詞';

  @override
  String get posAdverb => '副詞';

  @override
  String get posOther => '其他';

  @override
  String get posSeparator => '、';

  @override
  String get fieldWord => '英文單字 *';

  @override
  String get fieldIpa => '音標 (IPA)';

  @override
  String fieldMeaning(String language) {
    return '$language翻譯 *';
  }

  @override
  String get fieldPartsOfSpeech => '詞性(可複選)';

  @override
  String get fieldExampleEn => '英文例句';

  @override
  String fieldExampleTranslation(String language) {
    return '$language例句';
  }

  @override
  String get manualInputHint => '請手動輸入';

  @override
  String registrationIntro(String language) {
    return '輸入英文單字，就會從字典自動取得音標、$language翻譯、例句等資訊。';
  }

  @override
  String get autoFill => '自動填入';

  @override
  String get skipToManual => '略過，改為手動輸入';

  @override
  String get fetchingDictionary => '正在查詢字典...';

  @override
  String exampleTranslationFailed(String language) {
    return '無法取得例句的$language翻譯，可以手動輸入。';
  }

  @override
  String get exampleTranslationFailedShort => '例句翻譯失敗（可以手動輸入）';

  @override
  String get registerButton => '新增';

  @override
  String get registerShort => '新增';

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get close => '關閉';

  @override
  String get save => '儲存';

  @override
  String get noticeNotFound => '字典裡找不到這個單字，可以手動輸入。';

  @override
  String noticeMeaningNotFound(String language) {
    return '字典裡找不到$language翻譯（請手動輸入）';
  }

  @override
  String get noticeOnlyMeaningFound => '字典裡找不到音標和例句（只自動填入翻譯）';

  @override
  String errorDuplicate(String word) {
    return '「$word」已經新增過了。';
  }

  @override
  String get errorEmptyWord => '請輸入英文單字。';

  @override
  String get errorFetchFailed => '無法取得字典資料，請確認網路連線。';

  @override
  String errorRequiredFields(String language) {
    return '英文單字和$language翻譯為必填。';
  }

  @override
  String get editWordTitle => '編輯單字';

  @override
  String get deleteThisWord => '刪除這個單字';

  @override
  String get editEllipsis => '編輯...';

  @override
  String get deleteEllipsis => '刪除...';

  @override
  String deleteConfirmTitle(String word) {
    return '要刪除「$word」嗎？';
  }

  @override
  String get deleteConfirmBody => '這個動作無法復原。';

  @override
  String get deleteConfirmCancel => '取消';

  @override
  String get deleteConfirmOk => '刪除';

  @override
  String get noExample => '沒有例句';

  @override
  String get markLearned => '標記為已學會';

  @override
  String showMeaningWithLanguage(String language) {
    return '顯示$language翻譯';
  }

  @override
  String get showMeaning => '顯示翻譯';

  @override
  String correctCount(int count) {
    return '記住 $count 次';
  }

  @override
  String get rememberedCheck => '學會了';

  @override
  String get learningHint => '勾選後會標記為已學會，並從這個清單移除。點一下卡片即可編輯（按右鍵開啟選單）。';

  @override
  String get noWordsYet => '還沒有單字。';

  @override
  String get learningEmpty => '目前沒有學習中的單字。\n來新增單字吧。';

  @override
  String sortOrderLabel(String order) {
    return '排序：$order';
  }

  @override
  String get sortSheetTitle => '排序';

  @override
  String get sortNewest => '新增日期（新到舊）';

  @override
  String get sortOldest => '新增日期（舊到新）';

  @override
  String get sortLearningFirst => '學習中 → 已學會';

  @override
  String get sortLearnedFirst => '已學會 → 學習中';

  @override
  String get sortMostCorrect => '記住次數（多到少）';

  @override
  String get sortLeastCorrect => '記住次數（少到多）';

  @override
  String get tableLearned => '已學會';

  @override
  String get tableWord => '單字';

  @override
  String get tableIpa => '音標';

  @override
  String get tablePartOfSpeech => '詞性';

  @override
  String tableMeaning(String language) {
    return '$language翻譯';
  }

  @override
  String get tableExample => '例句';

  @override
  String get tablePronunciation => '發音';

  @override
  String get showAnswer => '顯示答案';

  @override
  String get quizForgot => '忘記了';

  @override
  String get quizRemembered => '記得';

  @override
  String get quizForgotHint => '選擇「忘記了」會把單字移回學習中清單';

  @override
  String get quizEmpty => '還沒有要複習的單字。\n把單字標記為已學會後，就會出現在這裡。';

  @override
  String get toLearningList => '前往學習中清單';

  @override
  String get quizDone => '複習完成';

  @override
  String quizSummary(int ok, int forgot) {
    return '記得 $ok 個 / 忘記了 $forgot 個';
  }

  @override
  String get quizContinue => '繼續';

  @override
  String get quizForgotWordsHeader => '忘記的單字（已移回學習中清單）';

  @override
  String quizDirectionFromEnglish(String language) {
    return '英文 → $language';
  }

  @override
  String quizDirectionToEnglish(String language) {
    return '$language → 英文';
  }

  @override
  String get sectionDisplay => '顯示';

  @override
  String get theme => '主題';

  @override
  String get appearanceLight => '淺色';

  @override
  String get appearanceDark => '深色';

  @override
  String get cardLayout => '學習中卡片的排列';

  @override
  String get layoutTwoColumns => '2 欄（精簡）';

  @override
  String get layoutOneColumn => '1 欄（滿版）';

  @override
  String get showIpa => '顯示音標（IPA）';

  @override
  String get sectionQuiz => '測驗';

  @override
  String get sectionTranslation => '翻譯語言';

  @override
  String get translationLanguageCaption => '新增單字時會以這個語言取得翻譯。\n已新增的單字翻譯不會改變。';

  @override
  String get sectionData => '資料';

  @override
  String get sectionSupport => '支援';

  @override
  String get writeReview => '在 App Store 撰寫評論';

  @override
  String get sectionAuthorApps => '開發者的其他 App';

  @override
  String get getApp => '取得';

  @override
  String get sectionInfo => '關於';

  @override
  String get version => '版本';

  @override
  String get licenses => '授權';

  @override
  String licenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項授權',
      one: '授權',
    );
    return '$_temp0';
  }

  @override
  String get licenseLoadFailed => '無法載入授權資訊。';

  @override
  String get licenseAutoGenerated => '這份清單會在建置時自動產生。';

  @override
  String get uiScale => '顯示大小';

  @override
  String get exportDone => '已匯出';

  @override
  String get exportData => '匯出資料';

  @override
  String get exportDataEllipsis => '匯出資料...';

  @override
  String get importData => '匯入資料';

  @override
  String get importDataEllipsis => '匯入資料...';

  @override
  String get importDoneTitle => '匯入完成';

  @override
  String importAdded(int count) {
    return '新增 $count 筆';
  }

  @override
  String importUpdated(int count) {
    return '更新 $count 筆';
  }

  @override
  String importUnchanged(int count) {
    return '未變更 $count 筆';
  }

  @override
  String importSkipped(int count) {
    return '略過 $count 筆';
  }

  @override
  String get importFailedTitle => '無法匯入';

  @override
  String get importErrorInvalidJson => '無法以 JSON 格式讀取這個檔案。';

  @override
  String get importErrorInvalidFormat => 'JSON 格式不正確。';

  @override
  String get importErrorUnsupportedVersion => '不支援這個版本的檔案。';

  @override
  String get deeplKeyHint => '輸入 DeepL API 金鑰';

  @override
  String deeplDescription(String language) {
    return '設定 DeepL API Free 的金鑰後，自動填入時會取得英文例句的$language翻譯。未設定時會略過例句翻譯。';
  }

  @override
  String get icloudSync => 'iCloud 同步';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncing => '同步中...';

  @override
  String get neverSynced => '尚未同步';

  @override
  String lastSynced(String time) {
    return '上次同步：$time';
  }

  @override
  String get syncErrorNoICloud => '無法使用 iCloud。請在「設定」中登入 iCloud 雲碟。';

  @override
  String get syncErrorNotCurrent => '無法從 iCloud 取得最新資料，因此暫不同步。';

  @override
  String get syncErrorUnsupported => '這個平台無法使用 iCloud 同步。';

  @override
  String syncErrorFailed(String detail) {
    return '同步失敗：$detail';
  }

  @override
  String get removeAds => '移除廣告';

  @override
  String get proPurchasedCaption => '已購買 Pro';

  @override
  String get priceUnavailable => '無法取得價格';

  @override
  String oneTimePrice(String price) {
    return '一次買斷 $price';
  }

  @override
  String get purchased => '已購買';

  @override
  String get purchase => '購買';

  @override
  String get restorePurchases => '回復購買項目';

  @override
  String get purchaseFailed => '無法完成購買';

  @override
  String get restoreChecking => '確認中…';

  @override
  String get restoreDone => '已回復';

  @override
  String get restoreNotFound => '找不到購買紀錄';

  @override
  String get restoreFailed => '無法回復';

  @override
  String get listenPronunciation => '聽發音';

  @override
  String get pronunciationShort => '發音';

  @override
  String get pronunciationTooltip => '在 Google 翻譯確認發音';

  @override
  String get pageLoadFailed => '無法載入頁面。\n請確認網路連線後再試一次。';

  @override
  String get reload => '重新載入';
}
