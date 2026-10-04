import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/pos_badge.dart';
import 'package:flutter/material.dart';

/// 学習中リストの単語カード 1 枚(プロトタイプの学習中カード準拠)。
/// 「日本語訳を表示」トグルはカードのローカル state で保持する
/// (画面切替で揮発してよい・プロトタイプも永続化していない)。
class WordCard extends StatefulWidget {
  const WordCard({
    required this.word,
    required this.showIpa,
    required this.onToggleLearned,
    required this.onTap,
    required this.onContextMenu,
    super.key,
  });

  final Word word;

  /// IPA を表示するか(設定 showIpa。word.ipa が空なら本値に関わらず非表示)。
  final bool showIpa;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;

  /// コンテキストメニューを開く。引数はメニューを出すグローバル座標。
  final ValueChanged<Offset> onContextMenu;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _revealed = false;
  bool _isHovered = false;

  // 英例文は行数差でカード高さがばらつくため、常に 2 行分の高さを確保する。
  /// ホバー中の影。通常の影に、下へ広く落ちる影を 1 枚足す。
  static final _hoverShadow = [
    ...AppPalette.light.elevation,
    const BoxShadow(
      color: Color(0x14101828), // rgba(16,24,40,0.08)
      blurRadius: 16,
      spreadRadius: -4,
      offset: Offset(0, 6),
    ),
  ];

  static const _exampleFontSize = 13.0;
  static const _exampleLineHeight = 1.5;
  static const _exampleAreaHeight =
      _exampleFontSize * _exampleLineHeight * 2; // 2 行分 = 39.0

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final hasExample = word.exampleEn.trim().isNotEmpty;
    final showIpa = widget.showIpa && word.ipa.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapUp: (details) =>
            widget.onContextMenu(details.globalPosition),
        child: Container(
          padding: const EdgeInsets.all(16),
          // iOS のカードと同じく枠線なし + 淡い影で浮かせる(2.2.0)。
          // ホバーは青い枠をやめ、影を一段足して少し持ち上げる。
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.mobileCardRadius),
            boxShadow: _isHovered ? _hoverShadow : AppPalette.light.elevation,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // 単語 + IPA は左側で自然幅を取り、バッジを右端へ押し出す。
                  // 幅が足りないときは折り返さず省略表示にする。
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            word.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (showIpa) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              word.ipa,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Menlo',
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PosBadge(partsOfSpeech: word.partsOfSpeech),
                ],
              ),
              const SizedBox(height: 10),
              _RevealArea(
                meaning: word.meaning,
                revealed: _revealed,
                onToggle: () => setState(() => _revealed = !_revealed),
              ),
              const SizedBox(height: 10),
              // カード高さを揃えるため英例文の領域は常に 2 行分を確保し、
              // 超過分は末尾を … で省略する(全文は編集ダイアログで確認できる)。
              SizedBox(
                height: _exampleAreaHeight,
                width: double.infinity,
                child: Text(
                  hasExample ? word.exampleEn : '例文なし',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _exampleFontSize,
                    color: hasExample
                        ? const Color(0xB3000000)
                        : AppColors.textDisabled,
                    height: _exampleLineHeight,
                  ),
                ),
              ),
              if (hasExample && _revealed) ...[
                const SizedBox(height: 4),
                Text(
                  word.exampleTranslation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0x80000000),
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0x0F000000))),
                ),
                child: Row(
                  children: [
                    // チェック操作をカードのタップ(編集モーダル)に伝播させない。
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LearnedCheckbox(
                            value: word.isLearned,
                            onChanged: widget.onToggleLearned,
                          ),
                          const Text(
                            '学習済みにする',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PronunciationButton(
                      word: word.word,
                      variant: PronunciationButtonVariant.cardPill,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 日本語訳の隠し/表示エリア。未表示は破線ボタン、表示は訳テキスト。
class _RevealArea extends StatefulWidget {
  const _RevealArea({
    required this.meaning,
    required this.revealed,
    required this.onToggle,
  });

  final String meaning;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  State<_RevealArea> createState() => _RevealAreaState();
}

class _RevealAreaState extends State<_RevealArea> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // チェック操作と同様、訳トグルはカードクリック(編集)に伝播させない。
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onToggle,
          borderRadius: BorderRadius.circular(7),
          child: widget.revealed
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  // macOS の入力欄と同じ白地 + 枠(iOS の訳の表示枠に対応)。
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Text(
                    widget.meaning,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              : DottedBorderBox(
                  backgroundColor: _isHovered ? const Color(0x08000000) : null,
                  child: const Text(
                    '日本語訳を表示',
                    style: TextStyle(fontSize: 12, color: Color(0x66000000)),
                  ),
                ),
        ),
      ),
    );
  }
}

/// 破線 border のボックス(「日本語訳を表示」ボタン用)。
/// Flutter 標準に破線 border がないため CustomPaint で描く。
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        color: backgroundColor,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const _radius = 7.0;
  static const _dashWidth = 4.0;
  static const _dashGap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x2E000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashWidth),
          paint,
        );
        distance += _dashWidth + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
