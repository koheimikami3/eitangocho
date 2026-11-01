#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のセクション(小見出し + 角丸カード。Flutter 版の MobileSettingsSection)。
  ///
  /// 中身の行は区切り線を挟んで縦に並べる。小見出し(MobileSettingsSubheader)の直後には線を入れない。
  struct MobileSettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius)
      VStack(alignment: .leading, spacing: 8) {
        // 見出しはカードの外枠ではなく、角丸が終わる位置まで内側に寄せる(iOS 標準の設定画面と同じ考え方)。
        // 外枠に揃えると見出しだけが左にはみ出して見え、行の文字の頭まで寄せると右に寄りすぎる。
        AppText(title, style: AppTextStyle(size: 12, weight: .w700))
          .foregroundStyle(palette.textAlpha(50))
          .padding(.horizontal, AppDimensions.mobileCardRadius)
        VStack(spacing: 0) {
          Group(subviews: content()) { rows in
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
              // 小見出しは直後の行と 1 組に見せたいので、間に線を入れない
              // (見出しの手前には入るので、組の区切りは保たれる)。
              if index > 0 && !rows[index - 1].containerValues.isMobileSettingsSubheader {
                MobileSettingsDivider()
              }
              row
            }
          }
        }
        .frame(maxWidth: .infinity)
        .background(palette.surface)
        .clipShape(shape)
        .appShadows(palette.elevation, in: shape, scale: 1)
      }
    }
  }

  extension ContainerValues {
    /// 設定のカードの小見出しか(MobileSettingsSection が直後の区切り線を省く)。
    @Entry var isMobileSettingsSubheader = false
  }
#endif
