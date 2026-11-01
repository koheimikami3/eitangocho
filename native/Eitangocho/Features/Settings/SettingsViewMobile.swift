#if os(iOS)
  import EitangochoSync
  import SwiftUI

  /// iOS 版の設定画面。変更は即保存(Flutter 版の SettingsViewMobile)。
  ///
  /// macOS 版との違いは 2 つ:
  /// - 「表示」に外観(ライト / ダーク)と学習中カードの並びを持つ。
  ///   macOS は外観を独立したセクションに置き、カードの並びは 1 種類のため無い
  /// - 「表示サイズ」(uiScale)を持たない。iOS は OS の文字サイズの設定に委ねる
  ///
  /// 並びは「表示 → クイズ → 訳の言語 → データ → サポート → (作者の他のアプリ)→ 情報」。
  /// 見た目に関わるものを 1 枚のカードにまとめ、セクションの中はアプリ全体(テーマ)→ 一覧のレイアウト
  /// → 表示する項目(IPA)の順にする。
  struct SettingsViewMobile: View {
    let session: AppModel.Session
    let settings: SettingsStore
    let shell: MainShellModel

    @Environment(\.openURL) private var openURL
    @Environment(\.purchase) private var purchase
    /// 表示の位置。タブが選ばれるたびに先頭へ戻す(下記)。
    @State private var position = ScrollPosition(edge: .top)
    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics

    var body: some View {
      ScrollView {
        VStack(spacing: 22) {
          // 課金を扱えない環境(SDK キーが未設定・iOS 以外・初期化の失敗)では欄ごと出さない
          // (VStack の spacing なので、欄を置かなければ余白も残らない)。
          if let purchase, purchase.available {
            MobileProSection(purchase: purchase)
          }
          display
          MobileSettingsSection(title: String(localized: .sectionQuiz)) {
            ForEach(QuizDirection.allCases, id: \.self) { direction in
              MobileSettingsRadioRow(
                label: String(localized: direction.label(settings.translationLanguage)),
                selected: settings.quizDirection == direction
              ) { settings.setQuizDirection(direction) }
            }
          }
          translationLanguages
          // iCloud 同期と書き出し / 読み込みは、どちらも単語帳そのものの持ち出しを扱うため 1 枚のカードにまとめる。
          MobileSettingsSection(title: String(localized: .sectionData)) {
            MobileSyncRows(sync: session.sync)
            MobileDataBackupRows(service: WordExportService(database: session.database))
          }
          MobileSettingsSection(title: String(localized: .sectionSupport)) {
            // 自分から書きたい人の受け皿。OS のレビュー依頼は年 3 回の上限で出ないことがあるため、常設の導線を別に置く。
            MobileSettingsLinkRow(label: String(localized: .writeReview)) {
              analytics.logStoreListingOpened()
              openURL(ReviewConfig.writeReviewURL)
            }
          }
          // 紹介先がどちらも日本語だけのアプリなので、日本語の画面でだけ出す(他の言語の利用者に薦めても使えないため)。
          if AppLocale.current == .ja {
            MobileSettingsSection(title: String(localized: .sectionAuthorApps)) {
              ForEach(AuthorApp.all) { app in
                MobileAuthorAppRow(app: app)
              }
            }
          }
          MobileSettingsSection(title: String(localized: .sectionInfo)) {
            MobileSettingsValueRow(label: String(localized: .version), value: AppVersion.display)
            MobileSettingsLinkRow(label: String(localized: .licenses)) {
              overlay?.push { LicenseViewMobile() }
            }
            #if DEBUG
              // Dev ビルドだけ、引き継ぎ・同期の診断画面へ進む(macOS はメニューの「Debug」から開く)。
              MobileSettingsLinkRow(label: "データの診断") {
                overlay?.push {
                  MobilePushPage(title: "データの診断", backLabel: String(localized: .navSettings)) {
                    DiagnosticsView(session: session)
                  }
                }
              }
            #endif
          }
        }
        // 最後のカードがタブバーに近づきすぎないよう、設定画面だけ下を余分に空ける。
        .padding(
          EdgeInsets(
            top: AppDimensions.mobilePadding, leading: AppDimensions.mobilePadding,
            bottom: AppDimensions.mobilePadding * 2, trailing: AppDimensions.mobilePadding))
      }
      // タブが選ばれるたびに先頭から表示する(Flutter 版はタブの切り替えのたびに作り直していた)。
      // クイズ結果の Pro への導線は、設定のタブに移るだけで先頭の Pro の欄が見えることを前提にしている。
      .scrollPosition($position)
      .onChange(of: shell.view) { _, view in
        if view == .settings { position.scrollTo(edge: .top) }
      }
    }

    private var display: some View {
      MobileSettingsSection(title: String(localized: .sectionDisplay)) {
        MobileSettingsSubheader(label: String(localized: .theme))
        ForEach(AppAppearance.allCases, id: \.self) { appearance in
          MobileSettingsRadioRow(
            label: String(localized: appearance.label), selected: settings.appearance == appearance
          ) { settings.setAppearance(appearance) }
        }
        MobileSettingsSubheader(label: String(localized: .cardLayout))
        ForEach(LearningCardLayout.allCases, id: \.self) { layout in
          MobileSettingsRadioRow(
            label: String(localized: layout.label), selected: settings.cardLayout == layout,
            action: { settings.setCardLayout(layout) }
          ) {
            MobileCardLayoutPreview(layout: layout)
          }
        }
        MobileSettingsToggleRow(label: String(localized: .showIpa), value: settings.showIpa) {
          settings.setShowIpa($0)
        }
      }
    }

    private var translationLanguages: some View {
      VStack(alignment: .leading, spacing: 8) {
        MobileSettingsSection(title: String(localized: .sectionTranslation)) {
          ForEach(
            AppLocale.deviceTranslationLanguageChoices(current: settings.translationLanguage), id: \.self
          ) { language in
            MobileSettingsRadioRow(
              label: String(localized: language.label), selected: settings.translationLanguage == language
            ) { settings.setTranslationLanguage(language) }
          }
        }
        MobileSettingsCaption(text: String(localized: .translationLanguageCaption))
      }
    }
  }
#endif
