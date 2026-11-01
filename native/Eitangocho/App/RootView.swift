import EitangochoSync
import StoreKit
import SwiftUI

/// 起動の段階に応じて画面を出し分ける。配色と表示倍率はここで設定から配る。
struct RootView: View {
  let model: AppModel

  @Environment(\.requestReview) private var requestReview
  #if os(iOS)
    /// OS の文字サイズ。Flutter 版と同じ倍率に直して配る(TextScale)。
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// シートの下端のバナーの先読み。シートは重ね層(AppOverlayHost)に出るので、タブの殻ではなくここで持つ。
    @State private var sheetBannerPreloader = MobileAdPreloader(
      adUnitId: AdUnitIds.sheetBanner, resolveSize: MobileSheetBannerAd.adSize(sheetWidth:))
    /// クイズ結果のレクタングルの先読み。「続ける」で回をまたいでも使い回すので、クイズの画面より長く持つ。
    @State private var quizRectanglePreloader = MobileAdPreloader(
      adUnitId: AdUnitIds.quizRectangle, resolveSize: MobileQuizRectangleAd.adSize(width:))
  #endif

  var body: some View {
    content
      .overlay { AppOverlayHost(overlay: model.overlay) }
      .environment(\.appOverlay, model.overlay)
      .environment(\.analytics, model.analytics)
      .environment(\.purchase, model.purchase)
      .environment(\.ads, model.ads)
      // レビュー依頼の口は画面からしか取れないので、ここで ReviewPrompter のクライアントに渡す。
      .onAppear { model.reviewClient.action = requestReview }
      .environment(\.colors, model.settings.appearance.colors)
      .environment(\.openPronunciation, openPronunciation)
      #if os(iOS)
        .environment(\.palette, model.settings.appearance.palette)
        .environment(\.textScale, TextScale.factor(for: dynamicTypeSize))
        .environment(\.sheetBannerPreloader, sheetBannerPreloader)
        .environment(\.quizRectanglePreloader, quizRectanglePreloader)
      #endif
      #if os(macOS)
        .environment(\.uiScale, UIScale(factor: model.settings.uiScale))
        .frame(minWidth: WindowAppearance.minimumSize.width, minHeight: WindowAppearance.minimumSize.height)
        .onChange(of: model.settings.appearance, initial: true) { _, appearance in
          WindowAppearance.apply(appearance)
        }
      #endif
      .preferredColorScheme(model.settings.appearance == .dark ? .dark : .light)
  }

  /// 発音確認を開く。macOS は別ウィンドウ(ページもアプリと同じ拡大率で出す)、iOS はシート。
  private func openPronunciation(_ word: String) {
    // ボタンは主画面(学習中・全単語・クイズ)にしか無いので、今の主画面がそのまま押された場所になる。
    model.analytics.logPronunciationOpened(model.shell.view)
    // 開いた時点の訳の言語で引く(開いている間に変わることはない)。
    let url = GoogleTranslateURL.make(word, language: model.settings.translationLanguage)
    #if os(macOS)
      PronunciationWindowController.shared.open(url: url, title: word, zoom: model.settings.uiScale)
    #else
      model.overlay.presentSheet { dismiss in
        MobilePronunciationSheet(word: word, url: url, dismiss: dismiss)
      }
    #endif
  }

  @ViewBuilder
  private var content: some View {
    switch model.phase {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failed(let failure):
      StartupFailureView(failure: failure, model: model)
    case .ready(let session):
      readyContent(session)
        .modifier(
          AnalyticsReporting(
            reporter: model.analyticsReporter, shell: model.shell, settings: model.settings, session: session,
            purchase: model.purchase, trackingClient: model.trackingClient))
    }
  }

  /// 起動に成功した後の画面。
  @ViewBuilder
  private func readyContent(_ session: AppModel.Session) -> some View {
    #if os(macOS)
      MacMainShell(
        shell: model.shell, settings: model.settings,
        learningCount: WordListing.learning(session.words.words).count,
        wordCount: session.words.words.count,
        onStartQuiz: { session.quiz.start(trigger: .tab) }
      ) { view in
        mainContent(view, session: session)
      }
    #else
      MobileTabShell(model: model, session: session)
    #endif
  }
}

#if os(macOS)
  extension RootView {
    /// シェルの中身(表示中の画面)。
    @ViewBuilder
    fileprivate func mainContent(_ view: MainView, session: AppModel.Session) -> some View {
      switch view {
      case .learning:
        LearningWordsView(store: session.words, shell: model.shell, settings: model.settings)
      case .allWords:
        AllWordsView(store: session.words, shell: model.shell, settings: model.settings)
      case .registration:
        WordRegistrationView(
          shell: model.shell, settings: model.settings, dao: session.database.wordDao, wordInfo: session.wordInfo,
          analytics: model.analytics, review: session.review)
      case .quiz:
        QuizView(quiz: session.quiz, shell: model.shell, settings: model.settings)
      case .settings:
        SettingsView(
          settings: model.settings, sync: session.sync, exportService: WordExportService(database: session.database))
      }
    }
  }
#endif
