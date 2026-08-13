import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/ads/presentation/tab_bar_banner_visible_provider.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Provider を読むだけでも binding の初期化が要る(riverpod 3)。
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  /// 学習済み 1 件でクイズを開始できる container。quiz_page_notifier_test と
  /// 同じく learnedWordsProvider を静的リストに差し替え、drift の watch() を
  /// 購読させない。
  Future<ProviderContainer> setup() async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    await db.wordDao.setLearned(id, isLearned: true);
    final learned = (await db.wordDao.watchAll().first)
        .where((w) => w.isLearned)
        .toList();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        learnedWordsProvider.overrideWithValue(learned),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('クイズ以外のビューでは出す', () async {
    final container = await setup();

    container.read(mainPageProvider.notifier).selectView(MainView.learning);

    expect(container.read(tabBarBannerVisibleProvider), isTrue);
  });

  test('出題中のクイズでは出す(レクタングルはまだ出ていない)', () async {
    final container = await setup();

    container.read(mainPageProvider.notifier).selectView(MainView.quiz);
    container.read(quizPageProvider.notifier).startQuiz();

    expect(container.read(quizPageProvider).phase, QuizPhase.active);
    expect(container.read(tabBarBannerVisibleProvider), isTrue);
  });

  test('クイズ結果ではレクタングルに譲って引っ込む', () async {
    final container = await setup();

    container.read(mainPageProvider.notifier).selectView(MainView.quiz);
    container.read(quizPageProvider.notifier).startQuiz();
    // 1 件だけなので 1 回答えれば結果画面になる。
    await container.read(quizPageProvider.notifier).answerKnew();

    expect(container.read(quizPageProvider).phase, QuizPhase.done);
    expect(container.read(tabBarBannerVisibleProvider), isFalse);
  });
}
