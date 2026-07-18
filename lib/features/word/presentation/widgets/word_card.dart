import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
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
    required this.onSecondaryTapUp,
    super.key,
  });

  final Word word;

  /// IPA を表示するか(設定 showIpa。word.ipa が空なら本値に関わらず非表示)。
  final bool showIpa;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;
  final void Function(TapUpDetails details) onSecondaryTapUp;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _revealed = false;
  bool _isHovered = false;

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
        onSecondaryTapUp: widget.onSecondaryTapUp,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? const Color(0x730A6EE0)
                  : const Color(0x1A000000),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(_isHovered ? 0x12000000 : 0x0A000000),
                blurRadius: _isHovered ? 8 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      word.word,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Menlo',
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(width: 8),
                  PosBadge(partsOfSpeech: word.partsOfSpeech),
                ],
              ),
              const SizedBox(height: 10),
              _RevealArea(
                japanese: word.japanese,
                revealed: _revealed,
                onToggle: () => setState(() => _revealed = !_revealed),
              ),
              if (hasExample) ...[
                const SizedBox(height: 10),
                Text(
                  word.exampleEn,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xB3000000),
                    height: 1.5,
                  ),
                ),
                if (_revealed) ...[
                  const SizedBox(height: 4),
                  Text(
                    word.exampleJa,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0x80000000),
                      height: 1.5,
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 10),
                const Text(
                  '例文なし',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDisabled,
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
                    PronunciationButton(word: word.word, audioUrl: word.audioUrl),
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
class _RevealArea extends StatelessWidget {
  const _RevealArea({
    required this.japanese,
    required this.revealed,
    required this.onToggle,
  });

  final String japanese;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    // チェック操作と同様、訳トグルはカードクリック(編集)に伝播させない。
    return GestureDetector(
      onTap: () {},
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(7),
        child: revealed
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  japanese,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : DottedBorderBox(
                child: const Text(
                  '日本語訳を表示',
                  style: TextStyle(fontSize: 12, color: Color(0x66000000)),
                ),
              ),
      ),
    );
  }
}

/// 破線 border のボックス(「日本語訳を表示」ボタン用)。
/// Flutter 標準に破線 border がないため CustomPaint で描く。
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
