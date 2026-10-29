import EitangochoData
import SwiftUI

/// 品詞バッジの配色(Flutter 版の PartOfSpeech のライトと AppPalette.posBadge のダーク)。
///
/// バッジ色の決め方:
/// - 色相を 70 度以上離す。紫と青、赤と緑のように色覚特性で潰れる組には
///   さらに明度差を付ける
/// - 出番の多い品詞ほど淡く、まれな品詞ほど濃くする。一覧の大半を占める
///   名詞をいちばん静かな青に、いちばんまれな副詞を紫にしている
/// - 文字は 10〜11px と小さいので、チップ背景に対して 4.5:1 以上を確保する(テストで確かめる)
nonisolated extension PartOfSpeech {
  func badgeColors(_ colors: AppColors) -> (background: Color, foreground: Color) {
    if colors.isDark {
      switch self {
      case .noun: (Color(argb: 0x3D0A_8FD1), Color(argb: 0xFFA4_D8FE))
      case .verb: (Color(argb: 0x3D47_9C4D), Color(argb: 0xFFA1_F7A3))
      case .adjective: (Color(argb: 0x3DCD_605A), Color(argb: 0xFFFF_958E))
      case .adverb: (Color(argb: 0x3DA0_6CC4), Color(argb: 0xFFD3_9DFA))
      case .other: (Color(argb: 0x1FFF_FFFF), Color(argb: 0xFFB7_B7BA))
      }
    } else {
      switch self {
      case .noun: (Color(argb: 0xFFE6_F4FE), Color(argb: 0xFF02_6A9D))
      case .verb: (Color(argb: 0xFFE6_F8E6), Color(argb: 0xFF09_7F23))
      case .adjective: (Color(argb: 0xFFFF_EDEB), Color(argb: 0xFF90_101A))
      case .adverb: (Color(argb: 0xFFF7_EEFE), Color(argb: 0xFF67_298C))
      case .other: (Color(argb: 0xFFEC_ECEF), Color(argb: 0xFF68_696B))
      }
    }
  }

  /// 表示用ラベル
  var label: LocalizedStringResource {
    switch self {
    case .noun: .posNoun
    case .verb: .posVerb
    case .adjective: .posAdjective
    case .adverb: .posAdverb
    case .other: .posOther
    }
  }
}
