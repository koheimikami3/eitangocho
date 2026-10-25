import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 塗りボタン(白文字・角丸)。
///
/// 既定はアクセント色の主ボタンで、iOS の MobileFilledButton と同じ
/// グラデーション + 影にする(2.2.0 で iOS の意匠に揃えた)。
/// [color] を渡すと(削除の赤など)その単色で塗る。
class AppFilledButton extends StatefulWidget {
  const AppFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.color,
    this.hoverColor,
    this.verticalPadding = 9,
    this.fontSize = 14,
    this.borderRadius = 8,
  });

  final String label;
  final VoidCallback onPressed;

  /// 単色で塗るときの色とホバー色。null ならアクセント色のグラデーション。
  final Color? color;
  final Color? hoverColor;
  // AppOutlinedButton と組み合わせて使う画面で高さを揃えるためのパラメータ。
  // デフォルトはダイアログ・登録フォーム系(プロトタイプの標準ボタン)の値。
  final double verticalPadding;
  final double fontSize;
  final double borderRadius;

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
        // 高さを指定されたとき(入力欄の横に並べて引き伸ばす場合)だけ、
        // Center で文字を上下中央に置く(heightFactor 1 なので、高さに
        // 余裕があるだけの場所では広がらない)。
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: widget.verticalPadding,
          ),
          decoration: _decoration(),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              widget.label,
              // ボタン幅がラベル幅より広い場面(全幅ボタン等)でも中央寄せにする。
              // Container 自体に alignment は付けない(上記コメント参照)ため、
              // Text 側で明示する。
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
                // 日本語フォールバックフォントの行高が大きく、ボタンの上下が
                // プロトタイプより太って見えるため行高を明示する
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    final radius = BorderRadius.circular(widget.borderRadius);
    final color = widget.color;
    if (color != null) {
      return BoxDecoration(
        color: _isHovered ? widget.hoverColor ?? color : color,
        borderRadius: radius,
      );
    }
    final colors = context.colors;
    final palette = context.palette;
    return BoxDecoration(
      gradient: _isHovered
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors.buttonGradientHover,
            )
          : palette.buttonGradient,
      borderRadius: radius,
      boxShadow: palette.buttonShadow,
    );
  }
}
