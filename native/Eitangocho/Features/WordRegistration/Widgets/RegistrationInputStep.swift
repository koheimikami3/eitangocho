import SwiftUI

/// ステップ 1: 英単語の入力(自動入力 or 手動入力へスキップ)。Flutter 版の RegistrationInputStep。
struct RegistrationInputStep: View {
  @Bindable var model: WordRegistrationModel
  let intro: String
  let errorMessage: String?
  var focus: FocusState<Bool>.Binding

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AppText(intro, style: AppTextStyle(size: 12))
        .foregroundStyle(colors.textTertiary)
      Spacer().frame(height: px(14))
      LabeledTextField(
        label: String(localized: .fieldWord), text: $model.word, hint: "apple",
        onSubmit: { Task { await model.autoFill() } }, focus: focus,
        trailing: { EmptyView() },
        fieldTrailing: {
          // 入力欄の高さに引き伸ばすので、ボタン自身の上下の余白は持たせない。
          AppFilledButton(label: String(localized: .autoFill), verticalPadding: 0) {
            Task { await model.autoFill() }
          }
          .frame(maxHeight: .infinity)
        })
      // エラーがあればそちらを優先して出す。
      if let errorMessage {
        Spacer().frame(height: px(10))
        AppText(errorMessage, style: AppTextStyle(size: 12)).foregroundStyle(colors.danger)
      } else if let registered = model.registeredWord {
        Spacer().frame(height: px(10))
        AppText(.wordRegistered(registered), style: AppTextStyle(size: 12)).foregroundStyle(colors.success)
      }
      Spacer().frame(height: px(14))
      SkipLink { model.skipToManual() }
    }
  }
}
