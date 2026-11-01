import EitangochoSync
import SwiftUI

/// 読み込みに失敗したときのダイアログ(Flutter 版の showImportErrorDialog)。
struct ImportErrorDialog: View {
  let error: WordExportFormatError
  let dismiss: () -> Void

  @Environment(\.colors) private var colors

  var body: some View {
    ImportDialogFrame(title: String(localized: .importFailedTitle), dismiss: dismiss) {
      AppText(message, style: ImportDialogStyle.body)
        .foregroundStyle(colors.textSecondary)
    }
  }

  private var message: String {
    switch error {
    case .invalidJson: String(localized: .importErrorInvalidJson)
    case .invalidFormat: String(localized: .importErrorInvalidFormat)
    case .unsupportedVersion: String(localized: .importErrorUnsupportedVersion)
    }
  }
}

/// 読み込みの結果・失敗のダイアログの本文の書式。Flutter 版は文字の大きさを指定せず、
/// ダイアログ(Material)の既定の bodyMedium のまま。
enum ImportDialogStyle {
  static let body = AppTextStyle(size: 14)
}

/// 読み込みの結果・失敗のダイアログの枠(見出し・本文・「閉じる」)。
struct ImportDialogFrame<Content: View>: View {
  let title: String
  let dismiss: () -> Void
  @ViewBuilder let content: () -> Content

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    AppDialogSurface(cornerRadius: 13) {
      VStack(alignment: .leading, spacing: 0) {
        AppText(title, style: AppTextStyle(size: 15, weight: .w700))
          .foregroundStyle(colors.textPrimary)
        Spacer().frame(height: px(12))
        content()
        Spacer().frame(height: px(16))
        AppFilledButton(label: String(localized: .close), action: dismiss)
      }
      // 幅 380 は上限。iPhone のように画面が狭いときは、Flutter の Dialog と同じく縁から 40 空けて縮む。
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(px(24))
      .frame(maxWidth: px(380 + 24 * 2))
    }
  }
}
