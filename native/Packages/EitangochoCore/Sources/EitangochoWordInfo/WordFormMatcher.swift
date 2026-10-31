import Foundation

/// 例文が見出し語(または規則変化形)を実際に含んでいるかを判定する。
///
/// 外部ソースの例文検索はどちらも見出し語と無関係な文を返しうるため、
/// 採用前にこのフィルタを必ず通す:
/// - Tatoeba の検索はステミングするので、`negligible` で検索すると
///   `negligence` / `negligent` の文しか返らないことがある(引用符で
///   囲んでも無効)。`substantial` では `substantiate` の文が混ざる
/// - kaikki の例文は語義ごとに付くため、派生語の項に入った文が混ざる
///
/// 判定は「文中のいずれかのトークンが見出し語の語形集合に一致するか」。
/// 見出し語化(lemmatize)は行わないため、活用形で登録された単語
/// (`looked` 等)は原形の文にマッチしない。単語帳には原形を登録する
/// 前提で割り切っている。
public enum WordFormMatcher {
  /// `sentence` が `word` またはその規則変化形をトークンとして含むか。
  ///
  /// `word` が `give up` のような句(句動詞・複合語)のときは、**先頭語だけ
  /// 規則変化を許し、後続のトークンはその形のまま**文中にあることを求める。
  /// 句動詞の後ろに付くのは副詞・前置詞(up / forward / to)で活用しないため。
  /// 語順と隣接は問わない: `The wedding was put off.` のように受動態で語順が
  /// 変わる文や、`give himself up` のように目的語が割り込む文を落とさないため。
  ///
  /// 先頭語が不規則変化する句(`give up` に対する `He gave up.`)は拾えない。
  /// 単語 1 語のときと同じ割り切りで、Tatoeba は候補を複数件取るため
  /// 実用上は原形を含む文が残る。
  public static func containsWordForm(_ sentence: String, _ word: String) -> Bool {
    let headwordTokens = tokenize(word)
    guard let first = headwordTokens.first else { return false }

    let sentenceTokens = Set(tokenize(sentence))
    let forms = wordForms(first)
    guard !sentenceTokens.isDisjoint(with: forms) else { return false }
    return headwordTokens.dropFirst().allSatisfy(sentenceTokens.contains)
  }

  /// `word` の規則変化形(小文字)。不規則変化は扱わない。
  public static func wordForms(_ word: String) -> Set<String> {
    let base = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !base.isEmpty else { return [] }

    var forms: Set<String> = [base, base + "s", base + "es", base + "ed", base + "d", base + "ing"]
    let characters = Array(base)

    // make → making / made 相当(語尾 e の脱落)
    if base.hasSuffix("e") && characters.count > 1 {
      let stem = String(base.dropLast())
      forms.formUnion([stem + "ing", stem + "ed"])
    }
    // study → studies / studied
    if base.hasSuffix("y") && characters.count > 1 && !isVowel(characters[characters.count - 2]) {
      let stem = String(base.dropLast())
      forms.formUnion([stem + "ies", stem + "ied"])
    }
    // drag → dragged / dragging(短母音 + 子音で終わる語の子音重ね)
    if characters.count > 2,
      let last = characters.last,
      !isVowel(last), last != "y",
      isVowel(characters[characters.count - 2]),
      !isVowel(characters[characters.count - 3])
    {
      let doubled = base + String(last)
      forms.formUnion([doubled + "ed", doubled + "ing"])
    }
    return forms
  }

  /// 文を小文字のトークン列に分解する。a〜z とアポストロフィ以外で区切り、
  /// 前後のアポストロフィを落とす(`well-known` は well / known に割れて後者が拾える)。
  /// 語中のアポストロフィは残す(`don't` を don で切らない)。
  static func tokenize(_ sentence: String) -> [String] {
    var tokens: [String] = []
    var current = ""
    func flush() {
      let token = current.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
      if !token.isEmpty { tokens.append(token) }
      current = ""
    }
    for scalar in sentence.lowercased().unicodeScalars {
      if ("a"..."z").contains(scalar) || scalar == "'" {
        current.unicodeScalars.append(scalar)
      } else {
        flush()
      }
    }
    flush()
    return tokens
  }

  private static func isVowel(_ character: Character) -> Bool { "aeiou".contains(character) }
}

/// 見出し語(単語・句動詞)の表記ゆれを入口で潰す。
///
/// 前後の空白を落とし、語の間の連続空白を 1 つにまとめる。句動詞を登録
/// できるようにしたことで、`give  up` のように空白を重ねて入力されうる
/// ようになった。そのままだと kaikki のパス(`give  up.jsonl`)が 404 に
/// なり、`give up` と別単語として重複登録もできてしまう。
///
/// 保存・照合の直前で通す前提。WordDao.matchKey と書き出しのマージキー
/// (trim + 小文字化)は同期のマージキーでもあるため触らない。ここで正規化した
/// 文字列を渡せば両者はそのまま成立する。
public func normalizeHeadword(_ word: String) -> String {
  word.split(whereSeparator: \.isWhitespace).joined(separator: " ")
}
