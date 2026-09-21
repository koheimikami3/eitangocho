import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版フォームの項目を縦に並べ、項目と項目の間に区切り線を引く
/// (単語の登録・編集シート)。
///
/// 立体案では入力欄を内側の影で沈めて枠線を持たないため、間隔だけだと項目の
/// 境目がぼやける。各項目の上下に余白を取り、間に淡い線を入れて区切る。
class MobileFormRows extends StatelessWidget {
  const MobileFormRows({required this.children, super.key});

  final List<Widget> children;

  /// 項目の上下の余白。デザインは 14 だが、区切り線との間が詰まって見えたため
  /// ユーザー判断で広げた。
  static const _verticalPadding = 18.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
            // 最後の項目の下には引かない(下に続くのはエラー文や削除ボタン)。
            decoration: i < children.length - 1
                ? BoxDecoration(
                    border: Border(bottom: BorderSide(color: palette.rowLine)),
                  )
                : null,
            child: children[i],
          ),
      ],
    );
  }
}
