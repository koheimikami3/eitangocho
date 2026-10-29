import SwiftUI

/// 起動に失敗したときの画面。空の DB では始めず、やり直す手段だけを出す。
///
/// 文言は Phase 3 で String Catalog に移すまで日本語の仮置き。
struct StartupFailureView: View {
  let failure: AppModel.StartupFailure
  let model: AppModel

  var body: some View {
    VStack(spacing: 16) {
      Text(verbatim: title)
        .font(.headline)
      Text(verbatim: String(describing: failure))
        .font(.caption)
        .foregroundStyle(.secondary)
        .textSelection(.enabled)
      Button {
        Task { await model.start() }
      } label: {
        Text(verbatim: "再試行")
      }
      if case .openFailed = failure {
        // 引き継いだ後の変更は失われる(同期が有効なら iCloud から戻る)ので、
        // 自動ではやらず、押したときだけ行う。
        Button(role: .destructive) {
          Task { await model.reimport() }
        } label: {
          Text(verbatim: "引き継ぎ直す")
        }
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var title: String {
    switch failure {
    case .appGroupUnavailable: "データの保存先を用意できませんでした"
    case .importFailed: "以前の版のデータを引き継げませんでした"
    case .openFailed: "データを開けませんでした"
    }
  }
}
