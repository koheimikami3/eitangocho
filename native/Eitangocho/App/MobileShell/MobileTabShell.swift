#if os(iOS)
  import EitangochoData
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
    @Environment(\.ads) private var ads
    @Environment(\.purchase) private var purchase
    @Environment(\.sheetBannerPreloader) private var sheetBannerPreloader
    /// 選択中のタブの中身の下端(画面の座標)= タブバーの上端。バナーをタブバーのすぐ上に置くのに使う。
    @State private var tabBarTop: CGFloat?
    /// タブバー上のバナーの帯の高さ(出ていない間は 0)。タブの中身の下余白に足す。
    @State private var bannerHeight: CGFloat = 0

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
        // バナーはタブを切り替えても読み込み直さないよう、タブごとではなく TabView の上に 1 つだけ重ねる。
        .overlay {
          // 重ねる側の下端からタブバーの上端までを空ける。TabView の枠が下のセーフエリアを含むか
          // (iOS 26 以降は含み、iOS 18 は含まない)に左右されないよう、どちらも画面の座標で測る。
          GeometryReader { geometry in
            MobileBannerAd(visible: bannerVisible) { bannerHeight = $0 }
              .padding(.bottom, max(geometry.frame(in: .global).maxY - (tabBarTop ?? .infinity), 0))
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
          }
          .ignoresSafeArea(.keyboard)
        }
      }
      // iPhone の大きい機種でも Flutter 版と同じくデザインの幅(402pt)に収める。
      .frame(maxWidth: AppDimensions.mobileContentMaxWidth)
      .frame(maxWidth: .infinity)
      .background(palette.background)
      // 一覧の画面にいる間に、登録・編集シートの下端のバナーを読み込んでおく。シートは画面の幅いっぱいに
      // 出るので、幅の上限を掛ける前の幅(= 画面の幅)を渡す。
      .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
        guard let ads, let purchase else { return }
        sheetBannerPreloader?.prepare(width: width, ads: ads, purchase: purchase)
      }
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

    /// タブバー上のバナーを出すか。シート・押して進む画面・ダイアログに覆われている間は出さない
    /// (Flutter 版は上に画面が積まれたこと(RouteAware の didPushNext)で隠していた。見えていない広告の
    /// インプレッションを稼がないため)。クイズ結果ではレクタングルに譲る。
    private var bannerVisible: Bool {
      let overlay = model.overlay
      let covered = overlay.sheet != nil || !overlay.pages.isEmpty || !overlay.dialogs.isEmpty
      return !covered && TabBarBannerVisibility.isVisible(view: model.shell.view, quizPhase: session.quiz.phase)
    }

    @ViewBuilder
    private func tabContent(_ view: MainView) -> some View {
      Group {
        switch view {
        case .learning, .registration:
          LearningWordsViewMobile(
            store: session.words, shell: model.shell, settings: model.settings, onEdit: openEdit,
            onRegister: openRegistration)
        case .allWords:
          AllWordsViewMobile(store: session.words, shell: model.shell, settings: model.settings, onEdit: openEdit)
        case .quiz:
          QuizViewMobile(quiz: session.quiz, shell: model.shell, settings: model.settings)
        case .settings:
          SettingsViewMobile(session: session, settings: model.settings, shell: model.shell)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      // バナーが重なる分を下の余白にする(Flutter 版はタブバーの高さ + バナーの高さを渡していた)。
      .safeAreaPadding(.bottom, bannerHeight)
      .background(palette.background)
      // 中身の枠はタブバーの上端で終わる(下余白は枠を変えない)。選択中のタブのものだけを使う。
      .onGeometryChange(for: CGFloat.self) { $0.frame(in: .global).maxY } action: { maxY in
        if view == model.shell.view { tabBarTop = maxY }
      }
    }

    /// ヘッダの ＋・学習中の空の状態のボタン。登録シートを開く。
    private func openRegistration() {
      // iOS の登録はシートなので主画面の切り替え(AnalyticsReporting)には現れない。
      // 開いたことをここで送る(macOS の登録の画面と同じ名前)。
      model.analytics.logScreenView("registration")
      model.overlay.presentSheet { [model, session] dismiss in
        WordRegistrationSheet(
          settings: model.settings, dao: session.database.wordDao, wordInfo: session.wordInfo,
          analytics: model.analytics, review: session.review, dismiss: dismiss)
      }
    }

    /// カード・行のタップ。編集シートを開く。
    private func openEdit(_ word: Word) {
      model.analytics.logScreenView("word_edit")
      model.overlay.presentSheet { [model, session] dismiss in
        WordEditSheet(
          word: word, store: session.words, language: model.settings.translationLanguage, dismiss: dismiss)
      }
    }
  }
#endif
