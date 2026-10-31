#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の学習中カード 1 枚(設定に応じて 1 列 / 2 列に並ぶ。Flutter 版の MobileWordCard)。
  ///
  /// 訳はタップで表示 / 非表示を切り替える。状態はカードの中に持つ(画面を切り替えたら戻ってよい。macOS 版と同じ方針)。
  struct MobileWordCard: View {
    let word: Word
    /// IPA を出すか(設定 showIpa。word.ipa が空なら出さない)。
    let showIpa: Bool
    /// 1 列表示か。ヘッダの組み方だけが変わる(MobileWordCardHeader)。
    let singleColumn: Bool
    let onToggleLearned: (Bool) -> Void
    let onTap: () -> Void

    @Environment(\.palette) private var palette
    @State private var revealed = false

    // 英例文は行数差でカードの高さがばらつくため、常に固定の行数分の高さを確保する(列数によらず 2 行)。
    private static var exampleStyle: AppTextStyle { AppTextStyle(size: 12, height: 1.45) }
    private static var exampleLines: Int { 2 }

    var body: some View {
      let hasExample = !word.exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      MobileRaisedSurface(
        cornerRadius: AppDimensions.mobileCardRadius, padding: EdgeInsets(top: 13, leading: 13, bottom: 13, trailing: 13),
        action: onTap
      ) {
        VStack(alignment: .leading, spacing: 0) {
          MobileWordCardHeader(word: word, showIpa: showIpa && !word.ipa.isEmpty, singleColumn: singleColumn)
          Spacer().frame(height: 8)
          MobileMeaningRevealToggle(
            meaning: word.meaning,
            // この端末の設定ではなく単語自身の訳の言語で文言を決める。
            language: TranslationLanguage.fromStorageCode(word.translationLanguage),
            revealed: revealed
          ) { revealed.toggle() }
          Spacer().frame(height: 8)
          example(hasExample)
          if hasExample && revealed && !word.exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            AppText(word.exampleTranslation, style: AppTextStyle(size: 11, height: 1.45))
              .foregroundStyle(palette.textAlpha(50))
              .padding(.top, 4)
          }
          // フッタ(区切り線 + 覚えた / 発音)は上下の余白を少し詰める(発音ボタンが 30pt あり、8 + 8 だと間延びする)。
          Spacer().frame(height: 6)
          footer
            .padding(.top, 6)
            .overlay(alignment: .top) { Rectangle().fill(palette.rowLine).frame(height: 1) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }

    /// 例文。訳を隠している間は 2 行分の高さを確保し(例文が無くても)、表示中は省略せず確保もしない
    /// (例文の訳は全文出るので、英文だけが途中で切れていると突き合わせられない)。
    private func example(_ hasExample: Bool) -> some View {
      let style = Self.exampleStyle
      let reserved = revealed ? 0 : style.size * (style.height ?? 1) * CGFloat(Self.exampleLines)
      return Group {
        if hasExample {
          AppText(word.exampleEn, style: style)
            .foregroundStyle(palette.textAlpha(70))
            .lineLimit(revealed ? nil : Self.exampleLines)
        }
      }
      .frame(maxWidth: .infinity, minHeight: reserved, alignment: .topLeading)
    }

    private var footer: some View {
      HStack(spacing: 0) {
        // チェックの操作はカードのタップ(編集)に伝えない。
        HStack(spacing: 6) {
          MobileLearnedCheckbox(value: word.isLearned)
          AppText(.rememberedCheck, style: AppTextStyle(size: 11))
            .foregroundStyle(palette.textAlpha(60))
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggleLearned(!word.isLearned) }
        Spacer(minLength: 0)
        MobilePronunciationButton(word: word.word, variant: .icon)
      }
    }
  }

  /// カード上部(単語 + IPA + 品詞バッジ)。列数で組み方が変わる。
  ///
  /// - 2 列: 単語・IPA・バッジをそれぞれ独立した行に積む(収まるときだけ並べると、単語ごとに行数が変わって揃わない)。
  /// - 1 列: 幅に余裕があるので単語と IPA を 1 行に並べ、バッジは次の行に置く(同じ行だと品詞が多いときに IPA が省略される)。
  private struct MobileWordCardHeader: View {
    let word: Word
    let showIpa: Bool
    let singleColumn: Bool

    @Environment(\.palette) private var palette

    /// 単語と IPA の間隔(デザインの column-gap)。
    private static var gap: CGFloat { 7 }

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        if singleColumn {
          HStack(alignment: .firstTextBaseline, spacing: Self.gap) {
            wordText
            if showIpa {
              // 1 列は単語と同じ行に置く都合でベースラインを揃える必要があるため縮小はしない。
              AppText(word.ipa, style: MobileShrinkingIpaText.style(MobileShrinkingIpaText.maxFontSize))
                .foregroundStyle(palette.textAlpha(45))
            }
          }
        } else {
          wordText
          if showIpa {
            // 単語との間は下(品詞チップとの間)より少し広く取り、発音記号が単語に詰まって見えないようにする。
            Spacer().frame(height: 5)
            MobileShrinkingIpaText(ipa: word.ipa)
          }
        }
        Spacer().frame(height: 3)
        MobilePosBadge(partsOfSpeech: word.partsOfSpeech)
      }
    }

    private var wordText: some View {
      AppText(word.word, style: AppTextStyle(size: 16, weight: .w700, height: 1.25))
        .foregroundStyle(palette.text)
    }
  }

  /// 訳の表示 / 非表示の切り替え。未表示は破線の枠、表示中は沈めた面。
  private struct MobileMeaningRevealToggle: View {
    let meaning: String
    let language: TranslationLanguage
    let revealed: Bool
    let onToggle: () -> Void

    @Environment(\.palette) private var palette

    private static var padding: CGFloat { 9 }
    private static var lineHeight: CGFloat { 1.4 }
    private static var meaningFontSize: CGFloat { 13 }
    private static var hintFontSize: CGFloat { 12 }
    private static var radius: CGFloat { 9 }

    /// 訳を 1 行表示したときの外形の高さ(パディング + 1 行)。表示中の枠は内側の影で描くので、枠線の分の高さは無い。
    private static var boxHeight: CGFloat { padding * 2 + meaningFontSize * lineHeight }
    /// 破線の側のパディング。文字が小さいぶんをここで埋め、タップしても高さが変わらないようにする。
    private static var hintPadding: CGFloat { (boxHeight - hintFontSize * lineHeight) / 2 }

    var body: some View {
      Group {
        if revealed {
          MobileWell(
            color: palette.wellBackground, shadows: palette.wellShadow, cornerRadius: Self.radius,
            padding: EdgeInsets(top: Self.padding, leading: Self.padding, bottom: Self.padding, trailing: Self.padding)
          ) {
            // 訳が 2 行に折り返したときに 2 行目だけ中央に寄って見えるため、左揃えにする。
            AppText(meaning, style: AppTextStyle(size: Self.meaningFontSize, height: Self.lineHeight))
              .foregroundStyle(palette.text)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        } else {
          AppText(language.showMeaningShortLabel, style: AppTextStyle(size: Self.hintFontSize, height: Self.lineHeight))
            .foregroundStyle(palette.textAlpha(45))
            .multilineTextAlignment(.center)
            .padding(Self.hintPadding)
            .frame(maxWidth: .infinity)
            .overlay(
              RoundedRectangle(cornerRadius: Self.radius)
                .stroke(palette.borderAlpha(18), style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
        }
      }
      // カードのタップ(編集)には伝えない。
      .contentShape(Rectangle())
      .onTapGesture(perform: onToggle)
    }
  }
#endif
