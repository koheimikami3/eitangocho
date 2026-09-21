import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
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

  test('未設定のときは既定値(enToJa / showIpa=true / キー空 / 既定スケール)を返す', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final settings = await container.read(settingsProvider.future);
    expect(settings.quizDirection, QuizDirection.enToJa);
    expect(settings.showIpa, isTrue);
    expect(settings.deeplApiKey, isEmpty);
    expect(settings.uiScale, AppDimensions.defaultUiScale);
    // 学習中カードの既定は 2 列。
    expect(settings.cardLayout, LearningCardLayout.twoColumns);
    // 全単語の並びの既定は登録日の新しい順(並び替え導入前と同じ)。
    expect(settings.wordSortOrder, WordSortOrder.newest);
  });

  test('setWordSortOrder で state が更新され、次回読み込みでも復元される', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);

    await container
        .read(settingsProvider.notifier)
        .setWordSortOrder(WordSortOrder.mostCorrect);
    expect(
      container.read(settingsProvider).requireValue.wordSortOrder,
      WordSortOrder.mostCorrect,
    );

    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final restored = await container2.read(settingsProvider.future);
    expect(restored.wordSortOrder, WordSortOrder.mostCorrect);
  });

  test('setCardLayout で state が更新され、次回読み込みでも復元される', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);

    await container
        .read(settingsProvider.notifier)
        .setCardLayout(LearningCardLayout.oneColumn);
    expect(
      container.read(settingsProvider).requireValue.cardLayout,
      LearningCardLayout.oneColumn,
    );

    // 同じインメモリ prefs を共有した別 container で読み直す。
    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final restored = await container2.read(settingsProvider.future);
    expect(restored.cardLayout, LearningCardLayout.oneColumn);
  });

  test('setUiScale は範囲外の値を min/max に丸めて保存する', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);

    final notifier = container.read(settingsProvider.notifier);
    await notifier.setUiScale(1.3);
    expect(container.read(settingsProvider).requireValue.uiScale, 1.3);

    await notifier.setUiScale(99);
    expect(
      container.read(settingsProvider).requireValue.uiScale,
      AppDimensions.maxUiScale,
    );
  });

  test(
    'setQuizDirection / setShowIpa / setDeeplApiKey で state が更新される',
    () async {
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
    },
  );

  test('appearance の既定はライトで、setAppearance で切り替わり永続化される', () async {
    final container1 = ProviderContainer();
    final initial = await container1.read(settingsProvider.future);
    expect(initial.appearance, AppAppearance.light);

    await container1
        .read(settingsProvider.notifier)
        .setAppearance(AppAppearance.dark);
    expect(
      container1.read(settingsProvider).requireValue.appearance,
      AppAppearance.dark,
    );
    container1.dispose();

    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final reloaded = await container2.read(settingsProvider.future);
    expect(reloaded.appearance, AppAppearance.dark);
  });

  test('保存した設定は新しい container(再読込)でも保持される', () async {
    final container1 = ProviderContainer();
    await container1.read(settingsProvider.future);
    await container1
        .read(settingsProvider.notifier)
        .setQuizDirection(QuizDirection.jaToEn);
    await container1.read(settingsProvider.notifier).setShowIpa(false);
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
