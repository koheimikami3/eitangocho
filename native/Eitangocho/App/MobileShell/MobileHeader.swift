#if os(iOS)
  import SwiftUI

  /// iOS 版のヘッダ(Flutter 版の MobileHeader)。ビュー名・件数・🔍 と ＋・検索欄・全単語の並び替えの行。
  ///
  /// 🔍・＋ は学習中 / 全単語のときだけ出す。検索欄は 🔍 で開き、検索語がある間は開いたまま(MainShellModel)。
  /// 下端は線ではなく影で区切る。影はコンテンツの上に落ちるので、シェルがヘッダを前面に置く。
  struct MobileHeader: View {
    let shell: MainShellModel
    let settings: SettingsStore
    let words: WordStore
    let onAdd: () -> Void

    @Environment(\.palette) private var palette

    private static var titleFontSize: CGFloat { 20 }
    private static var countFontSize: CGFloat { 12 }

    var body: some View {
      let view = shell.view
      let showSearchAndAdd = view == .learning || view == .allWords
      VStack(alignment: .leading, spacing: 0) {
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
          if showSearchAndAdd {
            MobileHeaderButtons(onSearch: shell.openSearch, onAdd: onAdd)
          }
        }
        .frame(minHeight: 44)
        if showSearchAndAdd && shell.isSearchOpen {
          MobileSearchField(shell: shell)
            .padding(.top, 4)
            .padding(.bottom, 10)
        }
        if view == .allWords {
          // 並び替えは全単語だけ(学習中は登録順のカード表示のまま)。
          // 右上の 🔍・＋ は 44pt の丸で、Flutter 版の「＋ 登録」の文字のボタンより背が高い。
          // 4pt だと並び替えのボタンと上下に接して見えるので、検索欄が閉じているときは 12pt 空ける。
          sortRow
            .padding(.top, shell.isSearchOpen ? 0 : 12)
            .padding(.bottom, 10)
        } else if !(showSearchAndAdd && shell.isSearchOpen) {
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

    /// 漢字・かなは字面の下端がベースラインより下に出て、その量は字の大きさに比例する。
    /// ベースラインで揃えてもタイトルの方が下まで伸び、件数が上に寄って見えるため、
    /// 和文・繁体字の画面では差の分だけ件数を下げる(欧文はベースラインで揃えば足元が揃う)。
    private var countOffset: CGFloat {
      AppFonts.isCjk(AppLocale.current) ? (Self.titleFontSize - Self.countFontSize) * AppFonts.cjkEmBoxDescent : 0
    }

    private func title(_ view: MainView) -> LocalizedStringResource {
      switch view {
      case .learning: .navLearning
      case .allWords: .navAllWords
      case .quiz: .navQuiz
      case .registration: .navRegistration
      case .settings: .navSettings
      }
    }

    /// 件数はタイトルの脇に小さく出す(学習中 / 全単語のみ。検索で絞り込む前の件数)。
    private func count(_ view: MainView) -> String {
      switch view {
      case .learning: String(localized: .wordCount(WordListing.learning(words.words).count))
      case .allWords: String(localized: .wordCount(words.words.count))
      default: ""
      }
    }

    /// 全単語の並び替えの行。左に表示中の件数(検索で絞り込んだ後)、右に現在の並び順のボタン。
    private var sortRow: some View {
      let shown = WordListing.filteredAll(words.words, query: shell.searchQuery, order: settings.wordSortOrder).count
      return HStack(spacing: 8) {
        AppText(String(localized: .showingWordCount(shown)), style: AppTextStyle(size: 12))
          .foregroundStyle(palette.textAlpha(45))
          .frame(maxWidth: .infinity, alignment: .leading)
        MobileWordSortButton(settings: settings)
      }
    }
  }
#endif
