import EitangochoData
import SwiftUI

@main
struct EitangochoApp: App {
  #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  #endif
  @State private var model = AppModel()
  @Environment(\.scenePhase) private var scenePhase

  /// アプリのモデルのテスト(EitangochoTests)の入れ物として起動されたか。
  /// そのときは Flutter 版の DB の引き継ぎも同期も始めない
  /// (テストを走らせただけで Dev ビルドのデータを引き継いでしまわないため)。
  static let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

  init() {
    AppFonts.register()
  }

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
      #if os(iOS)
        // App Group の DB のロックを持ったまま中断されないよう、中断の前に DB を止める。
        AppDatabase.setSuspended(phase == .background)
      #endif
      // iOS はアプリを終了させずに中断するので、戻ったときの同期が要る。
      guard phase == .active, !Self.isRunningTests else { return }
      Task { await model.appDidBecomeActive() }
    }
    #if os(macOS)
      // タイトルバーを透明にし、中身をウィンドウ全面に広げる(Flutter 版の MainFlutterWindow)。
      .windowStyle(.hiddenTitleBar)
      .defaultSize(WindowAppearance.defaultSize)
      .windowResizability(.contentMinSize)
      .commands { AppCommands(shell: model.shell) }
    #endif
    #if os(macOS) && DEBUG
      // Dev ビルドだけの診断画面(引き継ぎ・同期の確認用)。メニューの「Debug」から開く。
      Window(Text(verbatim: "Diagnostics"), id: DiagnosticsWindow.id) {
        DiagnosticsWindow(model: model)
      }
    #endif
  }
}

#if os(macOS)
  final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
      // タブで複数のウィンドウを並べる機能は使わない(表示メニューの「タブバーを表示」も消える)。
      NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
  }
#endif
