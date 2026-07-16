import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/widgets/deepl_api_key_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面(クイズ出題方向・IPA 表示)。変更は即保存。
/// 見た目は Material 標準ウィジェットで実装し、磨き込みは Phase 4 に回す。
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ロード前は既定値でフォールバックする。
    final settings =
        ref.watch(settingsProvider).value ??
        const SettingsState();
    final notifier = ref.read(settingsProvider.notifier);

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: SizedBox(
          width: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('クイズの出題方向'),
              RadioGroup<QuizDirection>(
                groupValue: settings.quizDirection,
                onChanged: (value) {
                  if (value != null) notifier.setQuizDirection(value);
                },
                child: Column(
                  children: [
                    for (final direction in QuizDirection.values)
                      RadioListTile<QuizDirection>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(direction.label),
                        value: direction,
                        activeColor: AppColors.accent,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('発音記号(IPA)を表示'),
                value: settings.showIpa,
                activeThumbColor: AppColors.accent,
                onChanged: notifier.setShowIpa,
              ),
              const SizedBox(height: 20),
              const _SectionLabel('DeepL API キー(例文の自動和訳)'),
              DeeplApiKeyField(
                // controller の初期値は初回 build でしか反映されないため、
                // 設定のロード完了(hasValue の変化)で作り直して保存値を映す。
                key: ValueKey(ref.watch(settingsProvider).hasValue),
                initialValue: settings.deeplApiKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
