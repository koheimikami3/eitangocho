import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ライト / ダークで地の色と本文色が入れ替わる', () {
    expect(AppPalette.light.brightness, Brightness.light);
    expect(AppPalette.dark.brightness, Brightness.dark);
    expect(AppPalette.light.isDark, isFalse);
    expect(AppPalette.dark.isDark, isTrue);

    // デザインの THEME_LIGHT / THEME_DARK の値。
    expect(AppPalette.light.background, const Color(0xFFFFFFFF));
    expect(AppPalette.dark.background, const Color(0xFF1C1C1E));
    expect(AppPalette.light.text, const Color(0xFF1D1D1F));
    expect(AppPalette.dark.text, const Color(0xFFF5F5F7));
  });

  test('アクセント色はライト / ダークで共通', () {
    expect(AppPalette.dark.accent, AppPalette.light.accent);
  });

  test('textAlpha / borderAlpha はライトが黒ベース、ダークが白ベース', () {
    // デザインの --t70 / --b10 に対応。
    expect(AppPalette.light.textAlpha(70).r, 0);
    expect(AppPalette.light.textAlpha(70).a, closeTo(0.7, 0.01));
    expect(AppPalette.dark.textAlpha(70).r, 1);
    expect(AppPalette.dark.textAlpha(70).a, closeTo(0.7, 0.01));

    expect(AppPalette.light.borderAlpha(10).r, 0);
    expect(AppPalette.dark.borderAlpha(10).r, 1);
  });

  test('品詞バッジはライト / ダークで別配色になる', () {
    for (final pos in PartOfSpeech.values) {
      final (lightBg, lightFg) = AppPalette.light.posBadge(pos);
      final (darkBg, darkFg) = AppPalette.dark.posBadge(pos);
      expect(lightBg, isNot(darkBg), reason: '${pos.name} の背景');
      expect(lightFg, isNot(darkFg), reason: '${pos.name} の文字色');
    }
  });

  test('AppPalette.of は Brightness から対応するパレットを返す', () {
    expect(AppPalette.of(Brightness.light), AppPalette.light);
    expect(AppPalette.of(Brightness.dark), AppPalette.dark);
  });

  testWidgets('context.palette は ThemeData.brightness に追従する', (tester) async {
    late AppPalette seen;
    Future<void> pump(Brightness brightness) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Builder(
            builder: (context) {
              seen = context.palette;
              return const SizedBox();
            },
          ),
        ),
      );
      // MaterialApp はテーマ変更を AnimatedTheme で補間するため、
      // 切り替え直後は前のテーマのままになる。落ち着くまで進める。
      await tester.pumpAndSettle();
    }

    await pump(Brightness.light);
    expect(seen, AppPalette.light);

    await pump(Brightness.dark);
    expect(seen, AppPalette.dark);
  });
}
