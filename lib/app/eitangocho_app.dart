import 'package:eitangocho/app/main_page.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリのルートウィジェット。
class EitangochoApp extends ConsumerWidget {
  const EitangochoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 設定の拡大率(ロード前は既定値)。変更すると全体が即時リスケールされる。
    final scale =
        ref.watch(settingsProvider).value?.uiScale ??
        AppDimensions.defaultUiScale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: AppColors.accent,
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        // カーソルは web の既定キャレット相当の黒(テキスト色)にする。
        // 選択ハイライト・ハンドルはアクセント色を薄く敷く。
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.textPrimary,
          selectionHandleColor: AppColors.accent,
          selectionColor: Color(0x33429FF0),
        ),
      ),
      // UI 全体をブラウザズーム相当で拡大する(設定 uiScale)。
      // 縮小サイズでレイアウトしてから拡大描画する。Navigator ごと包むため
      // ダイアログ・メニューにも一律に適用される。
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
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
}
