#if os(macOS)
  import SwiftUI

  /// アプリシェルのツールバー(Flutter 版の MainToolbar)。画面の見出し・検索・登録ボタンを出す。
  struct MainToolbar: View {
    let shell: MainShellModel

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: 0) {
        // 見出しの上でもドラッグ・ダブルクリックが効くよう、当たり判定を背面に通す。
        AppText(shell.view.title, style: AppTextStyle(size: 15, weight: .w700))
          .foregroundStyle(colors.textPrimary)
          .allowsHitTesting(false)
        Spacer(minLength: 0)
        // 検索は学習中・全単語の画面だけに出す。
        if shell.view.hasSearchField {
          ToolbarSearchField(shell: shell)
          Spacer().frame(width: px(10))
        }
        AppFilledButton(
          label: String(localized: .addWord), verticalPadding: 6, fontSize: 13, borderRadius: 7
        ) {
          shell.selectView(.registration)
        }
      }
      .padding(.horizontal, px(16))
      // 下の境界線の分だけ中身を狭める(Flutter の Container は枠線の幅を内側の余白に足す)。
      .padding(.bottom, px(1))
      .frame(height: px(AppDimensions.toolbarHeight))
      .frame(maxWidth: .infinity)
      // タイトルバーの代わり: 空いている所のドラッグで移動、ダブルクリックで拡大 / 元に戻す。
      .background(WindowDragArea())
      // iOS のヘッダと同じく面の色(ライトは白)にし、下のグレーの地(カードを並べる面)と分ける。
      .background(colors.surface)
      .overlay(alignment: .bottom) {
        Rectangle().fill(colors.border).frame(height: px(1))
      }
    }
  }
#endif
