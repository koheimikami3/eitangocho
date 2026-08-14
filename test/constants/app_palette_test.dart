import 'dart:math' as math;

import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG の相対輝度。半透明の色は重ねる先([under])と合成してから測る。
double _luminance(Color c, Color under) {
  double channel(double fg, double bg) {
    final v = fg * c.a + bg * (1 - c.a);
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel(c.r, under.r) +
      0.7152 * channel(c.g, under.g) +
      0.0722 * channel(c.b, under.b);
}

/// [foreground] を [background] の上に載せたときのコントラスト比。
/// 背景が半透明なら [under](その下の面)と合成してから測る。
double _contrastRatio(Color foreground, Color background, Color under) {
  final bgLum = _luminance(background, under);
  final composited = Color.lerp(
    under,
    background.withValues(alpha: 1),
    background.a,
  )!;
  final fgLum = _luminance(foreground, composited);
  return (math.max(bgLum, fgLum) + 0.05) / (math.min(bgLum, fgLum) + 0.05);
}

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

  test('品詞バッジのライト配色は enum の定数と一致する(macOS が直接引くため)', () {
    for (final pos in PartOfSpeech.values) {
      expect(AppPalette.light.posBadge(pos), (
        pos.badgeBackground,
        pos.badgeForeground,
      ), reason: pos.name);
    }
  });

  test('品詞バッジの文字は背景に対して 4.5:1 以上ある(10px の小さな文字のため)', () {
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      for (final pos in PartOfSpeech.values) {
        final (bg, fg) = palette.posBadge(pos);
        // チップはカードの上に乗るため、半透明の背景はカード面と合成する。
        expect(
          _contrastRatio(fg, bg, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.isDark ? 'dark' : 'light'} / ${pos.name}',
        );
      }
    }
  });

  test('発音ボタンの文字・アイコンは淡い地に対して 4.5:1 以上ある', () {
    // ラベルは 12〜13px で「大きい文字」の 3:1 基準は使えないため 4.5:1 を要求する。
    // デザインの #1E7FD6 のままだとライトが 3.77:1 で足りず、色相を保ったまま
    // 明度を下げた経緯がある(AppColors.accentOnSoft 参照)。
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      expect(
        _contrastRatio(
          palette.accentOnSoft,
          palette.accentSoft,
          palette.surface,
        ),
        greaterThanOrEqualTo(4.5),
        reason: palette.isDark ? 'dark' : 'light',
      );
    }

    // macOS の hover は地が濃くなるぶんコントラストが下がる。ここも割らない。
    expect(
      _contrastRatio(
        AppColors.accentOnSoft,
        AppColors.accentSoftHover,
        AppPalette.light.surface,
      ),
      greaterThanOrEqualTo(4.5),
      reason: 'macOS hover',
    );
  });

  test('Pro の購入ボタンと復元行は 4.5:1 以上ある', () {
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      final theme = palette.isDark ? 'dark' : 'light';

      // 13px のラベル。デザインの #1E7FD6 のままだと白文字が 4.15:1 で
      // 足りないため、発音ボタンと同じ濃い青に振り直してある。
      expect(
        _contrastRatio(Colors.white, palette.proButton, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '$theme / 購入ボタン',
      );

      // 復元行はカードの地に直接載る 13px。accent(#429FF0)では届かない。
      expect(
        _contrastRatio(palette.accentOnSoft, palette.surface, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: '$theme / 購入を復元',
      );
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
