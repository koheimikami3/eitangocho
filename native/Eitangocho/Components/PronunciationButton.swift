import SwiftUI

/// 発音確認ボタン(Flutter 版の PronunciationButton)。押すと設定に応じて、端末の読み上げで流すか
/// Google 翻訳を別ウィンドウで開く。
///
/// 押したときの処理は環境値 `openPronunciation` で受け取る(ウィンドウと読み上げを持つのはアプリの側のため)。
/// 自身がクリックを消費するため、カード・行のクリック(編集)には伝わらない。
struct PronunciationButton: View {
  /// 置かれる場所ごとの形。
  enum Variant {
    /// 学習中カードのフッタ。高さ 26 のピル + 「発音」。
    case cardPill
    /// 全単語テーブルの発音列。28×28 の円のアイコンのみ。
    case tableIcon
    /// クイズカード。高さ 32 のピル + 「発音を聞く」。
    case quizPill

    /// ピルの高さ / アイコンボタンの一辺。
    var height: CGFloat {
      switch self {
      case .cardPill: 26
      case .tableIcon: 28
      case .quizPill: 32
      }
    }

    var iconSize: CGFloat { self == .cardPill ? 13 : 15 }

    /// ラベル。アイコンのみの形は nil。
    var label: LocalizedStringResource? {
      switch self {
      case .cardPill: .pronunciationShort
      case .tableIcon: nil
      case .quizPill: .listenPronunciation
      }
    }

    var fontSize: CGFloat { self == .cardPill ? 12 : 13 }

    /// アイコンのみは正方形にするため、左右の余白を持たない。
    var horizontalPadding: CGFloat {
      switch self {
      case .cardPill: 10
      case .tableIcon: 0
      case .quizPill: 14
      }
    }

    var gap: CGFloat {
      switch self {
      case .cardPill: 5
      case .tableIcon: 0
      case .quizPill: 6
      }
    }
  }

  let word: String
  let variant: Variant

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @Environment(\.openPronunciation) private var openPronunciation
  @Environment(\.pronunciationMethod) private var pronunciationMethod
  @State private var isHovered = false

  var body: some View {
    // すべて丸(ラベル付きはピル、アイコンのみは円。iOS の発音ボタンと形を揃えた)。
    let button = HStack(spacing: px(variant.gap)) {
      SpeakerIcon(size: variant.iconSize, color: colors.accentOnSoft)
      if let label = variant.label {
        AppText(label, style: AppTextStyle(size: variant.fontSize, weight: .w600))
          .foregroundStyle(colors.accentOnSoft)
      }
    }
    .padding(.horizontal, px(variant.horizontalPadding + 1))
    .frame(width: variant.label == nil ? px(variant.height) : nil, height: px(variant.height))
    .background(Capsule().fill(isHovered ? colors.accentSoftHover : colors.accentSoft))
    .overlay(Capsule().strokeBorder(isHovered ? colors.accentLineHover : colors.accentLine, lineWidth: px(1)))
    .hoverTap($isHovered, in: Capsule()) { openPronunciation(word) }
    #if os(macOS)
      .pointerStyle(.link)
    #endif

    // ラベルが無い形は用途が読めないため、説明を出す(「Google 翻訳で確認」は読み上げのときには合わないので出し分ける)。
    if variant.label == nil {
      let tooltip: LocalizedStringResource =
        pronunciationMethod == .deviceSpeech ? .listenPronunciation : .pronunciationTooltip
      button.help(Text(tooltip))
    } else {
      button
    }
  }
}

extension EnvironmentValues {
  /// 発音確認を開く(単語を受け取る)。アプリのルートで差し込む。
  @Entry var openPronunciation: @MainActor (String) -> Void = { _ in }
  /// 今の発音の確かめ方(ボタンの説明の出し分け用)。アプリのルートで設定から配る。
  @Entry var pronunciationMethod: PronunciationMethod = .googleTranslate
}
