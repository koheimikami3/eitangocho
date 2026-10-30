#if os(macOS)
  import EitangochoSync
  import SwiftUI

  /// macOS 版の設定画面(表示・テーマ・クイズ・訳の言語・データ・サポート・情報)。変更は即保存。
  /// Flutter 版の SettingsView。
  struct SettingsView: View {
    let settings: SettingsStore
    let sync: SyncController
    let exportService: WordExportService

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @Environment(\.openURL) private var openURL
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      // スクロール領域はビューの全幅に広げ、中身だけを左に寄せる。スクロール領域ごと寄せると、
      // スクロールバーがカードのすぐ横に出る(全単語の表と同じく、ビューの右端に出す)。
      ScrollView {
        VStack(alignment: .leading, spacing: px(22)) {
          SettingsSection(title: String(localized: .sectionDisplay)) {
            SettingsCard {
              SettingsToggleRow(label: String(localized: .showIpa), value: settings.showIpa) {
                settings.setShowIpa($0)
              }
              // 表示サイズは macOS 専用。iOS では OS の文字サイズ設定に委ねるため出さない。
              UiScaleSlider(value: settings.uiScale) { settings.setUiScale($0) }
            }
          }
          // iOS は「表示」の中に小見出しで置くが、macOS のカードには小見出しの部品が無いため、
          // クイズの出題方向と同じく独立したセクションのラジオの行にする。
          SettingsSection(title: String(localized: .theme)) {
            SettingsCard {
              ForEach(AppAppearance.allCases, id: \.self) { appearance in
                SettingsRadioRow(
                  label: String(localized: appearance.label), selected: settings.appearance == appearance
                ) { settings.setAppearance(appearance) }
              }
            }
          }
          SettingsSection(title: String(localized: .sectionQuiz)) {
            SettingsCard {
              ForEach(QuizDirection.allCases, id: \.self) { direction in
                SettingsRadioRow(
                  label: String(localized: direction.label(settings.translationLanguage)),
                  selected: settings.quizDirection == direction
                ) { settings.setQuizDirection(direction) }
              }
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
              SettingsLinkRow(label: String(localized: .writeReview)) { openURL(ReviewConfig.writeReviewURL) }
            }
          }
          SettingsSection(title: String(localized: .sectionInfo)) {
            SettingsCard {
              SettingsValueRow(label: String(localized: .version), value: Self.appVersion)
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

    /// 表示用のアプリのバージョン(`2.11.1` の形)。バンドルから取る(定数で持つと上げ忘れる)。
    private static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }
#endif
