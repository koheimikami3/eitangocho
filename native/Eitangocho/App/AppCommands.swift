#if os(macOS)
  import SwiftUI

  /// macOS のメニューバー(Flutter 版の AppMenuBar と同じ項目・ショートカット)。
  ///
  /// 「単語」メニューに登録(⌘N)、「編集」メニューに検索(⌘F)を置く。
  /// 検索は検索欄の無い画面では無効にする。
  ///
  /// Flutter 版は編集メニューに文字の編集の項目を載せていなかったが、AppKit の入力欄は
  /// コピー・ペーストなどをメニューの項目経由で受けるので、標準の項目は残す。
  /// 新規ウィンドウ(⌘N の既定)・検索と置換(⌘F の既定)・ヘルプ・表示メニューの項目は
  /// Flutter 版に無いので消す。
  struct AppCommands: Commands {
    let shell: MainShellModel

    var body: some Commands {
      CommandGroup(replacing: .newItem) {}
      CommandGroup(replacing: .help) {}
      CommandGroup(replacing: .sidebar) {}
      CommandGroup(replacing: .toolbar) {}
      CommandMenu(Text(.menuWords)) {
        Button(String(localized: .navRegistration)) { shell.selectView(.registration) }
          .keyboardShortcut("n", modifiers: .command)
      }
      CommandGroup(replacing: .textEditing) {
        Button(String(localized: .search)) { shell.focusSearch() }
          .keyboardShortcut("f", modifiers: .command)
          .disabled(!shell.view.hasSearchField)
      }
    }
  }
#endif
