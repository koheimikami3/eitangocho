#if os(macOS)
  import SwiftUI

  /// macOS 版のクイズの入口(2.18.0)。出題元・問題数・向きを選んで始める。
  ///
  /// 構成と決まりは iOS の MobileQuizEntrance と同じ(出題元は 2×2 のタイルに語数を添え、開始ボタンには実際に出せる数を出す。
  /// 選んだ条件は始めたときに覚える。鍵付きの項目(Pro)を押したら Pro 版の案内を出す)。
  /// macOS ではキーでも始められるよう、Return / Enter で開始ボタンと同じ動きをする。
  struct QuizEntrance: View {
    let quiz: QuizModel
    let settings: SettingsStore
    /// 登録が 0 語のときの「単語を登録」。
    let onRegister: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @Environment(\.purchase) private var purchase
    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics
    @FocusState private var focused: Bool

    /// 画面の上で選び直している間の出題元・問題数。始めるまでは保存しない(nil は保存した値を使う)。
    @State private var pickedSource: QuizSource?
    @State private var pickedCount: QuizQuestionCount?

    var body: some View {
      // 購入状態がまだ分からない間(nil)は鍵を掛けず、保存した条件のまま見せる(iOS と同じ)。
      let proUnlocked = purchase.flatMap { $0.isProUnlockedKnown ? $0.proUnlocked : nil }
      let locksPro = proUnlocked == false
      let source = pickedSource ?? quiz.entranceSource(proUnlocked: proUnlocked)
      let count = pickedCount ?? quiz.entranceCount(proUnlocked: proUnlocked)
      if !quiz.hasAnyWords {
        // 登録が 0 語なら、出題元を選んでも出せるものが無いので登録へ案内する。
        VStack(spacing: px(14)) {
          AppText(.quizNoWords, style: AppTextStyle(size: 14, height: 1.7))
            .foregroundStyle(colors.textTertiary)
            .multilineTextAlignment(.center)
          AppFilledButton(label: String(localized: .addWord), fontSize: 13, action: onRegister)
        }
      } else {
        let available = quiz.availableCount(source: source, count: count)
        let start: (() -> Void)? =
          available == 0 ? nil : { quiz.start(source: source, count: count, trigger: .tab) }
        VStack(alignment: .leading, spacing: px(20)) {
          SettingsSection(title: String(localized: .quizSourceHeader)) {
            Grid(horizontalSpacing: px(10), verticalSpacing: px(10)) {
              ForEach([[QuizSource.learning, .learned], [.bookmarks, .all]], id: \.self) { row in
                GridRow {
                  ForEach(row, id: \.self) { option in
                    let lock = locksPro ? option.lockedOption : nil
                    QuizSourceTile(
                      label: String(localized: option.label), count: quiz.wordCount(option),
                      selected: option == source, locked: lock != nil
                    ) {
                      if let lock { offerPro(lock) } else { pickedSource = option }
                    }
                  }
                }
              }
            }
          }
          SettingsSection(title: String(localized: .quizCountHeader)) {
            QuizSegments(
              options: QuizQuestionCount.allCases, selected: count,
              label: { String(localized: $0.label) }, locked: { locksPro && $0.requiresPro }
            ) { option in
              if locksPro, let lock = option.lockedOption {
                offerPro(lock)
              } else {
                pickedCount = option
              }
            }
          }
          SettingsSection(title: String(localized: .quizDirectionHeader)) {
            QuizSegments(
              options: QuizDirection.allCases, selected: settings.quizDirection,
              label: { String(localized: $0.label(settings.translationLanguage)) }, locked: { _ in false }
            ) { settings.setQuizDirection($0) }
          }
          footer(source: source, count: count, available: available, start: start)
        }
        .focusable()
        .focused($focused)
        // キーを受けるためだけの焦点なので、焦点の枠は出さない(出題中と同じ)。
        .focusEffectDisabled()
        .onKeyPress(keys: [.return, KeyEquivalent("\u{03}")], phases: .down) { press in
          guard press.modifiers.isDisjoint(with: [.command, .control, .option, .shift]), let start else {
            return .ignored
          }
          start()
          return .handled
        }
        .onAppear { focused = true }
      }
    }

    /// 開始ボタン。選んだ出題元が空なら押せないボタンにする。全部のときは上に一巡の進み具合を出す。
    @ViewBuilder
    private func footer(
      source: QuizSource, count: QuizQuestionCount, available: Int, start: (() -> Void)?
    ) -> some View {
      let progress = count == .all ? quiz.cycleProgress(source) : nil
      VStack(spacing: px(10)) {
        if let progress, progress.done < progress.total {
          AppText(.quizCycleProgress(progress.done, progress.total), style: AppTextStyle(size: 12))
            .foregroundStyle(colors.textMuted)
        }
        // 0 語なら同じ位置・大きさの押せないボタンにする(出題元を切り替えても始める場所が変わらない。iOS と同じ)。
        if let start {
          AppFilledButton(
            label: String(localized: .quizStartCount(available)), verticalPadding: 11, borderRadius: 9,
            expands: true, action: start)
        } else {
          AppText(.quizSourceEmpty, style: AppTextStyle(size: 14, weight: .w600, height: 1.4))
            .foregroundStyle(colors.disabledButtonForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, px(11))
            .background(RoundedRectangle(cornerRadius: px(9)).fill(colors.disabledButton))
        }
      }
      .frame(maxWidth: .infinity)
    }

    private func offerPro(_ option: QuizLockedOption) {
      analytics.logQuizOptionLockedTapped(option)
      ProOfferDialog.present(purchase: purchase, source: .quiz, overlay: overlay)
    }
  }

  /// 出題元のタイル。選んでいるものはアクセントの淡い地 + アクセントの枠、それ以外は面の色 + 影(iOS と同じ)。
  /// 選んでいないものはホバーで枠を薄く出し、押せることを分からせる。
  private struct QuizSourceTile: View {
    let label: String
    let count: Int
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(AppDimensions.mobileCardRadius))
      VStack(alignment: .leading, spacing: px(6)) {
        HStack(spacing: px(6)) {
          AppText(label, style: AppTextStyle(size: 15, weight: .w600))
            .foregroundStyle(selected ? colors.accentOnSoft : colors.textPrimary)
            .lineLimit(1)
          Spacer(minLength: 0)
          if locked {
            QuizLockMark()
          }
        }
        AppText(.quizWordCount(count), style: AppTextStyle(size: 12))
          .foregroundStyle(selected ? colors.accentOnSoft.opacity(0.75) : colors.textTertiary)
      }
      .padding(px(14))
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(shape.fill(selected ? colors.accentSoft : colors.surface))
      .overlay(
        shape.strokeBorder(
          selected ? colors.accentLine : isHovered ? colors.borderStrong : .clear, lineWidth: px(selected ? 1.5 : 1)))
      .appShadows(selected ? [] : colors.elevation, in: shape, scale: px.factor)
      .hoverTap($isHovered, in: shape, action: action)
      .pointerStyle(.link)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
  }

  /// 入口の横並びの選択肢(問題数・向き)。iOS の MobileQuizSegments と同じ見た目(白い溝 + 影に、
  /// 選んだ項目へ滑る淡いアクセント色のつまみ)。鍵付きの項目には鍵を添える。
  private struct QuizSegments<Option: Hashable>: View {
    let options: [Option]
    let selected: Option
    let label: (Option) -> String
    let locked: (Option) -> Bool
    let action: (Option) -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @Namespace private var thumb

    var body: some View {
      HStack(spacing: 0) {
        ForEach(Array(options.enumerated()), id: \.element) { index, option in
          let isSelected = option == selected
          // 区切り線は選んでいない項目どうしの間にだけ出し、つまみに接する所では消す(iOS と同じ)。
          let showsDivider = index > 0 && !isSelected && options[index - 1] != selected
          QuizSegment(label: label(option), selected: isSelected, locked: locked(option)) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { action(option) }
          }
          .background {
            if isSelected {
              let shape = RoundedRectangle(cornerRadius: px(8))
              // accentSoft は半透明なので、先に画面の背景色で塗ってから重ねる(iOS と同じ)。
              shape.fill(colors.background)
                .overlay(shape.fill(colors.accentSoft))
                .overlay(shape.strokeBorder(colors.accentLine, lineWidth: px(1.5)))
                .matchedGeometryEffect(id: "thumb", in: thumb)
            }
          }
          .overlay(alignment: .leading) {
            Rectangle()
              .fill(colors.borderAlpha(15))
              .frame(width: px(1), height: px(16))
              .opacity(showsDivider ? 1 : 0)
          }
        }
      }
      .padding(px(4))
      .background {
        let track = RoundedRectangle(cornerRadius: px(11))
        track.fill(colors.surface)
          .appShadows(colors.elevation, in: track, scale: px.factor)
      }
    }
  }

  /// 切り替えの 1 項目。選んでいないものはホバーで文字を濃くする。
  /// 文字の色は即座に切り替える(文字までアニメーションさせると遅れて見えるため。iOS と同じ)。
  private struct QuizSegment: View {
    let label: String
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      HStack(spacing: px(4)) {
        AppText(label, style: AppTextStyle(size: 13, weight: .w600))
          .lineLimit(1)
        if locked {
          QuizLockMark()
        }
      }
      .foregroundStyle(selected ? colors.accentOnSoft : colors.textAlpha(isHovered ? 75 : 55))
      .transaction { $0.animation = nil }
      .frame(maxWidth: .infinity)
      .padding(.vertical, px(8))
      .hoverTap($isHovered, in: Rectangle(), action: action)
      .pointerStyle(.link)
      .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
  }

  /// Pro の項目の鍵(タイルと切り替えで共通)。
  private struct QuizLockMark: View {
    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      Image(systemName: "lock.fill")
        .font(.system(size: px(10), weight: .semibold))
        .foregroundStyle(colors.textQuaternary)
    }
  }
#endif
