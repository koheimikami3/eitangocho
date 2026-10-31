import SwiftUI

/// 起動に失敗したときの画面。空の DB では始めず、やり直す手段だけを出す。
///
/// エラーの中身は利用者には読めないが、問い合わせのときに原因を調べる手がかりになるので、
/// 説明の下に見出しを付けて小さく出し、選択してコピーできるようにしておく。
struct StartupFailureView: View {
  let failure: AppModel.StartupFailure
  let model: AppModel

  var body: some View {
    VStack(spacing: 16) {
      Text(title)
        .font(.headline)
      Text(.startupFailureMessage)
        .multilineTextAlignment(.center)
      VStack(spacing: 4) {
        Text(.startupFailureDetails)
          .font(.caption.weight(.semibold))
        Text(verbatim: String(describing: failure))
          .font(.caption)
          .textSelection(.enabled)
      }
      .foregroundStyle(.secondary)
      Button {
        Task { await model.start() }
      } label: {
        Text(.retry)
      }
      if case .openFailed = failure {
        // 引き継いだ後の変更は失われる(同期が有効なら iCloud から戻る)ので、
        // 自動ではやらず、押したときだけ行う。
        Button(role: .destructive) {
          Task { await model.reimport() }
        } label: {
          Text(.startupFailureReimport)
        }
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var title: LocalizedStringResource {
    switch failure {
    case .appGroupUnavailable: .startupFailureStorageTitle
    case .importFailed: .startupFailureImportTitle
    case .openFailed: .startupFailureOpenTitle
    }
  }
}
