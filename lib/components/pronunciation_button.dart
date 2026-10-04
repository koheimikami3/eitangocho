import 'package:eitangocho/components/speaker_icon.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:eitangocho/utils/pronunciation_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String? label(AppLocalizations l10n) => switch (this) {
    cardPill => l10n.pronunciationShort,
    tableIcon => null,
    quizPill => l10n.listenPronunciation,
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

  /// すべて丸(ラベル付きはピル、アイコンのみは円)。アイコンのみは
  /// 2.2.0 で角丸 8 から円にし、iOS の発音ボタンと形を揃えた。
  double get borderRadius => 99;
}

/// 発音確認ボタン(機能横断コンポーネント)。Google 翻訳をアプリ内の別ウィンドウで開く。
///
/// iOS 版([MobilePronunciationButton])は画面内の WebView で完結するが、
/// macOS は Flutter の platform view がまだジェスチャに対応しておらず、
/// 埋め込むと再生ボタンを押せないため、ネイティブのウィンドウに出す
/// ([openPronunciationWindow]。docs/design.md 参照)。
///
/// 配色は macOS がライト固定のため [AppColors] から直接引く。
///
/// 自身がタップを消費するため、カード・行のクリック(編集モーダル)には
/// 伝播しない。
class PronunciationButton extends ConsumerStatefulWidget {
  const PronunciationButton({
    required this.word,
    required this.variant,
    super.key,
  });

  final String word;
  final PronunciationButtonVariant variant;

  @override
  ConsumerState<PronunciationButton> createState() =>
      _PronunciationButtonState();
}

class _PronunciationButtonState extends ConsumerState<PronunciationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final label = variant.label(context.l10n);

    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // ページもアプリと同じ拡大率(ブラウザズーム相当の uiScale)で表示する。
        // 押したときだけ読むので build では watch しない。
        onTap: () => openPronunciationWindow(
          widget.word,
          ref.read(translationLanguageProvider),
          zoom:
              ref.read(settingsProvider).value?.uiScale ??
              AppDimensions.defaultUiScale,
        ),
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
        ? Tooltip(message: context.l10n.pronunciationTooltip, child: button)
        : button;
  }
}
