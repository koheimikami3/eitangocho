#if os(iOS)
  import SwiftUI

  /// iOS 版の発音確認ボタン(Flutter 版の MobilePronunciationButton)。
  /// 設定に応じて、端末の読み上げで流すか Google 翻訳をアプリ内のシートで開く(押したときの処理は環境値 `openPronunciation`)。
  ///
  /// macOS 版の PronunciationButton と役割は同じだが、ホバー演出とツールチップを持たず、配色を AppPalette から引く。
  struct MobilePronunciationButton: View {
    enum Variant {
      /// 学習中カードのフッタ・全単語リストの行。円形アイコンのみ。
      case icon
      /// クイズカード。ピル + 「発音を聞く」。
      case pill
    }

    let word: String
    let variant: Variant

    @Environment(\.palette) private var palette
    @Environment(\.openPronunciation) private var openPronunciation

    /// アイコンのみの形のタップ領域の幅(Apple のヒューマンインターフェイスガイドラインの 44pt)。
    static let minTapTarget: CGFloat = 44
    /// ピル形の高さ(デザインの min-height:36px)。
    static let pillHeight: CGFloat = 36
    /// アイコンのみの形の円の直径。この形はこの値が高さになる。
    static let circleDiameter: CGFloat = 30

    private static var iconSize: CGFloat { 15 }

    var body: some View {
      MobilePressable(action: { openPronunciation(word) }) {
        switch variant {
        case .icon: iconButton
        case .pill: pillButton
        }
      }
    }

    /// タップ領域は 44pt 幅 × 30pt 高。高さを 44pt にするとカードのフッタが間延びするので幅だけ広げる。
    /// 円はタップ領域の右端に揃える(常に行やフッタの末尾に置かれるため、中央寄せだと左寄りに見える)。
    private var iconButton: some View {
      // 淡い青の地 + 青の細い縁のフラットな丸(地だけだと品詞バッジと同じ見た目になりボタンに見えない)。
      SpeakerIcon(size: Self.iconSize, color: palette.accentOnSoft)
        .frame(width: Self.circleDiameter, height: Self.circleDiameter)
        .background(Circle().fill(palette.accentSoft))
        .overlay(Circle().strokeBorder(palette.accentLine, lineWidth: 1))
        .frame(width: Self.minTapTarget, height: Self.circleDiameter, alignment: .trailing)
    }

    private var pillButton: some View {
      HStack(spacing: 6) {
        SpeakerIcon(size: Self.iconSize, color: palette.accentOnSoft)
        AppText(.listenPronunciation, style: AppTextStyle(size: 13, weight: .w700))
          .foregroundStyle(palette.accentOnSoft)
      }
      .padding(.horizontal, 15)
      .frame(height: Self.pillHeight)
      .background(Capsule().fill(palette.accentSoft))
      .overlay(Capsule().strokeBorder(palette.accentLine, lineWidth: 1))
    }
  }
#endif
