#if os(iOS)
  import SwiftUI

  /// iOS 版のクイズカード(表面 + 答えの面。Flutter 版の MobileQuizCard)。
  ///
  /// 出題中の画面の、上の進み具合と下のボタンの間いっぱいの高さに広げる(2.18.0 の試作)。
  /// カードの位置と大きさを答えの表示や広告の帯の有無で変えず、押す場所を毎回同じにするため。
  /// 答えの前は単語をカードの縦中央に置く。答えを表示したら、単語はカードの上から一定の位置(`frontTop`)へ滑らかに上がり、
  /// 訳と例文はその下へ伸ばす。収まらないときはカードの中でスクロールする。
  /// 答えの後も縦中央のままだと、中身の長さで単語の高さが問題ごとに変わり、そろわなかったため。
  /// 上がる動きは答えを表示するボタンが付ける(MobileActiveQuiz)。
  ///
  /// 発音のボタンは答えを表示してから、カードの右上の角に出す。発音は Google 翻訳で開くため、答えの前に押せると訳が見えてしまう。
  /// 角に置くのは、中央揃えの文字の列に挟むと浮いて見え、英語→訳の向きでは訳の下に来て何の発音か分かりにくかったため。
  /// 向きに関わらず同じ場所なので、押す場所も覚えやすい。
  struct MobileQuizCard: View {
    let front: String
    /// 表面に出す IPA(空なら出さない。ja→en のときは空で渡す)。
    let ipa: String
    let revealed: Bool
    let back: String
    let exampleEn: String
    let exampleTranslation: String
    /// 発音の対象(表裏に関わらず常に英単語)。
    let englishWord: String

    @Environment(\.palette) private var palette
    /// 下にまだ読んでいない中身があるか(カードの下端をぼかして、続きがあると伝える)。
    @State private var moreBelow = false

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 14)
      GeometryReader { geometry in
        ScrollView {
          content
            .padding(.horizontal, 24)
            .padding(.top, revealed ? Self.frontTop : 32)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: revealed ? .top : .center)
            // 発音のボタンは中身と一緒にスクロールさせる(カードに固定すると、長い訳をスクロールしたときに
            // 文字の上に居座って重なるため)。
            .overlay(alignment: .topTrailing) {
              if revealed {
                MobilePronunciationButton(word: englishWord, variant: .large)
                  // 丸がカードの上と右の縁からどちらも 14pt になるようにする(タップ領域 44pt の中に丸 36pt があるため 10)。
                  // 右の縁から 2pt 内側のスクロールバーとも重ならない。
                  .padding(10)
                  // 動かすのはこのボタンだけ。カード全体に .animation を掛けると、答えの表示や次の問題への切り替えで
                  // 文字まで動いてしまうため。次の問題では前の単語のボタンを残さないよう、すぐ消す。
                  .transition(
                    .asymmetric(insertion: .opacity.animation(.easeOut(duration: 0.2)), removal: .identity))
              }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // スクロールバーをカードの角丸から離す(端いっぱいだと、丸い角に沿わず切れて見えたため)。
        .contentMargins(.vertical, 14, for: .scrollIndicators)
        // 右は発音のボタンから離すため、縁に寄せる(4pt では近すぎた)。
        .contentMargins(.trailing, 2, for: .scrollIndicators)
        // スクロールできることを伝える。下に続きがある間は下端の文字を地の色へ溶かす(最後まで読むと消える)。
        // iOS のスクロールバーは動かしている間しか出ず、文字が下端で切れているだけだとカードからはみ出しているように
        // 見えたため。答えの表示でスクロールバーを一瞬出す案も試したが、ぼかしだけで足りた。
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
            .frame(height: Self.fadeHeight)
          }
          .animation(.easeOut(duration: 0.2), value: moreBelow)
        }
      }
      .background(shape.fill(palette.surface))
      .clipShape(shape)
      .appShadows(palette.elevation, in: shape, scale: 1)
    }

    /// 下に続きがあるときに、下端をぼかす高さ。
    private static let fadeHeight: CGFloat = 48

    /// 答えを表示した後の、カードの上端から単語までの高さ。問題が変わっても単語をいつもこの位置に置く。
    static let frontTop: CGFloat = 80

    /// 表面の文字の大きさ。単語は大きく見せ、訳→英語の向きで表に出る長い訳(「収容する,泊める / 対応する」など)は
    /// 画面を占領しないよう段階的に小さくする。
    static func frontSize(_ text: String) -> CGFloat {
      switch text.count {
      case ...12: 34
      case ...30: 26
      default: 22
      }
    }

    private var content: some View {
      VStack(spacing: 0) {
        AppText(front, style: AppTextStyle(size: Self.frontSize(front), weight: .w700))
          .foregroundStyle(palette.text)
        if !ipa.isEmpty {
          Spacer().frame(height: 14)
          AppText(ipa, style: AppTextStyle(size: 16, family: .ipa))
            .foregroundStyle(palette.textAlpha(45))
        }
        if revealed {
          Spacer().frame(height: 20)
          // 区切り線はカード幅いっぱいに引く。線の太さの分は上の余白に足す
          // (Flutter の Container は枠線の幅を内側の余白に足す)。
          AppText(back, style: AppTextStyle(size: 18))
            .foregroundStyle(palette.text)
            .frame(maxWidth: .infinity)
            .padding(.top, 20 + 1)
            .overlay(alignment: .top) {
              Rectangle().fill(palette.rowLine).frame(height: 1)
            }
          if !exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Spacer().frame(height: 16)
            let translation = exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
            AppText(
              translation.isEmpty ? exampleEn : "\(exampleEn)\n\(exampleTranslation)",
              style: AppTextStyle(size: 14, height: 1.6)
            )
            .foregroundStyle(palette.textAlpha(55))
          }
        }
      }
      .multilineTextAlignment(.center)
    }
  }
#endif
