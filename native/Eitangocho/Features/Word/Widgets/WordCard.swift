import EitangochoData
import SwiftUI

/// 学習中の単語カード 1 枚(Flutter 版の WordCard)。
/// 「訳を表示」はカードの中だけの状態で持つ(画面を切り替えたら戻ってよい)。
struct WordCard: View {
  let word: Word
  /// IPA を出すか(設定 showIpa。word.ipa が空なら出さない)。
  let showIpa: Bool
  let meaningLabel: String
  let onToggleLearned: (Bool) -> Void
  let onTap: () -> Void
  /// 右クリックのメニューを開く(押した位置を受け取る)。
  let onContextMenu: (CGPoint) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var revealed = false
  @State private var isHovered = false

  private static let exampleStyle = AppTextStyle(size: 13, height: 1.5)
  /// 英例文は行数差でカードの高さがばらつくため、常に 2 行分の高さを確保する。
  private static let exampleAreaHeight: CGFloat = 13 * 1.5 * 2

  /// ホバー中の影。通常の影に、下へ広く落ちる影を 1 枚足す。
  private var hoverShadow: [AppShadow] {
    colors.elevation + [AppShadow(color: Color(argb: 0x1410_1828), blurRadius: 16, spread: -4, y: 6)]
  }

  var body: some View {
    let hasExample = !word.exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    let shape = RoundedRectangle(cornerRadius: px(AppDimensions.mobileCardRadius))
    VStack(alignment: .leading, spacing: 0) {
      // 単語・IPA・品詞はそれぞれ別の行に積む。単語は省略せず折り返す。
      // IPA は補助情報なので 1 行に留め、溢れる分は末尾を省略する。
      AppText(word.word, style: AppTextStyle(size: 17, weight: .w700))
        .foregroundStyle(colors.textPrimary)
      if showIpa && !word.ipa.isEmpty {
        // 単語との間は下(品詞バッジとの間)より少し広く取り、発音記号が単語に詰まって見えないようにする。
        Spacer().frame(height: px(5))
        AppText(word.ipa, style: AppTextStyle(size: 14, family: .ipa))
          .foregroundStyle(colors.textTertiary)
          .lineLimit(1)
      }
      Spacer().frame(height: px(4))
      PosBadge(partsOfSpeech: word.partsOfSpeech)
      Spacer().frame(height: px(10))
      MeaningRevealArea(meaning: word.meaning, revealed: revealed, showLabel: meaningLabel) {
        revealed.toggle()
      }
      Spacer().frame(height: px(10))
      // 英例文の領域は 2 行分を確保し、超過分は末尾を … で省略する。訳を表示している間は省略しない
      // (例文の訳は全文出るため、英文だけ切れていると突き合わせられない)。確保も訳を隠している間だけにする。
      AppText(hasExample ? word.exampleEn : String(localized: .noExample), style: Self.exampleStyle)
        .foregroundStyle(hasExample ? colors.textAlpha(70) : colors.textDisabled)
        .lineLimit(revealed ? nil : 2)
        .frame(maxWidth: .infinity, minHeight: revealed ? 0 : px(Self.exampleAreaHeight), alignment: .topLeading)
      // 例文の訳が無い単語では欄ごと出さない(空の文字でも 1 行分の高さを取り、例文の下が空く)。
      if hasExample && revealed && !word.exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Spacer().frame(height: px(4))
        AppText(word.exampleTranslation, style: AppTextStyle(size: 12, height: 1.5))
          .foregroundStyle(colors.textAlpha(50))
      }
      Spacer().frame(height: px(10))
      footer
    }
    // 枠線は透明色で常に描く(ホバー時だけ足すと、枠の太さの分だけ中身がずれるため)。
    .padding(px(16 + 1))
    .background(shape.fill(colors.surface))
    .overlay(shape.strokeBorder(isHovered ? colors.accentLine : .clear, lineWidth: px(1)))
    // iOS のカードと同じく枠線なし + 淡い影で浮かせる。ホバーは影を一段足し、薄い青の枠も付ける。
    .appShadows(isHovered ? hoverShadow : colors.elevation, in: shape, scale: px.factor)
    .hoverTap($isHovered, in: shape, action: onTap)
    #if os(macOS)
      .overlay(RightClickArea(action: onContextMenu))
    #endif
  }

  private var footer: some View {
    HStack(spacing: 0) {
      // チェックの操作をカードのクリック(編集)に伝えない。
      HStack(spacing: 0) {
        LearnedCheckbox(value: word.isLearned, onChange: onToggleLearned)
        AppText(.markLearned, style: AppTextStyle(size: 12))
          .foregroundStyle(colors.textSecondary)
      }
      .contentShape(Rectangle())
      .onTapGesture {}
      // チェックは押せる範囲の余白(6)を四辺に持つため、その分だけ左へ出して、
      // 箱の左端を区切り線・本文の左端に揃える。
      .offset(x: px(-6))
      Spacer(minLength: 0)
      PronunciationButton(word: word.word, variant: .cardPill)
    }
    .padding(.top, px(6 + 1))
    .overlay(alignment: .top) {
      Rectangle().fill(colors.borderAlpha(6)).frame(height: px(1))
    }
  }
}
