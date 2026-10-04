import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_radio_row.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全単語の並び順を選ぶシートを下から出す(iOS 版)。
///
/// 出し方(オーバーレイ色など)は登録・編集シートと同じ [showMobileSheet] を使う。
/// ただし [MobileSheet] は画面高の 88% 固定で 8 行の選択には大きすぎるため、
/// 中身の高さに合わせた枠をここで組む。見た目(下端に付けた上角丸・つまみ・
/// ヘッダの区切り線)は登録・編集シートに揃える(デザインの浮いたカード形は
/// ユーザー判断で採らない)。
Future<void> showMobileWordSortSheet(BuildContext context) {
  return showMobileSheet<void>(
    context: context,
    builder: (_) => const MobileWordSortSheet(),
  );
}

class MobileWordSortSheet extends ConsumerWidget {
  const MobileWordSortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final current = ref.watch(
      settingsProvider.select(
        (s) => s.value?.wordSortOrder ?? const SettingsState().wordSortOrder,
      ),
    );
    const orders = WordSortOrder.values;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: palette.borderAlpha(6)),
                ),
              ),
              child: Column(
                children: [
                  const MobileSheetGrabber(),
                  Container(
                    height: 46,
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.sortSheetTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: palette.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < orders.length; i++) ...[
                    // 基準が変わるところにだけ線を入れ、昇順・降順を 1 組に見せる。
                    if (i > 0 && orders[i - 1].group != orders[i].group)
                      const MobileSettingsDivider(),
                    MobileSettingsRadioRow(
                      label: orders[i].label(context.l10n),
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
