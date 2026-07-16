import 'package:eitangocho/app/eitangocho_app.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // wordListProvider は drift の watch() ストリームを直接公開しており、
  // widget テスト終了時の暗黙的破棄で drift 側の購読解除タイマーと
  // flutter_test の "pending timer" 検査が衝突するため、シェルの表示のみを
  // 検証するこのテストでは静的な Stream に差し替えて DB に触れないようにする。
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordListProvider.overrideWith((ref) => Stream.value(const <Word>[])),
        ],
        child: const EitangochoApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('サイドバーの項目とツールバーのタイトルが表示される', (tester) async {
    await pumpApp(tester);

    expect(find.text('単語帳'), findsOneWidget);
    expect(find.text('全単語'), findsNWidgets(2));
    expect(find.text('単語を登録'), findsOneWidget);
    expect(find.text('ローカル DB に保存済み'), findsOneWidget);
    expect(find.text('＋ 単語を登録'), findsOneWidget);
  });

  testWidgets('サイドバー項目クリックでビューが切り替わる', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('単語を登録').first);
    await tester.pumpAndSettle();

    expect(find.text('単語を登録'), findsNWidgets(2));
  });
}
