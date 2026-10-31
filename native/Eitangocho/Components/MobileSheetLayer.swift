#if os(iOS)
  import SwiftUI

  /// AppOverlay のシートを下から出す層(iOS。Flutter 版の showMobileSheet = showModalBottomSheet)。
  ///
  /// 幕は rgba(20,25,35,0.35) で、押すと閉じる。シートは画面の下端に付け、つまみ・ヘッダを下へ引くと
  /// 指に付いてきて、半分より引くか素早く払えば閉じる(Flutter の BottomSheet と同じ判定)。
  /// キーボードが出ている間は、残りの高さをシートの寸法の基準にする(MobileSheetLayout)。
  struct MobileSheetLayer: View {
    let overlay: AppOverlay

    @Environment(\.palette) private var palette
    /// 画面の高さ(キーボードを除かない)と下端のホームインジケータの高さ。
    @State private var screenHeight: CGFloat = 0
    @State private var bottomSafeArea: CGFloat = 0

    var body: some View {
      GeometryReader { proxy in
        ZStack(alignment: .bottom) {
          if let sheet = overlay.sheet {
            palette.barrier
              .contentShape(Rectangle())
              .onTapGesture { overlay.dismissSheet() }
              .transition(.opacity)
            sheet.content
              .id(sheet.id)
              .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { overlay.sheetHeight = $0 }
              .offset(y: overlay.sheetDragOffset)
              .transition(.move(edge: .bottom))
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
        .environment(
          \.mobileSheetLayout,
          MobileSheetLayout(
            availableHeight: proxy.size.height,
            keyboardHeight: max(screenHeight - proxy.size.height, 0),
            bottomSafeArea: bottomSafeArea))
      }
      // 上下のセーフエリアには広げ、キーボードは避ける(シートの寸法の基準がキーボードの上の高さになる)。
      .ignoresSafeArea(.container)
      .background {
        // キーボードを避けない入れ物で、画面の高さとホームインジケータの高さを測る。
        GeometryReader { proxy in
          Color.clear
            .onGeometryChange(for: EdgeInsets.self, of: { $0.safeAreaInsets }) { insets in
              bottomSafeArea = insets.bottom
              screenHeight = proxy.size.height + insets.top + insets.bottom
            }
        }
        .ignoresSafeArea(.keyboard)
      }
    }
  }

  /// シートが自分の寸法を決めるための値。MobileSheetLayer が配る。
  struct MobileSheetLayout: Equatable {
    /// シートを置ける高さ(画面の高さからキーボードを除いたもの)。
    var availableHeight: CGFloat = 0
    /// キーボードの高さ(出ていなければ 0)。シートはその裏も面の色で埋める。
    var keyboardHeight: CGFloat = 0
    /// 下端のホームインジケータの高さ(中身の高さに合わせるシートが下に空ける)。
    var bottomSafeArea: CGFloat = 0
  }

  extension EnvironmentValues {
    @Entry var mobileSheetLayout = MobileSheetLayout()
  }

  extension View {
    /// 下へ引くとシートが付いてきて、半分より引くか素早く払えば閉じる(つまみ・ヘッダに付ける)。
    /// 中のスクロールと取り合わないよう、シート全体ではなくスクロールしない所にだけ付ける。
    func mobileSheetDragHandle() -> some View {
      modifier(MobileSheetDragHandle())
    }
  }

  private struct MobileSheetDragHandle: ViewModifier {
    @Environment(\.appOverlay) private var overlay

    /// Flutter の BottomSheet が払ったとみなす速さ(_minFlingVelocity = 700 px/s)。
    private static var flingVelocity: CGFloat { 700 }

    func body(content: Content) -> some View {
      content
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .onChanged { value in
              overlay?.sheetDragOffset = max(value.translation.height, 0)
            }
            .onEnded { value in
              guard let overlay else { return }
              let closes =
                value.velocity.height > Self.flingVelocity
                || overlay.sheetDragOffset > overlay.sheetHeight / 2
              if closes {
                overlay.dismissSheet()
              } else {
                withAnimation(AppOverlay.sheetEnter) { overlay.sheetDragOffset = 0 }
              }
            })
    }
  }
#endif
