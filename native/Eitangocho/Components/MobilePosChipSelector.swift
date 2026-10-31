#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の品詞選択チップ(複数選択可。Flutter 版の MobilePosChipSelector)。
  ///
  /// 5 つを同じ幅で 1 行に並べる。ラベルが入り切らないとき(英語の adjective や、文字サイズを
  /// 大きくした端末)だけ 3 + 2 の 2 段にする。選択中はその品詞のバッジ色(文字色で縁取り)、未選択は面の色 + 淡い縁。
  struct MobilePosChipSelector: View {
    let selected: Set<PartOfSpeech>
    let onToggle: (PartOfSpeech) -> Void

    @Environment(\.textScale) private var textScale
    @State private var width: CGFloat = 0

    private static var gap: CGFloat { 6 }
    private static var horizontalPadding: CGFloat { 4 }
    private static var borderWidth: CGFloat { 1 }
    /// 1 行に収まらないときの 1 段目の数。残りは 2 段目に同じ幅で左から並べる。
    private static var firstRowCount: Int { 3 }

    var body: some View {
      let values = PartOfSpeech.allCases
      let oneRowWidth = Self.chipWidth(width, count: values.count)
      VStack(alignment: .leading, spacing: Self.gap) {
        if labelsFit(oneRowWidth) {
          row(values[...], chipWidth: oneRowWidth)
        } else {
          let twoRowWidth = Self.chipWidth(width, count: Self.firstRowCount)
          row(values.prefix(Self.firstRowCount), chipWidth: twoRowWidth)
          row(values.dropFirst(Self.firstRowCount), chipWidth: twoRowWidth)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width = $0 }
    }

    /// `count` 個を間隔込みで `width` に並べたときの 1 個の幅。
    private static func chipWidth(_ width: CGFloat, count: Int) -> CGFloat {
      max((width - gap * CGFloat(count - 1)) / CGFloat(count), 0)
    }

    /// すべてのラベルが `chipWidth` のチップに 1 行で収まるか。
    /// 選択中は太字になり幅が増えるので、太字で測る(選んだ途端に段組みが変わらないようにする)。
    private func labelsFit(_ chipWidth: CGFloat) -> Bool {
      let available = chipWidth - (Self.horizontalPadding + Self.borderWidth) * 2
      let style = MobilePosChip.textStyle(selected: true)
      return PartOfSpeech.allCases.allSatisfy {
        style.width(of: String(localized: $0.label), scale: .none, textScale: textScale) <= available
      }
    }

    private func row(_ items: ArraySlice<PartOfSpeech>, chipWidth: CGFloat) -> some View {
      HStack(spacing: Self.gap) {
        ForEach(items, id: \.self) { pos in
          MobilePosChip(pos: pos, isSelected: selected.contains(pos)) { onToggle(pos) }
            .frame(width: chipWidth)
        }
      }
    }
  }

  /// 品詞の選択チップ 1 つ。
  private struct MobilePosChip: View {
    let pos: PartOfSpeech
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    static func textStyle(selected: Bool) -> AppTextStyle {
      AppTextStyle(size: 13, weight: selected ? .w700 : .w500)
    }

    var body: some View {
      let (background, foreground) = pos.badgeColors(palette)
      MobilePressable(action: action) {
        AppText(pos.label, style: Self.textStyle(selected: isSelected))
          .foregroundStyle(isSelected ? foreground : palette.textAlpha(55))
          .lineLimit(1)
          .frame(maxWidth: .infinity)
          .padding(.horizontal, 4 + 1)
          .padding(.vertical, 9 + 1)
          .background(Capsule().fill(isSelected ? background : palette.surface))
          // 選択中は文字色で縁取り、未選択は淡い縁 + 小さな影で「押せる面」に見せる。
          // 縁の濃さは入力欄の枠(AppPalette.wellShadow)と揃える。
          .overlay(Capsule().strokeBorder(isSelected ? foreground : palette.borderAlpha(28), lineWidth: 1))
          .appShadows(
            isSelected ? [] : [AppShadow(color: Color(argb: 0x0F10_1828), blurRadius: 1.5, y: 1)], in: Capsule(),
            scale: 1)
          .animation(.linear(duration: 0.12), value: isSelected)
      }
    }
  }
#endif
