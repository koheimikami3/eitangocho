import SwiftUI

@main
struct EitangochoApp: App {
  @State private var model = AppModel()
  @Environment(\.scenePhase) private var scenePhase

  /// アプリのモデルのテスト(EitangochoTests)の入れ物として起動されたか。
  /// そのときは Flutter 版の DB の引き継ぎも同期も始めない
  /// (テストを走らせただけで Dev ビルドのデータを引き継いでしまわないため)。
  static let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

  var body: some Scene {
    WindowGroup {
      if Self.isRunningTests {
        EmptyView()
      } else {
        RootView(model: model)
          .task { await model.start() }
      }
    }
    .onChange(of: scenePhase) { _, phase in
      // iOS はアプリを終了させずに中断するので、戻ったときの同期が要る。
      guard phase == .active, !Self.isRunningTests else { return }
      Task { await model.appDidBecomeActive() }
    }
  }
}
