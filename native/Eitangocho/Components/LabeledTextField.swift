import SwiftUI

/// ラベル付き入力欄。Flutter 版の LabeledTextField。
///
/// 複数行は `lineLimit` に範囲を渡す(下限の行数ぶんの高さを確保し、上限まで伸びる)。
/// `trailing` にはラベル横の補助(自動入力バッジ等)を、`fieldTrailing` には入力欄の右に
/// 並べるボタン等を置ける(高さは入力欄に揃う)。
struct LabeledTextField<Trailing: View, FieldTrailing: View>: View {
  let label: String
  @Binding var text: String
  /// 空欄のときのヒント。nil なら「手動で入力してください」(manualInputHint)。
  var hint: String?
  /// 行数の範囲。nil は 1 行。
  var lineLimit: ClosedRange<Int>?
  var onSubmit: (() -> Void)?
  var focus: FocusState<Bool>.Binding?
  @ViewBuilder var trailing: () -> Trailing
  /// 入力欄の右に並べるもの。入力欄と同じ高さに引き伸ばす(ボタンなら上下の余白を 0 にしておく)。
  @ViewBuilder var fieldTrailing: () -> FieldTrailing

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  private static var textStyle: AppTextStyle { AppTextStyle(size: 14) }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: px(6)) {
        AppText(label, style: AppTextStyle(size: 12, weight: .w600))
          .foregroundStyle(colors.textSecondary)
        trailing()
      }
      Spacer().frame(height: px(5))
      HStack(spacing: px(10)) {
        field
        fieldTrailing()
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var field: some View {
    let hintText = hint ?? String(localized: .manualInputHint)
    let shape = RoundedRectangle(cornerRadius: px(7))
    let layout = Self.textStyle.lineLayout(for: text.isEmpty ? hintText : text, scale: px)
    let lines = lineLimit?.lowerBound ?? 1
    return TextField(
      "", text: $text, prompt: Text(verbatim: hintText).foregroundStyle(colors.textDisabled),
      axis: lineLimit == nil ? .horizontal : .vertical
    )
    .textFieldStyle(.plain)
    .font(Self.textStyle.font(px))
    .foregroundStyle(colors.materialOnSurface)
    .lineLimit(lineLimit ?? 1...1)
    .lineSpacing(max(layout.lineSpacing, 0))
    .focusEffectDisabled()
    .modifier(OptionalFocus(focus: focus))
    .onSubmit { onSubmit?() }
    .padding(.horizontal, px(10))
    // Flutter の入力欄は、入力とヒントの行の高さの大きい方 + 上下の余白 12 の高さになる
    // (和文を含むと和文の行の高さ)。複数行は下限の行数ぶんを確保し、上から並べる。
    .padding(.vertical, lineLimit == nil ? 0 : px(12))
    .frame(
      minHeight: lineLimit == nil
        ? AppTextField.height(style: Self.textStyle, texts: [hintText, text], verticalPadding: 12, scale: px)
        : layout.lineHeight * CGFloat(lines) + px(12) * 2,
      alignment: lineLimit == nil ? .center : .top
    )
    .frame(maxWidth: .infinity)
    // 塗りなしだと画面の地のグレーが透けるため、入力欄の地で塗る(ライトは白。ダークは面より暗く沈める)。
    .background(shape.fill(colors.inputFill))
    // フォーカス時も枠の色は変えない。
    .overlay(shape.strokeBorder(colors.inputBorder, lineWidth: px(1)))
  }
}

extension LabeledTextField where Trailing == EmptyView, FieldTrailing == EmptyView {
  init(
    label: String, text: Binding<String>, hint: String? = nil, lineLimit: ClosedRange<Int>? = nil,
    onSubmit: (() -> Void)? = nil, focus: FocusState<Bool>.Binding? = nil
  ) {
    self.init(
      label: label, text: text, hint: hint, lineLimit: lineLimit, onSubmit: onSubmit, focus: focus,
      trailing: { EmptyView() }, fieldTrailing: { EmptyView() })
  }
}

/// 呼び出し側がフォーカスを持つときだけ `focused` を付ける。
private struct OptionalFocus: ViewModifier {
  let focus: FocusState<Bool>.Binding?

  func body(content: Content) -> some View {
    if let focus { content.focused(focus) } else { content }
  }
}
