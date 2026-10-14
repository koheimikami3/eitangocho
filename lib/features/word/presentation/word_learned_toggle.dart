import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 一覧・カードの「覚えた」チェックの操作。
///
/// 学習中・全単語 × macOS / iOS の 4 画面が同じことをするため 1 つにまとめる
/// (計測の送り忘れを防ぐ)。クイズの「忘れていた」による学習中への戻しは
/// ユーザーの操作ではないので、ここを通さない(QuizPageNotifier.answerForgot)。
Future<void> toggleWordLearned(
  WidgetRef ref,
  Word word, {
  required bool isLearned,
}) {
  ref
      .read(analyticsLoggerProvider)
      .logWordLearnedToggled(word, isLearned: isLearned);
  return ref
      .read(databaseProvider)
      .wordDao
      .setLearned(word.id, isLearned: isLearned);
}
