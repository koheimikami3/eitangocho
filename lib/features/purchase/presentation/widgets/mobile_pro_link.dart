import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面の Pro カードへの小さな文字リンク(iOS のみ)。
///
/// 置くのはクイズ結果の広告の下だけ。広告を見たその場で「消せる」と分かる
/// 文脈で、押しても作業を中断させないため。タブバー上のバナーは横に余白が
/// 無く、登録・編集シートは閉じると入力が失われるので置かない。
///
/// 設定タブは切り替えのたびに作り直されて先頭から表示されるため、
/// タブを切り替えるだけで先頭の Pro カードが見える。
class MobileProLink extends ConsumerWidget {
  const MobileProLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return MobilePressable(
      onTap: () {
        ref.read(analyticsLoggerProvider).logProLinkTapped();
        ref.read(mainPageProvider.notifier).selectView(MainView.settings);
      },
      style: MobilePressStyle.text,
      builder: (context, _) => Padding(
        // 文字だけでは押しにくいので、上下に余白を足してタップ領域を広げる。
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          context.l10n.proCoffeeLink,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: palette.textAlpha(55)),
        ),
      ),
    );
  }
}
