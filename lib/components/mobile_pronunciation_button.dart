import 'package:eitangocho/components/mobile_pronunciation_sheet.dart';
import 'package:eitangocho/components/speaker_icon.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// [MobilePronunciationButton] の形。
enum MobilePronunciationButtonVariant {
  /// 学習中カードのフッタ・全単語リストの行。34px の円形アイコンのみ。
  icon,

  /// クイズカード。ピル + 「発音を聞く」。
  pill;

  /// ラベル。アイコンのみの形は null。
  String? get label => switch (this) {
    icon => null,
    pill => '発音を聞く',
  };
}

/// iOS 版の発音確認ボタン。
/// Google 翻訳をアプリ内のシート([showMobilePronunciationSheet])で開く。
///
/// macOS 版の [PronunciationButton] と役割は同じだが、ホバー演出と Tooltip を
/// 持たず(タッチでは出ないため)、配色を [AppPalette] から引く。
///
/// アイコンのみの形のタップ領域は **44pt 幅 × 34pt 高**。デザインは負マージンで
/// レイアウトを膨らませずに 44pt 四方を作っているが、Flutter は親の矩形の外を
/// ヒットテストしないため同じ手が使えない。高さを 44pt にするとカードのフッタが
/// そのぶん間延びするので、行の高さに響かない幅だけ広げ、高さは円の直径に
/// 合わせている(デザインの実効高 30pt に近い)。
class MobilePronunciationButton extends StatelessWidget {
  const MobilePronunciationButton({
    required this.word,
    required this.variant,
    super.key,
  });

  final String word;
  final MobilePronunciationButtonVariant variant;

  /// タップ領域の幅、およびピル形の高さ
  /// (Apple のヒューマンインターフェイスガイドラインの 44pt)。
  static const minTapTarget = 44.0;

  /// アイコンのみの形の円の直径。この形はこの値が高さになる。
  static const circleDiameter = 34.0;

  static const _iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = variant.label;

    final icon = SpeakerIcon(size: _iconSize, color: palette.accentOnSoft);
    final decoration = BoxDecoration(
      color: palette.accentSoft,
      shape: label == null ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: label == null ? null : BorderRadius.circular(99),
      border: Border.all(color: palette.accentLine),
    );

    return GestureDetector(
      // 円の外側の余白(タップ領域)でも反応させる。
      behavior: HitTestBehavior.opaque,
      onTap: () => showMobilePronunciationSheet(context, word),
      child: label == null
          ? SizedBox(
              width: minTapTarget,
              height: circleDiameter,
              child: Center(
                child: Container(
                  width: circleDiameter,
                  height: circleDiameter,
                  decoration: decoration,
                  child: Center(child: icon),
                ),
              ),
            )
          : Container(
              height: minTapTarget,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: decoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.accentOnSoft,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
