import SwiftUI

/// Flutter の `BoxShadow` と同じ値で書く影。
///
/// SwiftUI の `shadow` は 1 つずつしか重ねられず(重ねると前の影にも影が付く)、
/// 広がり(spread)も持たないので、面と同じ形を影の数だけ背面に描いて再現する。
nonisolated struct AppShadow: Equatable, Sendable {
  var color: Color
  /// Flutter の blurRadius(CSS の blur と同じ意味)。
  var blurRadius: CGFloat
  var spread: CGFloat = 0
  var x: CGFloat = 0
  var y: CGFloat = 0

  /// ぼかしの標準偏差。Flutter の `BoxShadow.convertRadiusToSigma` と同じ式
  /// (SwiftUI の blur の radius は標準偏差として扱われる)。
  func sigma(scale: CGFloat) -> CGFloat {
    blurRadius > 0 ? blurRadius * scale * 0.57735 + 0.5 : 0
  }
}

extension View {
  /// `shape` の形の影を背面に重ねる。値は素の値で渡し、ここで倍率を掛ける。
  func appShadows<S: Shape>(_ shadows: [AppShadow], in shape: S, scale: CGFloat) -> some View {
    background {
      ZStack {
        ForEach(Array(shadows.enumerated()), id: \.offset) { _, shadow in
          // 影を出す面は塗りが要るが、上に載る本体で隠れるので色は問わない。
          // spread は形を広げる(負なら縮める)ことで表す。
          shape
            .fill(shadow.color)
            .padding(-shadow.spread * scale)
            .blur(radius: shadow.sigma(scale: scale))
            .offset(x: shadow.x * scale, y: shadow.y * scale)
        }
      }
    }
  }
}
