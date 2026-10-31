import SwiftUI

/// OS の文字サイズの設定に合わせた、文字の大きさの倍率(iOS)。
///
/// Flutter 版は iOS の文字サイズの設定から倍率を作り(engine の `FlutterViewController.textScaleFactor`)、
/// 文字の大きさだけに掛ける(余白・アイコン・字間は変えない)。同じ表で倍率を作り、
/// `AppText` と `AppTextStyle.font` が文字の大きさに掛ける。同梱フォントは `Font(CTFont)` で
/// 組んでいるので、SwiftUI が自分で Dynamic Type の拡大を重ねることはない。
nonisolated enum TextScale {
  /// 本文の大きさ(pt)を既定の L(17pt)で割った値。Flutter の engine の表と同じ。
  static func factor(for size: DynamicTypeSize) -> CGFloat {
    let body: CGFloat =
      switch size {
      case .xSmall: 14
      case .small: 15
      case .medium: 16
      case .large: 17
      case .xLarge: 19
      case .xxLarge: 21
      case .xxxLarge: 23
      case .accessibility1: 28
      case .accessibility2: 33
      case .accessibility3: 40
      case .accessibility4: 47
      case .accessibility5: 53
      @unknown default: 17
      }
    return body / 17
  }
}

extension EnvironmentValues {
  /// 文字の大きさの倍率。iOS はルートで OS の文字サイズから決めて配る。macOS は 1 のまま(uiScale が受け持つ)。
  @Entry var textScale: CGFloat = 1
}
