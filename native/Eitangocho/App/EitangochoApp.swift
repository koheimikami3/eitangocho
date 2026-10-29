import SwiftUI

@main
struct EitangochoApp: App {
  @State private var model = AppModel()
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      RootView(model: model)
        .task { await model.start() }
    }
    .onChange(of: scenePhase) { _, phase in
      // iOS はアプリを終了させずに中断するので、戻ったときの同期が要る。
      guard phase == .active else { return }
      Task { await model.appDidBecomeActive() }
    }
  }
}
