#if os(iOS)
  import UIKit

  extension UIApplication {
    /// いちばん上に出ている画面(前面のウィンドウの根から、上に出した画面をたどった先)。
    /// UIKit の画面を重ねて出すとき(全画面広告・削除の確認のアラート)の出し元に使う。
    var topViewController: UIViewController? {
      var top = connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)?
        .rootViewController
      while let presented = top?.presentedViewController { top = presented }
      return top
    }
  }
#endif
