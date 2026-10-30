#if os(macOS)
  import EitangochoSync
  import SwiftUI

  /// 設定の「データ」カードのうち、JSON の書き出し / 読み込みの行(Flutter 版の DataBackupRows)。
  ///
  /// ラベル末尾の `...` は macOS だけに付ける(ダイアログが開くことを示す macOS の慣習)。
  /// 2 行を 1 つにまとめているのは、実行中の印を両方で共有して、書き出し中の読み込み
  /// (およびその逆)を止めるため。
  struct DataBackupRows: View {
    let service: WordExportService

    @Environment(\.appOverlay) private var overlay
    @State private var busy = false
    @State private var document: WordBackupDocument?
    @State private var showsExporter = false
    @State private var showsImporter = false

    var body: some View {
      VStack(spacing: 0) {
        SettingsLinkRow(label: String(localized: .exportDataEllipsis)) { export() }
        SettingsDivider()
        SettingsLinkRow(label: String(localized: .importDataEllipsis)) {
          guard !busy else { return }
          showsImporter = true
        }
      }
      .fileExporter(
        isPresented: $showsExporter, document: document, contentType: .json,
        defaultFilename: WordBackup.suggestedFileName()
      ) { result in
        if case .success = result {
          overlay?.showSnackBar(String(localized: .exportDone))
        }
      }
      // 保存パネルを閉じたら(保存・取り消しのどちらでも)次の操作を受け付ける。
      .onChange(of: showsExporter) { _, shows in
        if !shows { busy = false }
      }
      .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.json]) { result in
        guard case .success(let url) = result else { return }
        busy = true
        Task {
          let outcome = await WordBackup.importFile(at: url, into: service)
          busy = false
          present(outcome)
        }
      }
    }

    private func export() {
      guard !busy else { return }
      busy = true
      Task {
        guard let document = await WordBackup.makeDocument(service) else {
          busy = false
          return
        }
        self.document = document
        showsExporter = true
      }
    }

    private func present(_ outcome: WordBackup.ImportOutcome) {
      switch outcome {
      case .imported(let result):
        overlay?.present { dismiss in ImportResultDialog(result: result, dismiss: dismiss) }
      case .formatError(let error):
        overlay?.present { dismiss in ImportErrorDialog(error: error, dismiss: dismiss) }
      case .failed:
        break
      }
    }
  }
#endif
