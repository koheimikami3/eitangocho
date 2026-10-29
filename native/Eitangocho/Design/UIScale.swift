import SwiftUI

/// 表示倍率(設定の uiScale)。macOS は Flutter 版と同じく UI 全体を一律に拡大する。
///
/// Flutter 版は画面全体を Transform.scale で拡大していたが、SwiftUI で同じことを
/// すると AppKit が描く部品(入力欄・メニュー)が拡大されないため、寸法と文字の
/// 大きさの方に倍率を掛ける。画面では `@Environment(\.uiScale) private var px` を
/// 置き、`px(14)` のように素の値を包んで書く。
struct UIScale: Equatable, Sendable {
  var factor: CGFloat

  func callAsFunction(_ value: CGFloat) -> CGFloat { value * factor }

  func callAsFunction(_ insets: EdgeInsets) -> EdgeInsets {
    EdgeInsets(
      top: insets.top * factor, leading: insets.leading * factor,
      bottom: insets.bottom * factor, trailing: insets.trailing * factor)
  }

  /// 拡大しない(iOS。OS の文字サイズ設定に委ねる)。
  static let none = UIScale(factor: 1)

  #if os(macOS)
    static let `default` = UIScale(factor: AppDimensions.defaultUiScale)
  #else
    static let `default` = none
  #endif
}

extension EnvironmentValues {
  @Entry var uiScale: UIScale = .default
}
