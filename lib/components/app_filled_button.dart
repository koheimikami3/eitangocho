import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// プロトタイプ様式の塗りボタン(白文字・角丸)。
class AppFilledButton extends StatefulWidget {
  const AppFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.color = AppColors.accent,
    this.hoverColor = AppColors.accentHover,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color hoverColor;

  @override
  State<AppFilledButton> createState() => _AppFilledButtonState();
}

class _AppFilledButtonState extends State<AppFilledButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        // alignment を指定すると高さ制約のある場所(ツールバー等)で
        // Container が上下いっぱいに広がるため、テキスト + padding に任せる。
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.color,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              // 日本語フォールバックフォントの行高が大きく、ボタンの上下が
              // プロトタイプより太って見えるため行高を明示する
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
