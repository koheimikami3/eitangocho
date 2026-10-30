import EitangochoData
import EitangochoWordInfo
import SwiftUI

/// 単語登録の画面(単語の入力 → 自動入力 → 確認フォーム)。Flutter 版の WordRegistrationView。
struct WordRegistrationView: View {
  let shell: MainShellModel
  let settings: SettingsStore

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var model: WordRegistrationModel
  @FocusState private var wordFocused: Bool

  init(
    shell: MainShellModel, settings: SettingsStore, dao: WordDao, wordInfo: any WordInfoProvider,
    analytics: AnalyticsLogger
  ) {
    self.shell = shell
    self.settings = settings
    _model = State(
      initialValue: WordRegistrationModel(dao: dao, wordInfo: wordInfo, analytics: analytics) {
        settings.translationLanguage
      })
  }

  var body: some View {
    let language = settings.translationLanguage
    ScrollView {
      Group {
        switch model.step {
        case .input:
          RegistrationInputStep(
            model: model, intro: String(localized: language.registrationIntro),
            errorMessage: errorText(language), focus: $wordFocused)
        case .loading:
          RegistrationLoadingStep()
        case .form:
          form(language)
        }
      }
      .frame(width: px(AppDimensions.formWidth), alignment: .leading)
      .padding(px(28))
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    // 続けて登録できるよう、保存したら次の単語をすぐ打てるよう英単語の欄にフォーカスを置く。
    .onChange(of: model.registeredWord) { _, registered in
      if registered != nil { wordFocused = true }
    }
  }

  private func errorText(_ language: TranslationLanguage) -> String? {
    guard let error = model.error else { return nil }
    switch error {
    case .duplicate(let word): return String(localized: .errorDuplicate(word))
    case .emptyWord: return String(localized: .errorEmptyWord)
    case .fetchFailed: return String(localized: .errorFetchFailed)
    case .requiredFields: return String(localized: .errorRequiredFields(String(localized: language.shortLabel)))
    }
  }

  private func noticeText(_ notice: WordRegistrationModel.Notice, _ language: TranslationLanguage) -> String {
    switch notice {
    case .notFound: String(localized: .noticeNotFound)
    case .meaningNotFound: String(localized: .noticeMeaningNotFound(String(localized: language.shortLabel)))
    case .onlyMeaningFound: String(localized: .noticeOnlyMeaningFound)
    }
  }

  @ViewBuilder
  private func badge(_ field: WordRegistrationModel.Field) -> some View {
    if model.showsBadge(field) { AutoFillBadge() }
  }

  private func form(_ language: TranslationLanguage) -> some View {
    let languageLabel = String(localized: language.shortLabel)
    return VStack(alignment: .leading, spacing: 0) {
      if let notice = model.notice {
        DictionaryWarningBanner(message: noticeText(notice, language))
        Spacer().frame(height: px(16))
      }
      // iOS の登録シートと同じく、辞書の警告と同じバナーで出す。
      if model.translationFailed {
        DictionaryWarningBanner(message: String(localized: .exampleTranslationFailed(languageLabel)))
        Spacer().frame(height: px(16))
      }
      HStack(alignment: .top, spacing: px(14)) {
        LabeledTextField(label: String(localized: .fieldWord), text: $model.word)
        LabeledTextField(
          label: String(localized: .fieldIpa), text: $model.ipa, trailing: { badge(.ipa) }, fieldTrailing: { EmptyView() })
      }
      Spacer().frame(height: px(16))
      LabeledTextField(
        label: String(localized: language.meaningFieldLabel), text: $model.meaning, lineLimit: 1...Int.max,
        trailing: { badge(.meaning) }, fieldTrailing: { EmptyView() })
      Spacer().frame(height: px(16))
      HStack(spacing: px(6)) {
        AppText(.fieldPartsOfSpeech, style: AppTextStyle(size: 12, weight: .w600))
          .foregroundStyle(colors.textSecondary)
        badge(.partsOfSpeech)
      }
      Spacer().frame(height: px(5))
      PosChipSelector(selected: model.selectedPartsOfSpeech) { model.togglePartOfSpeech($0) }
      Spacer().frame(height: px(16))
      LabeledTextField(
        label: String(localized: .fieldExampleEn), text: $model.exampleEn, lineLimit: 2...Int.max,
        trailing: { badge(.exampleEn) }, fieldTrailing: { EmptyView() })
      // 例文の訳を持たない言語(英語の語義)では欄ごと出さない
      if language.translatesExamples {
        Spacer().frame(height: px(16))
        LabeledTextField(
          label: String(localized: .fieldExampleTranslation(languageLabel)), text: $model.exampleTranslation,
          lineLimit: 2...Int.max, trailing: { badge(.exampleTranslation) }, fieldTrailing: { EmptyView() })
      }
      if let errorMessage = errorText(language) {
        Spacer().frame(height: px(16))
        AppText(errorMessage, style: AppTextStyle(size: 12)).foregroundStyle(colors.danger)
      }
      Spacer().frame(height: px(16))
      HStack(spacing: 0) {
        AppFilledButton(label: String(localized: .registerButton)) { Task { await model.save() } }
        Spacer().frame(width: px(10))
        AppOutlinedButton(label: String(localized: .back)) { model.backToInput() }
        Spacer().frame(width: px(12))
        TextActionButton(label: String(localized: .cancel)) { shell.selectView(.allWords) }
      }
    }
  }
}
