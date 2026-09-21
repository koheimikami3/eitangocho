import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/domain/author_app.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 設定の「作者の他のアプリ」に出すカード。タップで App Store を開く。
///
/// **iOS 専用**。紹介するアプリが iPhone 専用で、macOS から踏んでも
/// インストールできないため([AuthorApp] 参照)。
class MobileAuthorAppCard extends StatelessWidget {
  const MobileAuthorAppCard({super.key});

  /// App Store を外部で開く。
  ///
  /// **`LaunchMode.externalApplication` を明示するのが要点**。既定の
  /// `platformDefault` は iOS ではアプリ内 Safari になり、App Store アプリに
  /// 渡らない(発音リンクと同じ理由。google_translate_url.dart 参照)。
  Future<void> _open() => launchUrl(
    Uri.parse(AuthorApp.appStoreUrl),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MobilePressable(
      onTap: _open,
      style: MobilePressStyle.row,
      builder: (context, pressed) => Container(
        decoration: BoxDecoration(
          color: pressed ? palette.surfaceAlt : palette.surface,
          borderRadius: BorderRadius.circular(AppDimensions.mobileCardRadius),
          boxShadow: palette.elevation,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              // 枠線は角丸の内側に重ねて引く(foregroundDecoration)。
              // 明るいアイコンがカード地に溶けないよう縁を作るのが目的で、
              // 外側に足すと 52px の見た目が狂う。
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.borderAlpha(10)),
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(AuthorApp.iconAsset, width: 52, height: 52),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthorApp.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AuthorApp.tagline,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: palette.textAlpha(45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AuthorApp.availability,
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.textAlpha(40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 「入手」は App Store のボタンに合わせた見た目のラベルで、
            // ボタンではない(タップ領域はカード全体)。押せる青の面は
            // accent のベタ + 白文字に統一している(購入ボタンと同じ)。
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: palette.buttonGradient,
                borderRadius: BorderRadius.circular(99),
                boxShadow: palette.buttonShadow,
              ),
              child: const Text(
                '入手',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
