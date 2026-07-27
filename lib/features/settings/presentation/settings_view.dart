import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/widgets/data_management_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/deepl_api_key_field.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_card.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_radio_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/ui_scale_slider.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面(クイズ出題方向・表示・DeepL API キー・データ)。変更は即保存。
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
              SettingsSection(
                title: 'クイズの出題方向',
                child: SettingsCard(
                  children: [
                    for (final direction in QuizDirection.values)
                      SettingsRadioRow(
                        label: direction.label,
                        selected: settings.quizDirection == direction,
                        onTap: () => notifier.setQuizDirection(direction),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: '表示',
                child: SettingsCard(
                  children: [
                    SettingsToggleRow(
                      label: '発音記号(IPA)を表示',
                      value: settings.showIpa,
                      onChanged: notifier.setShowIpa,
                    ),
                    // 表示サイズは macOS 専用(EitangochoApp の uiScale)。
                    // iOS では OS の文字サイズ設定に委ねるため出さない。
                    if (AppPlatform.isMacOS)
                      UiScaleSlider(value: settings.uiScale),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: 'DeepL API キー(例文の自動和訳)',
                child: DeeplApiKeyField(
                  // controller の初期値は初回 build でしか反映されないため、
                  // 設定のロード完了(hasValue の変化)で作り直して保存値を映す。
                  key: ValueKey(ref.watch(settingsProvider).hasValue),
                  initialValue: settings.deeplApiKey,
                ),
              ),
              const SizedBox(height: 22),
              const SettingsSection(
                title: 'データ',
                child: DataManagementSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
