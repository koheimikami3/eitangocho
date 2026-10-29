#if os(macOS)
  import SwiftUI

  /// アプリシェルのサイドバー(Flutter 版の AppSidebar)。
  struct AppSidebar: View {
    let shell: MainShellModel
    let learningCount: Int
    let wordCount: Int

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      VStack(spacing: 0) {
        // 信号機ボタンの並ぶ上端はタイトルバーとして振る舞わせる
        // (ドラッグで移動、ダブルクリックで拡大 / 元に戻す)。
        WindowDragArea().frame(height: px(52))
        AppText(.sidebarTitle, style: AppTextStyle(size: 11, weight: .w700))
          .foregroundStyle(colors.textTertiary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(EdgeInsets(top: px(6), leading: px(18), bottom: px(2), trailing: 0))
        item(.navLearning, count: "\(learningCount)", view: .learning)
        item(.navAllWords, count: "\(wordCount)", view: .allWords)
        // 件数は出さない。学習済みの語数を出しても、1 回に出題するのは
        // 決まった語数なので、何の数か分かりにくいため。
        // 押すたびに出題をやり直す処理は、クイズの画面を移すときに足す。
        item(.navQuiz, view: .quiz)
        item(.navRegistration, view: .registration)
        Spacer(minLength: 0)
        item(.navSettings, view: .settings)
        AppText(.sidebarSavedLocally, style: AppTextStyle(size: 11))
          .foregroundStyle(colors.textAlpha(35))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, px(12))
          .overlay(alignment: .top) {
            Rectangle().fill(colors.borderAlpha(6)).frame(height: px(1))
          }
          .padding(.horizontal, px(18))
          .padding(.vertical, px(12))
      }
      // 右の境界線の分だけ中身を狭める(Flutter の Container は枠線の幅を内側の余白に足す)。
      .padding(.trailing, px(1))
      .frame(width: px(AppDimensions.sidebarWidth))
      .frame(maxHeight: .infinity)
      .background(colors.sidebarBackground)
      .overlay(alignment: .trailing) {
        Rectangle().fill(colors.border).frame(width: px(1))
      }
    }

    private func item(_ label: LocalizedStringResource, count: String = "", view: MainView) -> some View {
      SidebarItem(label: String(localized: label), count: count, selected: shell.view == view) {
        shell.selectView(view)
      }
    }
  }
#endif
