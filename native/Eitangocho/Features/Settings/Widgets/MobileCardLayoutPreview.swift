#if os(iOS)
  import SwiftUI

  /// 「学習中カードの並び」の選択肢に添える小さな見本(Flutter 版の MobileCardLayoutPreview)。
  /// カードに見立てた枠を列数のぶんだけ並べる(2 列は細い枠 2 つ、1 列は太い枠 1 つ)。
  struct MobileCardLayoutPreview: View {
    let layout: LearningCardLayout

    @Environment(\.palette) private var palette

    private static var height: CGFloat { 16 }
    private static var gap: CGFloat { 2 }
    private static var totalWidth: CGFloat { 24 }

    var body: some View {
      let columns = layout.columns
      // どの選択肢でも全体の幅を揃える(枠の数だけ変える)。
      let width = (Self.totalWidth - Self.gap * CGFloat(columns - 1)) / CGFloat(columns)
      HStack(spacing: Self.gap) {
        ForEach(0..<columns, id: \.self) { _ in
          RoundedRectangle(cornerRadius: 2)
            .strokeBorder(palette.textAlpha(30), lineWidth: 1.5)
            .frame(width: width, height: Self.height)
        }
      }
    }
  }
#endif
