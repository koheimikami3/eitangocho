#if os(macOS)
  import EitangochoSync
  import SwiftUI

  /// macOS 版の設定画面(Pro・表示・外観・テーマカラー・訳の言語・データ・サポート・情報)。変更は即保存。
  /// クイズの出題の向きは 2.18.0 でクイズの入口へ移した(iOS と同じ)。
  /// Flutter 版の SettingsView。
  struct SettingsView: View {
    let settings: SettingsStore
    let sync: SyncController
    let exportService: WordExportService

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @Environment(\.openURL) private var openURL
    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics
    @Environment(\.purchase) private var purchase

    var body: some View {
      // スクロール領域はビューの全幅に広げ、中身だけを左に寄せる。スクロール領域ごと寄せると、
      // スクロールバーがカードのすぐ横に出る(全単語の表と同じく、ビューの右端に出す)。
      ScrollView {
        VStack(alignment: .leading, spacing: px(22)) {
          // iOS と同じく先頭に置く。課金を扱えない環境(SDK キーが未設定・初期化の失敗)では欄ごと出さない。
          if let purchase, purchase.available {
            ProSection(purchase: purchase)
          }
          SettingsSection(title: String(localized: .sectionDisplay)) {
            SettingsCard {
              SettingsToggleRow(label: String(localized: .showIpa), value: settings.showIpa) {
                settings.setShowIpa($0)
              }
              // 表示サイズは macOS 専用。iOS では OS の文字サイズ設定に委ねるため出さない。
              UiScaleSlider(value: settings.uiScale) { settings.setUiScale($0) }
            }
          }
          // iOS は次の階層の画面に分けるが、macOS は横幅に余裕があるので、独立したセクションにラジオの行を並べる。
          SettingsSection(title: String(localized: .sectionAppearance)) {
            SettingsCard {
              ForEach(AppAppearance.allCases, id: \.self) { appearance in
                SettingsRadioRow(
                  label: String(localized: appearance.label), selected: settings.appearance == appearance
                ) { settings.setAppearance(appearance) }
              }
            }
          }
          // テーマカラーは外観とは別の欄にする(iOS と同じく別の行に分け、Pro で解放するものとして目に入るように)。
          SettingsSection(title: String(localized: .themeColor)) {
            SettingsCard {
              ThemeColorPicker(settings: settings)
            }
          }
          SettingsSection(title: String(localized: .sectionTranslation)) {
            translationLanguages
          }
          // iCloud 同期と書き出し / 読み込みは、どちらも単語帳そのものの持ち出しを扱うため 1 枚のカードにまとめる。
          SettingsSection(title: String(localized: .sectionData)) {
            SettingsCard {
              SyncRows(sync: sync)
              DataBackupRows(service: exportService)
            }
          }
          SettingsSection(title: String(localized: .sectionSupport)) {
            SettingsCard {
              // 自分から書きたい人の受け皿。OS のレビュー依頼は年 3 回の上限で出ないことがあるため、
              // 常設の導線を別に置く。
              SettingsLinkRow(label: String(localized: .writeReview)) {
                analytics.logStoreListingOpened()
                openURL(ReviewConfig.writeReviewURL)
              }
            }
          }
          SettingsSection(title: String(localized: .sectionInfo)) {
            SettingsCard {
              SettingsValueRow(label: String(localized: .version), value: AppVersion.display)
              SettingsLinkRow(label: String(localized: .licenses)) {
                overlay?.present { dismiss in LicenseDialog(dismiss: dismiss) }
              }
            }
          }
        }
        .frame(width: px(560), alignment: .leading)
        .padding(px(28))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }

    private var translationLanguages: some View {
      VStack(alignment: .leading, spacing: 0) {
        SettingsCard {
          ForEach(
            AppLocale.deviceTranslationLanguageChoices(current: settings.translationLanguage), id: \.self
          ) { language in
            SettingsRadioRow(
              label: String(localized: language.label), selected: settings.translationLanguage == language
            ) { settings.setTranslationLanguage(language) }
          }
        }
        Spacer().frame(height: px(6))
        // 位置はセクションの見出しと同じく、カードの角丸が終わる位置。
        AppText(.translationLanguageCaption, style: AppTextStyle(size: 11, height: 1.6))
          .foregroundStyle(colors.textQuaternary)
          .padding(.horizontal, px(AppDimensions.mobileCardRadius))
      }
    }
  }
#endif
