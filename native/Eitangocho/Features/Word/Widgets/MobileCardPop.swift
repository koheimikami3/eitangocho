#if os(iOS)
  import SwiftUI

  /// 登録したばかりのカードを弾むように出し、まわりへ短い線を飛ばして振動させる演出(iOS の学習中のカード)。
  ///
  /// 登録の達成感を出して次の登録の後押しにする。続けて何語も登録する人の邪魔にならないよう、
  /// 0.6 秒ほどで終わる控えめな動きにする(保存の 1 秒後に出る Pro の案内・レビュー依頼とも重ねない)。
  /// 飾りは波紋・淡く光って戻る形・弾む動きだけも試したうえで、四隅と四辺へ飛ぶ 8 本の線に戻した(2026-11-12 のユーザー判断)。
  /// 「視差効果を減らす」の人には動きを出さない(カードは CardIn のふわっと出る動きだけになる)。
  /// 振動は動きではないので、その人にも同じように出す(動きが無くても登録できたことが伝わるように)。
  struct MobileCardPop: ViewModifier {
    /// このカードが今回登録した単語か。
    let active: Bool

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1
    /// 線の進み具合(0 で縁に重なって見えない → 1 で外へ飛んで消える)。nil の間は描かない。
    @State private var burst: CGFloat?
    /// 振動の合図。増やすたびに 1 回振動する(sensoryFeedback は値の変化で鳴るため)。
    @State private var feedbackCount = 0

    /// シートが閉じきるのを待つ(AppOverlay.sheetExit の 0.2 秒)。閉じる途中だとシートの裏で終わってしまう。
    private static let startDelay: Duration = .milliseconds(200)

    func body(content: Content) -> some View {
      content
        .scaleEffect(scale)
        .overlay {
          if let burst {
            // 色はテーマカラー(palette.accent)。テーマカラーやライト / ダークを変えればそのまま変わる。
            MobileCardBurst(progress: burst, color: palette.accent)
              .allowsHitTesting(false)
          }
        }
        // 線が右・下のカードの裏に隠れないよう、前に出す。
        .zIndex(active ? 1 : 0)
        // 「カチッ」と一度だけの振動。軽い(light)では弱くて気付きにくかったため中くらいにする。
        // 強い(heavy)は続けて何語も登録すると重たく感じるため使わない。
        .sensoryFeedback(.impact(weight: .medium), trigger: feedbackCount)
        .onAppear { if active { play() } }
        .onChange(of: active) { _, isActive in if isActive { play() } }
    }

    private func play() {
      let animates = !reduceMotion
      if animates {
        // シートの裏にいる間に小さくしておき、閉じきったら弾ませる。
        scale = 0.85
        burst = 0
      }
      Task { @MainActor in
        try? await Task.sleep(for: Self.startDelay)
        // 振動はカードが弾み始めるのと同時に出す(動きと手の感触を揃える)。
        feedbackCount += 1
        guard animates else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { scale = 1 }
        withAnimation(.easeOut(duration: 0.55)) { burst = 1 }
        try? await Task.sleep(for: .milliseconds(600))
        burst = nil
      }
    }
  }

  /// カードの四隅と四辺から外へ飛ぶ短い線。`progress` を 0 → 1 に動かすと、外へ進みながら短く薄くなって消える。
  /// 毎フレーム描き直すよう Animatable にする(始めと終わりの見た目を補間するだけだと、どちらも見えないため)。
  private struct MobileCardBurst: View, Animatable {
    var progress: CGFloat
    let color: Color

    var animatableData: CGFloat {
      get { progress }
      set { progress = newValue }
    }

    var body: some View {
      Canvas { context, size in
        guard progress > 0, progress < 1 else { return }
        // 最初の 15% で現れ、あとは消えていく。
        let peak = progress < 0.15 ? progress / 0.15 : (1 - progress) / 0.85
        let opacity = peak * Self.maxOpacity
        // 描く面はカードより reach だけ広いので、カードの半分の大きさは広げた分を引いて求める。
        let half = CGSize(width: size.width / 2 - Self.reach, height: size.height / 2 - Self.reach)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        // 四隅へは中心から角へ向かう向きに、四辺の中ほどからは辺に垂直に飛ばす(計 8 本)。
        // 角の線は角の丸みの外から出るよう、角から少し離す。
        let toCorner = (half.width * half.width + half.height * half.height).squareRoot()
        let corners = [(-1.0, -1.0), (1.0, -1.0), (-1.0, 1.0), (1.0, 1.0)].map { sx, sy in
          (dx: sx * half.width / toCorner, dy: sy * half.height / toCorner, toEdge: toCorner)
        }
        let sides: [(dx: CGFloat, dy: CGFloat, toEdge: CGFloat)] = [
          (0, -1, half.height), (0, 1, half.height),
          (-1, 0, half.width), (1, 0, half.width),
        ]
        for (dx, dy, toEdge) in corners + sides {
          // 縁から 4pt 離れたところから 18pt まで進み、長さは 6pt → 2pt に縮む
          // (気付かれないほど控えめだったため、太く濃くして遠くまで飛ばす。長すぎると線が主張するので長さは控えめ)。
          let inner = toEdge + 4 + 14 * progress
          let length = 6 - 4 * progress
          var path = Path()
          path.move(to: CGPoint(x: center.x + dx * inner, y: center.y + dy * inner))
          path.addLine(to: CGPoint(x: center.x + dx * (inner + length), y: center.y + dy * (inner + length)))
          context.stroke(
            path, with: .color(color.opacity(opacity)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
      }
      // 線はカードの外に描くので、描ける範囲をカードより広げる。
      .padding(-Self.reach)
    }

    /// 線がカードの外へ届く最大の距離(4 + 14 + 6 と線の太さの余裕)。
    private static let reach: CGFloat = 28
    /// 線のいちばん濃いときの不透明度。0.85 では少し主張が強かったため、気付ける範囲で一段薄くする。
    private static let maxOpacity: CGFloat = 0.7
  }
#endif
