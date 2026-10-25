import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/delete_confirm_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/hover_menu_item.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 右クリックで「編集...」「削除...」のコンテキストメニューを表示する。
/// macOS 専用。iOS は編集シート内の「この単語を削除...」を削除導線にしており、
/// 長押しメニューは持たない(デザイン準拠)。
Future<void> showWordContextMenu(
  BuildContext context,
  WidgetRef ref,
  Word word,
  Offset position,
) async {
  // position はウィンドウのグローバル座標。Overlay は UI 全体拡大
  // (EitangochoApp の uiScale)の内側にあるため、変換を挟まないと
  // メニューが右下方向にずれる。globalToLocal が拡大の逆変換も行う。
  final colors = context.colors;
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final local = overlay.globalToLocal(position);
  final selected = await showMenu<_ContextMenuAction>(
    context: context,
    position: RelativeRect.fromLTRB(local.dx, local.dy, local.dx, local.dy),
    color: colors.menuBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: colors.borderAlpha(12)),
    ),
    constraints: const BoxConstraints(minWidth: 140),
    menuPadding: const EdgeInsets.all(4),
    items: [
      PopupMenuItem(
        value: _ContextMenuAction.edit,
        padding: EdgeInsets.zero,
        height: 0,
        child: HoverMenuItem(label: context.l10n.editEllipsis),
      ),
      PopupMenuItem(
        value: _ContextMenuAction.delete,
        padding: EdgeInsets.zero,
        height: 0,
        child: HoverMenuItem(
          label: context.l10n.deleteEllipsis,
          color: colors.danger,
          hoverColor: colors.danger,
        ),
      ),
    ],
  );

  if (!context.mounted) return;
  switch (selected) {
    case _ContextMenuAction.edit:
      await showEditWordDialog(context, ref, word);
    case _ContextMenuAction.delete:
      await showDeleteConfirmDialog(context, ref, word);
    case null:
      break;
  }
}

enum _ContextMenuAction { edit, delete }
