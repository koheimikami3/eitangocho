#if os(iOS)
  import SwiftUI

  /// 全単語の並び順を選ぶシート(iOS。Flutter 版の MobileWordSortSheet)。
  ///
  /// MobileSheet は画面高の 88% 固定で 8 行の選択には大きすぎるため、中身の高さに合わせた枠をここで組む。
  /// 見た目(下端に付けた上角丸・つまみ・ヘッダの区切り線)は登録・編集シートに揃える(ヘッダは MobileSheetHeader)。
  struct MobileWordSortSheet: View {
    let settings: SettingsStore
    let dismiss: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.mobileSheetLayout) private var layout

    var body: some View {
      let orders = WordSortOrder.allCases
      VStack(spacing: 0) {
        MobileSheetHeader(title: String(localized: .sortSheetTitle))
        VStack(spacing: 0) {
          ForEach(Array(orders.enumerated()), id: \.element) { index, order in
            // 基準が変わるところにだけ線を入れ、昇順・降順を 1 組に見せる。
            if index > 0 && orders[index - 1].group != order.group {
              MobileSettingsDivider()
            }
            MobileSettingsRadioRow(label: order.label, selected: order == settings.wordSortOrder) {
              settings.setWordSortOrder(order)
              dismiss()
            }
          }
        }
        .padding(EdgeInsets(top: 4, leading: 2, bottom: 8, trailing: 2))
        // 下端のホームインジケータの分を空ける(Flutter 版の SafeArea(top: false))。
        .padding(.bottom, layout.bottomSafeArea)
      }
      .background(UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18).fill(palette.surface))
    }
  }
#endif
