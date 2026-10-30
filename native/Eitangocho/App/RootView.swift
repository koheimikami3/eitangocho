import SwiftUI

/// 起動の段階に応じて画面を出し分ける。配色と表示倍率はここで設定から配る。
struct RootView: View {
  let model: AppModel

  var body: some View {
    content
      .overlay { AppOverlayHost(overlay: model.overlay) }
      .environment(\.appOverlay, model.overlay)
      .environment(\.colors, model.settings.appearance.colors)
      #if os(macOS)
        .environment(\.uiScale, UIScale(factor: model.settings.uiScale))
        .environment(\.openPronunciation, openPronunciation)
        .frame(minWidth: WindowAppearance.minimumSize.width, minHeight: WindowAppearance.minimumSize.height)
        .onChange(of: model.settings.appearance, initial: true) { _, appearance in
          WindowAppearance.apply(appearance)
        }
      #endif
      .preferredColorScheme(model.settings.appearance == .dark ? .dark : .light)
  }

  #if os(macOS)
    /// 発音確認のウィンドウを開く。ページもアプリと同じ拡大率で出す。
    private func openPronunciation(_ word: String) {
      PronunciationWindowController.shared.open(
        url: GoogleTranslateURL.make(word, language: model.settings.translationLanguage), title: word,
        zoom: model.settings.uiScale)
    }
  #endif

  @ViewBuilder
  private var content: some View {
    switch model.phase {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failed(let failure):
      StartupFailureView(failure: failure, model: model)
    case .ready(let session):
      #if os(macOS)
        MacMainShell(
          shell: model.shell, settings: model.settings,
          learningCount: WordListing.learning(session.words.words).count,
          wordCount: session.words.words.count,
          onStartQuiz: { session.quiz.start() }
        ) { view in
          mainContent(view, session: session)
        }
      #elseif DEBUG
        // iOS の画面は Phase 6 で作る。それまでは Dev ビルドで診断画面を出す。
        DiagnosticsView(session: session)
      #else
        Text(verbatim: "\(session.importOutcome)")
      #endif
    }
  }
}

#if os(macOS)
  extension RootView {
    /// シェルの中身(表示中の画面)。設定は Phase 3 の後のコミットで移すまで空にしておく。
    @ViewBuilder
    fileprivate func mainContent(_ view: MainView, session: AppModel.Session) -> some View {
      switch view {
      case .learning:
        LearningWordsView(store: session.words, shell: model.shell, settings: model.settings)
      case .allWords:
        AllWordsView(store: session.words, shell: model.shell, settings: model.settings)
      case .registration:
        WordRegistrationView(
          shell: model.shell, settings: model.settings, dao: session.database.wordDao, wordInfo: session.wordInfo)
      case .quiz:
        QuizView(quiz: session.quiz, shell: model.shell, settings: model.settings)
      case .settings:
        Color.clear
      }
    }
  }
#endif
