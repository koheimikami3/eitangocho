import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_fonts.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/pos_badge.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static List<BoxShadow> _hoverShadow(AppPalette palette) => [
    ...palette.elevation,
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
    final colors = context.colors;
    final palette = context.palette;
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
          // ホバーは影を一段足して少し持ち上げ、薄い青の枠も付ける。
          // 枠は透明色で常に描く。ホバー時だけ足すと、枠の太さの分だけ
          // 中身がずれるため。
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.mobileCardRadius),
            border: Border.all(
              color: _isHovered ? colors.accentLine : Colors.transparent,
            ),
            boxShadow: _isHovered ? _hoverShadow(palette) : palette.elevation,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 単語・IPA・品詞はそれぞれ別の行に積む(iOS の 2 列カードと同じ)。
              // 1 行に並べていた頃は単語が長いと省略され、肝心の単語が
              // 読めないカードが多かった。単語は省略せず折り返す。
              // IPA は補助情報なので 1 行に留め、溢れる分は末尾を省略する。
              Text(
                word.word,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (showIpa) ...[
                // 単語との間は下(品詞バッジとの間)より少し広く取り、発音記号が
                // 単語に詰まって見えないようにする。
                const SizedBox(height: 5),
                Text(
                  word.ipa,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFonts.ipa,
                    color: colors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              PosBadge(partsOfSpeech: word.partsOfSpeech),
              const SizedBox(height: 10),
              _RevealArea(
                meaning: word.meaning,
                revealed: _revealed,
                onToggle: () => setState(() => _revealed = !_revealed),
              ),
              const SizedBox(height: 10),
              // カード高さを揃えるため英例文の領域は 2 行分を確保し、
              // 超過分は末尾を … で省略する。訳を表示している間は省略しない
              // (例文の訳は全文出るため、英文だけ切れていると突き合わせられない)。
              // 確保も訳を隠している間だけにする。表示中は訳の分だけカードの
              // 高さがどのみち変わるため、確保すると 1 行の例文と訳の間が空くだけになる。
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: _revealed ? 0 : _exampleAreaHeight,
                  minWidth: double.infinity,
                ),
                child: Text(
                  hasExample ? word.exampleEn : context.l10n.noExample,
                  maxLines: _revealed ? null : 2,
                  overflow: _revealed ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _exampleFontSize,
                    color: hasExample
                        ? colors.textAlpha(70)
                        : colors.textDisabled,
                    height: _exampleLineHeight,
                  ),
                ),
              ),
              // 例文の訳が無い単語では欄ごと出さない(空の Text でも 1 行分の
              // 高さを取り、例文の下が空く)。iOS の MobileWordCard と同じ条件。
              if (hasExample &&
                  _revealed &&
                  word.exampleTranslation.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  word.exampleTranslation,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textAlpha(50),
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.borderAlpha(6))),
                ),
                child: Row(
                  children: [
                    // チェック操作をカードのタップ(編集モーダル)に伝播させない。
                    GestureDetector(
                      onTap: () {},
                      // LearnedCheckbox はヒット領域の余白(6)を四辺に持つため、
                      // そのままだと箱が区切り線の左端より内側に寄る。余白の分だけ
                      // 左へ出して、箱の左端を区切り線・本文の左端に揃える
                      // (ヒット領域はカードの padding の中に収まる)。
                      child: Transform.translate(
                        offset: const Offset(-6, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LearnedCheckbox(
                              value: word.isLearned,
                              onChanged: widget.onToggleLearned,
                            ),
                            Text(
                              context.l10n.markLearned,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
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

/// 訳の隠し/表示エリア。未表示は破線ボタン、表示は訳テキスト。
class _RevealArea extends ConsumerStatefulWidget {
  const _RevealArea({
    required this.meaning,
    required this.revealed,
    required this.onToggle,
  });

  final String meaning;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  ConsumerState<_RevealArea> createState() => _RevealAreaState();
}

class _RevealAreaState extends ConsumerState<_RevealArea> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  // macOS の入力欄と同じ地 + 枠(iOS の訳の表示枠に対応)。
                  decoration: BoxDecoration(
                    color: colors.inputFill,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: colors.inputBorder),
                  ),
                  child: Text(
                    widget.meaning,
                    style: TextStyle(fontSize: 13, color: colors.textPrimary),
                  ),
                )
              : DottedBorderBox(
                  backgroundColor: _isHovered ? colors.textAlpha(3) : null,
                  child: Text(
                    ref
                        .watch(translationLanguageProvider)
                        .showMeaningLabel(context.l10n),
                    style: TextStyle(fontSize: 12, color: colors.textAlpha(40)),
                  ),
                ),
        ),
      ),
    );
  }
}

/// 破線 border のボックス(「訳を表示」ボタン用)。
/// Flutter 標準に破線 border がないため CustomPaint で描く。
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(context.colors.borderAlpha(18)),
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
  _DashedBorderPainter(this.color);

  /// 破線の色(ライトはプロトタイプの rgba(0,0,0,0.18))。
  final Color color;

  static const _radius = 7.0;
  static const _dashWidth = 4.0;
  static const _dashGap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
