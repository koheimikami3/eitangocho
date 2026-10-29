import Testing

@testable import EitangochoData

/// Flutter 版の test/enums/part_of_speech_test.dart と
/// test/db/converters/part_of_speech_list_converter_test.dart の移植。
struct PartOfSpeechTests {
  @Test("チップの並びは 名詞 → 動詞 → 形容詞 → 副詞 → その他")
  func declarationOrder() {
    #expect(PartOfSpeech.allCases == [.noun, .verb, .adjective, .adverb, .other])
  }

  @Test("空文字列は空の並びになり、空の並びは空文字列になる")
  func emptyList() {
    #expect(PartOfSpeech.decodeList("") == [])
    #expect(PartOfSpeech.encodeList([]) == "")
  }

  @Test("品詞の並びを往復変換できる", arguments: [[PartOfSpeech.verb], [.verb, .noun]])
  func roundTrip(list: [PartOfSpeech]) {
    #expect(PartOfSpeech.decodeList(PartOfSpeech.encodeList(list)) == list)
  }

  @Test("保存形式は Flutter 版と同じ 'verb,noun'")
  func storageFormat() {
    #expect(PartOfSpeech.encodeList([.verb, .noun]) == "verb,noun")
  }

  @Test("未知のトークンは無視される")
  func ignoresUnknownTokens() {
    #expect(PartOfSpeech.decodeList("verb,unknown,noun") == [.verb, .noun])
  }

  @Test("基準にある品詞は基準の並びを保つ(辞書が返した主用法が先頭に残る)")
  func keepsBaseOrder() {
    let selected: Set<PartOfSpeech> = [.noun, .verb]
    #expect(selected.ordered(basedOn: [.verb, .noun]) == [.verb, .noun])
  }

  @Test("基準に無い品詞は宣言順で後ろに付く")
  func appendsNewInDeclarationOrder() {
    let selected: Set<PartOfSpeech> = [.adjective, .verb, .noun]
    #expect(selected.ordered(basedOn: [.verb]) == [.verb, .noun, .adjective])
  }

  @Test("基準が空なら宣言順になる")
  func emptyBase() {
    let selected: Set<PartOfSpeech> = [.adverb, .noun]
    #expect(selected.ordered(basedOn: []) == [.noun, .adverb])
  }
}
