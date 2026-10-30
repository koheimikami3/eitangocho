import EitangochoData
import SwiftUI

/// 品詞の複数選択チップ(横並び・折り返し)。Flutter 版の PosChipSelector。
struct PosChipSelector: View {
  let selected: Set<PartOfSpeech>
  let onToggle: (PartOfSpeech) -> Void

  @Environment(\.uiScale) private var px

  var body: some View {
    FlowLayout(spacing: px(8), runSpacing: px(8)) {
      ForEach(PartOfSpeech.allCases, id: \.self) { pos in
        PosChip(pos: pos, isSelected: selected.contains(pos)) { onToggle(pos) }
      }
    }
  }
}

/// 品詞の選択チップ 1 つ。
struct PosChip: View {
  let pos: PartOfSpeech
  let isSelected: Bool
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    // 選択中は品詞バッジと同じ配色にし、文字色で縁取る(iOS のチップと揃える)。
    let (background, foreground) = pos.badgeColors(colors)
    // 選択しても太さは変えない。チップは文字の幅に合わせて伸び縮みする
    // ため、太字にすると押すたびに幅が変わって並びがずれる(選択は配色と縁取りで示す)。
    AppText(pos.label, style: AppTextStyle(size: 12, weight: .w600))
      .foregroundStyle(isSelected ? foreground : colors.textAlpha(65))
      .padding(.horizontal, px(14 + 1))
      .padding(.vertical, px(5 + 1))
      .background(Capsule().fill(isSelected ? background : colors.surface))
      .overlay(Capsule().strokeBorder(isSelected ? foreground : colors.inputBorder, lineWidth: px(1)))
      .contentShape(Capsule())
      .onTapGesture(perform: action)
  }
}
