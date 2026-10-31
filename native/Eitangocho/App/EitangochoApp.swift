import EitangochoData
import SwiftUI

@main
struct EitangochoApp: App {
  #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  #endif
  @State private var model = AppModel()
  #if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
  #endif

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
          #if os(macOS)
            // macOS の scenePhase はほかのアプリへ切り替えても active のまま(ウィンドウが見えている間は
            // 変わらない)なので、戻ったことはアプリの前面化の通知で知る(Flutter 版の macOS の onResume と同じ契機)。
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
              Task { await model.appDidBecomeActive() }
            }
          #endif
      }
    }
    #if os(iOS)
      .onChange(of: scenePhase) { _, phase in
        // App Group の DB のロックを持ったまま中断されないよう、中断の前に DB を止める。
        AppDatabase.setSuspended(phase == .background)
        // iOS はアプリを終了させずに中断するので、戻ったときの同期が要る。
        guard phase == .active, !Self.isRunningTests else { return }
        Task { await model.appDidBecomeActive() }
      }
    #endif
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
