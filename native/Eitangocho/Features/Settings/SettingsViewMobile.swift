#if os(iOS)
  import EitangochoSync
  import SwiftUI

  /// iOS 版の設定画面。変更は即保存(Flutter 版の SettingsViewMobile)。
  ///
  /// 選択肢から選ぶ項目(外観モード・テーマカラー・カードの並び・クイズの出題・訳の言語)は次の階層の画面へ移し、
  /// トップの行の右端に今の値を出す。トグルと操作(同期・書き出し・読み込みなど)は 1 タップのままトップに残す。
  ///
  /// macOS 版との違い:
  /// - 選ぶ項目を次の階層に分ける(macOS は横幅に余裕があるので 1 画面に並べたまま)
  /// - テーマカラー・学習中カードの並びを持つ(macOS は課金が無く、カードの並びは 1 種類のため無い)
  /// - 「表示サイズ」(uiScale)を持たない。iOS は OS の文字サイズの設定に委ねる
  ///
  /// 並びは「(Pro)→ 表示 → 学習 → データ → サポート → (作者の他のアプリ)→ 情報」。
  /// 「表示」はアプリ全体(外観モード・テーマカラー)→ 一覧のレイアウト → 表示する項目(IPA)の順にする。
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
    @Environment(\.palette) private var palette

    var body: some View {
      ScrollView {
        VStack(spacing: 22) {
          // 課金を扱えない環境(SDK キーが未設定・iOS 以外・初期化の失敗)では欄ごと出さない
          // (VStack の spacing なので、欄を置かなければ余白も残らない)。
          if let purchase, purchase.available {
            MobileProSection(purchase: purchase)
          }
          display
          learning
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
        MobileSettingsLinkRow(
          label: String(localized: .appearanceMode), value: String(localized: settings.appearance.label)
        ) { overlay?.push { AppearanceViewMobile(settings: settings) } }
        // 値は画面に出ている色(未購入ならブルー)。保存した色ではない。
        MobileSettingsLinkRow(
          label: String(localized: .themeColor), value: String(localized: palette.theme.label)
        ) { overlay?.push { ThemeColorViewMobile(settings: settings) } }
        MobileSettingsLinkRow(
          label: String(localized: .cardLayout), value: String(localized: settings.cardLayout.label)
        ) { overlay?.push { CardLayoutViewMobile(settings: settings) } }
        MobileSettingsToggleRow(label: String(localized: .showIpa), value: settings.showIpa) {
          settings.setShowIpa($0)
        }
      }
    }

    private var learning: some View {
      MobileSettingsSection(title: String(localized: .sectionLearning)) {
        MobileSettingsLinkRow(
          label: String(localized: .quizDirection),
          value: String(localized: settings.quizDirection.label(settings.translationLanguage))
        ) { overlay?.push { QuizDirectionViewMobile(settings: settings) } }
        MobileSettingsLinkRow(
          label: String(localized: .sectionTranslation), value: String(localized: settings.translationLanguage.label)
        ) { overlay?.push { TranslationLanguageViewMobile(settings: settings) } }
      }
    }
  }
#endif
