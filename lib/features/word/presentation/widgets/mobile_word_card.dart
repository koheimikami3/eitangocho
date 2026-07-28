import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_pos_badge.dart';
import 'package:flutter/material.dart';

/// iOS 版の学習中カード 1 枚(2 列グリッドに並ぶ)。
///
/// 訳はタップで表示 / 非表示を切り替える。状態はカードのローカルに持つ
/// (画面切替で揮発してよい。macOS 版の [WordCard] と同じ方針)。
class MobileWordCard extends StatefulWidget {
  const MobileWordCard({
    required this.word,
    required this.showIpa,
    required this.onToggleLearned,
    required this.onTap,
    super.key,
  });

  final Word word;

  /// IPA を表示するか(設定 showIpa。word.ipa が空なら本値に関わらず非表示)。
  final bool showIpa;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;

  @override
  State<MobileWordCard> createState() => _MobileWordCardState();
}

class _MobileWordCardState extends State<MobileWordCard> {
  bool _revealed = false;

  // 英例文は行数差でカード高さがばらつくため、常に 2 行分の高さを確保する。
  static const _exampleFontSize = 12.0;
  static const _exampleLineHeight = 1.45;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final word = widget.word;
    final showIpa = widget.showIpa && word.ipa.isNotEmpty;
    final hasExample = word.exampleEn.trim().isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.borderAlpha(10)),
          boxShadow: [
            BoxShadow(
              color: palette.borderAlpha(4),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: palette.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                MobilePosBadge(partsOfSpeech: word.partsOfSpeech),
              ],
            ),
            if (showIpa)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  word.ipa,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Menlo',
                    color: palette.textAlpha(45),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _RevealToggle(
              japanese: word.japanese,
              revealed: _revealed,
              onTap: () => setState(() => _revealed = !_revealed),
            ),
            const SizedBox(height: 8),
            // 例文の行数差でも、例文が無いカードでも高さが揃うよう、
            // 常に 2 行分を確保する(child が無ければ空白のまま)。
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: _exampleFontSize * _exampleLineHeight * 2,
              ),
              child: hasExample
                  ? Text(
                      word.exampleEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _exampleFontSize,
                        height: _exampleLineHeight,
                        color: palette.textAlpha(70),
                      ),
                    )
                  : null,
            ),
            if (hasExample && _revealed && word.exampleJa.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  word.exampleJa,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: palette.textAlpha(50),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.borderAlpha(6)),
                ),
              ),
              child: Row(
                children: [
                  // チェック操作をカードのタップ(編集)に伝播させない。
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onToggleLearned(!word.isLearned),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MobileLearnedCheckbox(value: word.isLearned),
                        const SizedBox(width: 6),
                        Text(
                          '覚えた',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textAlpha(60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 発音操作もカードのタップに伝播させない。
                  GestureDetector(
                    onTap: () {},
                    child: MobilePronunciationButton(
                      word: word.word,
                      audioUrl: word.audioUrl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 訳の表示 / 非表示トグル。未表示は破線枠、表示中は塗りつぶし枠。
class _RevealToggle extends StatelessWidget {
  const _RevealToggle({
    required this.japanese,
    required this.revealed,
    required this.onTap,
  });

  final String japanese;
  final bool revealed;
  final VoidCallback onTap;

  static const _padding = 9.0;
  static const _lineHeight = 1.4;
  static const _japaneseFontSize = 13.0;
  static const _hintFontSize = 12.0;

  /// 訳を 1 行表示したときの外形高さ(パディング + 1 行 + 枠線 1px×2)。
  static const _boxHeight =
      _padding * 2 + _japaneseFontSize * _lineHeight + 2;

  /// 破線側のパディング。枠線を CustomPaint で描く(= 高さを取らない)ぶんと
  /// 文字が小さいぶんをここで埋め、タップしても高さが変わらないようにする。
  /// 訳が 2 行以上になったときは訳側が伸びる(それは許容)。
  static const _hintPadding = (_boxHeight - _hintFontSize * _lineHeight) / 2;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      // カードのタップ(編集)に伝播させない。
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: revealed
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.borderAlpha(8)),
              ),
              child: Text(
                japanese,
                // 訳が 2 行に折り返したときに 2 行目だけ中央に寄って見えるため、
                // 左揃えにする(「訳を表示」の方は 1 行固定なので中央のまま)。
                style: TextStyle(
                  fontSize: _japaneseFontSize,
                  height: _lineHeight,
                  color: palette.text,
                ),
              ),
            )
          : _DashedBox(
              color: palette.borderAlpha(18),
              child: Padding(
                padding: const EdgeInsets.all(_hintPadding),
                child: Text(
                  '訳を表示',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _hintFontSize,
                    height: _lineHeight,
                    color: palette.textAlpha(40),
                  ),
                ),
              ),
            ),
    );
  }
}

/// 破線の角丸枠。Flutter の Border は破線を描けないため CustomPaint で描く。
class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const _radius = 8.0;
  static const _dash = 3.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
