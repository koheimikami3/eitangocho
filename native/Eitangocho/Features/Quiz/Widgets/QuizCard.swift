#if os(macOS)
  import SwiftUI

  /// macOS 版のクイズカード(表面 + 答えの面)。作りは iOS の MobileQuizCard と同じ(2.18.0 でそろえた)。
  ///
  /// 高さは固定(`height`)。答えの表示や中身の長さでカードとボタンの位置を変えず、押す場所を毎回同じにするため
  /// (それまでは中身に合わせて伸び、答えを表示するたびに下のボタンが動いていた)。
  /// 答えの前は単語をカードの縦中央に置き、答えを表示したら単語は上から一定の位置(`frontTop`)へ滑らかに上がり、
  /// 訳と例文はその下へ伸ばす。収まらないときはカードの中でスクロールし、下に続きがある間は下端をぼかす。
  ///
  /// 発音のボタンは答えを表示してから、カードの右上の角に出す(発音は Google 翻訳で開くため、答えの前に押せると
  /// 訳が見えてしまう。iOS と同じ)。
  struct QuizCard: View {
    let front: String
    /// 表面に出す IPA(空なら出さない。ja→en のときは空で渡す)。
    let ipa: String
    let revealed: Bool
    let back: String
    let exampleEn: String
    let exampleTranslation: String
    /// 発音の対象(表裏に関わらず常に英単語)。
    let englishWord: String

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    /// 下にまだ読んでいない中身があるか(カードの下端をぼかして、続きがあると伝える)。
    @State private var moreBelow = false

    /// カードの高さ。ウィンドウの最小の高さ(700)でも、上の案内と下のボタンと合わせて収まる大きさにする
    /// (380 では小さく見えたため一回り大きくした)。
    static let height: CGFloat = 440

    /// 答えを表示した後の、カードの上端から単語までの高さ(iOS と同じ)。
    static let frontTop: CGFloat = 80

    /// 下に続きがあるときに、下端をぼかす高さ。
    private static let fadeHeight: CGFloat = 48

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(14))
      GeometryReader { geometry in
        ScrollView {
          content
            .padding(.horizontal, px(24))
            .padding(.top, px(revealed ? Self.frontTop : 32))
            .padding(.bottom, px(32))
            .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: revealed ? .top : .center)
            // 発音のボタンは中身と一緒にスクロールさせる(カードに固定すると、長い訳の上に重なるため。iOS と同じ)。
            .overlay(alignment: .topTrailing) {
              if revealed {
                PronunciationButton(word: englishWord, variant: .quizIcon)
                  .padding(px(14))
                  // 動かすのはこのボタンだけ。次の問題では前の単語のボタンを残さないよう、すぐ消す。
                  .transition(
                    .asymmetric(insertion: .opacity.animation(.easeOut(duration: 0.2)), removal: .identity))
              }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // スクロールバーをカードの角丸から離す(iOS と同じ)。
        .contentMargins(.vertical, px(14), for: .scrollIndicators)
        .onScrollGeometryChange(for: Bool.self) { scroll in
          scroll.contentOffset.y + scroll.containerSize.height < scroll.contentSize.height - 1
        } action: { _, isMore in
          moreBelow = isMore
        }
        .mask {
          VStack(spacing: 0) {
            Rectangle()
            LinearGradient(
              colors: [.black, .black.opacity(moreBelow ? 0 : 1)], startPoint: .top, endPoint: .bottom
            )
            .frame(height: px(Self.fadeHeight))
          }
          .animation(.easeOut(duration: 0.2), value: moreBelow)
        }
      }
      .frame(height: px(Self.height))
      .background(shape.fill(colors.surface))
      .clipShape(shape)
      // iOS のクイズカードと同じく枠線なし + 淡い影。
      .appShadows(colors.elevation, in: shape, scale: px.factor)
    }

    /// 表面の文字の大きさ。長い訳(訳→英語の向き)は段階的に小さくする(iOS の MobileQuizCard.frontSize と同じ)。
    private static func frontSize(_ text: String) -> CGFloat {
      switch text.count {
      case ...12: 34
      case ...30: 26
      default: 22
      }
    }

    private var content: some View {
      VStack(spacing: 0) {
        AppText(front, style: AppTextStyle(size: Self.frontSize(front), weight: .w700))
          .foregroundStyle(colors.textPrimary)
        if !ipa.isEmpty {
          Spacer().frame(height: px(14))
          AppText(ipa, style: AppTextStyle(size: 16, family: .ipa))
            .foregroundStyle(colors.textTertiary)
        }
        if revealed {
          Spacer().frame(height: px(20))
          // 区切り線はカード幅いっぱいに引く。線の太さの分は上の余白に足す。
          AppText(back, style: AppTextStyle(size: 18))
            .foregroundStyle(colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.top, px(20 + 1))
            .overlay(alignment: .top) {
              Rectangle().fill(colors.rowLine).frame(height: px(1))
            }
          if !exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Spacer().frame(height: px(16))
            let translation = exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
            AppText(
              translation.isEmpty ? exampleEn : "\(exampleEn)\n\(exampleTranslation)",
              style: AppTextStyle(size: 14, height: 1.6)
            )
            .foregroundStyle(colors.textSecondary)
          }
        }
      }
      .multilineTextAlignment(.center)
    }
  }
#endif
