import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/delete_confirm_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 右クリックで「編集...」「削除...」のコンテキストメニューを表示する。
Future<void> showWordContextMenu(
  BuildContext context,
  WidgetRef ref,
  Word word,
  Offset position,
) async {
  // position はウィンドウのグローバル座標。Overlay は UI 全体拡大
  // (EitangochoApp の uiScale)の内側にあるため、変換を挟まないと
  // メニューが右下方向にずれる。globalToLocal が拡大の逆変換も行う。
  final overlay =
      Overlay.of(context).context.findRenderObject()! as RenderBox;
  final local = overlay.globalToLocal(position);
  final selected = await showMenu<_ContextMenuAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      local.dx,
      local.dy,
      local.dx,
      local.dy,
    ),
    items: const [
      PopupMenuItem(value: _ContextMenuAction.edit, child: Text('編集...')),
      PopupMenuItem(
        value: _ContextMenuAction.delete,
        child: Text('削除...', style: TextStyle(color: AppColors.danger)),
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
