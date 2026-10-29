import Testing

@testable import EitangochoWordInfo

/// Flutter 版の test/features/word_registration/domain/word_form_matcher_test.dart の移植。
struct WordFormMatcherTests {
  private func contains(_ sentence: String, _ word: String) -> Bool {
    WordFormMatcher.containsWordForm(sentence, word)
  }

  @Test("見出し語そのものを含む文にマッチする")
  func matchesHeadword() {
    #expect(contains("Tom obtained a gun.", "obtain"))
    #expect(contains("He is diligent.", "diligent"))
  }

  @Test("規則変化形にマッチする")
  func matchesRegularForms() {
    #expect(contains("She obtains permission.", "obtain"))
    #expect(contains("We are obtaining data.", "obtain"))
    #expect(contains("He studied hard.", "study"))
    #expect(contains("He dragged his feet.", "drag"))
    #expect(contains("She is making dinner.", "make"))
  }

  // Tatoeba の検索はステミングするため、これを弾けないと無関係な文が入る。
  @Test("派生語しか含まない文は弾く")
  func rejectsDerivedWords() {
    #expect(!contains("I'm displeased with your negligence.", "negligible"))
    #expect(!contains("He was negligent of his duties.", "negligible"))
    #expect(!contains("I am going to substantiate this theory.", "substantial"))
    #expect(!contains("It's abundantly clear.", "abundant"))
  }

  @Test("大文字・約物は無視して判定する")
  func ignoresCaseAndPunctuation() {
    #expect(contains("Monster!", "monster"))
    #expect(contains("\"Ghosts exist,\" he said.", "ghost"))
    #expect(contains("Tom obtained a gun.", "OBTAIN"))
  }

  @Test("ハイフンで繋がった語も切り出して判定する")
  func splitsHyphenatedWords() {
    #expect(!contains("He is a well-known writer.", "know"))
    #expect(contains("He is a well-known writer.", "known"))
  }

  @Test("アポストロフィは語中に残す")
  func keepsApostrophes() {
    #expect(contains("I don't know.", "know"))
  }

  @Test("部分一致では拾わない")
  func rejectsPartialMatches() {
    #expect(!contains("He is a monsterous liar.", "monster"))
    #expect(!contains("The account is open.", "count"))
  }

  @Test("空文字は常に false")
  func emptyWordIsFalse() {
    #expect(!contains("Tom obtained a gun.", "  "))
  }

  // 句動詞。Tatoeba・kaikki とも実際に返してくる文で確認する。
  @Test("句: 先頭語の規則変化を許して句を含む文にマッチする")
  func phraseMatchesWithRegularForms() {
    #expect(contains("I give up!", "give up"))
    #expect(contains("I look forward to that.", "look forward to"))
    #expect(contains("Are you looking forward to spring?", "look forward to"))
    #expect(contains("Stop putting off finding a job.", "put off"))
  }

  @Test("句: 語順が変わっても・目的語が割り込んでもマッチする")
  func phraseMatchesReordered() {
    // 受動態で put と off が離れる
    #expect(contains("The wedding was put off.", "put off"))
    // give と up の間に目的語が挟まる
    #expect(contains("They give it up easily.", "give up"))
  }

  @Test("句: 後続の語を欠く文は弾く")
  func phraseRejectsMissingParticle() {
    #expect(!contains("I gave him a book.", "give up"))
    #expect(!contains("I look at the sky.", "look forward to"))
  }

  @Test("句: 先頭語の不規則変化は拾えない(既知の制約)")
  func phraseMissesIrregularForms() {
    #expect(!contains("He gave up smoking.", "give up"))
  }

  @Test("wordForms: 語尾 e は落ちた形も持つ")
  func formsDropFinalE() {
    #expect(WordFormMatcher.wordForms("make").isSuperset(of: ["make", "making", "maked"]))
  }

  @Test("wordForms: 子音 + y は ies / ied を持つ")
  func formsConsonantY() {
    #expect(WordFormMatcher.wordForms("study").isSuperset(of: ["studies", "studied"]))
  }

  @Test("wordForms: 母音 + y は ies を作らない")
  func formsVowelY() {
    #expect(!WordFormMatcher.wordForms("play").contains("plaies"))
    #expect(WordFormMatcher.wordForms("play").isSuperset(of: ["plays", "played"]))
  }

  @Test("wordForms: 短母音 + 子音の語は子音重ねを持つ")
  func formsDoubledConsonant() {
    #expect(WordFormMatcher.wordForms("drag").isSuperset(of: ["dragged", "dragging"]))
    // 直前が母音 2 つ(long vowel)なら重ねない
    #expect(!WordFormMatcher.wordForms("read").contains("readded"))
  }

  @Test("normalizeHeadword は前後の空白を落とし、語の間の連続空白を 1 つにする")
  func normalizesHeadword() {
    #expect(normalizeHeadword("  give   up \n") == "give up")
    #expect(normalizeHeadword("apple") == "apple")
  }
}
