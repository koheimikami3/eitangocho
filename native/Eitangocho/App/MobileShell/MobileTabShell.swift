#if os(iOS)
  import SwiftUI

  /// iOS 版のシェル: ヘッダ + 標準の下タブバー(Flutter 版の TabBarShell)。
  ///
  /// タブは 4 つ(学習中 / 全単語 / クイズ / 設定)。タブバーは標準の TabView(iOS 26 以降は Liquid Glass)。
  /// 単語登録はタブに置かず、ヘッダの ＋ からシートで開く。検索もタブにしない(iOS 26 の検索タブは使わない)。
  /// ヘッダはタブごとに持たず TabView の上に 1 つだけ置く(Flutter 版と同じ構成。検索欄が 1 つで済む)。
  /// キーボードが出ている間は、タブバーはキーボードの下に隠れる(標準の挙動)。
  struct MobileTabShell: View {
    let model: AppModel
    let session: AppModel.Session

    @Environment(\.palette) private var palette

    var body: some View {
      let shell = model.shell
      VStack(spacing: 0) {
        MobileHeader(shell: shell, settings: model.settings, words: session.words, onAdd: openRegistration)
          // ヘッダの影をコンテンツの上に落とす。
          .zIndex(1)
        TabView(selection: selection) {
          Tab(value: MainView.learning) {
            tabContent(.learning)
          } label: {
            // デザインは「カードが 2 枚重なった」線画(Flutter 版は Icons.filter_none)。
            Label(String(localized: .navLearning), systemImage: "square.on.square")
          }
          Tab(value: MainView.allWords) {
            tabContent(.allWords)
          } label: {
            Label(String(localized: .navAllWords), systemImage: "list.bullet")
          }
          Tab(value: MainView.quiz) {
            tabContent(.quiz)
          } label: {
            Label(String(localized: .navQuizShort), systemImage: "bolt")
          }
          Tab(value: MainView.settings) {
            tabContent(.settings)
          } label: {
            Label(String(localized: .navSettings), systemImage: "gearshape")
          }
        }
        .tint(palette.accent)
      }
      // iPhone の大きい機種でも Flutter 版と同じくデザインの幅(402pt)に収める。
      .frame(maxWidth: AppDimensions.mobileContentMaxWidth)
      .frame(maxWidth: .infinity)
      .background(palette.background)
    }

    /// タブの選択。クイズのタブは押すたびに出題をやり直す(Flutter 版と同じく、遷移の前にシャッフルし直す)。
    /// 登録はタブではない(シートで開く)ので、万一その状態になっても学習中を返す。
    private var selection: Binding<MainView> {
      let shell = model.shell
      return Binding(
        get: { shell.view == .registration ? .learning : shell.view },
        set: { view in
          if view == .quiz { session.quiz.start(trigger: .tab) }
          shell.selectView(view)
        })
    }

    @ViewBuilder
    private func tabContent(_ view: MainView) -> some View {
      Group {
        switch view {
        case .learning, .allWords, .quiz, .registration:
          // 学習中・全単語は次のコミットで、クイズは Phase 6b で作る。
          Color.clear
        case .settings:
          #if DEBUG
            // 設定は Phase 6b で作る。それまで Dev ビルドでは引き継ぎ・同期の診断画面を出す。
            DiagnosticsView(session: session)
          #else
            Color.clear
          #endif
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(palette.background)
    }

    /// ヘッダの ＋。登録シートを開く。
    private func openRegistration() {}
  }
#endif
