#if os(iOS)
  import SwiftUI

  /// AppOverlay の押し出した画面を重ねる層(iOS。Flutter 版の MaterialPageRoute = iOS では CupertinoPageRoute)。
  ///
  /// 画面は右から入り、左端から右へ引くと指に付いてきて、半分より引くか素早く払えば戻る
  /// (Flutter の CupertinoPageRoute の戻るジェスチャと同じ判定)。
  struct MobilePushLayer: View {
    let overlay: AppOverlay

    /// いちばん上の画面を右へ引いている量。
    @State private var dragOffset: CGFloat = 0
    /// 左端から引き始めたか(引き始めの位置で決め、指を離すまで変えない)。
    @State private var dragging = false

    /// 戻るジェスチャを受ける左端の幅(Flutter の _kBackGestureWidth)。
    private static var edgeWidth: CGFloat { 20 }

    var body: some View {
      GeometryReader { proxy in
        ZStack {
          ForEach(overlay.pages) { page in
            let isTop = page.id == overlay.pages.last?.id
            page.content
              .frame(width: proxy.size.width, height: proxy.size.height)
              .offset(x: isTop ? dragOffset : 0)
              // 左端に押せない帯を重ねると、そこにある戻るボタンまで押せなくなるので、
              // 画面全体で受けて引き始めの位置で振り分ける。
              .simultaneousGesture(isTop ? backGesture(width: proxy.size.width) : nil)
              .transition(.move(edge: .trailing))
          }
        }
      }
    }

    private func backGesture(width: CGFloat) -> some Gesture {
      DragGesture(minimumDistance: 4, coordinateSpace: .global)
        .onChanged { value in
          if !dragging {
            guard value.startLocation.x < Self.edgeWidth else { return }
            dragging = true
          }
          dragOffset = max(value.translation.width, 0)
        }
        .onEnded { value in
          guard dragging else { return }
          dragging = false
          // Flutter は 1 秒で画面幅を超える速さなら払ったとみなす(_kMinFlingVelocity = 1.0)。
          let pops = value.velocity.width > width || dragOffset > width / 2
          if pops {
            // 指の位置から右端まで送ってから、遷移の動きを付けずに外す
            // (外す動きを付けると、引いた量に遷移の移動が足されて二重に動く)。
            withAnimation(.easeOut(duration: 0.2)) {
              dragOffset = width
            } completion: {
              overlay.pop(animated: false)
              dragOffset = 0
            }
          } else {
            withAnimation(AppOverlay.pushEnter) { dragOffset = 0 }
          }
        }
    }
  }
#endif
