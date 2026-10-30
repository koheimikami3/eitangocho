import EitangochoData
import SwiftUI

/// 全単語の表の 1 行(Flutter 版の WordTableRow)。
struct WordTableRow: View {
  let word: Word
  let columns: WordTableColumns
  /// 覚えた回数を単語の下に出すか。普段は出さず、覚えた回数で並べているときだけ並びの根拠として見せる。
  let showCorrectCount: Bool
  let onToggleLearned: (Bool) -> Void
  let onTap: () -> Void
  let onContextMenu: (CGPoint) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let hasExample = !word.exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    HStack(alignment: .top, spacing: px(WordTableColumns.gap)) {
      // チェックは押せる範囲の余白(6)を四辺に持つため、その分だけ左上へ出す。箱の左端が
      // 見出しの左端に、箱の上下中央が 1 行目の単語(13px)の中ほどに揃う。
      LearnedCheckbox(value: word.isLearned, onChange: onToggleLearned)
        .offset(x: px(-6), y: px(-6))
        .frame(width: px(WordTableColumns.learned), alignment: .topLeading)
      VStack(alignment: .leading, spacing: 0) {
        AppText(word.word, style: AppTextStyle(size: 13, weight: .w600))
          .foregroundStyle(colors.textPrimary)
        // 単語の列は幅が狭いため、iOS と違い横ではなく下に置く。
        if showCorrectCount {
          Spacer().frame(height: px(2))
          AppText(.correctCount(word.correctCount), style: AppTextStyle(size: 11, weight: .w600))
            .foregroundStyle(colors.accentOnSoft)
        }
      }
      .frame(width: px(WordTableColumns.word), alignment: .leading)
      AppText(word.ipa, style: AppTextStyle(size: 14, family: .ipa))
        .foregroundStyle(colors.textAlpha(50))
        .frame(width: px(WordTableColumns.ipa), alignment: .leading)
      // ピルは文字の幅に収める(列幅は整列のため確保)。
      PosBadge(partsOfSpeech: word.partsOfSpeech)
        .frame(width: px(WordTableColumns.partOfSpeech), alignment: .leading)
      AppText(word.meaning, style: AppTextStyle(size: 13))
        .foregroundStyle(colors.textAlpha(75))
        .frame(width: px(columns.meaning), alignment: .leading)
      Group {
        if hasExample {
          AppText("\(word.exampleEn)\n\(word.exampleTranslation)", style: AppTextStyle(size: 12, height: 1.5))
            .foregroundStyle(colors.textSecondary)
        } else {
          AppText(.noExample, style: AppTextStyle(size: 12))
            .foregroundStyle(colors.textDisabled)
        }
      }
      .frame(width: px(columns.example), alignment: .leading)
      // 行は上揃えなので、28 のボタンをそのまま置くと 13px の文字の行より低く見える。
      // 上下中央を先頭列のチェックの箱に揃えるだけ、見た目だけ引き上げる。
      PronunciationButton(word: word.word, variant: .tableIcon)
        .offset(y: px(-5))
        .frame(width: px(WordTableColumns.pronunciation), alignment: .topLeading)
    }
    .padding(.horizontal, px(WordTableColumns.horizontalPadding))
    .padding(.top, px(10))
    .padding(.bottom, px(10 + 1))
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(isHovered ? colors.rowHoverBackground : word.isLearned ? colors.learnedRowBackground : colors.surface)
    .overlay(alignment: .bottom) {
      Rectangle().fill(colors.borderAlpha(6)).frame(height: px(1))
    }
    .hoverTap($isHovered, in: Rectangle(), action: onTap)
    #if os(macOS)
      .overlay(RightClickArea(action: onContextMenu))
    #endif
  }
}
