import 'package:eitangocho/components/speaker_icon.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';

/// [PronunciationButton] の形。置かれる場所ごとにデザインが違う。
enum PronunciationButtonVariant {
  /// 学習中カードのフッタ。高さ 26 のピル + 「発音」。
  cardPill,

  /// 全単語テーブルの発音列。28×28 の角丸アイコンのみ。
  tableIcon,

  /// クイズカード。高さ 32 のピル + 「発音を聞く」。
  quizPill;

  /// ピルの高さ / アイコンボタンの一辺。
  double get height => switch (this) {
    cardPill => 26,
    tableIcon => 28,
    quizPill => 32,
  };

  double get iconSize => switch (this) {
    cardPill => 13,
    tableIcon => 15,
    quizPill => 15,
  };

  /// ラベル。アイコンのみの形は null。
  String? get label => switch (this) {
    cardPill => '発音',
    tableIcon => null,
    quizPill => '発音を聞く',
  };

  double get fontSize => switch (this) {
    cardPill => 12,
    tableIcon || quizPill => 13,
  };

  /// アイコンのみは正方形にするため、左右の余白を持たない。
  double get horizontalPadding => switch (this) {
    cardPill => 10,
    tableIcon => 0,
    quizPill => 14,
  };

  double get gap => switch (this) {
    cardPill => 5,
    tableIcon => 0,
    quizPill => 6,
  };

  /// アイコンのみは角丸 8、ラベル付きはピル。
  double get borderRadius => switch (this) {
    tableIcon => 8,
    cardPill || quizPill => 99,
  };
}

/// 発音確認ボタン(機能横断コンポーネント)。Google 翻訳を外部ブラウザで開く。
///
/// iOS 版([MobilePronunciationButton])はアプリ内の WebView で完結するが、
/// macOS は Flutter の platform view がまだジェスチャに対応しておらず、
/// WebView を埋め込んでも再生ボタンを押せないため外部ブラウザに出す
/// (docs/design.md 参照)。
///
/// 配色は macOS がライト固定のため [AppColors] から直接引く。
///
/// 自身がタップを消費するため、カード・行のクリック(編集モーダル)には
/// 伝播しない。
class PronunciationButton extends StatefulWidget {
  const PronunciationButton({
    required this.word,
    required this.variant,
    super.key,
  });

  final String word;
  final PronunciationButtonVariant variant;

  @override
  State<PronunciationButton> createState() => _PronunciationButtonState();
}

class _PronunciationButtonState extends State<PronunciationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final label = variant.label;

    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => openGoogleTranslateInBrowser(widget.word),
        child: Container(
          height: variant.height,
          // アイコンのみの形は正方形にする。
          width: label == null ? variant.height : null,
          padding: EdgeInsets.symmetric(horizontal: variant.horizontalPadding),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.accentSoftHover
                : AppColors.accentSoft,
            borderRadius: BorderRadius.circular(variant.borderRadius),
            border: Border.all(
              color: _isHovered
                  ? AppColors.accentLineHover
                  : AppColors.accentLine,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpeakerIcon(
                size: variant.iconSize,
                color: AppColors.accentOnSoft,
              ),
              if (label != null) ...[
                SizedBox(width: variant.gap),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: variant.fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOnSoft,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // ラベルが無い形は用途が読めないため、説明を出す。
    return label == null
        ? Tooltip(message: 'Google 翻訳で発音を確認', child: button)
        : button;
  }
}
