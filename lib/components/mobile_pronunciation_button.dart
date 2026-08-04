import 'package:eitangocho/components/speaker_icon.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// iOS 版の発音確認ボタン。Google 翻訳を開く。
///
/// macOS 版の [PronunciationButton] と役割は同じだが、ホバー演出と Tooltip を
/// 持たず(タッチでは出ないため)、配色を [AppPalette] から引く。
///
/// タップ領域は Apple の推奨する 44pt 四方を確保する。デザインは負マージンで
/// レイアウトを膨らませずに 44pt を作っているが、Flutter は親の矩形の外を
/// ヒットテストしないため同じ手が使えない。押しやすさを優先し、レイアウト上も
/// 44pt を占める(デザインより数 px 高くなる)。
class MobilePronunciationButton extends StatelessWidget {
  const MobilePronunciationButton({
    required this.word,
    required this.variant,
    super.key,
  });

  final String word;
  final MobilePronunciationButtonVariant variant;

  /// 最小タップ領域(Apple のヒューマンインターフェイスガイドライン)。
  static const minTapTarget = 44.0;

  /// アイコンのみの形の円の直径。タップ領域より小さく、中央に置く。
  static const _circleDiameter = 34.0;

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
      onTap: () => launchUrl(googleTranslateUrl(word)),
      child: label == null
          ? SizedBox.square(
              dimension: minTapTarget,
              child: Center(
                child: Container(
                  width: _circleDiameter,
                  height: _circleDiameter,
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
