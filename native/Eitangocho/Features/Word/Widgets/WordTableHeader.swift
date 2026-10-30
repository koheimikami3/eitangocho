import SwiftUI

/// 全単語の表の見出しの行(Flutter 版の WordTableHeader)。列幅は WordTableColumns と揃える。
struct WordTableHeader: View {
  let columns: WordTableColumns
  let meaningLabel: String

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    HStack(spacing: px(WordTableColumns.gap)) {
      cell(String(localized: .tableLearned), width: WordTableColumns.learned)
      cell(String(localized: .tableWord), width: WordTableColumns.word)
      cell(String(localized: .tableIpa), width: WordTableColumns.ipa)
      cell(String(localized: .tablePartOfSpeech), width: WordTableColumns.partOfSpeech)
      cell(meaningLabel, width: columns.meaning)
      cell(String(localized: .tableExample), width: columns.example)
      cell(String(localized: .tablePronunciation), width: WordTableColumns.pronunciation)
    }
    .padding(.horizontal, px(WordTableColumns.horizontalPadding))
    .padding(.top, px(8))
    .padding(.bottom, px(8 + 1))
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(colors.tableHeaderBackground)
    .overlay(alignment: .bottom) {
      Rectangle().fill(colors.borderStrong).frame(height: px(1))
    }
  }

  private func cell(_ text: String, width: CGFloat) -> some View {
    AppText(text, style: AppTextStyle(size: 11, weight: .w700))
      .foregroundStyle(colors.textTertiary)
      .frame(width: px(width), alignment: .leading)
  }
}
