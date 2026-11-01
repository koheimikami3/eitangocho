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

  @Test func 文字を選択してReturnを押したら改行だけを取り除く() {
    // 末尾の "le" を選択して Return(選択していた文字は消える)。全文を選択して "app\n" を貼り付けたときも同じ値になる。
    #expect(ReturnKeyInput.removingReturn(old: "apple", new: "app\n") == "app")
  }

  @Test func 自動修正が文字を減らしながら改行を入れても直した単語を残す() {
    #expect(ReturnKeyInput.removingReturn(old: "helllo", new: "hello\n") == "hello")
    // 末尾の余分な文字を直したときに、誤字へ巻き戻さない。
    #expect(ReturnKeyInput.removingReturn(old: "helloo", new: "hello\n") == "hello")
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
