import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// プロトタイプ様式の枠線ボタン(白地・文字色指定可)。
class AppOutlinedButton extends StatefulWidget {
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.textColor = AppColors.textPrimary,
    this.hoverBackground = AppColors.rowHoverBackground,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;
  final Color hoverBackground;

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverBackground : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
