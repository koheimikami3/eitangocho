import SwiftUI

/// 全単語のときだけツールバーの検索欄の左に出る並び替えボタン(Flutter 版の WordSortButton)。
///
/// 今の並びを「並び順: ○○ ▾」と文字で出し、押すとメニューで選ばせる。
/// 見た目は青の文字のピル。地は macOS 26 以降は Liquid Glass、それより前は iOS の並び替えボタンと同じ淡い青の地 + 青の縁(Surface)。
struct WordSortButton: View {
  let settings: SettingsStore

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @Environment(\.appOverlay) private var overlay
  @State private var frame = CGRect.zero

  var body: some View {
    HStack(spacing: px(4)) {
      AppText(.sortOrderLabel(settings.wordSortOrder.label), style: AppTextStyle(size: 13, weight: .w600))
        .foregroundStyle(colors.accentOnSoft)
        .lineLimit(1)
      MaterialIconView(.expandMore, size: 16, color: colors.accentOnSoft)
    }
    .padding(.horizontal, px(12 + 1))
    .padding(.vertical, px(7 + 1))
    .modifier(Surface())
    .contentShape(Capsule())
    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
    .onTapGesture(perform: showMenu)
    #if os(macOS)
      .pointerStyle(.link)
    #endif
  }

  /// ボタンの左下(4 下げた位置)にメニューを出す。基準が変わるところにだけ線を入れ、
  /// 昇順・降順を 1 組に見せる。
  private func showMenu() {
    let current = settings.wordSortOrder
    var items: [AppOverlay.MenuItem] = []
    for (index, order) in WordSortOrder.allCases.enumerated() {
      if index > 0 && WordSortOrder.allCases[index - 1].group != order.group { items.append(.divider) }
      items.append(AppOverlay.MenuItem(label: order.label, checked: order == current) { settings.setWordSortOrder(order) })
    }
    overlay?.showMenu(at: CGPoint(x: frame.minX, y: frame.maxY + px(4)), items: items, minWidth: 180)
  }

  /// ピルの地。macOS 26 以降はツールバーのほかの部品と同じ無色の Liquid Glass(文字は青のまま)。
  /// それより前は淡い青の地 + 青の縁。
  private struct Surface: ViewModifier {
    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    func body(content: Content) -> some View {
      if #available(macOS 26, iOS 26, *) {
        content
          .frame(height: px(AppDimensions.toolbarControlHeight))
          .glassEffect(.regular.interactive(), in: .capsule)
      } else {
        content
          .background(Capsule().fill(colors.accentSoft))
          .overlay(Capsule().strokeBorder(colors.accentLine, lineWidth: px(1)))
      }
    }
  }
}
