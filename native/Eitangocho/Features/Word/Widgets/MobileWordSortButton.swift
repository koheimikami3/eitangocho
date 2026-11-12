#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダの並び替えボタン(全単語のときだけ出す。Flutter 版の MobileWordSortButton)。
  ///
  /// 現在の並び順をラベルにしたピル形。どの順で並んでいるかがボタンを見るだけで分かるので、
  /// 既定以外のときに色で知らせる必要は無い。
  /// 地はヘッダの 🔍・⚙、左のブックマークと同じガラスにし、色は付けない(試作。アクセント色を付けると、
  /// 右下の ＋ と青が競うため)。
  /// 押すと OS 標準のメニューで並び順を選ぶ(試作)。8 つから 1 つ選ぶだけなので、下からせり上がるシートより
  /// 押した所に開くメニューの方が軽く、ファイル・メモなどの並び替えとも同じ作法になる。
  struct MobileWordSortButton: View {
    let settings: SettingsStore

    @Environment(\.palette) private var palette

    /// メニューの区切り。基準(登録日・アルファベット・学習状態・正解数)ごとにまとめ、昇順・降順を 1 組に見せる。
    private static let sections: [[WordSortOrder]] = WordSortOrder.allCases.reduce(into: []) { result, order in
      if let last = result.last?.last, last.group == order.group {
        result[result.count - 1].append(order)
      } else {
        result.append([order])
      }
    }

    var body: some View {
      Menu {
        // 区切りは Section で付ける。Picker(.inline)に入れると Section が平らにならされて線が出ないため、
        // 項目は Toggle にしてメニュー標準のチェックで選んでいるものを示す。
        ForEach(Self.sections, id: \.self) { section in
          Section {
            ForEach(section, id: \.self) { order in
              Toggle(isOn: isSelected(order)) {
                Text(order.label)
              }
            }
          }
        }
      } label: {
        // 開くことを示す下向きの矢印は付けない(先頭の並び替えのアイコンと飾りが重なるため。押せることはピル形で分かる)。
        let content = HStack(spacing: 6) {
          MaterialIconView(.sort, size: 14, color: palette.text)
          AppText(settings.wordSortOrder.label, style: AppTextStyle(size: 12, weight: .w700))
            .foregroundStyle(palette.text)
        }
        .padding(.horizontal, 14)
        // 高さは左のブックマークの丸と揃える。
        .frame(height: MobileBookmarksFilterButton.diameter)
        if #available(iOS 26, *) {
          content.glassEffect(.regular.interactive(), in: .capsule)
        } else {
          // iOS 18 はガラスが無いので、🔍 などの丸と同じく面の色をカードと同じ影で浮かせる。
          content
            .background(Capsule().fill(palette.surface))
            .appShadows(palette.elevation, in: Capsule(), scale: 1)
        }
      }
    }

    /// その並び順を選んでいるか。選んだら並び順を切り替える(選んでいるものを押し直しても外れない)。
    private func isSelected(_ order: WordSortOrder) -> Binding<Bool> {
      Binding(get: { settings.wordSortOrder == order }, set: { _ in settings.setWordSortOrder(order) })
    }
  }
#endif
