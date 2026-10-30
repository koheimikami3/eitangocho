import SwiftUI

/// AppOverlay のメニューとダイアログを描く層。シェルの最前面に重ねる。
struct AppOverlayHost: View {
  let overlay: AppOverlay

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    ZStack {
      ForEach(overlay.dialogs) { dialog in
        ZStack {
          colors.barrier
            .contentShape(Rectangle())
            .onTapGesture { if dialog.dismissible { overlay.dismiss(dialog.id) } }
          dialog.content
            .onEscape { if dialog.dismissible { overlay.dismiss(dialog.id) } }
        }
      }
      // 下端の全幅に出す(Flutter の SnackBar の既定の fixed)。下から滑り込ませる。
      VStack(spacing: 0) {
        Spacer(minLength: 0)
        if let snackBar = overlay.snackBar {
          SnackBarView(message: snackBar.message)
            .id(snackBar.id)
            .transition(.move(edge: .bottom))
        }
      }
      .animation(.easeOut(duration: 0.25), value: overlay.snackBar)
      if let menu = overlay.menu {
        // メニューの外を押したら閉じる(押したものには届かない。Flutter の showMenu と同じ)。
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture { overlay.closeMenu() }
        MenuPlacement(anchor: menu.anchor, minWidth: menu.minWidth, px: px) {
          PopupMenuBox(items: menu.items) { overlay.closeMenu() }
        }
      }
    }
    .ignoresSafeArea()
  }
}

/// スナックバーの帯(Flutter の Material 3 の SnackBar の既定: inverseSurface の地・
/// 本文は bodyMedium・左右 24 と上下 14 の余白・高さ 6 の影・角丸なし)。
private struct SnackBarView: View {
  let message: String

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    AppText(message, style: AppTextStyle(size: 14, height: 20.0 / 14, letterSpacing: 0.25))
      .foregroundStyle(colors.materialOnInverseSurface)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, px(24))
      .padding(.vertical, px(14))
      .background(colors.materialInverseSurface)
      .appShadows(colors.snackBarShadow, in: Rectangle(), scale: px.factor)
  }
}

/// メニューの枠(Flutter の showMenu の Material と、menuPadding 4・角丸 8・枠線)。
private struct PopupMenuBox: View {
  let items: [AppOverlay.MenuItem]
  let close: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @FocusState private var focused: Bool

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(8))
    VStack(spacing: 0) {
      ForEach(items) { item in
        if item.isDivider {
          Rectangle().fill(colors.materialOutlineVariant).frame(height: px(1)).padding(.vertical, px(4))
        } else {
          HoverMenuItem(label: item.label, color: item.color, hoverColor: item.hoverColor, checked: item.checked) {
            close()
            item.action()
          }
        }
      }
    }
    .padding(px(4 + 1))
    .background(shape.fill(colors.menuBackground))
    .overlay(shape.strokeBorder(colors.borderAlpha(12), lineWidth: px(1)))
    .appShadows(colors.menuShadow, in: shape, scale: px.factor)
    // Esc で閉じる。
    .focusable()
    .focused($focused)
    .focusEffectDisabled()
    .onEscape(perform: close)
    .onAppear { focused = true }
  }
}

/// メニューを anchor に置き、ウィンドウからはみ出すなら内側へ寄せる
/// (Flutter の _PopupMenuRouteLayout と同じく、ウィンドウの端から 8 空ける)。
/// 幅は中身の幅を 56 刻みに切り上げ、minWidth を下限にする(Flutter の IntrinsicWidth(stepWidth: 56)
/// と constraints の minWidth)。
private struct MenuPlacement: Layout {
  let anchor: CGPoint
  let minWidth: CGFloat
  let px: UIScale

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    guard let menu = subviews.first else { return }
    let step = px(56)
    let intrinsic = menu.sizeThatFits(.unspecified).width
    let width = max(px(minWidth), (intrinsic / step).rounded(.up) * step)
    let size = menu.sizeThatFits(ProposedViewSize(width: width, height: nil))
    let margin = px(8)
    let x = min(max(anchor.x, bounds.minX + margin), bounds.maxX - size.width - margin)
    let y = min(max(anchor.y, bounds.minY + margin), bounds.maxY - size.height - margin)
    menu.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: width, height: size.height))
  }
}

/// ダイアログの面(Flutter の Dialog: 面の色・影なし・最小幅 280・画面の縁から 40 / 24 空ける)。
struct AppDialogSurface<Content: View>: View {
  var cornerRadius: CGFloat
  @ViewBuilder let content: () -> Content

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    content()
      .frame(minWidth: px(280))
      .background(RoundedRectangle(cornerRadius: px(cornerRadius)).fill(colors.surface))
      .clipShape(RoundedRectangle(cornerRadius: px(cornerRadius)))
      // ダイアログの中のクリックで幕(外側)の閉じる処理が走らないようにする。
      .contentShape(Rectangle())
      .onTapGesture {}
      .padding(.horizontal, px(40))
      .padding(.vertical, px(24))
  }
}

extension View {
  /// Esc で閉じる(macOS の exit command。iOS には無いので何もしない)。
  @ViewBuilder
  fileprivate func onEscape(perform action: @escaping () -> Void) -> some View {
    #if os(macOS)
      onExitCommand(perform: action)
    #else
      self
    #endif
  }
}
