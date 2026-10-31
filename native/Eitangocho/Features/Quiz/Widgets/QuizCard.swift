import SwiftUI

/// クイズの出題カード(Flutter 版の QuizCard)。進捗・表面・IPA・答えを表示するボタン、
/// 答えを開いた後は区切り線 + 裏面 + 例文を出す。
/// 発音のボタンは答えが分からないよう、英単語が出ている側にだけ置く
/// (en→ja は表面、ja→en は答えの面)。
struct QuizCard: View {
  let progress: String
  let front: String
  /// 表面に出す IPA(空なら出さない。ja→en のときは空で渡す)。
  let ipa: String
  let revealed: Bool
  let back: String
  let exampleEn: String
  let exampleTranslation: String
  /// 発音の対象(表裏に関わらず常に英単語)。
  let englishWord: String
  /// true なら表面(en→ja)、false なら答えの面(ja→en)に発音のボタンを置く。
  let pronunciationOnFront: Bool
  let onReveal: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(spacing: 0) {
      AppText(progress, style: AppTextStyle(size: 12))
        .foregroundStyle(colors.textTertiary)
      Spacer().frame(height: px(16))
      card
      if !revealed {
        Spacer().frame(height: px(16))
        AppFilledButton(
          label: String(localized: .showAnswer), verticalPadding: 11, borderRadius: 9, expands: true,
          action: onReveal)
      }
    }
  }

  private var card: some View {
    let shape = RoundedRectangle(cornerRadius: px(14))
    let hasExample = !exampleEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    return VStack(spacing: 0) {
      AppText(front, style: AppTextStyle(size: 32, weight: .w700))
        .foregroundStyle(colors.textPrimary)
      if !ipa.isEmpty {
        Spacer().frame(height: px(14))
        AppText(ipa, style: AppTextStyle(size: 15, family: .ipa))
          .foregroundStyle(colors.textTertiary)
      }
      if pronunciationOnFront {
        Spacer().frame(height: px(10))
        PronunciationButton(word: englishWord, variant: .quizPill)
      }
      if revealed {
        Spacer().frame(height: px(14))
        // 区切り線はカード幅いっぱいに引く。線の太さの分は上の余白に足す
        // (Flutter の Container は枠線の幅を内側の余白に足す)。
        AppText(back, style: AppTextStyle(size: 18))
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity)
          .padding(.top, px(14 + 1))
          .overlay(alignment: .top) {
            Rectangle().fill(colors.border).frame(height: px(1))
          }
        if !pronunciationOnFront {
          Spacer().frame(height: px(10))
          PronunciationButton(word: englishWord, variant: .quizPill)
        }
        if hasExample {
          Spacer().frame(height: px(10))
          AppText("\(exampleEn)\n\(exampleTranslation)", style: AppTextStyle(size: 13, height: 1.6))
            .foregroundStyle(colors.textSecondary)
        }
      }
    }
    .multilineTextAlignment(.center)
    // 高さの下限 220(余白込み)。中身が低いときは縦の中央に置く。
    .frame(maxWidth: .infinity, minHeight: px(220 - 44 * 2))
    .padding(.horizontal, px(32))
    .padding(.vertical, px(44))
    .background(shape.fill(colors.surface))
    // iOS のクイズカードと同じく枠線なし + 淡い影。
    .appShadows(colors.elevation, in: shape, scale: px.factor)
  }
}
