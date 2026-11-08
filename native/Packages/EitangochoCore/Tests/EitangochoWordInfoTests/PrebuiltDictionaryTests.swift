import EitangochoData
import Foundation
import Testing

@testable import EitangochoWordInfo

/// 同梱の事前生成辞書(Resources/prebuilt-dictionary.json)が読めることを確かめる。
/// 中身の良し悪しは tool/dictgen の検査で見ているので、ここでは形だけを見る。
struct PrebuiltDictionaryTests {
  @Test("同梱の辞書から単語と句動詞を日本語・繁体字で引ける")
  func bundledLookup() async throws {
    for word in ["the", "give up"] {
      for language in [TranslationLanguage.ja, .zhHant] {
        let entry = try #require(await PrebuiltDictionary.bundled.lookup(word, language: language))
        #expect(!entry.meaning.isEmpty)
        #expect(!entry.exampleEn.isEmpty)
        #expect(!entry.exampleTranslation.isEmpty)
        #expect(!entry.partsOfSpeech.isEmpty)
      }
    }
    #expect(await PrebuiltDictionary.bundled.lookup("the", language: .ja)?.ipa.isEmpty == false)
  }

  @Test("訳を持たない言語と、載っていない語は nil")
  func notCovered() async {
    #expect(await PrebuiltDictionary.bundled.lookup("the", language: .es) == nil)
    #expect(await PrebuiltDictionary.bundled.lookup("the", language: .enDefinition) == nil)
    #expect(await PrebuiltDictionary.bundled.lookup("serendipity", language: .ja) == nil)
  }

  @Test("同梱の辞書から、綴りの誤りに近い見出しを近い順に返す")
  func bundledNearestHeadwords() async {
    #expect(await PrebuiltDictionary.bundled.nearestHeadwords(to: "acommodate", limit: 3).first == "accommodate")
    #expect(await PrebuiltDictionary.bundled.nearestHeadwords(to: "recieve", limit: 3).first == "receive")
    #expect(await PrebuiltDictionary.bundled.contains("give up"))
  }

  @Test("編集距離は隣り合う 2 文字の入れ替えを 1 と数える")
  func editDistance() {
    #expect(PrebuiltDictionary.editDistance(Array("recieve"), Array("receive")) == 1)
    #expect(PrebuiltDictionary.editDistance(Array("acommodate"), Array("accommodate")) == 1)
    #expect(PrebuiltDictionary.editDistance(Array("cat"), Array("dog")) == 3)
    #expect(PrebuiltDictionary.editDistance(Array(""), Array("ab")) == 2)
  }

  @Test("訳を持たない言語では辞書を読み込まない")
  func notCoveredDoesNotLoad() async {
    let dictionary = PrebuiltDictionary {
      Issue.record("辞書を読み込んだ")
      return Data()
    }
    for language in [TranslationLanguage.es, .fr, .enDefinition] {
      #expect(await dictionary.lookup("the", language: language) == nil)
    }
  }

  @Test("韓国語は省略可で読み、無い語は nil で、ほかの言語は引ける")
  func optionalKorean() async {
    let dictionary = PrebuiltDictionary {
      Data(
        #"""
        {"version":1,"words":{
        "a":{"ipa":"","pos":[],"exampleEn":"e","ja":{"meaning":"日","exampleTranslation":"日例"},
        "zhHant":{"meaning":"繁","exampleTranslation":"繁例"},"ko":{"meaning":"한","exampleTranslation":"한예"}},
        "b":{"ipa":"","pos":[],"exampleEn":"e","ja":{"meaning":"日","exampleTranslation":"日例"},
        "zhHant":{"meaning":"繁","exampleTranslation":"繁例"}}}}
        """#.utf8)
    }
    #expect(await dictionary.lookup("a", language: .ko)?.meaning == "한")
    #expect(await dictionary.lookup("a", language: .ko)?.exampleTranslation == "한예")
    #expect(await dictionary.lookup("b", language: .ko) == nil)
    #expect(await dictionary.lookup("b", language: .ja)?.meaning == "日")
  }

  @Test("版が違うファイルは空の辞書として扱う")
  func unsupportedVersion() async {
    let dictionary = PrebuiltDictionary {
      Data(#"{"version":2,"words":{"x":{"ipa":"","pos":[],"exampleEn":"","ja":{"meaning":"x","exampleTranslation":""},"zhHant":{"meaning":"x","exampleTranslation":""}}}}"#.utf8)
    }
    #expect(await dictionary.lookup("x", language: .ja) == nil)
  }
}
