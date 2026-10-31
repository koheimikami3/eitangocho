#if os(macOS) && DEBUG
  import SwiftUI

  /// 診断画面を出す別ウィンドウ(Dev ビルドだけ)。本来の画面は本体ウィンドウに出す。
  struct DiagnosticsWindow: View {
    static let id = "diagnostics"

    let model: AppModel

    var body: some View {
      if case .ready(let session) = model.phase {
        DiagnosticsView(session: session)
          .frame(minWidth: 640, minHeight: 600)
      } else {
        Text(verbatim: "起動の処理が終わっていません")
          .padding(40)
      }
    }

    /// メニューの項目。開く処理は環境値から取るので View にしている。
    struct MenuItem: View {
      @Environment(\.openWindow) private var openWindow

      var body: some View {
        Button {
          openWindow(id: DiagnosticsWindow.id)
        } label: {
          Text(verbatim: "データの診断")
        }
      }
    }
  }
#endif
