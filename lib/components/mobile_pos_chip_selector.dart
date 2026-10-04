import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版の品詞選択チップ(複数選択可)。
///
/// 選択中はその品詞のバッジ色(文字色で縁取り)、未選択は面の色 + 淡い縁。
class MobilePosChipSelector extends StatelessWidget {
  const MobilePosChipSelector({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<PartOfSpeech> selected;
  final ValueChanged<PartOfSpeech> onToggle;

  static const _gap = 6.0;
  static const _horizontalPadding = 4.0;
  static const _borderWidth = 1.0;
  static const _fontSize = 13.0;

  /// 1 行に収まらないときの 1 段目の数。残りは 2 段目に同じ幅で左から並べる。
  static const _firstRowCount = 3;

  @override
  Widget build(BuildContext context) {
    // 5 つを同じ幅で 1 行に並べる。ラベルが入り切らないとき(英語の
    // adjective や、文字サイズを大きくした端末)だけ 3 + 2 の 2 段にする。
    // 日本語・繁体字は iPhone SE 幅でも 1 行に収まる。
    return LayoutBuilder(
      builder: (context, constraints) {
        const values = PartOfSpeech.values;
        final width = constraints.maxWidth;
        final oneRowWidth = _chipWidth(width, values.length);
        if (_labelsFit(context, oneRowWidth)) {
          return _row(context, values, oneRowWidth);
        }
        final twoRowWidth = _chipWidth(width, _firstRowCount);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(context, values.take(_firstRowCount), twoRowWidth),
            const SizedBox(height: _gap),
            _row(context, values.skip(_firstRowCount), twoRowWidth),
          ],
        );
      },
    );
  }

  /// [count] 個を間隔込みで [width] に並べたときの 1 個の幅。
  static double _chipWidth(double width, int count) =>
      (width - _gap * (count - 1)) / count;

  /// すべてのラベルが [chipWidth] のチップに 1 行で収まるか。
  ///
  /// 選択中は太字になり幅が増えるので、太字で測る(選んだ途端に段組みが
  /// 変わらないようにする)。
  bool _labelsFit(BuildContext context, double chipWidth) {
    final available = chipWidth - (_horizontalPadding + _borderWidth) * 2;
    final textScaler = MediaQuery.textScalerOf(context);
    final style = DefaultTextStyle.of(context).style.merge(
      const TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
    );
    final l10n = context.l10n;
    for (final pos in PartOfSpeech.values) {
      final painter = TextPainter(
        text: TextSpan(text: pos.label(l10n), style: style),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final fits = painter.width <= available;
      painter.dispose();
      if (!fits) return false;
    }
    return true;
  }

  Widget _row(
    BuildContext context,
    Iterable<PartOfSpeech> items,
    double chipWidth,
  ) {
    return Row(
      children: [
        for (final (i, pos) in items.indexed) ...[
          if (i > 0) const SizedBox(width: _gap),
          SizedBox(width: chipWidth, child: _chip(context, pos)),
        ],
      ],
    );
  }

  Widget _chip(BuildContext context, PartOfSpeech pos) {
    final palette = context.palette;
    final isSelected = selected.contains(pos);
    final (background, foreground) = palette.posBadge(pos);
    return MobilePressable(
      onTap: () => onToggle(pos),
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? background : palette.surface,
          borderRadius: BorderRadius.circular(99),
          // 選択中は文字色で縁取り、未選択は淡い縁 + 小さな影で
          // 「押せる面」に見せる。縁の濃さは入力欄の枠
          // (AppPalette.wellShadow)と揃える。
          border: Border.all(
            color: isSelected ? foreground : palette.borderAlpha(28),
          ),
          boxShadow: isSelected
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0F101828), // rgba(16,24,40,0.06)
                    blurRadius: 1.5,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          pos.label(context.l10n),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? foreground : palette.textAlpha(55),
          ),
        ),
      ),
    );
  }
}
