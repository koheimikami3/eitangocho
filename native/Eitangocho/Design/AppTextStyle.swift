import SwiftUI

/// 文字の書式。Flutter の `TextStyle(fontSize, fontWeight, height, letterSpacing)` と
/// 同じ値を書けば、同じ大きさ・同じ行の高さ・同じベースラインの位置になる。
///
/// Flutter 版の文字は、Scaffold・ダイアログの Material が敷く既定の書式(Material 3 の bodyMedium:
/// 行の高さ 1.43・字間 0.25・行間は上下に均等)を継承している。height・letterSpacing の既定はその値で、
/// Flutter 版で書いてある所だけ書けばよい。継承元が違う所は、その値を書く
/// (メニューの項目は labelLarge = w500・字間 0.1、入力欄は bodyLarge = 行の高さ 1.5・字間 0.5)。
///
/// 値は素の値(倍率を掛ける前)で書く。色は書式に含めず `foregroundStyle` で付ける。
struct AppTextStyle: Hashable, Sendable {
  /// Flutter の FontWeight と同じ名前の太さ。
  enum Weight: Int, Sendable {
    case w300 = 300
    case w400 = 400
    case w500 = 500
    case w600 = 600
    case w700 = 700
    case w800 = 800
  }

  var size: CGFloat
  var weight: Weight = .w400
  /// Flutter の `TextStyle.height`(文字の大きさに対する行の高さの比)。nil はフォントの既定。
  var height: CGFloat?
  var letterSpacing: CGFloat
  var family: AppFonts.Family = .sans

  /// Flutter 版の文字が継承する bodyMedium の行の高さと字間。
  static let inheritedHeight: CGFloat = 1.43
  static let inheritedLetterSpacing: CGFloat = 0.25

  init(
    size: CGFloat, weight: Weight = .w400, height: CGFloat? = inheritedHeight,
    letterSpacing: CGFloat = inheritedLetterSpacing,
    family: AppFonts.Family = .sans
  ) {
    self.size = size
    self.weight = weight
    self.height = height
    self.letterSpacing = letterSpacing
    self.family = family
  }

  /// 倍率を掛けた SwiftUI のフォント(入力欄など AppText を使えない所で使う)。
  func font(_ scale: UIScale) -> Font {
    Font(AppFonts.ctFont(family, size: scale(size), weight: weight.rawValue))
  }

  /// `text` をこの書式で 1 行に組んだときの、Flutter と同じ行の寸法。
  ///
  /// Flutter(SkParagraph)は行に含まれるフォントごとの数値の最大で行を組む。`height` があれば、
  /// フォントごとに行の高さ `size * height` と文字の高さの差を上下に半分ずつ足す(継承した書式の
  /// leadingDistribution が even のため)。代替フォントが混ざる行は、上下それぞれの最大を取るので
  /// `size * height` より少し高くなる。SwiftUI は代替フォントが入っても主のフォントの数値だけで
  /// 行を組むので、その差を上下の余白と行間で埋める(LineLayout)。
  func lineLayout(for text: String, scale: UIScale) -> LineLayout {
    let size = scale(self.size)
    let primary = AppFonts.verticalMetrics(postScriptName: AppFonts.primaryName(family))
    let coverage = AppFonts.coverage(text, family: family)
    var fonts: [AppFonts.VerticalMetrics] = []
    if coverage.primary { fonts.append(primary) }
    if coverage.fallback { fonts.append(AppFonts.fallbackMetrics) }

    let ascent: CGFloat
    let descent: CGFloat
    if let height {
      let lineHeight = size * height
      ascent = fonts.map { (lineHeight + ($0.ascent - $0.descent) * size) / 2 }.max()!
      descent = fonts.map { (lineHeight - ($0.ascent - $0.descent) * size) / 2 }.max()!
    } else {
      ascent = fonts.map { $0.ascent * size }.max()!
      descent = fonts.map { $0.descent * size }.max()!
    }
    let swiftUIAscent = primary.ascent * size
    let swiftUIDescent = primary.descent * size
    return LineLayout(
      top: ascent - swiftUIAscent,
      bottom: descent - swiftUIDescent,
      lineSpacing: (ascent + descent) - (swiftUIAscent + swiftUIDescent),
      lineHeight: ascent + descent
    )
  }

  /// SwiftUI の Text に足す余白と行間。
  struct LineLayout: Equatable {
    /// 1 行目の上に足す量(負なら詰める)
    var top: CGFloat
    /// 最後の行の下に足す量(負なら詰める)
    var bottom: CGFloat
    /// 行と行の間に足す量
    var lineSpacing: CGFloat
    /// Flutter の 1 行の高さ
    var lineHeight: CGFloat
  }
}

/// AppTextStyle で組む文字。Flutter 版の `Text(..., style: TextStyle(...))` に当たる。
///
/// 内容の文字列から行の高さを決める(和文を含むかで Flutter の行の高さが変わる)ので、
/// 文字列を受け取る形にしている。文言は `AppText(.navLearning, style: ...)` で引く。
struct AppText: View {
  private let content: String
  private let style: AppTextStyle
  @Environment(\.uiScale) private var px

  init(_ content: String, style: AppTextStyle) {
    self.content = content
    self.style = style
  }

  init(_ resource: LocalizedStringResource, style: AppTextStyle) {
    self.init(String(localized: resource), style: style)
  }

  var body: some View {
    let layout = style.lineLayout(for: content, scale: px)
    Text(verbatim: content)
      .font(style.font(px))
      .tracking(px(style.letterSpacing))
      // SwiftUI の lineSpacing は負の値を無視する。Flutter の height がフォントの既定より
      // 小さい複数行の文字だけは、行が Flutter より少し広くなる(1 行なら上下の余白で合う)。
      // OS 26 の lineHeight は行の中のベースラインの位置が上の余白の計算と合わないので使わない。
      .lineSpacing(max(layout.lineSpacing, 0))
      .padding(.top, layout.top)
      .padding(.bottom, layout.bottom)
  }
}
