import 'package:eitangocho/app/app_route_observer.dart';
import 'package:eitangocho/app/main_page.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_fonts.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:eitangocho/utils/app_locale.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:eitangocho/utils/window_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリのルートウィジェット。
class EitangochoApp extends ConsumerWidget {
  const EitangochoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 設定の拡大率(ロード前は既定値)。変更すると全体が即時リスケールされる。
    // iOS では拡大を行わないため、設定を watch する必要もない。
    final scale = AppPlatform.isMacOS
        ? ref.watch(settingsProvider).value?.uiScale ??
              AppDimensions.defaultUiScale
        : 1.0;

    // 配色は設定で切り替える(macOS は 2.11.1 から。それまではライト固定)。
    // ロード前はライト。
    final appearanceProvider = settingsProvider.select(
      (s) => s.value?.appearance,
    );
    final palette = AppPalette.of(switch (ref.watch(appearanceProvider)) {
      AppAppearance.dark => Brightness.dark,
      AppAppearance.light || null => Brightness.light,
    });
    // macOS は AppKit が描く部分(信号機ボタン等)にも伝える。設定のロード完了
    // (null → 値)でも呼ばれるので、起動時の分もこれで足りる。
    if (AppPlatform.isMacOS) {
      ref.listen(appearanceProvider, (_, next) {
        if (next != null) {
          setWindowAppearance(dark: next == AppAppearance.dark);
        }
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(palette),
      // 表示言語は端末の優先言語から AppLocale.resolve で決める(対応外は英語)。
      // 生成された AppLocalizations.supportedLocales には gen-l10n の都合で
      // 置いた素の zh も入るため、対応言語は AppLocale.supported を渡す。
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocale.supported,
      localeListResolutionCallback: (locales, _) => AppLocale.resolve(locales),
      // 「上に別の画面が積まれたか」をバナー広告が知るために要る。
      navigatorObservers: [appRouteObserver],
      // UI 全体をブラウザズーム相当で拡大する(設定 uiScale)。
      // 縮小サイズでレイアウトしてから拡大描画する。Navigator ごと包むため
      // ダイアログ・メニューにも一律に適用される。
      //
      // これは macOS 専用の機能。iOS では OS の文字サイズ設定に委ね、
      // MediaQuery.size の差し替えも行わない(セーフエリアの計算と噛み合わず、
      // ノッチ・ホームインジケータ周りのレイアウトが崩れるため)。
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final themed = _withAppFonts(context, child);
        if (!AppPlatform.isMacOS) return themed;
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              constraints.maxWidth / scale,
              constraints.maxHeight / scale,
            );
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(size: size),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                // ルートからの tight constraints は SizedBox では覆せないため、
                // OverflowBox で断ち切って縮小サイズでレイアウトさせる。
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: size.width,
                  maxWidth: size.width,
                  minHeight: size.height,
                  maxHeight: size.height,
                  child: themed,
                ),
              ),
            );
          },
        );
      },
      home: const MainPage(),
    );
  }

  /// 同梱フォントを文字のテーマに当てる。
  ///
  /// 和文・繁体字の優先順は解決済みの表示言語で決めるため、[ThemeData] の
  /// fontFamily ではなく、Localizations より下にある builder の中で当てる。
  /// 各ウィジェットの TextStyle は fontFamily を持たないので、ここで当てた
  /// フォントがそのまま継承される。
  Widget _withAppFonts(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final fallback = AppFonts.cjkFallback(Localizations.localeOf(context));
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          fontFamily: AppFonts.sans,
          fontFamilyFallback: fallback,
        ),
        primaryTextTheme: theme.primaryTextTheme.apply(
          fontFamily: AppFonts.sans,
          fontFamilyFallback: fallback,
        ),
      ),
      child: child,
    );
  }

  /// パレットから ThemeData を組む。
  /// ウィジェット側は `context.palette` で配色を引くため、ここで設定するのは
  /// Flutter 側が握っている部分(地の色・カーソル・選択色)だけでよい。
  ThemeData _buildTheme(AppPalette palette) => ThemeData(
    brightness: palette.brightness,
    scaffoldBackgroundColor: palette.background,
    colorSchemeSeed: palette.accent,
    dialogTheme: DialogThemeData(backgroundColor: palette.surface),
    // 白で塗った入力欄にマウスを当てると、Material 既定では黒 4% が重なって
    // グレーになり、地に溶けて使えない欄のように見える。macOS 標準の入力欄と
    // 同じく、ホバーでは見た目を変えない(I 字カーソルで入力できると分かる)。
    inputDecorationTheme: const InputDecorationThemeData(
      hoverColor: Colors.transparent,
    ),
    // カーソルは web の既定キャレット相当の本文色にする。
    // 選択ハイライト・ハンドルはアクセント色を薄く敷く。
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.text,
      selectionHandleColor: palette.accent,
      selectionColor: palette.accent.withValues(alpha: 0.2),
    ),
  );
}
