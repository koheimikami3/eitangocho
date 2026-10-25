import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/license_dialog.dart';
import 'package:eitangocho/features/settings/presentation/widgets/data_backup_rows.dart';
// DeepL の欄を隠している間だけ未使用になる(下のコメントアウト箇所を参照)。
// ignore: unused_import
import 'package:eitangocho/features/settings/presentation/widgets/deepl_api_key_field.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_card.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_link_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_radio_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_value_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/ui_scale_slider.dart';
import 'package:eitangocho/features/sync/presentation/desktop_sync_rows.dart';
import 'package:eitangocho/utils/app_locale.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面(表示・テーマ・クイズ・訳の言語・データ・サポート・情報)。
/// 変更は即保存。
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // ロード前は既定値でフォールバックする。
    final settings = ref.watch(settingsProvider).value ?? const SettingsState();
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = context.l10n;
    final translationLanguage = ref.watch(translationLanguageProvider);

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
                title: l10n.sectionDisplay,
                child: SettingsCard(
                  children: [
                    SettingsToggleRow(
                      label: l10n.showIpa,
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
              // iOS は「表示」の中に小見出しで置くが、macOS のカードには
              // 小見出しの部品が無いため、クイズの出題方向と同じく独立した
              // セクションのラジオ行にする。
              SettingsSection(
                title: l10n.theme,
                child: SettingsCard(
                  children: [
                    for (final appearance in AppAppearance.values)
                      SettingsRadioRow(
                        label: appearance.label(l10n),
                        selected: settings.appearance == appearance,
                        onTap: () => notifier.setAppearance(appearance),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: l10n.sectionQuiz,
                child: SettingsCard(
                  children: [
                    for (final direction in QuizDirection.values)
                      SettingsRadioRow(
                        label: direction.label(l10n, translationLanguage),
                        selected: settings.quizDirection == direction,
                        onTap: () => notifier.setQuizDirection(direction),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: l10n.sectionTranslation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsCard(
                      children: [
                        for (final language
                            in AppLocale.deviceTranslationLanguageChoices(
                              translationLanguage,
                            ))
                          SettingsRadioRow(
                            label: language.label(l10n),
                            selected: translationLanguage == language,
                            onTap: () =>
                                notifier.setTranslationLanguage(language),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 説明文の意匠は DeepL の欄(DeeplApiKeyField)に合わせる。
                    // 位置はセクションの見出しと同じく、カードの角丸が終わる位置。
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.mobileCardRadius,
                      ),
                      child: Text(
                        l10n.translationLanguageCaption,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.6,
                          color: colors.textQuaternary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // DeepL API キーの欄は様子見で隠している。例文の和訳は Tatoeba が
              // 対で返すようになり、キーを用意できる利用者もほぼいないため
              // (欄があるだけで何のことか分からず混乱を招く)。設定値と
              // DeeplClient は残してあるので、戻すならここを外すだけでよい。
              // const SizedBox(height: 22),
              // SettingsSection(
              //   title: 'DeepL API キー(例文の自動和訳)',
              //   child: DeeplApiKeyField(
              //     // controller の初期値は初回 build でしか反映されないため、
              //     // 設定のロード完了(hasValue の変化)で作り直して保存値を映す。
              //     key: ValueKey(ref.watch(settingsProvider).hasValue),
              //     initialValue: settings.deeplApiKey,
              //   ),
              // ),
              const SizedBox(height: 22),
              // iCloud 同期と書き出し / 読み込みは、どちらも単語帳そのものの
              // 持ち出しを扱うため 1 枚のカードにまとめる(デザイン準拠)。
              SettingsSection(
                title: l10n.sectionData,
                child: const SettingsCard(
                  children: [DesktopSyncRows(), DataBackupRows()],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: l10n.sectionSupport,
                child: SettingsCard(
                  children: [
                    // 自分から書きたい人の受け皿。OS のレビュー依頼はクォータ
                    // (年 3 回)で出ないことがあるため、常設の導線を別に置く。
                    SettingsLinkRow(
                      label: l10n.writeReview,
                      onTap: () {
                        ref
                            .read(analyticsLoggerProvider)
                            .logStoreListingOpened();
                        ref.read(reviewPrompterProvider).openStoreListing();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: l10n.sectionInfo,
                child: SettingsCard(
                  children: [
                    SettingsValueRow(
                      label: l10n.version,
                      // 取得前は空欄にする(一瞬のプレースホルダの方が目に付く)。
                      value: ref.watch(appVersionProvider).value ?? '',
                    ),
                    SettingsLinkRow(
                      label: l10n.licenses,
                      onTap: () => showLicenseDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
