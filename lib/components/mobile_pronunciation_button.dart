import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_pronunciation_sheet.dart';
import 'package:eitangocho/components/speaker_icon.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// [MobilePronunciationButton] の形。
enum MobilePronunciationButtonVariant {
  /// 学習中カードのフッタ・全単語リストの行。円形アイコンのみ。
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
/// アイコンのみの形のタップ領域は **44pt 幅 × 30pt 高**。デザインは負マージンで
/// レイアウトを膨らませずに 44pt 四方を作っているが、Flutter は親の矩形の外を
/// ヒットテストしないため同じ手が使えない。高さを 44pt にするとカードのフッタが
/// そのぶん間延びするので、行の高さに響かない幅だけ広げ、高さは円の直径に
/// 合わせている(デザインの実効高 30pt と同じ)。
///
/// **円はタップ領域の右端に揃える**(中央寄せにしない)。この形は常に行や
/// カードのフッタの末尾に置かれるため、中央寄せだと円の右端がコンテンツの
/// 右端より内側に入り、左端のチェックボックスに対して左寄りに見える。
/// 幅を広げたぶんは左側に伸ばす(隣の要素との間隔が広がるだけで済む)。
class MobilePronunciationButton extends StatelessWidget {
  const MobilePronunciationButton({
    required this.word,
    required this.variant,
    super.key,
  });

  final String word;
  final MobilePronunciationButtonVariant variant;

  /// アイコンのみの形のタップ領域の幅
  /// (Apple のヒューマンインターフェイスガイドラインの 44pt)。
  static const minTapTarget = 44.0;

  /// ピル形の高さ(デザインの min-height:36px)。
  static const pillHeight = 36.0;

  /// アイコンのみの形の円の直径。この形はこの値が高さになる。
  static const circleDiameter = 30.0;

  static const _iconSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = variant.label;
    final icon = SpeakerIcon(size: _iconSize, color: palette.accentOnSoft);

    return MobilePressable(
      onTap: () => showMobilePronunciationSheet(context, word),
      builder: (context, _) => label == null
          ? SizedBox(
              width: minTapTarget,
              height: circleDiameter,
              child: Align(
                alignment: Alignment.centerRight,
                // 淡い青の地 + 青の細い縁のフラットな丸にする。2.0.0 の立体案では
                // 白からのグラデーションと外周線で膨らみを出していたが、
                // 2.2.0 で画面全体をフラット寄りにしたのに合わせて変えた。
                // 地だけだと品詞バッジと同じ見た目になりボタンに見えないため、
                // ピル形と同じ縁を付けて配色も揃える(ユーザー判断)。
                child: Container(
                  width: circleDiameter,
                  height: circleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.accentSoft,
                    border: Border.all(color: palette.accentLine),
                  ),
                  child: Center(child: icon),
                ),
              ),
            )
          : Container(
              height: pillHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: palette.accentLine),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: palette.accentOnSoft,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
