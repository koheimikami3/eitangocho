#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の全単語リストの 1 行(Flutter 版の MobileWordRow)。
  ///
  /// macOS 版は 8 列の表だが iPhone の幅では成り立たないため、チェック / 単語 + IPA + 品詞・訳 / 発音 の 1 行にまとめる。
  struct MobileWordRow: View {
    let word: Word
    let showIpa: Bool
    /// 覚えた回数を訳の下の行に出すか(覚えた回数で並べているときだけ、並びの根拠として見せる)。
    var showCorrectCount = false
    let onToggleLearned: (Bool) -> Void
    let onTap: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(style: .row, action: onTap) { pressed in
        HStack(spacing: 0) {
          // チェックの操作は行のタップ(編集)に伝えない。
          MobileLearnedCheckbox(value: word.isLearned)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .onTapGesture { onToggleLearned(!word.isLearned) }
          Spacer().frame(width: 12)
          VStack(alignment: .leading, spacing: 3) {
            // 品詞は IPA の後ろに続けて置き、訳の行は幅いっぱいを使わせる(訳の横だと品詞が多いほど訳が省略される)。
            // 単語・IPA と並ばないときは品詞だけ次の行に回す。右寄せにしないのは、次の行に回ったときに位置が飛ぶため。
            FlowLayout(spacing: 8, runSpacing: 3, centersInRow: true) {
              MobileWordAndIpa(word: word.word, ipa: showIpa && !word.ipa.isEmpty ? word.ipa : nil)
              MobilePosBadge(partsOfSpeech: word.partsOfSpeech)
            }
            AppText(word.meaning, style: AppTextStyle(size: 13))
              .foregroundStyle(palette.textAlpha(60))
              .lineLimit(1)
            // 単語の横に並べると単語の長さ次第で位置が揃わないため、常に独立した行にする。
            if showCorrectCount {
              AppText(.correctCount(word.correctCount), style: AppTextStyle(size: 11, weight: .w600))
                .foregroundStyle(palette.accentOnSoft)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          Spacer().frame(width: 8)
          MobilePronunciationButton(word: word.word, variant: .icon)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
        .background(pressed ? palette.pressBackground : word.isLearned ? palette.surfaceHeader : palette.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(palette.rowLine).frame(height: 1) }
      }
    }
  }

  /// 単語と IPA を 1 行に並べる。行の幅に収まらないときは、単語は省略せず(長ければ折り返す)、
  /// 補助情報の IPA を末尾から省略する。横幅は中身の分だけ取る(品詞を同じ行に並べられるかの判定に使うため)。
  private struct MobileWordAndIpa: View {
    let word: String
    /// nil なら IPA を出さない。
    let ipa: String?

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(alignment: .firstTextBaseline, spacing: 7) {
        AppText(word, style: AppTextStyle(size: 15, weight: .w600))
          .foregroundStyle(palette.text)
          // 単語の幅を先に確定させて、残りを IPA に渡す。
          .layoutPriority(1)
        if let ipa {
          AppText(ipa, style: AppTextStyle(size: 13, family: .ipa))
            .foregroundStyle(palette.textAlpha(45))
            .lineLimit(1)
        }
      }
    }
  }
#endif
