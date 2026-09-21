import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// macOS 版ポップアップメニューの項目(プロトタイプ準拠: 角丸 5、ホバーで
/// 背景色 + 白文字)。PopupMenuItem 側は padding/height を潰し、この Container が
/// 項目全体の見た目を担う。単語のコンテキストメニューと並び替えメニューで共有する。
class HoverMenuItem extends StatefulWidget {
  const HoverMenuItem({
    required this.label,
    super.key,
    this.color = AppColors.textPrimary,
    this.hoverColor = AppColors.accent,
    this.checked,
  });

  final String label;
  final Color color;
  final Color hoverColor;

  /// 選択中の印。null ならチェック欄ごと出さない(コンテキストメニュー)。
  /// true / false のときは欄を確保し、ラベルの頭を項目間で揃える。
  final bool? checked;

  @override
  State<HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _isHovered ? Colors.white : widget.color;

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
        child: Row(
          children: [
            if (widget.checked != null)
              SizedBox(
                width: 20,
                child: widget.checked!
                    ? Icon(Icons.check, size: 14, color: foreground)
                    : null,
              ),
            Flexible(
              child: Text(
                widget.label,
                style: TextStyle(fontSize: 13, color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
