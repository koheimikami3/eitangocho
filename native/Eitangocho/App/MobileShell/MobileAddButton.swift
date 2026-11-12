#if os(iOS)
  import SwiftUI

  /// iOS 版の右下に浮かせた ＋(登録シートを開く)。学習中・全単語のタブにだけ出す(試作)。
  ///
  /// 登録はアプリで一番よく使う操作なので、片手で持ったときに親指が届く右下に置く(メモの新規作成と同じ位置)。
  /// 下にはタブバーとバナーがあるので、ヘッダにあったときより少しだけ大きくするにとどめる。
  /// 一覧の最後の行が ＋ に隠れないよう、一覧の側は `clearance` だけ下を空ける。
  struct MobileAddButton: View {
    let action: () -> Void

    static let size: CGFloat = 52
    /// 画面の右端・タブバー(バナー)の上端からの間隔。
    private static let inset: CGFloat = 16
    /// 一覧の下に足す余白(＋ の高さ + 下の間隔)。
    static let clearance: CGFloat = size + inset

    var body: some View {
      MobileGlassCircleButton(
        systemName: "plus", accessibilityLabel: String(localized: .navRegistration), iconSize: 22, size: Self.size,
        prominent: true, action: action
      )
      .padding(Self.inset)
      // キーボード(検索)が出ている間はキーボードの下に隠す(タブバーと同じ)。
      .ignoresSafeArea(.keyboard)
    }
  }
#endif
