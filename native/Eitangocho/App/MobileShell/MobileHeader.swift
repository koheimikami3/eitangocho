#if os(iOS)
  import SwiftUI

  /// iOS 版のヘッダ(Flutter 版の MobileHeader)。ビュー名・件数・🔍・⚙・検索欄・全単語の並び替えの行。
  ///
  /// 🔍 は学習中 / 全単語のときだけ出す(＋ は右下に浮かせる。MobileAddButton)。⚙(設定を開く)はどのタブでも出す(試作)。検索欄は 🔍 で開き、検索語がある間は開いたまま(MainShellModel)。
  /// 下端は線ではなく影で区切る。影はコンテンツの上に落ちるので、シェルがヘッダを前面に置く。
  struct MobileHeader: View {
    let shell: MainShellModel
    let settings: SettingsStore
    let words: WordStore
    let onSettings: () -> Void

    @Environment(\.palette) private var palette
    /// 🔍 の丸と検索欄のガラスを結ぶ(形を変えるアニメーション)。
    @Namespace private var glassNamespace

    private static var titleFontSize: CGFloat { 20 }
    private static var countFontSize: CGFloat { 12 }

    var body: some View {
      let view = shell.view
      let showSearchAndAdd = view == .learning || view == .allWords
      VStack(alignment: .leading, spacing: 0) {
        titleRow(view, showSearchAndAdd: showSearchAndAdd)
          .frame(minHeight: 44)
        if view == .allWords {
          // 並び替えは全単語だけ(学習中は登録順のカード表示のまま)。
          // 右上の 🔍・＋ は 44pt の丸で、Flutter 版の「＋ 登録」の文字のボタンより背が高い。
          // 4pt だと並び替えのボタンと上下に接して見えるので 12pt 空ける。
          sortRow
            .padding(.top, 12)
            .padding(.bottom, 10)
        } else {
          Spacer().frame(height: 8)
        }
      }
      .padding(EdgeInsets(top: 6, leading: AppDimensions.mobilePadding, bottom: 0, trailing: AppDimensions.mobilePadding))
      .background {
        Rectangle()
          .fill(palette.surface)
          .appShadows(palette.headerShadow, in: Rectangle(), scale: 1)
          .ignoresSafeArea(edges: .top)
      }
    }

    /// タイトル・件数と 🔍・＋ の行。検索欄を開いている間は、行ごと検索欄と ✕ に置き換える
    /// (行を増やさず、一覧を下にずらさないため。どの一覧かは下のタブで分かる)。
    /// iOS 26 以降は行全体を 1 つの GlassEffectContainer に入れ、🔍 の丸が検索欄へ形を変えて伸びるようにする。
    @ViewBuilder
    private func titleRow(_ view: MainView, showSearchAndAdd: Bool) -> some View {
      if #available(iOS 26, *) {
        GlassEffectContainer(spacing: MobileHeaderButtons.spacing) {
          titleRowContent(view, showSearchAndAdd: showSearchAndAdd)
        }
      } else {
        titleRowContent(view, showSearchAndAdd: showSearchAndAdd)
      }
    }

    @ViewBuilder
    private func titleRowContent(_ view: MainView, showSearchAndAdd: Bool) -> some View {
      if showSearchAndAdd && shell.isSearchOpen {
        MobileSearchField(shell: shell, namespace: glassNamespace)
      } else {
        HStack(spacing: 8) {
          // 件数はタイトルとベースラインで揃える(上下中央だと小さい件数がタイトルの中ほどに浮く)。
          HStack(alignment: .firstTextBaseline, spacing: 8) {
            AppText(title(view), style: AppTextStyle(size: Self.titleFontSize, weight: .w700))
              .foregroundStyle(palette.text)
              .lineLimit(1)
            if showSearchAndAdd {
              AppText(count(view), style: AppTextStyle(size: Self.countFontSize))
                .foregroundStyle(palette.textAlpha(40))
                .offset(y: countOffset)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          MobileHeaderButtons(
            namespace: glassNamespace, showsSearch: showSearchAndAdd,
            onSearch: { withAnimation(MobileSearchField.toggleAnimation) { shell.openSearch() } }, onSettings: onSettings)
        }
      }
    }

    /// 漢字・かな・ハングルは字面の下端がベースラインより下に出て、その量は字の大きさに比例する。
    /// ベースラインで揃えてもタイトルの方が下まで伸び、件数が上に寄って見えるため、
    /// 和文・繁体字・韓国語の画面では差の分だけ件数を下げる(欧文はベースラインで揃えば足元が揃う)。
    private var countOffset: CGFloat {
      AppFonts.isCjk(AppLocale.current) ? (Self.titleFontSize - Self.countFontSize) * AppFonts.cjkEmBoxDescent : 0
    }

    private func title(_ view: MainView) -> LocalizedStringResource { view.mobileTitle }

    /// 件数はタイトルの脇に小さく出す(学習中 / 全単語のみ。検索で絞り込む前の件数)。
    private func count(_ view: MainView) -> String {
      switch view {
      case .learning: String(localized: .wordCount(WordListing.learning(words.words).count))
      case .allWords: String(localized: .wordCount(words.words.count))
      default: ""
      }
    }

    /// 全単語の並び替えの行。左にブックマークの絞り込みと表示中の件数(検索で絞り込んだ後)、右に現在の並び順のボタン。
    ///
    /// 件数は検索かブックマークで絞り込んでいるときだけ出す。絞り込んでいなければタイトルの脇の件数と同じ数の重複になり、
    /// 検索中はタイトルの行が検索欄に置き換わって、絞り込んだ件数を伝えられるのがここだけになるため。
    /// ブックマークで絞った件数はタイトルの脇の件数(全単語の数)と違うので出す(2026-11-08 のユーザー判断)。
    /// ボタンは縮めず、幅が足りなければ件数の末尾を省略する(長い訳の言語・長い並び順の文言のとき)。
    private var sortRow: some View {
      let query = shell.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
      return HStack(spacing: 8) {
        MobileBookmarksFilterButton(shell: shell)
          .fixedSize()
        if !query.isEmpty || shell.bookmarksOnly {
          let shown = WordListing.filteredAll(
            words.words, query: shell.searchQuery, order: settings.wordSortOrder, bookmarksOnly: shell.bookmarksOnly
          ).count
          AppText(String(localized: .showingWordCount(shown)), style: AppTextStyle(size: 12))
            .foregroundStyle(palette.textAlpha(45))
            .lineLimit(1)
        }
        Spacer(minLength: 0)
        MobileWordSortButton(settings: settings)
          .fixedSize()
      }
    }
  }

  extension MainView {
    /// iOS のヘッダのタイトル(設定の画面の戻るボタンの読み上げにも使う)。
    var mobileTitle: LocalizedStringResource {
      switch self {
      case .learning: .navLearning
      case .allWords: .navAllWords
      // タブ名と揃える(2.18.0)。「フラッシュ」は日本語では馴染みが薄く、4 択を入れるとカードをめくる形だけではなくなるため。
      case .quiz: .navQuizShort
      case .registration: .navRegistration
      case .settings: .navSettings
      }
    }
  }
#endif
