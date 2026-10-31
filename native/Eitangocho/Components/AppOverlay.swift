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
    /// 後ろに敷く幕の色。nil なら Flutter の showDialog の既定(AppColors.barrier)。
    var barrier: Color?
    var content: AnyView
  }

  /// 下から出すシート(iOS。Flutter 版の showModalBottomSheet)。一度に 1 枚だけ出す。
  /// 標準の sheet は幕の色と iOS 26 の浮いた形・ガラスを変えられないので使わない(MobileSheetLayer)。
  struct Sheet: Identifiable {
    let id: UUID
    var content: AnyView
  }

  /// 右から押し出して重ねる画面(iOS。Flutter 版の Navigator.push = 設定からライセンスへ)。
  /// タブバー・ヘッダごと覆う(Flutter 版はルートの Navigator に積むため)。シートとダイアログはこの上に出る。
  struct Page: Identifiable {
    let id: UUID
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
  private(set) var sheet: Sheet?
  private(set) var pages: [Page] = []

  /// シートを下へ引いている量(つまみ・ヘッダのドラッグ。MobileSheetDragHandle が書く)。
  var sheetDragOffset: CGFloat = 0
  /// 出ているシートの高さ(半分より引いたら閉じる判定に使う。MobileSheetLayer が書く)。
  var sheetHeight: CGFloat = 0

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
    dismissible: Bool = true, barrier: Color? = nil,
    @ViewBuilder content: (_ dismiss: @escaping () -> Void) -> Content
  ) {
    let id = UUID()
    let dismiss: () -> Void = { [weak self] in self?.dismiss(id) }
    dialogs.append(Dialog(id: id, dismissible: dismissible, barrier: barrier, content: AnyView(content(dismiss))))
  }

  /// シートを出す。`content` は閉じる関数を受け取る。出ているシートがあれば置き換える。
  func presentSheet<Content: View>(@ViewBuilder content: (_ dismiss: @escaping () -> Void) -> Content) {
    let id = UUID()
    let dismiss: () -> Void = { [weak self] in self?.dismissSheet(id) }
    sheetDragOffset = 0
    withAnimation(Self.sheetEnter) {
      sheet = Sheet(id: id, content: AnyView(content(dismiss)))
    }
  }

  /// シートを閉じる。`id` を渡したときは、そのシートが出ているときだけ閉じる(閉じた後に古い閉じる関数が呼ばれても次のシートを閉じない)。
  func dismissSheet(_ id: UUID? = nil) {
    guard let sheet, id == nil || sheet.id == id else { return }
    withAnimation(Self.sheetExit) {
      self.sheet = nil
    }
  }

  /// Flutter の BottomSheet の出入り(250 ms で出て 200 ms で引っ込む)。
  static let sheetEnter: Animation = .easeOut(duration: 0.25)
  static let sheetExit: Animation = .easeIn(duration: 0.2)

  /// 画面を押し出す(MobilePushLayer)。
  func push<Content: View>(@ViewBuilder content: () -> Content) {
    withAnimation(Self.pushEnter) {
      pages.append(Page(id: UUID(), content: AnyView(content())))
    }
  }

  /// いちばん上の画面を戻す。`animated` が false なら動きを付けずに外す(戻るジェスチャで送り終えたとき)。
  func pop(animated: Bool = true) {
    guard !pages.isEmpty else { return }
    var transaction = Transaction(animation: animated ? Self.pushExit : nil)
    transaction.disablesAnimations = !animated
    withTransaction(transaction) {
      _ = pages.removeLast()
    }
  }

  /// Flutter の iOS の画面遷移(CupertinoPageRoute: 500 ms。進むは linearToEaseOut、戻るは easeInToLinear)。
  static let pushEnter: Animation = .timingCurve(0.35, 0.91, 0.33, 0.97, duration: 0.5)
  static let pushExit: Animation = .timingCurve(0.67, 0.03, 0.65, 0.09, duration: 0.5)

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
