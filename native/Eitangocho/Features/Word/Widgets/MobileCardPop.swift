#if os(iOS)
  import SwiftUI

  /// 登録したばかりのカードを弾むように出し、まわりに波紋を添える演出(iOS の学習中のカード)。
  ///
  /// 登録の達成感を出して次の登録の後押しにする。続けて何語も登録する人の邪魔にならないよう、
  /// 0.6 秒ほどで終わる控えめな動きにする(保存の 1 秒後に出る Pro の案内・レビュー依頼とも重ねない)。
  /// 飾りは四隅へ飛ぶ線・飾りなしと見比べて、カードの形に沿って主張の弱い波紋に決めた(2026-11-08 のユーザー判断)。
  /// 「視差効果を減らす」の人には出さない(カードは CardIn のふわっと出る動きだけになる)。
  struct MobileCardPop: ViewModifier {
    /// このカードが今回登録した単語か。
    let active: Bool

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1
    /// 波紋の進み具合(0 で見えない → 1 で外へ広がって消える)。nil の間は描かない。
    @State private var ripple: CGFloat?

    /// シートが閉じきるのを待つ(AppOverlay.sheetExit の 0.2 秒)。閉じる途中だとシートの裏で終わってしまう。
    private static let startDelay: Duration = .milliseconds(200)

    func body(content: Content) -> some View {
      content
        .scaleEffect(scale)
        .overlay {
          if let ripple {
            // 色はテーマカラー(palette.accent)。テーマカラーやライト / ダークを変えればそのまま変わる。
            MobileCardRipple(progress: ripple, color: palette.accent)
              .allowsHitTesting(false)
          }
        }
        // 波紋が右・下のカードの裏に隠れないよう、前に出す。
        .zIndex(active ? 1 : 0)
        .onAppear { if active { play() } }
        .onChange(of: active) { _, isActive in if isActive { play() } }
    }

    private func play() {
      guard !reduceMotion else { return }
      // シートの裏にいる間に小さくしておき、閉じきったら弾ませる。
      scale = 0.85
      ripple = 0
      Task { @MainActor in
        try? await Task.sleep(for: Self.startDelay)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { scale = 1 }
        withAnimation(.easeOut(duration: 0.5)) { ripple = 1 }
        try? await Task.sleep(for: .milliseconds(550))
        ripple = nil
      }
    }
  }

  /// カードと同じ角丸の細い枠が、カードの外へ広がりながら薄れて消える波紋。`progress` を 0 → 1 に動かす。
  /// 毎フレーム描き直すよう Animatable にする(始めと終わりの見た目を補間するだけだと、どちらも見えないため)。
  private struct MobileCardRipple: View, Animatable {
    var progress: CGFloat
    let color: Color

    var animatableData: CGFloat {
      get { progress }
      set { progress = newValue }
    }

    var body: some View {
      // カードの縁から 1pt 外で始まり、7pt 外まで広がる。角丸も広がった分だけ大きくして、形をカードに沿わせる。
      let distance = 1 + 6 * progress
      // 最初の 15% で現れ、あとは消えていく。
      let peak = progress < 0.15 ? progress / 0.15 : (1 - progress) / 0.85
      RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius + distance)
        .stroke(color.opacity(progress > 0 && progress < 1 ? peak * Self.maxOpacity : 0), lineWidth: 1.25)
        .padding(-distance)
    }

    /// 枠のいちばん濃いときの不透明度。主役はカードの弾みなので、薄く添えるだけにする。
    private static let maxOpacity: CGFloat = 0.35
  }
#endif
