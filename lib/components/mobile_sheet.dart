import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版のボトムシート枠(画面高の 88%・上角丸・左右にアクション付きヘッダ)。
///
/// 単語の登録・編集で共通に使う。中身のスクロールは呼び出し側に任せず、
/// キーボード回避のためここでまとめて面倒を見る。
class MobileSheet extends StatelessWidget {
  const MobileSheet({
    required this.title,
    required this.leftLabel,
    required this.onLeft,
    required this.child,
    super.key,
    this.rightLabel,
    this.onRight,
    this.scrollableBody = true,
    this.showGrabber = true,
    this.footer,
    this.titleFontSize = 15,
  });

  final String title;

  /// ヘッダのタイトルの文字サイズ。発音シートは単語そのものを見出しに出すため
  /// 大きくする。
  final double titleFontSize;
  final String leftLabel;
  final VoidCallback onLeft;

  /// 右上のアクション(保存など)。null なら出さない。
  final String? rightLabel;
  final VoidCallback? onRight;

  final Widget child;

  /// 中身をスクロール領域に載せるか。フォームは true(既定)。
  /// WebView のように自前で高さいっぱいに広がるものは false にして、
  /// 余白ごとシートの残り高を渡す。
  final bool scrollableBody;

  /// 上端のつまみ(下へスワイプで閉じられる合図)を出すか。
  /// 閉じるボタンだけで閉じる発音シートは出さない(デザインどおり)。
  final bool showGrabber;

  /// スクロール領域の外側、シート最下部に固定で置くもの。
  /// 今のところ用途はバナー広告だけ(`MobileSheetBannerAd`)。
  final Widget? footer;

  /// 画面高に対するシートの高さ(デザインの height:88%)。
  static const _heightFactor = 0.88;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // キーボードが出ている分だけシートを持ち上げる。
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: FractionallySizedBox(
        heightFactor: _heightFactor,
        child: Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SheetHeader(
                showGrabber: showGrabber,
                title: title,
                titleFontSize: titleFontSize,
                leftLabel: leftLabel,
                onLeft: onLeft,
                rightLabel: rightLabel,
                onRight: onRight,
              ),
              Expanded(
                child: scrollableBody
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
                        child: child,
                      )
                    : child,
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.showGrabber,
    required this.title,
    required this.titleFontSize,
    required this.leftLabel,
    required this.onLeft,
    required this.rightLabel,
    required this.onRight,
  });

  final bool showGrabber;
  final String title;
  final double titleFontSize;
  final String leftLabel;
  final VoidCallback onLeft;
  final String? rightLabel;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.borderAlpha(6))),
      ),
      child: Column(
        children: [
          if (showGrabber) const MobileSheetGrabber(),
          Container(
            height: showGrabber ? 46 : 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // タイトルは左右のボタン幅に影響されず中央に置きたいため Stack で重ねる。
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: palette.text,
                  ),
                ),
                Row(
                  children: [
                    _SheetAction(label: leftLabel, onTap: onLeft),
                    const Spacer(),
                    // 確定操作(登録・保存)は文字ではなくピル形の主ボタンにする。
                    if (rightLabel != null && onRight != null)
                      MobileFilledButton(
                        label: rightLabel!,
                        onPressed: onRight!,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        borderRadius: 99,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MobilePressable(
      onTap: onTap,
      style: MobilePressStyle.text,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          label,
          style: TextStyle(fontSize: 15, color: context.palette.accentOnSoft),
        ),
      ),
    );
  }
}

/// シート上端のつまみ(下へスワイプで閉じられる合図)。
/// 並び替えシートのように [MobileSheet] を使わないシートでも同じものを出す。
class MobileSheetGrabber extends StatelessWidget {
  const MobileSheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Container(
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: context.palette.borderAlpha(12),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

/// [MobileSheet] を下から出す。デザインのオーバーレイ色に合わせる。
Future<T?> showMobileSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // 画面高の 88% を使うため、既定の高さ制限を外す。
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x59141923), // rgba(20,25,35,0.35)
    builder: builder,
  );
}
