import 'dart:async';

import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/domain/quiz_question_selection.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_page_notifier.g.dart';

/// フラッシュクイズの進行を管理する。プロトタイプの startQuiz / quizAnswer /
/// quizForgot のロジックに準拠する。
///
/// keepAlive にしているのは、サイドバーの onTap が `read().startQuiz()` で状態を
/// セットしてから selectView するため。自動破棄だと QuizView がマウントされる前に
/// (リスナー不在で)破棄され、startQuiz の結果が初期状態に戻ってしまう。
/// クイズビューへの入口は必ず startQuiz を呼ぶので「入場ごとに新セッション」は保たれる。
@Riverpod(keepAlive: true)
class QuizPageNotifier extends _$QuizPageNotifier {
  @override
  QuizPageState build() => const QuizPageState();

  /// 学習済み単語から 1 セッション分を選んで新セッションを開始する
  /// (選び方は [selectQuizQuestions])。結果画面の「続ける」もここを呼ぶ。
  /// 直前に答えた単語は日時が新しくなって後ろに回るため、次の単語が出る。
  void startQuiz() {
    final questions = selectQuizQuestions(ref.read(learnedWordsProvider));
    state = QuizPageState(
      phase: questions.isEmpty ? QuizPhase.empty : QuizPhase.active,
      questions: questions,
    );
  }

  void reveal() => state = state.copyWith(revealed: true);

  /// 「覚えている」: 実績を記録して次へ進む。
  Future<void> answerKnew() async {
    final word = state.questions[state.index];
    await ref
        .read(databaseProvider)
        .wordDao
        .recordQuizResult(word.id, knew: true);
    _advance(knew: true, word: word);
  }

  /// 「忘れていた」: 学習中に戻し、実績を記録して次へ進む。
  Future<void> answerForgot() async {
    final word = state.questions[state.index];
    final dao = ref.read(databaseProvider).wordDao;
    await dao.setLearned(word.id, isLearned: false);
    await dao.recordQuizResult(word.id, knew: false);
    _advance(knew: false, word: word);
  }

  void _advance({required bool knew, required Word word}) {
    final next = state.index + 1;
    final done = next >= state.questions.length;
    state = state.copyWith(
      index: next,
      revealed: false,
      okCount: state.okCount + (knew ? 1 : 0),
      forgotWords: knew ? state.forgotWords : [...state.forgotWords, word],
      phase: done ? QuizPhase.done : QuizPhase.active,
    );

    // 最後まで終えた直後がレビュー依頼の唯一の契機(条件は ReviewPrompter が
    // 判定し、満たさなければ何も起きない)。macOS / iOS の両方がこの Notifier を
    // 共有しているため、呼び出し口はここ 1 箇所で足りる。
    // 依頼の成否はクイズの進行に関係しないので待たない。
    if (done) {
      unawaited(
        ref
            .read(reviewPrompterProvider)
            .onQuizCompleted(
              okCount: state.okCount,
              total: state.questions.length,
            ),
      );
    }
  }
}
