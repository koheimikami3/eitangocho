import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// プロトタイプ様式の枠線ボタン(面の色の地・文字色指定可)。
class AppOutlinedButton extends StatefulWidget {
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.textColor,
    this.hoverBackground,
    this.verticalPadding = 9,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 8,
  });

  final String label;
  final VoidCallback onPressed;

  /// 文字色。null なら本文色(AppColors.textPrimary)。
  final Color? textColor;

  /// ホバー中の地。null なら他のボタン・行と同じグレー(AppColors.rowHoverBackground)。
  final Color? hoverBackground;
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
    final colors = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        // alignment を指定すると loose 制約下(空状態の中央配置等)で
        // Container が横いっぱいに広がるため、AppFilledButton と同じく
        // テキスト + padding に幅を任せ、中央寄せは Text 側で行う。
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: widget.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.hoverBackground ?? colors.rowHoverBackground
                : colors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: colors.borderStrong),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.textColor ?? colors.textPrimary,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
