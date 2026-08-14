import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定セクションの下に置く説明文。
///
/// 直前のカードに掛かる補足なので、セクションとの間は 8px 空ける
/// (空ける側は呼び出し元が持つ)。[color] は同期エラーのように
/// 色を変えたいときだけ渡す。
class MobileSettingsCaption extends StatelessWidget {
  const MobileSettingsCaption(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        height: 1.6,
        color: color ?? palette.textAlpha(40),
      ),
    );
  }
}
