import EitangochoData
import Foundation

/// Tatoeba(対訳付き例文コーパス)のクライアント。
///
/// 英文とその訳が対でぶら下がっているため、1 リクエストで exampleEn と
/// exampleTranslation の両方が埋まる。辞書側(kaikki)の例文は語義説明用の断片や
/// 文献引用が混ざるので、単語帳の例文としてはこちらを優先する。
///
/// 例文は補助情報なので、失敗しても throw せず nil を返す(登録を妨げない。
/// DeeplClient と同じ方針)。
public struct TatoebaClient: Sendable {
  private let session: URLSession

  public init(session: URLSession) {
    self.session = session
  }

  static let timeout: TimeInterval = 10

  /// 候補の取得件数。1 件だけ取ると語形フィルタで落ちたときに空振りするため
  /// 多めに取り、クライアント側で選ぶ。
  ///
  /// 10 から 30 に増やした(preferredMinWords を 6 に上げたのに合わせて)。
  /// 下限を満たす文が候補に入る確率が上がり、実測 25 語では下限に届かず降格
  /// するのが 2 件だけになった。`gradual` のように 10 件では語形フィルタを
  /// 通る文が 1 つも無く例文ゼロだった語も拾えるようになる。
  static let limit = 30

  /// 優先する最低語数。最短を採るだけだと `monster` に「Monster!」のような
  /// 感嘆詞 1 語の文が選ばれてしまうため、これを下回る文は後回しにする。
  ///
  /// **3 から 6 に上げた**。3 だと `He is diligent.` のような文が選ばれ、
  /// 単語帳の例文として文脈が足りていなかった(実測 25 語で平均 4.2 語)。
  /// 6 にすると平均 6.0 語になる。8 まで上げると 7/25 が下限に届かず降格し、
  /// `negligible` では 21 語の文が選ばれてカード(英例文は 2 行)で切れるため、6 で止める。
  ///
  /// **下限であって上限ではない**。長さを決めているのは select の
  /// 「下限以上の中で最短」の方で、この値を下げると例文は短くなる。
  ///
  /// なお辞書側(kaikki)の下限は 4 語のままにしてある。あちらは
  /// `obtain permission` のような句の断片を除くためのハード条件で目的が違い、
  /// 上げると例文が丸ごと消える(Tatoeba が空振りしたときしか使われない)。
  static let preferredMinWords = 6

  /// `word` を含む英文と、`language` の訳の組を 1 つ返す。見つからなければ nil。
  ///
  /// 対訳を持たない言語(translatesExamples が false)では、
  /// 訳で絞らずに英文だけを選び、訳は空にする。
  public func findExample(_ word: String, language: TranslationLanguage) async -> ExampleSentence? {
    let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else { return nil }

    var components = URLComponents(string: "https://api.tatoeba.org/unstable/sentences")!
    components.queryItems =
      [URLQueryItem(name: "lang", value: "eng"), URLQueryItem(name: "q", value: normalized)]
      + (language.tatoebaLang.map { [URLQueryItem(name: "trans:lang", value: $0)] } ?? [])
      // sort は必須。省略すると 400 が返る。
      + [URLQueryItem(name: "sort", value: "relevance"), URLQueryItem(name: "limit", value: "\(Self.limit)")]

    let response: TatoebaSearchResponse
    do {
      let (data, status) = try await HTTP.data(
        URLRequest(url: components.url!, timeoutInterval: Self.timeout), session: session)
      guard status == 200 else { return nil }
      response = try JSONDecoder().decode(TatoebaSearchResponse.self, from: data)
    } catch {
      // 通信失敗・レスポンス形式の変化はどちらも「例文なし」として扱う
      return nil
    }
    return Self.select(response.data, word: normalized, language: language)
  }

  /// 訳があり(対訳を持たない言語では問わない)、見出し語を実際に含む文のうち
  /// 最短のものを選ぶ。
  ///
  /// Tatoeba の検索はステミングするため、`negligible` で検索しても
  /// `negligence` の文しか返らないことがある。語形フィルタを通さないと
  /// 別の単語の例文を登録してしまう。短い文ほど単語帳では覚えやすいので、
  /// 条件を満たす中では最短を採る。
  ///
  /// ただし preferredMinWords 語以上を先に見て、そこに候補が無いときだけ
  /// 短い文に降りる。語数で足切りしてしまうと、短文しか無い語で訳付きの
  /// 例文を丸ごと失う(辞書側の訳なし例文に落ちる)ため。
  ///
  /// 長短の比較は文字数ではなく**語数**で行う。下限を語数で見ているのに
  /// 比較が文字数だと、降格したときに「語数は少ないが文字数は長い文」が
  /// 選ばれて基準が噛み合わない。
  static func select(_ sentences: [TatoebaSentence], word: String, language: TranslationLanguage)
    -> ExampleSentence?
  {
    var candidates: [ExampleSentence] = []
    for sentence in sentences {
      let en = (sentence.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
      guard !en.isEmpty, WordFormMatcher.containsWordForm(en, word) else { continue }
      let translation: String?
      if language.translatesExamples {
        translation = sentence.translations.first { matches($0, language) }?.text?
          .trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        translation = ""
      }
      guard let translation else { continue }
      candidates.append(ExampleSentence(en: en, translation: translation))
    }
    guard !candidates.isEmpty else { return nil }
    // 並べ替えは安定にする(同じ語数なら Tatoeba の関連度順を保つ。Dart の sort と同じ結果にするため)。
    let qualified = candidates.filter { wordCount($0.en) >= preferredMinWords }
    if !qualified.isEmpty {
      return qualified.enumerated().min { a, b in
        (wordCount(a.element.en), a.offset) < (wordCount(b.element.en), b.offset)
      }?.element
    }
    // 全部が短すぎるときは、その中でいちばん語数の多いものを採る
    // (ここで最短を採ると「Ghosts exist.」より「Ghosts!」が勝ってしまう)。
    return candidates.enumerated().min { a, b in
      (-wordCount(a.element.en), a.offset) < (-wordCount(b.element.en), b.offset)
    }?.element
  }

  /// `language` の訳として使えるか。
  ///
  /// 中国語(cmn)は繁体字と簡体字の訳が混ざって返るので、文字体系
  /// (`script`)でも絞る。字形を変換せずに済むよう、繁体字の訳がある文だけを
  /// 候補にする(実測では 40 語中 37 語で繁体字の訳が見つかる)。
  static func matches(_ translation: TatoebaTranslation, _ language: TranslationLanguage) -> Bool {
    translation.lang == language.tatoebaLang
      && (language.tatoebaScript == nil || translation.script == language.tatoebaScript)
      && !(translation.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  static func wordCount(_ sentence: String) -> Int {
    sentence.split(whereSeparator: \.isWhitespace).count
  }
}

/// Tatoeba の文検索レスポンス。
struct TatoebaSearchResponse: Decodable {
  var data: [TatoebaSentence]

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    data = container.lenientList(TatoebaSentence.self, .data)
  }

  enum CodingKeys: String, CodingKey { case data }
}

/// 検索にヒットした英文。translations は `trans:lang` を指定したときだけ入り、
/// 指定しないと null になる(必須にしない。CLAUDE.md 規約)。
struct TatoebaSentence: Decodable {
  var text: String?
  var translations: [TatoebaTranslation]

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = container.lenient(String.self, .text)
    translations = container.lenientList(TatoebaTranslation.self, .translations)
  }

  enum CodingKeys: String, CodingKey { case text, translations }
}

/// 英文の訳。script は文字体系(中国語の `Hant` / `Hans` など)で、
/// 文字体系の区別が無い言語では null になる。
struct TatoebaTranslation: Decodable {
  var lang: String?
  var script: String?
  var text: String?

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lang = container.lenient(String.self, .lang)
    script = container.lenient(String.self, .script)
    text = container.lenient(String.self, .text)
  }

  enum CodingKeys: String, CodingKey { case lang, script, text }
}
