import 'package:eitangocho/app/app_route_observer.dart';
import 'package:eitangocho/app/main_page.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/utils/app_platform.dart';
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

    // 配色は iOS のみ設定で切り替えられる。macOS はライト固定
    // (1.0 でリリース済みの外観を変えないため)。
    final palette = AppPlatform.isMacOS
        ? AppPalette.light
        : AppPalette.of(switch (ref.watch(
            settingsProvider.select((s) => s.value?.appearance),
          )) {
            AppAppearance.dark => Brightness.dark,
            AppAppearance.light || null => Brightness.light,
          });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(palette),
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
        if (!AppPlatform.isMacOS) return child;
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
                  child: child,
                ),
              ),
            );
          },
        );
      },
      home: const MainPage(),
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
    // カーソルは web の既定キャレット相当の本文色にする。
    // 選択ハイライト・ハンドルはアクセント色を薄く敷く。
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.text,
      selectionHandleColor: palette.accent,
      selectionColor: palette.accent.withValues(alpha: 0.2),
    ),
  );
}
