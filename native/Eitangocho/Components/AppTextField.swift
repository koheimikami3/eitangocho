import SwiftUI

/// Flutter の TextField と同じ寸法の入力欄を組むための計算。
enum AppTextField {
  /// 入力欄の高さ。Flutter の InputDecorator は、入力とヒントのうち行の高さが大きい方に
  /// 上下の余白(contentPadding)を足した高さになる。和文を含むと行の高さが変わる(AppTextStyle)。
  static func height(style: AppTextStyle, texts: [String], verticalPadding: CGFloat, scale: UIScale) -> CGFloat {
    let lineHeight = texts.map { style.lineLayout(for: $0, scale: scale).lineHeight }.max() ?? 0
    return lineHeight + scale(verticalPadding) * 2
  }
}
