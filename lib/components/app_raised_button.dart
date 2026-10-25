import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 影で浮かせた面のボタン(副操作)。
///
/// iOS のクイズの「忘れていた」(MobileRaisedSurface の面ボタン)に相当する。
/// 枠線は持たず、カードと同じ影([AppPalette.elevation])で輪郭を出す。
/// ホバーでは他のボタン・行と同じグレーの地にする。
class AppRaisedButton extends StatefulWidget {
  const AppRaisedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.textColor,
    this.verticalPadding = 9,
    this.fontSize = 14,
    this.borderRadius = 8,
  });

  final String label;
  final VoidCallback onPressed;

  /// 文字色。null なら本文色(AppColors.textPrimary)。
  final Color? textColor;
  final double verticalPadding;
  final double fontSize;
  final double borderRadius;

  @override
  State<AppRaisedButton> createState() => _AppRaisedButtonState();
}

class _AppRaisedButtonState extends State<AppRaisedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          decoration: BoxDecoration(
            color: _isHovered ? colors.rowHoverBackground : colors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: context.palette.elevation,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.textColor ?? colors.textPrimary,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
