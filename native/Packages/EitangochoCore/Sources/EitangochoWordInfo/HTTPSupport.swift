import Foundation

/// 取得元のクライアントが共通で使う、URLSession の呼び出し。
/// テストでは URLProtocol を差し込んだ URLSession を渡す。
enum HTTP {
  static func data(_ request: URLRequest, session: URLSession) async throws -> (Data, Int) {
    let (data, response) = try await session.data(for: request)
    return (data, (response as? HTTPURLResponse)?.statusCode ?? 0)
  }
}
