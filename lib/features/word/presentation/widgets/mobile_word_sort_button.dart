import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_sort_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版ヘッダの並び替えボタン(全単語のときだけ検索欄の下の行に出る)。
///
/// 現在の並び順をラベルにしたピル形。どの順で並んでいるかがボタンを見るだけで
/// 分かるので、既定以外のときに色で知らせる必要は無い(常にアクセント色)。
class MobileWordSortButton extends ConsumerWidget {
  const MobileWordSortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final order = ref.watch(
      settingsProvider.select(
        (s) => s.value?.wordSortOrder ?? const SettingsState().wordSortOrder,
      ),
    );

    return MobilePressable(
      onTap: () => showMobileWordSortSheet(context),
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: palette.accentSoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: palette.accentLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 14, color: palette.accentOnSoft),
            const SizedBox(width: 6),
            Text(
              order.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.accentOnSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
