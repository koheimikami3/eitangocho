#if os(iOS)
  import EitangochoSync
  import SwiftUI

  /// iOS 版の設定の「データ」カードのうち、JSON の書き出し / 読み込みの行(Flutter 版の MobileDataBackupRows)。
  ///
  /// 処理は macOS 版と共通(WordBackup)で、ここは見た目と多重実行の抑止だけを持つ。
  /// 2 行を 1 つにまとめているのは、実行中の印を両方で共有して、書き出し中の読み込み(およびその逆)を止めるため。
  /// iOS には保存パネルが無いので、書き出しはファイルの書き出しの画面(fileExporter)で保存先を選ぶ。
  struct MobileDataBackupRows: View {
    let service: WordExportService

    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics
    @State private var busy = false
    @State private var document: WordBackupDocument?
    @State private var showsExporter = false
    @State private var showsImporter = false

    var body: some View {
      VStack(spacing: 0) {
        MobileSettingsLinkRow(label: String(localized: .exportData)) { export() }
        MobileSettingsDivider()
        MobileSettingsLinkRow(label: String(localized: .importData)) {
          guard !busy else { return }
          showsImporter = true
        }
      }
      .fileExporter(
        isPresented: $showsExporter, document: document, contentType: .json,
        defaultFilename: WordBackup.suggestedFileName()
      ) { result in
        if case .success = result {
          analytics.logDataExported()
          overlay?.showSnackBar(String(localized: .exportDone))
        }
      }
      // 書き出しの画面を閉じたら(保存・取り消しのどちらでも)次の操作を受け付ける。
      .onChange(of: showsExporter) { _, shows in
        if !shows { busy = false }
      }
      .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.json]) { result in
        guard case .success(let url) = result else { return }
        busy = true
        Task {
          let outcome = await WordBackup.importFile(at: url, into: service)
          busy = false
          WordBackup.present(outcome, overlay: overlay, analytics: analytics)
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
  }
#endif
