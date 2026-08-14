import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// macOS 版の設定セクションの下に置く説明文。
///
/// 直前のカードに掛かる補足なので、セクションとの間は 8px 空ける
/// (空ける側は呼び出し元が持つ)。[color] は同期エラーのように
/// 色を変えたいときだけ渡す。
class SettingsCaption extends StatelessWidget {
  const SettingsCaption(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        height: 1.6,
        color: color ?? AppColors.textQuaternary,
      ),
    );
  }
}
