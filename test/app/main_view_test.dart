import 'package:eitangocho/app/main_page_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ⌘F(検索フォーカス)の有効/無効はこの getter で決まる。
  test('hasSearchField は学習中・全単語のみ true', () {
    expect(MainView.learning.hasSearchField, isTrue);
    expect(MainView.allWords.hasSearchField, isTrue);
    expect(MainView.quiz.hasSearchField, isFalse);
    expect(MainView.registration.hasSearchField, isFalse);
    expect(MainView.settings.hasSearchField, isFalse);
  });
}
