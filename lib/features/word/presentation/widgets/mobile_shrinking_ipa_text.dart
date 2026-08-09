import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 学習中カードの発音記号。幅に収まらないときは字を縮めて 1 行に収める。
///
/// 折り返させるとカードごとにヘッダの高さが変わり、2 列に並べたときに
/// 単語の位置が揃わない。IPA は読めれば足りる補助情報なので、行を増やす
/// より字を小さくする方を採る。
///
/// [FittedBox] を使わないのは下限が無いため。長い IPA では読めない大きさまで
/// 潰れるので、[minFontSize] で止めて、そこでも溢れる分は末尾を省略する。
class MobileShrinkingIpaText extends StatelessWidget {
  const MobileShrinkingIpaText({required this.ipa, super.key});

  final String ipa;

  /// 通常の字送り(カードの他の補助テキストと同じ 11px)。
  static const maxFontSize = 11.0;

  /// これ以上は縮めない下限。
  static const minFontSize = 8.0;

  static const _step = 0.5;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // iOS は OS の文字サイズ設定に従うため、計測にも同じ倍率を掛けないと
    // 大きい設定で溢れ、小さい設定で無駄に縮む。
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = maxFontSize;
        while (fontSize > minFontSize &&
            _widthOf(fontSize, textScaler) > constraints.maxWidth) {
          fontSize -= _step;
        }
        return Text(
          ipa,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _styleOf(fontSize).copyWith(color: palette.textAlpha(45)),
        );
      },
    );
  }

  static TextStyle _styleOf(double fontSize) =>
      TextStyle(fontSize: fontSize, fontFamily: 'Menlo');

  double _widthOf(double fontSize, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: ipa, style: _styleOf(fontSize)),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
