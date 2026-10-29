#if DEBUG
  import EitangochoData
  import EitangochoSync
  import SwiftUI

  /// Dev ビルドだけの診断画面。Flutter 版からの引き継ぎの結果・DB の状態・
  /// 設定のキーの有無を出し、同期と混在同期の確認用の操作を置く。
  struct DiagnosticsView: View {
    let session: AppModel.Session
    @State private var model: DiagnosticsModel

    init(session: AppModel.Session) {
      self.session = session
      _model = State(initialValue: DiagnosticsModel(database: session.database, sourceURL: session.locations.source))
    }

    var body: some View {
      List {
        importSection
        sourceSection
        databaseSection
        preferencesSection
        syncSection
        actionsSection
        wordsSection
      }
      .task { await model.observe() }
    }

    // MARK: - 引き継ぎ

    private var importSection: some View {
      Section {
        switch session.importOutcome {
        case .performed(let record):
          row("結果", "この起動で実行")
          recordRows(record)
        case .alreadyImported(let record):
          row("結果", "済み")
          if let record { recordRows(record) }
        }
      } header: {
        Text(verbatim: "引き継ぎ")
      }
    }

    @ViewBuilder
    private func recordRows(_ record: DatabaseImportRecord) -> some View {
      row("種類", record.kind.rawValue)
      row("日時", record.importedAt.formatted())
      row("元の user_version", record.sourceUserVersion.map(String.init) ?? "-")
      row("元のサイズ", record.sourceSize.map { "\($0) bytes" } ?? "-")
      row("元の更新日時", record.sourceModifiedAt?.formatted() ?? "-")
      row("付属ファイル", record.sourceSidecars.isEmpty ? "なし" : record.sourceSidecars.joined(separator: ", "))
      if let counts = record.counts {
        row("件数", "単語 \(counts.words) / 削除 \(counts.deletions) / EJDict \(counts.ejdict) / キャッシュ \(counts.dictionaryCache)")
      }
    }

    // MARK: - 元ファイル・DB

    private var sourceSection: some View {
      Section {
        row("パス", session.locations.source.path)
        if let source = model.source {
          row("有無", source.exists ? "あり" : "なし")
          row("サイズ", source.size.map { "\($0) bytes" } ?? "-")
          row("更新日時", source.modifiedAt?.formatted() ?? "-")
          row("付属ファイル", source.sidecars.isEmpty ? "なし" : source.sidecars.joined(separator: ", "))
        }
      } header: {
        Text(verbatim: "元ファイル(Flutter 版)")
      }
    }

    private var databaseSection: some View {
      Section {
        row("パス", session.locations.destination.path)
        if let inspection = model.inspection {
          row("user_version", "\(inspection.userVersion)")
          row("journal_mode", inspection.journalMode)
          row("件数", "単語 \(inspection.words) / 削除 \(inspection.deletions) / EJDict \(inspection.ejdict) / キャッシュ \(inspection.dictionaryCache)")
        }
        if let error = model.errorMessage {
          row("エラー", error)
        }
      } header: {
        Text(verbatim: "DB(App Group)")
      }
    }

    private var preferencesSection: some View {
      Section {
        ForEach(model.preferenceTypes, id: \.key) { item in
          row(item.key, item.type ?? "なし")
        }
      } header: {
        Text(verbatim: "設定のキー(型だけ)")
      }
    }

    // MARK: - 同期

    private var syncSection: some View {
      let sync = session.sync
      return Section {
        Toggle(
          isOn: Binding(get: { sync.enabled }, set: { enabled in Task { await sync.setEnabled(enabled) } })
        ) {
          Text(verbatim: "iCloud 同期")
        }
        Button {
          Task { await sync.syncNow() }
        } label: {
          Text(verbatim: sync.syncing ? "同期中…" : "今すぐ同期")
        }
        .disabled(!sync.enabled || sync.syncing)
        row("最終同期", sync.lastSyncedAt?.formatted() ?? "-")
        if let failure = sync.failure {
          row("失敗", "\(failure.reason.rawValue) \(failure.detail ?? "")")
        }
      } header: {
        Text(verbatim: "同期")
      }
    }

    private var actionsSection: some View {
      Section {
        Button { Task { await model.addTestWord() } } label: { Text(verbatim: "テスト用の単語を追加") }
        Button { Task { await model.editFirstWord() } } label: { Text(verbatim: "先頭の単語の訳を書き換え") }
        Button(role: .destructive) { Task { await model.deleteFirstWord() } } label: {
          Text(verbatim: "先頭の単語を削除")
        }
      } header: {
        Text(verbatim: "混在同期の確認")
      }
    }

    private var wordsSection: some View {
      Section {
        ForEach(model.words) { word in
          VStack(alignment: .leading) {
            Text(verbatim: word.word)
            Text(verbatim: "\(word.meaning) [\(word.translationLanguage)]")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      } header: {
        Text(verbatim: "単語(\(model.words.count))")
      }
    }

    private func row(_ title: String, _ value: String) -> some View {
      LabeledContent {
        Text(verbatim: value)
          .textSelection(.enabled)
      } label: {
        Text(verbatim: title)
      }
    }
  }
#endif
