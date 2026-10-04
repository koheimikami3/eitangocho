import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/components/mobile_raised_surface.dart';
import 'package:eitangocho/components/mobile_well.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_pos_badge.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_shrinking_ipa_text.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版の学習中カード 1 枚(設定に応じて 1 列 / 2 列グリッドに並ぶ)。
///
/// 訳はタップで表示 / 非表示を切り替える。状態はカードのローカルに持つ
/// (画面切替で揮発してよい。macOS 版の [WordCard] と同じ方針)。
class MobileWordCard extends StatefulWidget {
  const MobileWordCard({
    required this.word,
    required this.showIpa,
    required this.onToggleLearned,
    required this.onTap,
    this.singleColumn = false,
    super.key,
  });

  final Word word;

  /// IPA を表示するか(設定 showIpa。word.ipa が空なら本値に関わらず非表示)。
  final bool showIpa;

  /// 1 列表示か。ヘッダの組み方だけが変わる(_CardHeader 参照)。
  final bool singleColumn;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;

  @override
  State<MobileWordCard> createState() => _MobileWordCardState();
}

class _MobileWordCardState extends State<MobileWordCard> {
  bool _revealed = false;

  // 英例文は行数差でカード高さがばらつくため、常に固定行数分の高さを確保する。
  // 列数によらず 2 行(当初 2 列だけ 3 行にしていたが、辞書から入る例文は
  // 2 列幅でも 2 行に収まるものが大半で、3 行目はほぼ空白になっていた)。
  static const _exampleFontSize = 12.0;
  static const _exampleLineHeight = 1.45;
  static const _exampleLines = 2;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final word = widget.word;
    final showIpa = widget.showIpa && word.ipa.isNotEmpty;
    final hasExample = word.exampleEn.trim().isNotEmpty;

    return MobileRaisedSurface(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(AppDimensions.mobileCardRadius),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(
            word: word,
            showIpa: showIpa,
            singleColumn: widget.singleColumn,
          ),
          const SizedBox(height: 8),
          _RevealToggle(
            meaning: word.meaning,
            revealed: _revealed,
            onTap: () => setState(() => _revealed = !_revealed),
          ),
          const SizedBox(height: 8),
          // 例文の行数差でも、例文が無いカードでも高さが揃うよう、
          // 常に固定行数分を確保する(child が無ければ空白のまま)。
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _exampleFontSize * _exampleLineHeight * _exampleLines,
            ),
            child: hasExample
                ? Text(
                    word.exampleEn,
                    maxLines: _exampleLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _exampleFontSize,
                      height: _exampleLineHeight,
                      color: palette.textAlpha(70),
                    ),
                  )
                : null,
          ),
          if (hasExample &&
              _revealed &&
              word.exampleTranslation.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                word.exampleTranslation,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: palette.textAlpha(50),
                ),
              ),
            ),
          // フッタ(区切り線 + 覚えた / 発音)は上下の余白を少し詰める。
          // 発音ボタンが 34pt あり、8 + 8 だと間延びして見えるため。
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.rowLine)),
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
                        context.l10n.rememberedCheck,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textAlpha(60),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                MobilePronunciationButton(
                  word: word.word,
                  variant: MobilePronunciationButtonVariant.icon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// カード上部(単語 + IPA + 品詞バッジ)。列数で組み方が変わる。
///
/// - 2 列: 単語・IPA・バッジをそれぞれ独立した行に積む。
/// - 1 列: 幅に余裕があるので単語・IPA・バッジを 1 行に並べ、バッジだけ右端。
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.word,
    required this.showIpa,
    required this.singleColumn,
  });

  final Word word;
  final bool showIpa;
  final bool singleColumn;

  /// 単語と IPA の間隔(デザインの column-gap)。
  static const _gap = 7.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final wordText = Text(
      word.word,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: palette.text,
      ),
    );
    final badge = MobilePosBadge(partsOfSpeech: word.partsOfSpeech);

    if (singleColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // 単語 + IPA を Expanded で包み、バッジを右端に押し出す。
          // Flexible と Spacer を並べると空きを両者で折半してしまい、
          // 幅に余裕があっても長い単語が折り返す。
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(child: wordText),
                if (showIpa) ...[
                  const SizedBox(width: _gap),
                  // 1 列は幅に余裕があり、単語と同じ行に置く都合で
                  // ベースラインを揃える必要があるため縮小はしない。
                  Flexible(
                    child: Text(
                      word.ipa,
                      style: TextStyle(
                        fontSize: MobileShrinkingIpaText.maxFontSize,
                        fontFamily: 'Menlo',
                        color: palette.textAlpha(45),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: _gap),
          badge,
        ],
      );
    }

    // IPA とバッジは 1 行に収まるかに関わらず必ず別々の行に置く。
    // 収まるときだけ同じ行に並べる組み方(Wrap)だと、単語ごとに
    // 2 行になったり 3 行になったりしてカードの見え方が揃わない。
    // 行が固定なので IPA には幅いっぱいが渡り、バッジは左寄せになる
    // (IPA 非表示時に左へ寄っていた従来の挙動と同じ位置)。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        wordText,
        if (showIpa) ...[
          const SizedBox(height: 3),
          MobileShrinkingIpaText(ipa: word.ipa),
        ],
        const SizedBox(height: 3),
        badge,
      ],
    );
  }
}

/// 訳の表示 / 非表示トグル。未表示は破線枠、表示中は塗りつぶし枠。
class _RevealToggle extends StatelessWidget {
  const _RevealToggle({
    required this.meaning,
    required this.revealed,
    required this.onTap,
  });

  final String meaning;
  final bool revealed;
  final VoidCallback onTap;

  static const _padding = 9.0;
  static const _lineHeight = 1.4;
  static const _meaningFontSize = 13.0;
  static const _hintFontSize = 12.0;

  static const _radius = 9.0;

  /// 訳を 1 行表示したときの外形高さ(パディング + 1 行)。
  /// 表示中の枠は内側の影で描くため、枠線の分の高さは無い。
  static const _boxHeight = _padding * 2 + _meaningFontSize * _lineHeight;

  /// 破線側のパディング。文字が小さいぶんをここで埋め、タップしても
  /// 高さが変わらないようにする(破線は CustomPaint で描くので高さを取らない)。
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
          ? MobileWell(
              color: palette.wellBackground,
              shadows: palette.wellShadow,
              borderRadius: BorderRadius.circular(_radius),
              padding: const EdgeInsets.all(_padding),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  meaning,
                  // 訳が 2 行に折り返したときに 2 行目だけ中央に寄って見えるため、
                  // 左揃えにする(「訳を表示」の方は 1 行固定なので中央のまま)。
                  style: TextStyle(
                    fontSize: _meaningFontSize,
                    height: _lineHeight,
                    color: palette.text,
                  ),
                ),
              ),
            )
          : _DashedBox(
              color: palette.borderAlpha(18),
              child: Padding(
                padding: const EdgeInsets.all(_hintPadding),
                child: Text(
                  context.l10n.showMeaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _hintFontSize,
                    height: _lineHeight,
                    color: palette.textAlpha(45),
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

  static const _radius = _RevealToggle._radius;
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
