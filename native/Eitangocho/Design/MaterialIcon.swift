import SwiftUI

/// Flutter 版の `Icons.xxx`(Material Icons)と同じ字形のアイコン。
///
/// 輪郭は Flutter SDK の MaterialIcons フォントから tool/material_icon_paths.py で
/// 抜き出したもの(MaterialIconPaths.swift)。SF Symbols で代用すると字形が変わるため。
enum MaterialIcon: Sendable {
  case check
  case expandMore
  case search
  case volumeUp
}

/// Flutter の `Icon(icon, size:, color:)` に当たる。`size` は素の値(倍率はここで掛ける)。
struct MaterialIconView: View {
  let icon: MaterialIcon
  let size: CGFloat
  let color: Color
  @Environment(\.uiScale) private var px

  init(_ icon: MaterialIcon, size: CGFloat, color: Color) {
    self.icon = icon
    self.size = size
    self.color = color
  }

  var body: some View {
    MaterialIconShape(icon: icon)
      .fill(color, style: FillStyle(eoFill: false))
      .frame(width: px(size), height: px(size))
  }
}

/// 一辺 1 の輪郭を、与えられた矩形に広げて描く。
nonisolated struct MaterialIconShape: Shape {
  let icon: MaterialIcon

  func path(in rect: CGRect) -> Path {
    SVGPathParser.path(icon.svgPath)
      .applying(CGAffineTransform(scaleX: rect.width, y: rect.height))
      .offsetBy(dx: rect.minX, dy: rect.minY)
  }
}

/// fontTools の SVGPathPen が書くパス(M / L / H / V / C / Q / Z と、命令を省いた繰り返し)を読む。
nonisolated enum SVGPathParser {
  static func path(_ data: String) -> Path {
    var path = Path()
    var tokens = tokenize(data)[...]
    var command: Character = "M"
    var current = CGPoint.zero

    func number() -> CGFloat {
      guard case .number(let value) = tokens.popFirst() else { return 0 }
      return value
    }
    func point() -> CGPoint { CGPoint(x: number(), y: number()) }

    while let token = tokens.first {
      if case .command(let next) = token {
        command = next
        tokens.removeFirst()
        if next == "Z" {
          path.closeSubpath()
          continue
        }
      }
      switch command {
      case "M":
        current = point()
        path.move(to: current)
        // M に続く座標の繰り返しは L として扱う(SVG の規則)。
        command = "L"
      case "L":
        current = point()
        path.addLine(to: current)
      case "H":
        current.x = number()
        path.addLine(to: current)
      case "V":
        current.y = number()
        path.addLine(to: current)
      case "C":
        let control1 = point()
        let control2 = point()
        current = point()
        path.addCurve(to: current, control1: control1, control2: control2)
      case "Q":
        let control = point()
        current = point()
        path.addQuadCurve(to: current, control: control)
      default:
        tokens.removeFirst()
      }
    }
    return path
  }

  private enum Token {
    case command(Character)
    case number(CGFloat)
  }

  private static func tokenize(_ data: String) -> [Token] {
    var tokens: [Token] = []
    var buffer = ""
    func flush() {
      if let value = Double(buffer) { tokens.append(.number(CGFloat(value))) }
      buffer = ""
    }
    for character in data {
      if character.isLetter && character != "e" {
        flush()
        tokens.append(.command(character))
      } else if character == " " || character == "," {
        flush()
      } else if character == "-" && !buffer.isEmpty && buffer.last != "e" {
        flush()
        buffer.append(character)
      } else {
        buffer.append(character)
      }
    }
    flush()
    return tokens
  }
}
