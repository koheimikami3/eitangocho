#if os(iOS)
  import SwiftUI

  /// iOS 版の淡いボタン(淡い色の地 + 同じ系統の色の文字。枠・影なし。iOS 標準の控えめなボタンと同じ作り)。
  ///
  /// 主ボタン(MobileFilledButton)と並べる副ボタン。寸法は MobileFilledButton の既定(15px・上下 14・角丸 12)に揃える。
  /// 地は accentSoftButton / dangerSoftButton のような一段濃い淡色にする(白地に影だと背景の薄いグレーとの差が小さく
  /// ぼやけるため)。枠を付けないのは、淡い地 + 同色の枠がクイズの入口の「選んでいる」タイルと同じ見た目になり、
  /// 押すものに見えないため。
  struct MobileSoftButton: View {
    let label: String
    let color: Color
    let background: Color
    let action: () -> Void

    var body: some View {
      MobilePressable(action: action) {
        AppText(label, style: AppTextStyle(size: 15, weight: .w600))
          .foregroundStyle(color)
          .frame(maxWidth: .infinity)
          .padding(14)
          .background(RoundedRectangle(cornerRadius: 12).fill(background))
      }
    }
  }
#endif
