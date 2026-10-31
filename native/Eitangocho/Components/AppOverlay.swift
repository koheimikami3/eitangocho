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
    /// 区切り線(Flutter の PopupMenuDivider(height: 9))として描くか。
    var isDivider = false
    var label = ""
    var color: Color?
    var hoverColor: Color?
    var checked: Bool?
    var action: () -> Void = {}

    static var divider: MenuItem { MenuItem(isDivider: true) }
  }

  struct Menu {
    /// メニューの左上を置きたい位置(ウィンドウの左上が原点)。
    var anchor: CGPoint
    var items: [MenuItem]
    /// 幅の下限(Flutter の showMenu の constraints の minWidth)。
    var minWidth: CGFloat
  }

  struct Dialog: Identifiable {
    let id: UUID
    /// 外側のクリック・Esc で閉じられるか。
    var dismissible: Bool
    var content: AnyView
  }

  /// 下端に一時的に出す通知(Flutter の ScaffoldMessenger.showSnackBar)。
  struct SnackBar: Identifiable, Equatable {
    let id: UUID
    var message: String
  }

  private(set) var menu: Menu?
  private(set) var dialogs: [Dialog] = []
  private(set) var snackBar: SnackBar?

  /// スナックバーを出しておく時間(Flutter の SnackBar の既定と同じ 4 秒)。
  static let snackBarDuration: Duration = .seconds(4)

  func showMenu(at anchor: CGPoint, items: [MenuItem], minWidth: CGFloat = 140) {
    menu = Menu(anchor: anchor, items: items, minWidth: minWidth)
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

  /// スナックバーを出す。出ている間に次を出したら入れ替える(Flutter は順番待ちにするが、
  /// このアプリで続けて出すのは書き出しを繰り返したときだけなので、新しい方だけを見せる)。
  func showSnackBar(_ message: String) {
    let snackBar = SnackBar(id: UUID(), message: message)
    self.snackBar = snackBar
    Task { [weak self] in
      try? await Task.sleep(for: Self.snackBarDuration)
      if self?.snackBar?.id == snackBar.id { self?.snackBar = nil }
    }
  }
}

extension EnvironmentValues {
  @Entry var appOverlay: AppOverlay?
}
