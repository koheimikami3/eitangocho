import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_radio_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全単語の並び順を選ぶシートを下から出す(iOS 版)。
///
/// 出し方(オーバーレイ色など)は登録・編集シートと同じ [showMobileSheet] を使う。
/// ただし [MobileSheet] は画面高の 88% 固定で 8 行の選択には大きすぎるため、
/// 中身の高さに合わせた枠をここで組む。立体案では画面の下端に付けず、
/// 左右と下を空けて四隅を丸めた浮いたカードにする(iOS のアクションシート風)。
Future<void> showMobileWordSortSheet(BuildContext context) {
  return showMobileSheet<void>(
    context: context,
    builder: (_) => const MobileWordSortSheet(),
  );
}

class MobileWordSortSheet extends ConsumerWidget {
  const MobileWordSortSheet({super.key});

  /// 画面の左右・下端との間隔。
  static const _margin = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final current = ref.watch(
      settingsProvider.select(
        (s) => s.value?.wordSortOrder ?? const SettingsState().wordSortOrder,
      ),
    );
    const orders = WordSortOrder.values;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: _margin),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _margin),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color(0x47101828), // rgba(16,24,40,0.28)
              blurRadius: 30,
              offset: Offset(0, -6),
            ),
            BoxShadow(color: palette.borderAlpha(10), spreadRadius: 0.5),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: palette.borderAlpha(8)),
                ),
              ),
              child: Text(
                '並び替え',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: palette.text,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < orders.length; i++) ...[
                    // 基準が変わるところにだけ線を入れ、昇順・降順を 1 組に見せる。
                    if (i > 0 && orders[i - 1].group != orders[i].group)
                      const MobileSettingsDivider(),
                    MobileSettingsRadioRow(
                      label: orders[i].label,
                      selected: orders[i] == current,
                      onTap: () {
                        ref
                            .read(settingsProvider.notifier)
                            .setWordSortOrder(orders[i]);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
