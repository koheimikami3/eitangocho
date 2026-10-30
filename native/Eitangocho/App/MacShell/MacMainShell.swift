#if os(macOS)
  import SwiftUI

  /// macOS 版のシェル: サイドバー + ツールバー + 画面の切り替え(Flutter 版の SidebarShell)。
  struct MacMainShell<Content: View>: View {
    let shell: MainShellModel
    let settings: SettingsStore
    let learningCount: Int
    let wordCount: Int
    @ViewBuilder let content: (MainView) -> Content

    @Environment(\.colors) private var colors

    var body: some View {
      HStack(spacing: 0) {
        AppSidebar(shell: shell, learningCount: learningCount, wordCount: wordCount)
        VStack(spacing: 0) {
          MainToolbar(shell: shell, settings: settings)
          // 各画面を中身の幅に関わらず全幅に広げる。
          content(shell.view)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .background(colors.background)
      // タイトルバーを透明にして、サイドバーが信号機ボタンの背後まで届く見た目にする。
      .ignoresSafeArea()
    }
  }
#endif
