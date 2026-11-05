#if os(iOS)
  import EitangochoData
  import EitangochoWordInfo
  import SwiftUI

  /// iOS 版の単語登録シート(単語の入力 → 自動入力 → 確認フォーム。Flutter 版の WordRegistrationSheet)。
  ///
  /// macOS 版の WordRegistrationView と同じ WordRegistrationModel を使い、見た目と閉じ方だけが違う。
  /// 開くたびに新しいモデルで始める(前回の入力を残さない)。
  struct WordRegistrationSheet: View {
    let settings: SettingsStore
    let dismiss: () -> Void

    @Environment(\.palette) private var palette
    @State private var model: WordRegistrationModel

    init(
      settings: SettingsStore, dao: WordDao, wordInfo: any WordInfoProvider, analytics: AnalyticsLogger,
      review: ReviewPrompter, dismiss: @escaping () -> Void
    ) {
      self.settings = settings
      self.dismiss = dismiss
      _model = State(
        initialValue: WordRegistrationModel(
          dao: dao, wordInfo: wordInfo, analytics: analytics, review: review, resetsAfterSave: false
        ) {
          settings.translationLanguage
        })
    }

    var body: some View {
      let isForm = model.step == .form
      // フォームまで進んでいれば入力のステップへ戻す、そうでなければ閉じる。
      let leftLabel: String = isForm ? String(localized: .back) : String(localized: .cancel)
      // 右上の「登録」はフォームのときだけ出す(MobileSheet はラベルがあるときだけボタンを出す)。
      let rightLabel: String? = isForm ? String(localized: .registerShort) : nil
      MobileSheet(
        title: String(localized: .navRegistration), leftLabel: leftLabel, leftIcon: isForm ? .back : .close,
        onLeft: leftAction(isForm),
        rightLabel: rightLabel, onRight: { save() }
      ) {
        stepContent
      } footer: {
        // 単語の入力・読み込み中は中身の下のレクタングルに譲り、フォームでだけ下端のバナーを出す。
        if isForm { MobileSheetBannerAd() }
      }
    }

    private var stepContent: some View {
      let language = settings.translationLanguage
      return VStack(spacing: 0) {
        switch model.step {
        case .input: inputStep(language)
        case .loading: loadingStep
        case .form: formStep(language)
        }
        // 入力から読み込み中へ進んでも読み込み直さないよう、段階の切り替えの外に 1 つだけ置く。
        if model.step != .form {
          MobileRegistrationRectangleAd()
        }
      }
    }

    private func leftAction(_ isForm: Bool) -> () -> Void {
      isForm ? { model.backToInput() } : dismiss
    }

    /// macOS 版は登録の画面に留まるが、iOS はシートを閉じるだけでよい(背後の一覧は WordStore が更新する)。
    private func save() {
      Task {
        if await model.save() { dismiss() }
      }
    }

    private func errorText(_ language: TranslationLanguage) -> String? {
      model.error.map { RegistrationMessages.error($0, language: language) }
    }

    private func inputStep(_ language: TranslationLanguage) -> some View {
      VStack(alignment: .leading, spacing: 16) {
        AppText(language.registrationIntro, style: AppTextStyle(size: 12, height: 1.6))
          .foregroundStyle(palette.textAlpha(50))
        MobileLabeledField(
          label: String(localized: .fieldWord), text: $model.word, hint: "apple", asciiKeyboard: true,
          correction: false, onSubmit: autoFill)
        MobileFilledButton(
          label: String(localized: .autoFill), padding: EdgeInsets(top: 13, leading: 13, bottom: 13, trailing: 13),
          cornerRadius: 11, expands: true, action: autoFill)
        if let errorMessage = errorText(language) {
          AppText(errorMessage, style: AppTextStyle(size: 12))
            .foregroundStyle(palette.danger)
        }
        MobilePressable(style: .text, action: { model.skipToManual() }) {
          AppText(.skipToManual, style: AppTextStyle(size: 13))
            .foregroundStyle(palette.accentOnSoft)
            .multilineTextAlignment(.center)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
        }
      }
    }

    private func autoFill() {
      Task { await model.autoFill() }
    }

    private var loadingStep: some View {
      VStack(spacing: 14) {
        CircularProgress(color: palette.accent, size: 28, lineWidth: 3, trackColor: palette.borderAlpha(10))
        AppText(.fetchingDictionary, style: AppTextStyle(size: 13))
          .foregroundStyle(palette.textAlpha(50))
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 80)
    }

    private func formStep(_ language: TranslationLanguage) -> some View {
      let languageLabel = String(localized: language.shortLabel)
      return VStack(alignment: .leading, spacing: 0) {
        // 見出しを書き換えたことは、他の注意より先に伝える(英単語の欄を見直してもらうため)。
        if let baseFormNotice = model.baseFormNotice {
          MobileRegistrationWarningBanner(message: baseFormNotice)
            .padding(.bottom, 14)
        }
        if let notice = model.notice {
          MobileRegistrationWarningBanner(message: RegistrationMessages.notice(notice, language: language))
            .padding(.bottom, 14)
        }
        if model.translationFailed {
          MobileRegistrationWarningBanner(message: String(localized: .exampleTranslationFailed(languageLabel)))
            .padding(.bottom, 14)
        }
        MobileFormRows {
          MobileLabeledField(
            label: String(localized: .fieldWord), text: $model.word, asciiKeyboard: true, correction: false)
          // IPA は ASCII ではないので英字キーボードにしない。
          MobileLabeledField(label: String(localized: .fieldIpa), text: $model.ipa, autoFilled: model.showsBadge(.ipa))
          MobileLabeledField(
            label: String(localized: language.meaningFieldLabel), text: $model.meaning, lineLimit: 1...Int.max,
            autoFilled: model.showsBadge(.meaning))
          VStack(alignment: .leading, spacing: 7) {
            MobileFieldLabel(label: String(localized: .fieldPartsOfSpeech), autoFilled: model.showsBadge(.partsOfSpeech))
            MobilePosChipSelector(selected: model.selectedPartsOfSpeech) { model.togglePartOfSpeech($0) }
          }
          MobileLabeledField(
            label: String(localized: .fieldExampleEn), text: $model.exampleEn, lineLimit: 2...Int.max,
            autoFilled: model.showsBadge(.exampleEn), asciiKeyboard: true)
          // 例文の訳を持たない言語(英語の語義)では欄ごと出さない。
          if language.translatesExamples {
            MobileLabeledField(
              label: String(localized: .fieldExampleTranslation(languageLabel)), text: $model.exampleTranslation,
              lineLimit: 2...Int.max, autoFilled: model.showsBadge(.exampleTranslation))
          }
        }
        if let errorMessage = errorText(language) {
          AppText(errorMessage, style: AppTextStyle(size: 12))
            .foregroundStyle(palette.danger)
            .padding(.top, 14)
        }
      }
    }
  }

  /// 辞書の注意・例文の訳の失敗を知らせる帯(Flutter 版の登録シートの _WarningBanner)。
  private struct MobileRegistrationWarningBanner: View {
    let message: String

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 12)
      AppText(message, style: AppTextStyle(size: 13, height: 1.5))
        .foregroundStyle(palette.warningBannerForeground)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(shape.fill(palette.warningBannerBackground))
        .overlay(shape.strokeBorder(palette.warningBannerBorder, lineWidth: 1))
        .appShadows([AppShadow(color: Color(argb: 0x0F10_1828), blurRadius: 2, y: 1)], in: shape, scale: 1)
    }
  }
#endif
