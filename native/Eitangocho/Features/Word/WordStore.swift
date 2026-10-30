import EitangochoData
import Foundation
import Observation
import OSLog

/// 登録単語の一覧を DB から見張り、画面に配る(Flutter 版の wordListProvider)。
/// 学習済みの切り替え・編集・削除もここから DB に書く(画面から DB を直接触らない)。
@Observable
final class WordStore {
  /// 登録日の新しい順の全件。
  private(set) var words: [Word] = []

  /// 初回の読み込みが終わったか。終わる前に空の状態(「単語がまだありません」)を
  /// 一瞬出さないよう、画面はこれが false の間は読み込み中の表示を出す。
  private(set) var isLoaded = false

  @ObservationIgnored let dao: WordDao
  @ObservationIgnored private let analytics: AnalyticsLogger
  @ObservationIgnored private var observation: Task<Void, Never>?

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "words")

  init(dao: WordDao, analytics: AnalyticsLogger) {
    self.dao = dao
    self.analytics = analytics
  }

  /// 見張りを始める。アプリが生きている間ずっと続ける。
  func start() {
    guard observation == nil else { return }
    let values = dao.observeAll()
    observation = Task { [weak self] in
      do {
        for try await words in values {
          self?.words = words
          self?.isLoaded = true
        }
      } catch {
        Self.logger.error("単語の一覧を読めない: \(String(describing: error), privacy: .public)")
      }
    }
  }

  /// 一覧・カードの「覚えた」チェックの操作(Flutter 版の toggleWordLearned)。
  ///
  /// 学習中・全単語の画面が同じことをするため 1 つにまとめる(計測の送り忘れを防ぐ)。
  /// クイズの「忘れていた」による学習中への戻しはユーザーの操作ではないので、ここを通さない。
  func setLearned(_ word: Word, _ isLearned: Bool) async {
    analytics.logWordLearnedToggled(word, isLearned: isLearned)
    await perform { try await dao.setLearned(id: word.id, isLearned) }
  }

  /// 同じ単語が他に登録されていれば返す(編集で単語名を既存の単語に書き換えさせないため)。
  func duplicate(of word: String, excluding id: Int64? = nil) async -> Word? {
    do {
      return try await dao.findByWord(word, excludingId: id)
    } catch {
      Self.logger.error("重複の確認に失敗: \(String(describing: error), privacy: .public)")
      return nil
    }
  }

  func update(_ word: Word, _ edit: WordEdit) async {
    await perform { try await dao.updateWord(id: word.id, edit) }
  }

  /// 削除の確認ダイアログで「削除」を押したとき。
  func delete(_ word: Word) async {
    analytics.logWordDeleted(word)
    await perform { try await dao.deleteWord(id: word.id) }
  }

  private func perform(_ operation: () async throws -> Void) async {
    do {
      try await operation()
    } catch {
      Self.logger.error("単語の書き込みに失敗: \(String(describing: error), privacy: .public)")
    }
  }
}
