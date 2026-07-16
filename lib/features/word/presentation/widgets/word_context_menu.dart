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
  final selected = await showMenu<_ContextMenuAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
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
