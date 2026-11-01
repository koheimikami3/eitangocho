import Testing

@testable import Eitangocho

/// 縦に伸びる入力欄で、Return キーで入った改行だけを取り除くこと。
struct ReturnKeyInputTests {
  @Test func 末尾で押したReturnの改行を取り除く() {
    #expect(ReturnKeyInput.removingReturn(old: "apple", new: "apple\n") == "apple")
  }

  @Test func 途中で押したReturnの改行も取り除く() {
    #expect(ReturnKeyInput.removingReturn(old: "ab", new: "a\nb") == "ab")
  }

  @Test func 改行の隣で押したReturnは押した分だけ取り除く() {
    #expect(ReturnKeyInput.removingReturn(old: "a\nb", new: "a\n\nb") == "a\nb")
  }

  @Test func 自動修正が単語を直しながら改行を入れてもReturnとみなす() {
    #expect(ReturnKeyInput.removingReturn(old: "I dont", new: "I don't\n") == "I don't")
  }

  @Test func 改行を含む文の貼り付けはそのまま残す() {
    #expect(ReturnKeyInput.removingReturn(old: "", new: "first sentence.\nSecond sentence.") == nil)
    #expect(ReturnKeyInput.removingReturn(old: "x", new: "xa\nb\nc") == nil)
  }

  @Test func もとから改行を含む文を編集しても改行を残す() {
    #expect(ReturnKeyInput.removingReturn(old: "one\ntwo", new: "one\ntwos") == nil)
    #expect(ReturnKeyInput.removingReturn(old: "one\ntwo", new: "one\ntw") == nil)
  }

  @Test func 改行の無い入力は何もしない() {
    #expect(ReturnKeyInput.removingReturn(old: "app", new: "appl") == nil)
  }
}
