import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_data_management_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_deepl_api_key_field.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_radio_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_toggle_row.dart';
import 'package:eitangocho/features/sync/presentation/mobile_sync_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面。変更は即保存。
///
/// macOS 版との差分は 2 つ:
/// - 「外観」(ライト / ダーク)を持つ。macOS はライト固定
/// - 「表示サイズ」(uiScale)を持たない。iOS は OS の文字サイズ設定に委ねる
class SettingsViewMobile extends ConsumerWidget {
  const SettingsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    // ロード前は既定値でフォールバックする。
    final settings =
        ref.watch(settingsProvider).value ?? const SettingsState();
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        // タブバーが重なる分の余白(シェルが MediaQuery で渡している)。
        AppDimensions.mobilePadding + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        MobileSettingsSection(
          title: '外観',
          rows: [
            for (final appearance in AppAppearance.values)
              MobileSettingsRadioRow(
                label: appearance.label,
                selected: settings.appearance == appearance,
                onTap: () => notifier.setAppearance(appearance),
              ),
          ],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: 'クイズの出題方向',
          rows: [
            for (final direction in QuizDirection.values)
              MobileSettingsRadioRow(
                label: direction.label,
                selected: settings.quizDirection == direction,
                onTap: () => notifier.setQuizDirection(direction),
              ),
          ],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: '表示',
          rows: [
            MobileSettingsToggleRow(
              label: '発音記号(IPA)を表示',
              value: settings.showIpa,
              onChanged: notifier.setShowIpa,
            ),
          ],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: 'DeepL API キー(例文の自動和訳)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MobileDeeplApiKeyField(
                // controller の初期値は初回 build でしか反映されないため、
                // 設定のロード完了(hasValue の変化)で作り直して保存値を映す。
                key: ValueKey(ref.watch(settingsProvider).hasValue),
                initialValue: settings.deeplApiKey,
              ),
              const SizedBox(height: 8),
              Text(
                'DeepL API Free のキーを設定すると、自動入力時に英例文の日本語訳を'
                '取得します。未設定の場合、例文の和訳はスキップされます。',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.6,
                  color: palette.textAlpha(40),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const MobileSettingsSection(
          title: 'iCloud 同期',
          child: MobileSyncSection(),
        ),
        const SizedBox(height: 22),
        const MobileSettingsSection(
          title: 'データ',
          child: MobileDataManagementSection(),
        ),
      ],
    );
  }
}
