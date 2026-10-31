import Testing

@testable import EitangochoData

/// Flutter 版の test/db/ejdict_dao_test.dart と dictionary_cache_dao_test.dart の移植。
struct EjdictAndCacheDaoTests {
  let database: AppDatabase

  init() throws {
    database = try AppDatabase.inMemory()
  }

  @Test("bulkInsert と count")
  func bulkInsertAndCount() async throws {
    #expect(try await database.ejdictDao.count() == 0)

    try await database.ejdictDao.bulkInsert([("apple", "リンゴ"), ("book", "本")])

    #expect(try await database.ejdictDao.count() == 2)
  }

  @Test("lookup は収録語の訳を返し、未収録なら nil")
  func lookup() async throws {
    try await database.ejdictDao.bulkInsert([("apple", "リンゴ")])

    #expect(try await database.ejdictDao.lookup("apple") == "リンゴ")
    #expect(try await database.ejdictDao.lookup("zzzzz") == nil)
  }

  @Test("同一単語の再 bulkInsert は上書きする")
  func bulkInsertReplaces() async throws {
    try await database.ejdictDao.bulkInsert([("apple", "リンゴ")])
    try await database.ejdictDao.bulkInsert([("apple", "林檎")])

    #expect(try await database.ejdictDao.count() == 1)
    #expect(try await database.ejdictDao.lookup("apple") == "林檎")
  }

  @Test("EJDict と同程度の件数も取り込める")
  func bulkInsertMany() async throws {
    let many = (0..<50_000).map { (word: "word\($0)", meanings: "訳\($0)") }

    try await database.ejdictDao.bulkInsert(many)

    #expect(try await database.ejdictDao.count() == 50_000)
    #expect(try await database.ejdictDao.lookup("word49999") == "訳49999")
  }

  @Test("save した JSON を find で取得できる。未キャッシュは nil")
  func cacheSaveAndFind() async throws {
    #expect(try await database.dictionaryCacheDao.find("apple") == nil)

    try await database.dictionaryCacheDao.save("apple", responseJson: #"[{"word":"apple"}]"#)

    #expect(try await database.dictionaryCacheDao.find("apple") == #"[{"word":"apple"}]"#)
  }

  @Test("同一単語の save は上書きする")
  func cacheSaveReplaces() async throws {
    try await database.dictionaryCacheDao.save("apple", responseJson: "[1]")
    try await database.dictionaryCacheDao.save("apple", responseJson: "[2]")

    #expect(try await database.dictionaryCacheDao.find("apple") == "[2]")
  }
}
