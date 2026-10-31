import EitangochoSync
import SwiftUI

/// 読み込みの結果(追加 / 更新 / 変更なし / スキップの件数)を出すダイアログ(Flutter 版の showImportResultDialog)。
/// 意匠は削除の確認ダイアログに揃える(角丸 13・幅 380)。
struct ImportResultDialog: View {
  let result: ImportResult
  let dismiss: () -> Void

  @Environment(\.colors) private var colors

  var body: some View {
    ImportDialogFrame(title: String(localized: .importDoneTitle), dismiss: dismiss) {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(
          [
            String(localized: .importAdded(result.added)), String(localized: .importUpdated(result.updated)),
            String(localized: .importUnchanged(result.unchanged)), String(localized: .importSkipped(result.skipped)),
          ], id: \.self
        ) { line in
          AppText(line, style: ImportDialogStyle.body)
            .foregroundStyle(colors.materialOnSurface)
        }
      }
    }
  }
}
