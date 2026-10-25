import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/word/presentation/widgets/hover_menu_item.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版ツールバーの並び替えボタン(全単語のときだけ検索欄の左に出る)。
///
/// 今の並びを「並び順: ○○ ▾」と文字で出し、押すとメニューで選ばせる。
/// 見た目は iOS の並び替えボタンと同じ、淡い青の地 + 青の縁のピル(2.2.0)。
class WordSortButton extends ConsumerWidget {
  const WordSortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final order = ref.watch(
      settingsProvider.select(
        (s) => s.value?.wordSortOrder ?? const SettingsState().wordSortOrder,
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMenu(context, ref, order),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: colors.accentLine),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  context.l10n.sortOrderLabel(order.label(context.l10n)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.accentOnSoft,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 16, color: colors.accentOnSoft),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    WidgetRef ref,
    WordSortOrder current,
  ) async {
    // ボタンの左下にメニューを出す。Overlay は UI 全体拡大(uiScale)の内側に
    // あるため、Overlay 基準の座標に直してから渡す(word_context_menu と同じ理由)。
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final button = context.findRenderObject()! as RenderBox;
    final bottomLeft = button.localToGlobal(
      button.size.bottomLeft(Offset.zero) + const Offset(0, 4),
      ancestor: overlay,
    );
    const orders = WordSortOrder.values;

    final selected = await showMenu<WordSortOrder>(
      context: context,
      position: RelativeRect.fromLTRB(
        bottomLeft.dx,
        bottomLeft.dy,
        bottomLeft.dx,
        bottomLeft.dy,
      ),
      color: context.colors.menuBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.colors.borderAlpha(12)),
      ),
      constraints: const BoxConstraints(minWidth: 180),
      menuPadding: const EdgeInsets.all(4),
      items: [
        for (var i = 0; i < orders.length; i++) ...[
          // 基準が変わるところにだけ線を入れ、昇順・降順を 1 組に見せる。
          if (i > 0 && orders[i - 1].group != orders[i].group)
            const PopupMenuDivider(height: 9),
          PopupMenuItem(
            value: orders[i],
            padding: EdgeInsets.zero,
            height: 0,
            child: HoverMenuItem(
              label: orders[i].label(context.l10n),
              checked: orders[i] == current,
            ),
          ),
        ],
      ],
    );

    if (selected == null || !context.mounted) return;
    await ref.read(settingsProvider.notifier).setWordSortOrder(selected);
  }
}
