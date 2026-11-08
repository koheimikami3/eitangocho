#if os(macOS)
  import SwiftUI

  /// アプリシェルのツールバー(Flutter 版の MainToolbar)。画面の見出し・検索・登録ボタンを出す。
  struct MainToolbar: View {
    let shell: MainShellModel
    let settings: SettingsStore

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: 0) {
        // 見出しの上でもドラッグ・ダブルクリックが効くよう、当たり判定を背面に通す。
        AppText(shell.view.title, style: AppTextStyle(size: 15, weight: .w700))
          .foregroundStyle(colors.textPrimary)
          .allowsHitTesting(false)
          .layoutPriority(1)
        // 並び替えは全単語だけ(学習中は登録順のカード表示のまま)。右寄せで置き、
        // 既定の倍率でウィンドウを最小幅まで狭めると収まらないので、そのときは並び順の文字を省略して縮む。
        if shell.view == .allWords {
          Spacer(minLength: px(16))
          BookmarksFilterButton(shell: shell)
          Spacer().frame(width: px(8))
          WordSortButton(settings: settings)
          Spacer().frame(width: px(10))
        } else {
          Spacer(minLength: 0)
        }
        // 検索は学習中・全単語の画面だけに出す。
        if shell.view.hasSearchField {
          ToolbarSearchField(shell: shell)
            .fixedSize()
          Spacer().frame(width: px(10))
        }
        ToolbarAddButton { shell.selectView(.registration) }
          .fixedSize()
      }
      .padding(.horizontal, px(16))
      .modifier(ToolbarSurface())
      .frame(maxWidth: .infinity)
      // タイトルバーの代わり: 空いている所のドラッグで移動、ダブルクリックで拡大 / 元に戻す。
      .background(WindowDragArea())
    }
  }

  /// ツールバーの帯。macOS 26 以降は帯を描かず、下の地のまま部品(ガラス)だけを浮かせる
  /// (標準のツールバーと同じ)。それより前は、iOS のヘッダと同じく面の色(ライトは白)の帯 + 下の境界線で、
  /// 下のグレーの地(カードを並べる面)と分ける。
  private struct ToolbarSurface: ViewModifier {
    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    func body(content: Content) -> some View {
      if #available(macOS 26, *) {
        content.frame(height: px(AppDimensions.toolbarHeight))
      } else {
        content
          // 下の境界線の分だけ中身を狭める(Flutter の Container は枠線の幅を内側の余白に足す)。
          .padding(.bottom, px(1))
          .frame(height: px(AppDimensions.toolbarHeight))
          .frame(maxWidth: .infinity)
          .background(colors.surface)
          .overlay(alignment: .bottom) {
            Rectangle().fill(colors.border).frame(height: px(1))
          }
      }
    }
  }
#endif
