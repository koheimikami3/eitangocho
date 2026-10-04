import 'dart:math' as math;

import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
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

    // --bg(ライトは 2.2.0 の値)/ --text の値。
    expect(AppPalette.light.background, const Color(0xFFF7F8FA));
    expect(AppPalette.dark.background, const Color(0xFF131315));
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
    // iOS のライトは刷新案 A のデザイン判断で #1B78C2(4.14:1)を採用しており
    // 例外とする(AppPalette.accentOnSoft 参照)。ダークと macOS は割らない。
    expect(
      _contrastRatio(
        AppPalette.dark.accentOnSoft,
        AppPalette.dark.accentSoft,
        AppPalette.dark.surface,
      ),
      greaterThanOrEqualTo(4.5),
      reason: 'iOS dark',
    );
    expect(
      _contrastRatio(
        AppColors.accentOnSoft,
        AppColors.accentSoft,
        Colors.white,
      ),
      greaterThanOrEqualTo(4.5),
      reason: 'macOS',
    );

    // macOS の hover は地が濃くなるぶんコントラストが下がる。ここも割らない。
    expect(
      _contrastRatio(
        AppColors.accentOnSoft,
        AppColors.accentSoftHover,
        Colors.white,
      ),
      greaterThanOrEqualTo(4.5),
      reason: 'macOS hover',
    );
  });

  test('購入を復元などカード地に直接載る青文字は 4.5:1 以上ある', () {
    // 13px の文字。accent(#429FF0)では届かないため accentOnSoft を使う。
    // 購入ボタン(accent のベタ + 白文字)は主ボタンと同じ扱いの例外で、ここでは測らない。
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      expect(
        _contrastRatio(palette.accentOnSoft, palette.surface, palette.surface),
        greaterThanOrEqualTo(4.5),
        reason: palette.isDark ? 'dark' : 'light',
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
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
