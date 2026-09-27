import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_sheet.dart';
import 'package:flutter/material.dart';

/// iOS 版の学習中 0 件の空状態。
///
/// macOS 版(LearningEmptyState)と分けているのは、登録の導線が違うため。
/// タブバー版に登録ビューは無く、ヘッダの「＋ 登録」と同じくシートで開く
/// (macOS 版のように registration ビューへ切り替えると、中身は学習中のまま
/// タイトルだけ「単語を登録」に変わる行き止まりになる)。
///
/// タブバーとバナー広告が重なる分(MediaQuery の下端 padding)を除いた、
/// 見えている領域の中央に置く(MobileLoadingIndicator と同じ)。
class MobileLearningEmptyState extends StatelessWidget {
  const MobileLearningEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '学習中の単語はありません。\n単語を登録しましょう。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: palette.textAlpha(45),
              ),
            ),
            const SizedBox(height: 16),
            MobileFilledButton(
              label: '＋ 単語を登録',
              onPressed: () => showWordRegistrationSheet(context),
              fontSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              borderRadius: 11,
            ),
          ],
        ),
      ),
    );
  }
}
