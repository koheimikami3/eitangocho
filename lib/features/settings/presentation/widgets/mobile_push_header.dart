import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版のプッシュ遷移先ヘッダ(戻るボタン + 中央タイトル)。
///
/// 戻るの文字色はデザインの `#1e7fd6` ではなく `palette.accent` を使う。
/// デザイン内で `#1e7fd6` は広告 / Pro の導線に付く色で、アプリ本体の
/// アクセント(`#429FF0`)とは役割が違うため、トークン側に寄せている。
class MobilePushHeader extends StatelessWidget {
  const MobilePushHeader({
    required this.title,
    required this.backLabel,
    super.key,
  });

  final String title;

  /// 戻り先の画面名(iOS の慣習どおり「‹ 設定」のように出す)
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.borderAlpha(8))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // タイトルは画面中央に置く。戻るボタンのラベル長で
                // 中央がずれないよう、Row ではなく重ねる。
                Positioned.fill(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '‹',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          backLabel,
                          style: TextStyle(fontSize: 16, color: palette.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
