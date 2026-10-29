import SwiftUI

/// 起動の段階に応じて画面を出し分ける。
struct RootView: View {
  let model: AppModel

  var body: some View {
    switch model.phase {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failed(let failure):
      StartupFailureView(failure: failure, model: model)
    case .ready(let session):
      #if DEBUG
        DiagnosticsView(session: session)
      #else
        // 本番の画面は Phase 2 以降で作る。
        Text(verbatim: "\(session.importOutcome)")
      #endif
    }
  }
}
