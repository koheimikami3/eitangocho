import SwiftUI

/// 画面の上に重ねるポップアップメニューとダイアログ(Flutter 版の showMenu / showDialog)。
///
/// 標準の contextMenu(NSMenu)・alert は見た目が Flutter 版と変わるので使わず、
/// シェルの最前面(AppOverlayHost)に Flutter 版と同じ寸法で描く。
/// ダイアログは重ねられる(編集ダイアログの上に削除の確認を出す)。
@Observable
final class AppOverlay {
  struct MenuItem: Identifiable {
    let id = UUID()
    var label: String
    var color: Color?
    var hoverColor: Color?
    var checked: Bool?
    var action: () -> Void
  }

  struct Menu {
    /// メニューの左上を置きたい位置(ウィンドウの左上が原点)。
    var anchor: CGPoint
    var items: [MenuItem]
  }

  struct Dialog: Identifiable {
    let id: UUID
    /// 外側のクリック・Esc で閉じられるか。
    var dismissible: Bool
    var content: AnyView
  }

  private(set) var menu: Menu?
  private(set) var dialogs: [Dialog] = []

  func showMenu(at anchor: CGPoint, items: [MenuItem]) {
    menu = Menu(anchor: anchor, items: items)
  }

  func closeMenu() {
    menu = nil
  }

  /// ダイアログを出す。`content` は閉じる関数を受け取る。
  func present<Content: View>(
    dismissible: Bool = true, @ViewBuilder content: (_ dismiss: @escaping () -> Void) -> Content
  ) {
    let id = UUID()
    let dismiss: () -> Void = { [weak self] in self?.dismiss(id) }
    dialogs.append(Dialog(id: id, dismissible: dismissible, content: AnyView(content(dismiss))))
  }

  func dismiss(_ id: UUID) {
    dialogs.removeAll { $0.id == id }
  }
}

extension EnvironmentValues {
  @Entry var appOverlay: AppOverlay?
}
