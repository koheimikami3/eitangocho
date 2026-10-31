import EitangochoSync
import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

/// JSON のバックアップのファイルの読み書き(Flutter 版の word_backup_actions.dart)。
///
/// 変換そのものは WordExportService にあり、ここはその前後のファイルの扱いだけを持つ。
/// macOS 版 / iOS 版の設定画面が、見た目だけ変えて同じ処理を呼べるよう画面から分けている。
enum WordBackup {
  /// 読み込みの結果。表示の側がダイアログを出し分ける。
  enum ImportOutcome: Equatable {
    case imported(ImportResult)
    case formatError(WordExportFormatError)
    /// ファイルを読めなかった・DB に書けなかった(画面には出さない。Flutter 版と同じ)。
    case failed
  }

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "backup")

  /// 書き出すファイルの既定の名前(`eitangocho-2026-10-30`。拡張子は保存パネルが付ける)。
  static func suggestedFileName(now: Date = .now, timeZone: TimeZone = .current) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let parts = calendar.dateComponents([.year, .month, .day], from: now)
    return String(format: "eitangocho-%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
  }

  /// 書き出す中身を作る。保存パネル(fileExporter)は中身を先に要るので、パネルを出す前に呼ぶ。
  static func makeDocument(_ service: WordExportService) async -> WordBackupDocument? {
    do {
      return WordBackupDocument(json: try await service.exportJson())
    } catch {
      logger.error("書き出しの中身を作れない: \(String(describing: error), privacy: .public)")
      return nil
    }
  }

  /// 選んだファイルを読み込んでマージする。
  static func importFile(at url: URL, into service: WordExportService) async -> ImportOutcome {
    // サンドボックスの外のファイルは、選ばれた URL のスコープを開いている間だけ読める。
    let accessing = url.startAccessingSecurityScopedResource()
    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
    let source: String
    do {
      let data = try Data(contentsOf: url)
      // UTF-8 として読めないファイルは JSON ではないので、形式の誤りとして伝える。
      guard let text = String(data: data, encoding: .utf8) else { return .formatError(.invalidJson) }
      source = text
    } catch {
      logger.error("読み込むファイルを開けない: \(String(describing: error), privacy: .public)")
      return .failed
    }
    do {
      return .imported(try await service.importJson(source))
    } catch let error as WordExportFormatError {
      return .formatError(error)
    } catch {
      logger.error("読み込みに失敗: \(String(describing: error), privacy: .public)")
      return .failed
    }
  }
}

/// 書き出す JSON(fileExporter に渡す文書)。
struct WordBackupDocument: FileDocument {
  static let readableContentTypes: [UTType] = [.json]

  let json: String

  init(json: String) {
    self.json = json
  }

  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents, let json = String(data: data, encoding: .utf8) else {
      throw CocoaError(.fileReadCorruptFile)
    }
    self.json = json
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    FileWrapper(regularFileWithContents: Data(json.utf8))
  }
}
