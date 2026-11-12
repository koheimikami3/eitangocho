#if os(iOS)
  import SwiftUI

  /// iOS 版の読み込み中の印。テーマカラーの淡い輪の上を、端の丸い短い弧が回る。
  ///
  /// iOS の読み込み中はどこもこれに揃える(MobileLoadingIndicator・辞書の取得中・広告の待ち・同期・購入の処理中)。
  /// Flutter 版から引き継いだ灰色の輪 + 角張った 3/4 の弧は重く機械的に見え、iOS 標準のインジケーターは
  /// アプリの見た目になじまなかったため、輪をテーマカラーの淡色にし、弧を短く端を丸くした(2026-11-12 のユーザー判断)。
  /// macOS は CircularProgress の既定の形のまま。
  struct MobileSpinner: View {
    var size: CGFloat = Self.regularSize
    var lineWidth: CGFloat = 3
    /// 弧と輪の色。nil ならテーマカラー(色の付いたボタンの上では白を渡す)。
    var color: Color?

    @Environment(\.palette) private var palette

    /// 領域の中央に置く大きさ。
    static let regularSize: CGFloat = 32
    /// 行やボタンの中に置く大きさ。
    static let smallSize: CGFloat = 16

    var body: some View {
      let tint = color ?? palette.accent
      CircularProgress(
        color: tint, size: size, lineWidth: lineWidth, trackColor: tint.opacity(0.16), arcLength: 0.2, lineCap: .round,
        period: 0.9)
    }
  }

  extension MobileSpinner {
    /// 行やボタンの中に置く小さい形。
    static func small(color: Color? = nil) -> MobileSpinner {
      MobileSpinner(size: smallSize, lineWidth: 2, color: color)
    }
  }
#endif
