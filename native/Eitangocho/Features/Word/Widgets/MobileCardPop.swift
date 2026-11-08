#if os(iOS)
  import SwiftUI

  /// 登録したばかりのカードを弾むように出す演出(iOS の学習中のカード)。
  ///
  /// 登録の達成感を出して次の登録の後押しにする。続けて何語も登録する人の邪魔にならないよう、
  /// 0.5 秒ほどで終わる控えめな動きにする(保存の 1 秒後に出る Pro の案内・レビュー依頼とも重ねない)。
  /// 飾り(四隅へ飛ぶ線・波紋・淡く光って戻る形)も試したうえで、弾む動きだけにした(2026-11-09 のユーザー判断)。
  /// 「視差効果を減らす」の人には出さない(カードは CardIn のふわっと出る動きだけになる)。
  struct MobileCardPop: ViewModifier {
    /// このカードが今回登録した単語か。
    let active: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1

    /// シートが閉じきるのを待つ(AppOverlay.sheetExit の 0.2 秒)。閉じる途中だとシートの裏で終わってしまう。
    private static let startDelay: Duration = .milliseconds(200)

    func body(content: Content) -> some View {
      content
        .scaleEffect(scale)
        // 弾んで 1 倍を少し超える間、右・下のカードの裏に隠れないよう前に出す。
        .zIndex(active ? 1 : 0)
        .onAppear { if active { play() } }
        .onChange(of: active) { _, isActive in if isActive { play() } }
    }

    private func play() {
      guard !reduceMotion else { return }
      // シートの裏にいる間に小さくしておき、閉じきったら弾ませる。
      scale = 0.85
      Task { @MainActor in
        try? await Task.sleep(for: Self.startDelay)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { scale = 1 }
      }
    }
  }
#endif
