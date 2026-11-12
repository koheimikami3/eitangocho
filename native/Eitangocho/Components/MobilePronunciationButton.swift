#if os(iOS)
  import SwiftUI

  /// iOS 版の発音確認ボタン(Flutter 版の MobilePronunciationButton)。
  /// Google 翻訳をアプリ内のシートで開く(開く処理は環境値 `openPronunciation`)。
  ///
  /// macOS 版の PronunciationButton と役割は同じだが、ホバー演出とツールチップを持たず、配色を AppPalette から引く。
  struct MobilePronunciationButton: View {
    enum Variant {
      /// 学習中カードのフッタ・全単語リストの行。円形アイコンのみ。
      case icon
      /// クイズカードの右上の角。一回り大きい円形アイコンのみ。
      /// 以前は答えの下に置いた「発音を聞く」の文字付きのピルだったが、答えのカードで唯一の色付きの部品として
      /// 訳より先に目に入ったため、アイコンだけにして主張を抑えた(スピーカーで音が出ると分かり、学習中のカードもアイコンだけのため)。
      case large
    }

    let word: String
    let variant: Variant
    /// アイコンのみの形のタップ領域の幅。左隣に別のボタンが並ぶとき(全単語の行の 🔖)は、
    /// 丸の左の余白をその間の分だけに詰め、隣のボタンとタップ領域が重ならないようにする。
    var iconTapWidth: CGFloat = minTapTarget

    @Environment(\.palette) private var palette
    @Environment(\.openPronunciation) private var openPronunciation

    /// アイコンのみの形のタップ領域の幅(Apple のヒューマンインターフェイスガイドラインの 44pt)。
    static let minTapTarget: CGFloat = 44
    /// アイコンのみの形の円の直径。この形はこの値が高さになる。
    static let circleDiameter: CGFloat = 30
    /// クイズカードの円の直径。カードに 1 つだけ置くので、行やフッタの円より一回り大きくする。
    static let largeCircleDiameter: CGFloat = 36

    private static var iconSize: CGFloat { 15 }

    var body: some View {
      MobilePressable(action: { openPronunciation(word) }) {
        switch variant {
        case .icon: iconButton
        case .large: largeButton
        }
      }
      // アイコンだけなので、読み上げには何のボタンかを言葉で伝える。
      .accessibilityLabel(Text(.listenPronunciation))
    }

    /// タップ領域は既定で 44pt 幅 × 30pt 高。高さを 44pt にするとカードのフッタが間延びするので幅だけ広げる。
    /// 円はタップ領域の右端に揃える(常に行やフッタの末尾に置かれるため、中央寄せだと左寄りに見える)。
    private var iconButton: some View {
      // 淡い青の地 + 青の細い縁のフラットな丸(地だけだと品詞バッジと同じ見た目になりボタンに見えない)。
      SpeakerIcon(size: Self.iconSize, color: palette.accentOnSoft)
        .frame(width: Self.circleDiameter, height: Self.circleDiameter)
        .background(Circle().fill(palette.accentSoft))
        .overlay(Circle().strokeBorder(palette.accentLine, lineWidth: 1))
        .frame(width: iconTapWidth, height: Self.circleDiameter, alignment: .trailing)
    }

    /// 見た目は iconButton と同じ作りで、円とアイコンを一回り大きくする。タップ領域は 44pt 四方。
    private var largeButton: some View {
      SpeakerIcon(size: 17, color: palette.accentOnSoft)
        .frame(width: Self.largeCircleDiameter, height: Self.largeCircleDiameter)
        .background(Circle().fill(palette.accentSoft))
        .overlay(Circle().strokeBorder(palette.accentLine, lineWidth: 1))
        .frame(width: Self.minTapTarget, height: Self.minTapTarget)
    }
  }
#endif
