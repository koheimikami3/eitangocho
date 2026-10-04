import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_quiz_rectangle_ad.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のクイズ完了画面(成績・忘れていた単語一覧・導線)。
class MobileQuizResultView extends ConsumerWidget {
  const MobileQuizResultView({
    required this.okCount,
    required this.forgotWords,
    super.key,
  });

  final int okCount;
  final List<Word> forgotWords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '復習完了',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '覚えている $okCount語 / 忘れていた ${forgotWords.length}語',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.textAlpha(60)),
        ),
        if (forgotWords.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ForgotList(words: forgotWords),
        ],
        // 広告は一覧とボタンの間(デザインどおり)。上の余白は広告自身が
        // 持つため、読み込めなければ高さごと消えて元のレイアウトに戻る。
        const MobileQuizRectangleAd(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MobileFilledButton(
                label: '続ける',
                onPressed: () =>
                    ref.read(quizPageProvider.notifier).startQuiz(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // 立体案では 2 つとも主ボタン(どちらも次の行動として同格)。
              child: MobileFilledButton(
                label: '学習中リストへ',
                onPressed: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.learning),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForgotList extends StatelessWidget {
  const _ForgotList({required this.words});

  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final radius = BorderRadius.circular(AppDimensions.mobileCardRadius);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: radius,
        boxShadow: palette.elevation,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            // グレーの見出しは地(background)と見分けが付かなかったため、
            // 「忘れていた」に合わせて淡い赤の地 + 赤文字にする。
            decoration: BoxDecoration(
              color: palette.dangerSoft,
              border: Border(bottom: BorderSide(color: palette.rowLine)),
            ),
            child: Text(
              '忘れていた単語(学習中リストに戻りました)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.danger,
              ),
            ),
          ),
          for (var i = 0; i < words.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              // 区切り線は行と行の間だけ。最後の行にも引くとカードの下枠と
              // 2 本並んで太く見える。
              decoration: i < words.length - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: palette.rowLine),
                      ),
                    )
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      words[i].word,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      words[i].meaning,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textAlpha(60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
