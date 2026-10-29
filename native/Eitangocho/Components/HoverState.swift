import SwiftUI

extension View {
  /// Flutter 版の部品の `MouseRegion(onEnter:onExit:)` + `GestureDetector(onTap:)` に当たる。
  /// 押せる範囲は `shape` の形にする(透明な所も押せるように)。
  func hoverTap<S: Shape>(_ isHovered: Binding<Bool>, in shape: S, action: @escaping () -> Void) -> some View {
    contentShape(shape)
      .onHover { isHovered.wrappedValue = $0 }
      .onTapGesture(perform: action)
  }
}
