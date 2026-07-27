import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// 呼ばれた回数を数えるだけの保管先。失敗も再現できる。
class _CountingStore implements CloudFileStore {
  String? contents;
  int writeCount = 0;
  Exception? failWith;

  @override
  Future<String?> read() async {
    if (failWith != null) throw failWith!;
    return contents;
  }

  @override
  Future<DateTime?> lastModified() async => null;

  @override
  Future<void> write(String value) async {
    if (failWith != null) throw failWith!;
    contents = value;
    writeCount++;
  }
}

void main() {
  late AppDatabase db;
  late _CountingStore store;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = _CountingStore();
  });

  tearDown(() async => db.close());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        cloudFileStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('既定は無効で、無効なうちは同期を実行しない', () async {
    final container = makeContainer();

    expect(container.read(syncProvider).enabled, isFalse);

    await container.read(syncProvider.notifier).syncNow();

    expect(store.writeCount, 0);
  });

  test('有効にすると 1 回同期し、最終同期日時が入る', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final container = makeContainer();

    await container
        .read(syncProvider.notifier)
        .setEnabled(enabled: true);

    final state = container.read(syncProvider);
    expect(state.enabled, isTrue);
    expect(state.syncing, isFalse);
    expect(state.lastSyncedAt, isNotNull);
    expect(state.errorMessage, isNull);
    expect(store.writeCount, 1);
  });

  test('iCloud が使えないときはエラーメッセージを保持し、落ちない', () async {
    store.failWith = const CloudUnavailableException('iCloud が利用できません。');
    final container = makeContainer();

    await container
        .read(syncProvider.notifier)
        .setEnabled(enabled: true);

    final state = container.read(syncProvider);
    expect(state.syncing, isFalse);
    expect(state.errorMessage, 'iCloud が利用できません。');
    expect(state.lastSyncedAt, isNull);
  });

  test('有効/無効は永続化され、次回起動時に復元される', () async {
    final container1 = makeContainer();
    await container1
        .read(syncProvider.notifier)
        .setEnabled(enabled: true);
    container1.dispose();

    // 同じインメモリ prefs を共有した別 container で読み直す。
    final container2 = makeContainer();
    // build() 内の復元は非同期なので、完了を待ってから読む。
    await container2.read(syncProvider.notifier).initialized;

    expect(container2.read(syncProvider).enabled, isTrue);
  });
}
