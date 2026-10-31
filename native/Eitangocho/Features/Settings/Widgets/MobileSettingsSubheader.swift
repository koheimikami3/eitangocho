#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のカードの中に置く小見出し(「テーマ」「学習中カードの並び」など。Flutter 版の MobileSettingsSubheader)。
  ///
  /// 1 枚のカードに性質の違う設定をまとめるときだけ使う。直後の行との間に区切り線を入れないのは
  /// MobileSettingsSection の役目。
  struct MobileSettingsSubheader: View {
    let label: String

    @Environment(\.palette) private var palette

    var body: some View {
      AppText(label, style: AppTextStyle(size: 11, weight: .w600))
        .foregroundStyle(palette.textAlpha(45))
        .frame(maxWidth: .infinity, alignment: .leading)
        // 下だけ詰めているのは、直下の行の余白と合わせて見出しと中身が 1 組に見えるようにするため。
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 2, trailing: 14))
        .containerValue(\.isMobileSettingsSubheader, true)
    }
  }
#endif
