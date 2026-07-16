import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    // SharedPreferencesAsync のインメモリ実装をプラットフォームに差し込む。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('未設定のときは既定値(enToJa / showIpa=true / キー空)を返す', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final settings = await container.read(settingsProvider.future);
    expect(settings.quizDirection, QuizDirection.enToJa);
    expect(settings.showIpa, isTrue);
    expect(settings.deeplApiKey, isEmpty);
  });

  test('setQuizDirection / setShowIpa / setDeeplApiKey で state が更新される', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);

    final notifier = container.read(settingsProvider.notifier);
    await notifier.setQuizDirection(QuizDirection.jaToEn);
    await notifier.setShowIpa(false);
    await notifier.setDeeplApiKey(' my-key ');

    final settings = container.read(settingsProvider).requireValue;
    expect(settings.quizDirection, QuizDirection.jaToEn);
    expect(settings.showIpa, isFalse);
    // 前後の空白は取り除いて保存する
    expect(settings.deeplApiKey, 'my-key');
  });

  test('保存した設定は新しい container(再読込)でも保持される', () async {
    final container1 = ProviderContainer();
    await container1.read(settingsProvider.future);
    await container1
        .read(settingsProvider.notifier)
        .setQuizDirection(QuizDirection.jaToEn);
    await container1
        .read(settingsProvider.notifier)
        .setShowIpa(false);
    await container1
        .read(settingsProvider.notifier)
        .setDeeplApiKey('persisted-key');
    container1.dispose();

    // 同じプラットフォーム(インメモリ)を共有した別 container で読み直す。
    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final settings = await container2.read(settingsProvider.future);

    expect(settings.quizDirection, QuizDirection.jaToEn);
    expect(settings.showIpa, isFalse);
    expect(settings.deeplApiKey, 'persisted-key');
  });
}
