import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/app_menu_bar.dart';
import 'package:eitangocho/app/widgets/toolbar_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// native ⌘ 発火自体は widget test で再現できないため、ここでは
// buildMenus の配線(⌘N/⌘F が正しいコールバックに繋がるか)と
// ⌘F の有効/無効切替、および検索フォーカス要求の実効を検証する。
void main() {
  // 指定メニュー配下の項目を label で引く小ヘルパー。
  PlatformMenuItem itemOf(
    List<PlatformMenuItem> menus,
    String menuLabel,
    String itemLabel,
  ) {
    final menu = menus.firstWhere((m) => m.label == menuLabel) as PlatformMenu;
    return menu.menus.firstWhere((i) => i.label == itemLabel);
  }

  group('buildMenus', () {
    test('⌘N の項目は onRegister に配線される', () {
      var registered = false;
      final menus = AppMenuBar.buildMenus(
        onRegister: () => registered = true,
        onSearch: () {},
      );

      itemOf(menus, '単語', '単語を登録').onSelected!();
      expect(registered, isTrue);
    });

    test('検索フィールドがあるとき ⌘F は onSearch に配線される', () {
      var searched = false;
      final menus = AppMenuBar.buildMenus(
        onRegister: () {},
        onSearch: () => searched = true,
      );

      final searchItem = itemOf(menus, '編集', '検索');
      expect(searchItem.onSelected, isNotNull);
      searchItem.onSelected!();
      expect(searched, isTrue);
    });

    test('検索フィールドが無いとき(onSearch=null)⌘F は無効になる', () {
      final menus = AppMenuBar.buildMenus(onRegister: () {}, onSearch: null);

      // onSelected が null だと項目もショートカットも無効になる。
      expect(itemOf(menus, '編集', '検索').onSelected, isNull);
    });
  });

  testWidgets('AppMenuBar は child を描画する', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppMenuBar(
            child: Text('body', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );

    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('検索フォーカスノードで検索フィールドにフォーカスできる', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                return const ToolbarSearchField();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(toolbarSearchFocusProvider).hasFocus, isFalse);

    // ⌘F 押下時に AppMenuBar が呼ぶのと同じ操作。
    container.read(toolbarSearchFocusProvider).requestFocus();
    await tester.pump();

    expect(container.read(toolbarSearchFocusProvider).hasFocus, isTrue);

    // EditableText のカーソル点滅 Timer を残さないよう、フォーカスを外して
    // 破棄まで進める。
    container.read(toolbarSearchFocusProvider).unfocus();
    await tester.pump();
  });

  // ⌘N の発火先。ウィジェット不要のためプレーンな test で回す
  // (autoDispose provider の破棄 Timer が FakeAsync で pending 扱いになるのを避ける)。
  test('selectView(registration) で登録ビューに切り替わる(⌘N の発火先)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mainPageProvider).view, MainView.learning);

    container.read(mainPageProvider.notifier).selectView(MainView.registration);

    expect(container.read(mainPageProvider).view, MainView.registration);
  });
}
