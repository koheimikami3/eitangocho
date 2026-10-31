import Foundation

/// HTTP のレスポンスを差し替える URLProtocol(Flutter 版のテストの MockClient に当たる)。
///
/// テストは並行に走るので、応答の関数は URLSession ごとに登録し、
/// その URLSession が付けるヘッダの ID で引き分ける。
final class StubURLProtocol: URLProtocol, @unchecked Sendable {
  struct Response {
    var status: Int
    var body: String
  }

  typealias Handler = @Sendable (URLRequest, Data?) throws -> Response

  private static let lock = NSLock()
  nonisolated(unsafe) private static var handlers: [String: Handler] = [:]
  private static let header = "X-Stub-Session"

  /// `handler` で応答する URLSession を作る。
  static func session(_ handler: @escaping Handler) -> URLSession {
    let id = UUID().uuidString
    lock.withLock { handlers[id] = handler }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    configuration.httpAdditionalHeaders = [header: id]
    return URLSession(configuration: configuration)
  }

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    let id = request.value(forHTTPHeaderField: Self.header) ?? ""
    let handler = Self.lock.withLock { Self.handlers[id] }
    do {
      guard let handler else { throw URLError(.unknown) }
      let response = try handler(request, Self.body(of: request))
      let http = HTTPURLResponse(url: request.url!, statusCode: response.status, httpVersion: nil, headerFields: nil)!
      client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: Data(response.body.utf8))
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}

  /// URLProtocol に届く request は httpBody が stream に移っているので読み出す。
  private static func body(of request: URLRequest) -> Data? {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return nil }
    stream.open()
    defer { stream.close() }
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)
    while stream.hasBytesAvailable {
      let count = stream.read(&buffer, maxLength: buffer.count)
      if count <= 0 { break }
      data.append(buffer, count: count)
    }
    return data
  }
}

/// 呼ばれた回数・リクエストを数えるための入れ物。
final class Recorder: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [URLRequest] = []

  func append(_ request: URLRequest) { lock.withLock { storage.append(request) } }
  var requests: [URLRequest] { lock.withLock { storage } }
  var count: Int { requests.count }
}
