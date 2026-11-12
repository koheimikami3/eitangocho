#if os(iOS)
  import SwiftUI

  /// iOS 版のクイズの入口(2.18.0)。出題元・問題数・向きを選んで始める。
  ///
  /// 選ぶ項目が少ないので 1 画面にすべて並べ、別の画面へは分けない。出題元の各行に語数を出し、
  /// 何が出るのかを数で分からせる。開始ボタンには実際に出せる数を出す(学習中が 7 語なら「7問で始める」)。
  /// 選んだ条件は始めたときに覚え、次に開いたときはその状態から始まる(QuizModel.start(source:count:trigger:))。
  /// 鍵付きの項目(Pro)を押したら、テーマカラーと同じ Pro の案内を出す。
  struct MobileQuizEntrance: View {
    let quiz: QuizModel
    let settings: SettingsStore
    let onRegister: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.purchase) private var purchase
    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics

    /// 画面の上で選び直している間の出題元・問題数。始めるまでは保存しない(nil は保存した値を使う)。
    @State private var pickedSource: QuizSource?
    @State private var pickedCount: QuizQuestionCount?

    private static let tileColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
      // 購入状態がまだ分からない間(nil)は鍵を掛けず、保存した条件のまま見せる(テーマカラーと同じ)。
      // 分からないのを未購入として扱うと、Pro の人が読み込み前に始めたとき、保存した条件が無料の値で上書きされるため。
      let proUnlocked = purchase.flatMap { $0.isProUnlockedKnown ? $0.proUnlocked : nil }
      let locksPro = proUnlocked == false
      let source = pickedSource ?? quiz.entranceSource(proUnlocked: proUnlocked)
      let count = pickedCount ?? quiz.entranceCount(proUnlocked: proUnlocked)
      if !quiz.hasAnyWords {
        // 登録が 0 語なら、出題元を選んでも出せるものが無いので登録へ案内する。
        MobileLearningEmptyState(message: .quizNoWords, onRegister: onRegister)
      } else {
        VStack(spacing: 20) {
          // 出題元は 2×2 のタイル(試作)。名前・語数・鍵を 1 枚に載せ、縦を詰めて入口がスクロールなしで収まりやすくする。
          MobileQuizEntranceGroup(title: String(localized: .quizSourceHeader)) {
            LazyVGrid(columns: Self.tileColumns, spacing: 10) {
              ForEach(QuizSource.allCases, id: \.self) { option in
                let lock = locksPro ? option.lockedOption : nil
                MobileQuizSourceTile(
                  label: String(localized: option.label), count: quiz.wordCount(option), selected: option == source,
                  locked: lock != nil
                ) {
                  if let lock { offerPro(lock) } else { pickedSource = option }
                }
              }
            }
          }
          MobileQuizEntranceGroup(title: String(localized: .quizCountHeader)) {
            MobileQuizSegments(
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
          MobileQuizEntranceGroup(title: String(localized: .quizDirectionHeader)) {
            MobileQuizSegments(
              options: QuizDirection.allCases, selected: settings.quizDirection,
              label: { String(localized: $0.label(settings.translationLanguage)) }, locked: { _ in false }
            ) { settings.setQuizDirection($0) }
          }
          footer(source: source, count: count)
        }
      }
    }

    /// 開始ボタン。選んだ出題元が空なら押せないボタンにする。全部のときは上に一巡の進み具合を出す。
    /// 入口は上寄せなので、ここの高さが変わっても上の部品は動かない。
    @ViewBuilder
    private func footer(source: QuizSource, count: QuizQuestionCount) -> some View {
      let available = quiz.availableCount(source: source, count: count)
      let progress = count == .all ? quiz.cycleProgress(source) : nil
      VStack(spacing: 10) {
        if let progress, progress.done < progress.total {
          AppText(.quizCycleProgress(progress.done, progress.total), style: AppTextStyle(size: 12))
            .foregroundStyle(palette.textAlpha(50))
        }
        // 0 語なら同じ位置・大きさの押せないボタンにする(出題元を切り替えても下が動かず、始める場所が変わらない)。
        // 文言は 1 行の短いものだけ。理由はタイルの「0語」で分かる。
        MobileFilledButton(
          label: String(localized: available == 0 ? .quizSourceEmpty : .quizStartCount(available)), expands: true,
          action: available == 0 ? nil : { quiz.start(source: source, count: count, trigger: .tab) })
      }
    }

    private func offerPro(_ option: QuizLockedOption) {
      analytics.logQuizOptionLockedTapped(option)
      if let purchase {
        MobileProOfferDialog.present(purchase: purchase, source: .quiz, overlay: overlay)
      }
    }
  }

  /// 出題元のタイル。選んでいるものはアクセントの淡い地 + アクセントの枠、それ以外は面の色 + 影。
  private struct MobileQuizSourceTile: View {
    let label: String
    let count: Int
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius)
      MobilePressable(style: .card, action: action) {
        VStack(alignment: .leading, spacing: 6) {
          HStack(spacing: 6) {
            AppText(label, style: AppTextStyle(size: 15, weight: .w600))
              .foregroundStyle(selected ? palette.accentOnSoft : palette.text)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            if locked {
              // 切り替えの鍵と同じ、小さなグレーの鍵。アクセント色の丸だと、選べない印が選んでいるタイルより目立つため。
              MobileQuizLockMark()
            }
          }
          AppText(.quizWordCount(count), style: AppTextStyle(size: 12))
            .foregroundStyle(selected ? palette.accentOnSoft.opacity(0.75) : palette.textAlpha(45))
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(selected ? palette.accentSoft : palette.surface))
        .overlay(shape.strokeBorder(selected ? palette.accentLine : .clear, lineWidth: 1.5))
        .appShadows(selected ? [] : palette.elevation, in: shape, scale: 1)
      }
      .accessibilityAddTraits(selected ? .isSelected : [])
    }
  }

  /// 入口の横並びの選択肢(問題数・向き)。設定のカードの中に置く。鍵付きの項目には鍵を添える。
  private struct MobileQuizSegments<Option: Hashable>: View {
    let options: [Option]
    let selected: Option
    let label: (Option) -> String
    let locked: (Option) -> Bool
    let action: (Option) -> Void

    @Environment(\.palette) private var palette
    @Namespace private var thumb

    var body: some View {
      // 切り替え(試作): 選んだ項目へつまみが滑って動く。出題元のタイルと同じ見分け方にする:
      // 溝はタイルの選んでいないものと同じ白い面 + 影、つまみは「選んでいる」タイルと同じ淡いアクセント色の地 +
      // アクセント色の枠・文字(グレーの溝 + 白や淡い青のつまみは、タイルと見分け方が食い違って見えた)。
      // 濃いアクセント色のつまみは開始ボタンの青と競ったため使わず、濃い色は押して進む開始ボタンだけにする。
      // 文字の太さは全項目で揃え、選んだ項目は濃い文字・それ以外は薄い文字で分ける。選んだ項目だけ太くすると、
      // 矢印や空白(欧文の書体)の幅が太さで変わり、切り替えるたびに文字が左右にずれて見えたため。
      // 動かすのはつまみだけで、文字の色は即座に切り替える(文字までアニメーションさせると遅れて見えるため)。
      HStack(spacing: 0) {
        ForEach(Array(options.enumerated()), id: \.element) { index, option in
          let isSelected = option == selected
          // 区切り線は選んでいない項目どうしの間にだけ出し、つまみに接する所では消す(iOS 標準と同じ)。
          let showsDivider = index > 0 && !isSelected && options[index - 1] != selected
          HStack(spacing: 4) {
            AppText(label(option), style: AppTextStyle(size: 13, weight: .w600))
              .lineLimit(1)
              .minimumScaleFactor(0.8)
            if locked(option) {
              MobileQuizLockMark()
            }
          }
          .foregroundStyle(isSelected ? palette.accentOnSoft : palette.textAlpha(55))
          .transaction { $0.animation = nil }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background {
            if isSelected {
              let shape = RoundedRectangle(cornerRadius: 8)
              // accentSoft は半透明で、溝のグレーに直接重ねると灰色がかって濁るため、先に画面の背景色で
              // 塗ってから重ねる(タイルと同じく背景の上に淡い色を敷いた色になる)。
              shape.fill(palette.background)
                .overlay(shape.fill(palette.accentSoft))
                .overlay(shape.strokeBorder(palette.accentLine, lineWidth: 1.5))
                .matchedGeometryEffect(id: "thumb", in: thumb)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { action(option) }
          }
          .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
          .overlay(alignment: .leading) {
            Rectangle()
              .fill(palette.borderAlpha(15))
              .frame(width: 1, height: 16)
              .opacity(showsDivider ? 1 : 0)
          }
        }
      }
      .padding(4)
      .background {
        // 溝はタイルの選んでいないものと同じ面の色 + 影(白い面は背景の薄いグレーとの差が小さく、影が無いとぼやけるため)。
        let track = RoundedRectangle(cornerRadius: 11)
        track.fill(palette.surface)
          .appShadows(palette.elevation, in: track, scale: 1)
      }
    }
  }

  /// Pro の項目の鍵(タイルと切り替えで共通)。
  private struct MobileQuizLockMark: View {
    @Environment(\.palette) private var palette

    var body: some View {
      Image(systemName: "lock.fill")
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(palette.textAlpha(40))
    }
  }

  /// 入口の欄(見出し + 中身)。切り替えはカードに載せず、見出しの下にそのまま置く。
  private struct MobileQuizEntranceGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        AppText(title, style: AppTextStyle(size: 12, weight: .w700))
          .foregroundStyle(palette.textAlpha(50))
          .padding(.horizontal, AppDimensions.mobileCardRadius)
        content()
      }
    }
  }
#endif
