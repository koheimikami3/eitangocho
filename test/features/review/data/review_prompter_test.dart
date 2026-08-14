import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../fake_review_client.dart';

void main() {
  late AppDatabase db;
  late FakeReviewClient client;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = FakeReviewClient();
  });

  tearDown(() async {
    await db.close();
  });

  // 待ち時間は本番値(1 秒)のままだとテストが遅くなるだけなので潰す。
  ReviewPrompter createPrompter() => ReviewPrompter(
    client: client,
    wordDao: db.wordDao,
    promptDelay: Duration.zero,
  );

  Future<void> seedWords(int count) async {
    for (var i = 0; i < count; i++) {
      await db.wordDao.insertWord(
        WordsCompanion(word: Value('word$i'), japanese: Value('訳$i')),
      );
    }
  }

  /// 前回の依頼日時を直接書き込む(ReviewPrompter のキーと同じもの)。
  Future<void> setLastRequested(Duration ago) => SharedPreferencesAsync().setInt(
    'reviewLastRequestedAt',
    DateTime.now().subtract(ago).millisecondsSinceEpoch,
  );

  /// 成績・出題数の条件を満たすセッションを [times] 回終える。
  Future<void> completeGoodSessions(ReviewPrompter prompter, int times) async {
    for (var i = 0; i < times; i++) {
      await prompter.onQuizCompleted(okCount: 5, total: 5);
    }
  }

  test('条件をすべて満たすと 3 回目の完了で 1 回だけ依頼する', () async {
    await seedWords(20);
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 2);
    expect(client.requestCount, 0, reason: '完了 2 回目までは出さない');

    await completeGoodSessions(prompter, 1);
    expect(client.requestCount, 1);

    // 4 回目以降は間隔(120 日)に引っかかるので出さない。
    await completeGoodSessions(prompter, 1);
    expect(client.requestCount, 1);
  });

  test('出題数が少ないセッションでは依頼しない', () async {
    await seedWords(20);
    final prompter = createPrompter();

    for (var i = 0; i < 5; i++) {
      await prompter.onQuizCompleted(okCount: 4, total: 4);
    }

    expect(client.requestCount, 0);
  });

  test('成績が振るわないセッションでは依頼しない', () async {
    await seedWords(20);
    final prompter = createPrompter();

    for (var i = 0; i < 5; i++) {
      await prompter.onQuizCompleted(okCount: 2, total: 5);
    }

    expect(client.requestCount, 0);
  });

  test('登録単語が少ないうちは依頼しない', () async {
    await seedWords(19);
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 5);

    expect(client.requestCount, 0);
  });

  test('条件を満たさない回も完了回数には数える', () async {
    await seedWords(20);
    final prompter = createPrompter();

    // 成績が悪い 2 回を挟んでも、3 回目の良いセッションで依頼が出る。
    await prompter.onQuizCompleted(okCount: 0, total: 5);
    await prompter.onQuizCompleted(okCount: 1, total: 5);
    await completeGoodSessions(prompter, 1);

    expect(client.requestCount, 1);
  });

  test('前回の依頼から 120 日経っていなければ依頼しない', () async {
    await seedWords(20);
    await setLastRequested(const Duration(days: 119));
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 3);

    expect(client.requestCount, 0);
  });

  test('前回の依頼から 120 日以上経っていれば再び依頼する', () async {
    await seedWords(20);
    await setLastRequested(const Duration(days: 121));
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 3);

    expect(client.requestCount, 1);
  });

  test('レビュー依頼を出せない端末では呼ばない', () async {
    await seedWords(20);
    client.available = false;
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 3);

    expect(client.requestCount, 0);
  });

  test('依頼が失敗しても例外を漏らさず、記録もしないので次回また試す', () async {
    await seedWords(20);
    client.requestError = Exception('SDK エラー');
    final prompter = createPrompter();

    await completeGoodSessions(prompter, 3);
    expect(client.requestCount, 1);

    // 前回の依頼日時が記録されていなければ、次のセッションでも試せる。
    await completeGoodSessions(prompter, 1);
    expect(client.requestCount, 2);
  });

  test('openStoreListing は失敗しても例外を漏らさない', () async {
    client.openStoreListingError = Exception('App Store を開けない');
    final prompter = createPrompter();

    await prompter.openStoreListing();

    expect(client.openStoreListingCount, 1);
  });
}
