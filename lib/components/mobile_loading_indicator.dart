import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の読み込み中表示。領域の中央にアクセント色の小さなスピナーを出す。
///
/// 寸法と配色は単語登録シートの辞書取得中の表示と揃える。
/// タブの中身はタブバーとバナー広告の下まで広がっており、重なる分は
/// MediaQuery の下端 padding で渡される。その分を除いた見えている領域の
/// 中央に置く。
class MobileLoadingIndicator extends StatelessWidget {
  const MobileLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: palette.accent,
            backgroundColor: palette.borderAlpha(10),
          ),
        ),
      ),
    );
  }
}
