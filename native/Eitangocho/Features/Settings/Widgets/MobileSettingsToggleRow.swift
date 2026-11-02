#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のトグルの行(ラベル + OS のスイッチ)。行全体がタップ領域。
  ///
  /// スイッチは自前で描かず OS の `Toggle` を使う。OS の版に合った形(iOS 26 の横長の形など)と
  /// ドラッグでの切り替え・読み上げでのオン / オフが、そのまま手に入るため。
  struct MobileSettingsToggleRow: View {
    let label: String
    let value: Bool
    let onChanged: (Bool) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity, alignment: .leading)
        Toggle(label, isOn: Binding(get: { value }, set: onChanged))
          .labelsHidden()
          .tint(palette.accent)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
      // スイッチ以外(ラベルや余白)を押しても切り替える。スイッチ自身のタップはスイッチが受けるので二重にはならない。
      .onTapGesture { onChanged(!value) }
    }
  }
#endif
