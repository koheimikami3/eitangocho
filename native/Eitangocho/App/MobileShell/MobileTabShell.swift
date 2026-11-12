#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版のシェル: ヘッダ + 標準の下タブバー(Flutter 版の TabBarShell)。
  ///
  /// タブは 3 つ(学習中 / 全単語 / クイズ)。設定はたまにしか開かないのでタブにせず、ヘッダ右上の ⚙ から
  /// 下のシートで開く(試作。一時的に開いて閉じれば元の画面に戻る、という意味がシートの方が合うため)。タブバーは標準の TabView(iOS 26 以降は Liquid Glass)。
  /// 単語登録はタブに置かず、右下に浮かせた ＋ からシートで開く。検索もタブにしない(iOS 26 の検索タブは使わない)。
  /// ヘッダはタブごとに持たず TabView の上に 1 つだけ置く(Flutter 版と同じ構成。検索欄が 1 つで済む)。
  /// キーボードが出ている間は、タブバーはキーボードの下に隠れる(標準の挙動)。
  struct MobileTabShell: View {
    let model: AppModel
    let session: AppModel.Session

    @Environment(\.palette) private var palette
    @Environment(\.ads) private var ads
    @Environment(\.purchase) private var purchase
    @Environment(\.sheetBannerPreloader) private var sheetBannerPreloader
    @Environment(\.registrationRectanglePreloader) private var registrationRectanglePreloader
    /// 選択中のタブの中身の下端(画面の座標)= タブバーの上端。バナーをタブバーのすぐ上に置くのに使う。
    @State private var tabBarTop: CGFloat?
    /// タブバー上のバナーの帯の高さ(出ていない間は 0)。タブの中身の下余白に足す。
    @State private var bannerHeight: CGFloat = 0
    /// 登録したばかりの見出し語(学習中のカードで演出を出す間だけ持つ)。
    @State private var celebratedWord: String?

    var body: some View {
      let shell = model.shell
      VStack(spacing: 0) {
        MobileHeader(shell: shell, settings: model.settings, words: session.words, onSettings: openSettings)
          // ヘッダの下端の線をコンテンツの上に描く。
          .zIndex(1)
        TabView(selection: selection) {
          Tab(value: MainView.learning) {
            tabContent(.learning)
          } label: {
            // 開いた本(単語帳を開いて覚えている途中)。試作。
            Label(String(localized: .navLearning), systemImage: "book")
          }
          Tab(value: MainView.allWords) {
            tabContent(.allWords)
          } label: {
            Label(String(localized: .navAllWords), systemImage: "list.bullet")
          }
          Tab(value: MainView.quiz) {
            tabContent(.quiz)
          } label: {
            // 斜めに重なった 2 枚のカード(単語カードをめくって答えを確かめる)。試作。
            Label(String(localized: .navQuiz), systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
          }
        }
        .tint(palette.accent)
        // バナーはタブを切り替えても読み込み直さないよう、タブごとではなく TabView の上に 1 つだけ重ねる。
        .overlay {
          // 重ねる側の下端からタブバーの上端までを空ける。TabView の枠が下のセーフエリアを含むか
          // (iOS 26 以降は含み、iOS 18 は含まない)に左右されないよう、どちらも画面の座標で測る。
          GeometryReader { geometry in
            MobileBannerAd(visible: bannerVisible, covered: overlayCovers) { bannerHeight = $0 }
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
      // 一覧の画面にいる間に、登録・編集シートの広告を読み込んでおく。シートは画面の幅いっぱいに
      // 出るので、幅の上限を掛ける前の幅(= 画面の幅)を渡す(レクタングルは幅に関わらず同じ大きさ)。
      .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
        guard let ads, let purchase else { return }
        sheetBannerPreloader?.prepare(width: width, ads: ads, purchase: purchase)
        registrationRectanglePreloader?.prepare(width: width, ads: ads, purchase: purchase)
      }
    }

    /// タブの選択。クイズのタブは、回が無いときだけ出題を始め、途中の回・結果はそのまま見せる
    /// (`QuizModel.enterFromTab`。Flutter 版は押すたびにやり直していた)。
    /// 登録・設定はタブではない(シート・押して進む画面で開く)ので、万一その状態になっても学習中を返す。
    private var selection: Binding<MainView> {
      let shell = model.shell
      return Binding(
        get: { shell.view == .registration || shell.view == .settings ? .learning : shell.view },
        set: { view in
          if view == .quiz { session.quiz.enterFromTab() }
          shell.selectView(view)
        })
    }

    /// タブバー上のバナーを出すか。シート・押して進む画面・ダイアログに覆われている間は出さない
    /// (Flutter 版は上に画面が積まれたこと(RouteAware の didPushNext)で隠していた。見えていない広告の
    /// インプレッションを稼がないため)。クイズ結果ではレクタングルに譲る。
    private var bannerVisible: Bool {
      !overlayCovers && TabBarBannerVisibility.isVisible(view: model.shell.view, quizPhase: session.quiz.phase)
    }

    /// シート・押して進む画面・ダイアログのどれかが主画面を覆っているか。
    private var overlayCovers: Bool {
      let overlay = model.overlay
      return overlay.sheet != nil || !overlay.pages.isEmpty || !overlay.dialogs.isEmpty
    }

    @ViewBuilder
    private func tabContent(_ view: MainView) -> some View {
      Group {
        switch view {
        case .learning, .registration, .settings:
          LearningWordsViewMobile(
            store: session.words, shell: model.shell, settings: model.settings, celebratedWord: celebratedWord,
            onEdit: openEdit, onRegister: openRegistration)
            .safeAreaPadding(.bottom, MobileAddButton.clearance)
        case .allWords:
          AllWordsViewMobile(store: session.words, shell: model.shell, settings: model.settings, onEdit: openEdit)
            .safeAreaPadding(.bottom, MobileAddButton.clearance)
        case .quiz:
          QuizViewMobile(
            quiz: session.quiz, shell: model.shell, settings: model.settings, onRegister: openRegistration,
            onOpenSettings: openSettings)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(alignment: .bottomTrailing) {
        // 検索している間は隠す(探す作業に集中させ、絞り込んだ一覧の右下のカードを ＋ で覆わないため)。
        if (view == .learning || view == .allWords) && !model.shell.isSearchOpen {
          MobileAddButton(action: openRegistration)
            .transition(.scale(scale: 0.6).combined(with: .opacity))
        }
      }
      .animation(.smooth(duration: 0.2), value: model.shell.isSearchOpen)
      // バナーが重なる分を下の余白にする(Flutter 版はタブバーの高さ + バナーの高さを渡していた)。
      .safeAreaPadding(.bottom, bannerHeight)
      .background(palette.background)
      // 中身の枠はタブバーの上端で終わる(下余白は枠を変えない)。選択中のタブのものだけを使う。
      .onGeometryChange(for: CGFloat.self) { $0.frame(in: .global).maxY } action: { maxY in
        if view == model.shell.view { tabBarTop = maxY }
      }
    }

    /// 右下の ＋・学習中の空の状態のボタン。登録シートを開く。
    private func openRegistration() {
      // iOS の登録はシートなので主画面の切り替え(AnalyticsReporting)には現れない。
      // 開いたことをここで送る(macOS の登録の画面と同じ名前)。
      model.analytics.logScreenView("registration")
      model.overlay.presentSheet { [model, session] dismiss in
        WordRegistrationSheet(
          settings: model.settings, dao: session.database.wordDao, wordInfo: session.wordInfo,
          analytics: model.analytics, review: session.review, dismiss: dismiss,
          onRegistered: { headword in
            celebrate(headword)
            offerProIfNeeded()
          })
      }
    }

    /// ヘッダの ⚙・クイズ結果の Pro への導線。設定をシートで開く(先頭に Pro の欄がある)。
    private func openSettings() {
      // タブではないので主画面の切り替え(AnalyticsReporting)には現れない。開いたことをここで送る(登録と同じ)。
      model.analytics.logScreenView("settings")
      model.overlay.presentSheet { [model, session] dismiss in
        MobileSettingsSheet(session: session, settings: model.settings, dismiss: dismiss)
      }
    }

    /// 登録したカードに演出を出す(学習中のカードの画面にいるときだけ見える)。演出が終わったら外す。
    private func celebrate(_ headword: String) {
      celebratedWord = headword
      Task {
        try? await Task.sleep(for: .seconds(1.5))
        if celebratedWord == headword { celebratedWord = nil }
      }
    }

    /// 登録の保存直後に、条件を満たせば Pro の案内を 1 回だけ出す(条件は ProPrompter)。
    /// ほかのシート・ダイアログが出ていれば出さず、次の登録に回す。
    private func offerProIfNeeded() {
      Task { [model, session] in
        await session.proPrompter.onWordRegistered {
          let overlay = model.overlay
          guard overlay.sheet == nil, overlay.dialogs.isEmpty, overlay.pages.isEmpty else { return false }
          MobileProOfferDialog.present(purchase: model.purchase, source: .proPrompt, overlay: overlay)
          return true
        }
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
