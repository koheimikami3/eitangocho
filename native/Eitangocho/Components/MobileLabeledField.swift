#if os(iOS)
  import SwiftUI

  /// iOS 版のラベル付き入力欄(Flutter 版の MobileLabeledField)。
  ///
  /// `autoFilled` が true のときはラベル脇に「自動入力」バッジを出す(単語登録で辞書から埋まった項目)。
  /// `lineLimit` に範囲を渡すと内容量に応じて欄が伸びる(下限の行数ぶんの高さを確保する)。
  struct MobileLabeledField: View {
    let label: String
    @Binding var text: String
    /// 空欄のときのヒント。nil なら「手動で入力してください」(manualInputHint)。
    var hint: String?
    /// 行数の範囲。nil は 1 行。
    var lineLimit: ClosedRange<Int>?
    var autoFilled = false
    /// 半角英字キーボードに固定するか(英単語・英例文の入力欄)。
    var asciiKeyboard = false
    /// 自動修正・変換候補を出すか。見出し語は入力どおりに保存されるため切るが、
    /// 英例文のような文章は英字キーボードでも補正があった方が打ちやすいため残す。
    var correction = true
    var onSubmit: (() -> Void)?
    var focus: FocusState<Bool>.Binding?

    var body: some View {
      VStack(alignment: .leading, spacing: 5) {
        MobileFieldLabel(label: label, autoFilled: autoFilled)
        // 枠線は引かず、内側の影で沈めた面に置く(立体案)。
        MobileTextField(
          text: $text, hint: hint ?? String(localized: .manualInputHint), lineLimit: lineLimit,
          asciiKeyboard: asciiKeyboard, correction: correction, onSubmit: onSubmit, focus: focus)
      }
    }
  }

  /// MobileLabeledField の入力欄の部分(沈めた面の中の TextField)。
  private struct MobileTextField: View {
    @Binding var text: String
    let hint: String
    let lineLimit: ClosedRange<Int>?
    let asciiKeyboard: Bool
    let correction: Bool
    let onSubmit: (() -> Void)?
    let focus: FocusState<Bool>.Binding?

    @Environment(\.palette) private var palette
    @Environment(\.textScale) private var textScale
    @FocusState private var ownFocus: Bool

    /// iOS で入力欄をタップしたときに拡大されないよう 16px 以上にする。
    /// Flutter の TextField は bodyLarge(行の高さ 1.5・字間 0.5)を継承する。
    private static var textStyle: AppTextStyle { .input(size: 16) }
    private static var verticalPadding: CGFloat { 10 }

    var body: some View {
      let layout = Self.textStyle.lineLayout(for: text.isEmpty ? hint : text, scale: .none, textScale: textScale)
      let prompt = Text(verbatim: hint).foregroundStyle(palette.textAlpha(30))
      MobileWell(color: palette.wellBackground, shadows: palette.wellShadow, cornerRadius: 9) {
        Group {
          if let lineLimit {
            TextField("", text: $text, prompt: prompt, axis: .vertical)
              .lineLimit(lineLimit)
              .lineSpacing(max(layout.lineSpacing, 0))
              // 複数行の欄(訳・例文)も Return キーは「完了」にする。入力するのは 1 文・1 行の内容で、
              // 改行は一覧の表示を崩すだけで要らない。SwiftUI の縦に伸びる欄は Return で改行が入るので、
              // 入った改行を取り除いてキーボードを閉じる(Flutter 版の TextInputAction.done と同じ動き)。
              .submitLabel(.done)
              .onChange(of: text) { _, newValue in
                guard newValue.contains("\n") else { return }
                text = newValue.replacingOccurrences(of: "\n", with: "")
                isFocused.wrappedValue = false
                onSubmit?()
              }
          } else {
            TextField("", text: $text, prompt: prompt)
          }
        }
        .font(Self.textStyle.font(.none, textScale: textScale))
        .tracking(Self.textStyle.letterSpacing)
        .foregroundStyle(palette.text)
        .tint(palette.accent)
        .keyboardType(asciiKeyboard ? .asciiCapable : .default)
        .autocorrectionDisabled(!correction)
        // Flutter の TextField の既定(TextCapitalization.none)と同じく、文頭を大文字にしない。
        .textInputAutocapitalization(.never)
        .focused(isFocused)
        .onSubmit { onSubmit?() }
        .padding(.horizontal, 12)
        // 1 行の欄は行の高さ + 上下の余白の枠の中で上下中央に置く。複数行の欄は下限の行数ぶんを確保し、
        // その外に上下の余白を付ける(Flutter の InputDecorator と同じ高さ)。
        .frame(
          minHeight: lineLimit == nil
            ? layout.lineHeight + Self.verticalPadding * 2
            : layout.lineHeight * CGFloat(lineLimit?.lowerBound ?? 1),
          alignment: lineLimit == nil ? .center : .top
        )
        .padding(.vertical, lineLimit == nil ? 0 : Self.verticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }

    /// 呼び出し側がフォーカスを持たなければ自前のものを使う。
    private var isFocused: FocusState<Bool>.Binding { focus ?? $ownFocus }
  }
#endif
