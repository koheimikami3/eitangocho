import 'package:flutter/material.dart';

/// iOS 版フォームの項目を縦に並べる(単語の登録・編集シート)。
///
/// 2.0.0 では入力欄に枠線がなく項目の境目がぼやけるため、項目の間に淡い
/// 区切り線を引いていた。2.2.0 で入力欄に枠を付けたので線はやめ、余白だけで
/// 区切る(ユーザー判断)。
class MobileFormRows extends StatelessWidget {
  const MobileFormRows({required this.children, super.key});

  final List<Widget> children;

  /// 項目の上下の余白。区切り線があった頃は 18 に広げていたが、線をやめて
  /// 間が空きすぎたため、デザインの 14 に戻した(ユーザー判断)。
  static const _verticalPadding = 14.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
            child: child,
          ),
      ],
    );
  }
}
