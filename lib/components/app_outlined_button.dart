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
    this.verticalPadding = 9,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 8,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;
  final Color hoverBackground;
  // AppFilledButton と組み合わせて使う画面で高さを揃えるためのパラメータ。
  // デフォルトはダイアログ・登録フォーム系(プロトタイプの標準ボタン)の値。
  final double verticalPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;

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
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: widget.verticalPadding,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverBackground : Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
