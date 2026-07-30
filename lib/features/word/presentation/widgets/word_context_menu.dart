import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/delete_confirm_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
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
    color: const Color.fromRGBO(250, 250, 251, 0.98),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0x1F000000)),
    ),
    constraints: const BoxConstraints(minWidth: 140),
    menuPadding: const EdgeInsets.all(4),
    items: const [
      PopupMenuItem(
        value: _ContextMenuAction.edit,
        padding: EdgeInsets.zero,
        height: 0,
        child: _HoverMenuItem(label: '編集...'),
      ),
      PopupMenuItem(
        value: _ContextMenuAction.delete,
        padding: EdgeInsets.zero,
        height: 0,
        child: _HoverMenuItem(
          label: '削除...',
          color: AppColors.danger,
          hoverColor: AppColors.danger,
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

/// コンテキストメニューの項目(プロトタイプ準拠: 角丸 5、ホバーで背景色 +
/// 白文字)。PopupMenuItem 側は padding/height を潰し、この Container が
/// 項目全体の見た目を担う。
class _HoverMenuItem extends StatefulWidget {
  const _HoverMenuItem({
    required this.label,
    this.color = AppColors.textPrimary,
    this.hoverColor = AppColors.accent,
  });

  final String label;
  final Color color;
  final Color hoverColor;

  @override
  State<_HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<_HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered ? widget.hoverColor : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            color: _isHovered ? Colors.white : widget.color,
          ),
        ),
      ),
    );
  }
}
