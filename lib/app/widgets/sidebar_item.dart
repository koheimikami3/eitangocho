import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// サイドバーの項目 1 行。件数は呼び出し側から渡す(空文字ならバッジ非表示)。
class SidebarItem extends StatefulWidget {
  const SidebarItem({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.count = '',
  });

  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.selected
        ? AppColors.sidebarSelected
        : (_isHovered ? const Color(0x0F000000) : Colors.transparent);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.count.isNotEmpty)
                Text(
                  widget.count,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0x61000000),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
