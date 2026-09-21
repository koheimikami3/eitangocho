import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_sort_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版ヘッダの並び替えボタン(全単語のときだけ検索欄の右に出る)。
///
/// 高さは検索欄に合わせて親の Row から受け取り、正方形にする。
/// 既定(登録日が新しい順)以外で並べているときはアクセント色にして、
/// 並びを変えたままになっていることが一覧を見ただけで分かるようにする。
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
    final active = order != WordSortOrder.newest;

    return GestureDetector(
      onTap: () => showMobileWordSortSheet(context),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: active ? palette.accentSoft : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active ? palette.accentLine : palette.softBorder,
            ),
          ),
          child: Icon(
            Icons.swap_vert,
            size: 20,
            color: active ? palette.accent : palette.textAlpha(55),
          ),
        ),
      ),
    );
  }
}
