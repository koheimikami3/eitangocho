#if os(iOS)
  import SwiftUI

  /// iOS 版のクイズカード(表面 + 答えの面。Flutter 版の MobileQuizCard)。
  ///
  /// 発音のボタンは答えが分からないよう、英単語が出ている側にだけ置く
  /// (`pronunciationOnFront` が表面 = 英単語かどうか)。
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
    /// 表面が英単語の側か(false なら答えの面に発音のボタンを置く)。
    let pronunciationOnFront: Bool

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 14)
      VStack(spacing: 0) {
        AppText(front, style: AppTextStyle(size: 28, weight: .w700))
          .foregroundStyle(palette.text)
        if !ipa.isEmpty {
          Spacer().frame(height: 14)
          AppText(ipa, style: AppTextStyle(size: 15, family: .ipa))
            .foregroundStyle(palette.textAlpha(45))
        }
        // 発音のボタンは IPA の下に置く(macOS 版の QuizCard と揃える)。
        if pronunciationOnFront {
          Spacer().frame(height: 8)
          MobilePronunciationButton(word: englishWord, variant: .pill)
        }
        if revealed {
          Spacer().frame(height: 14)
          // 区切り線はカード幅いっぱいに引く。線の太さの分は上の余白に足す
          // (Flutter の Container は枠線の幅を内側の余白に足す)。
          AppText(back, style: AppTextStyle(size: 17))
            .foregroundStyle(palette.text)
            .frame(maxWidth: .infinity)
            .padding(.top, 14 + 1)
            .overlay(alignment: .top) {
              Rectangle().fill(palette.rowLine).frame(height: 1)
            }
          if !pronunciationOnFront {
            Spacer().frame(height: 8)
            MobilePronunciationButton(word: englishWord, variant: .pill)
          }
          if !exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Spacer().frame(height: 14)
            let translation = exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
            AppText(
              translation.isEmpty ? exampleEn : "\(exampleEn)\n\(exampleTranslation)",
              style: AppTextStyle(size: 13, height: 1.6)
            )
            .foregroundStyle(palette.textAlpha(55))
          }
        }
      }
      .multilineTextAlignment(.center)
      // 高さの下限 220(余白込み)。中身が低いときは縦の中央に置く。
      .frame(maxWidth: .infinity, minHeight: 220 - 40 * 2)
      .padding(.horizontal, 24)
      .padding(.vertical, 40)
      .background(shape.fill(palette.surface))
      .appShadows(palette.elevation, in: shape, scale: 1)
    }
  }
#endif
