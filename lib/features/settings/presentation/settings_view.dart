import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/license_dialog.dart';
import 'package:eitangocho/features/settings/presentation/widgets/data_backup_rows.dart';
// DeepL の欄を隠している間だけ未使用になる(下のコメントアウト箇所を参照)。
// ignore: unused_import
import 'package:eitangocho/features/settings/presentation/widgets/deepl_api_key_field.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_caption.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_card.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_link_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_radio_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_value_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/ui_scale_slider.dart';
import 'package:eitangocho/features/sync/presentation/desktop_sync_rows.dart';
import 'package:eitangocho/features/sync/presentation/desktop_sync_status_caption.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面(表示・クイズ・データ・サポート・情報)。変更は即保存。
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ロード前は既定値でフォールバックする。
    final settings = ref.watch(settingsProvider).value ?? const SettingsState();
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
                title: 'クイズ',
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
              const SettingsSection(
                title: 'データ',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsCard(
                      children: [DesktopSyncRows(), DataBackupRows()],
                    ),
                    SizedBox(height: 8),
                    // 同期状態(最終同期・エラー)はカードの外に出す。
                    // デザインの図には無いが、同期の失敗を伝える唯一の場所。
                    DesktopSyncStatusCaption(),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SettingsSection(
                title: 'サポート',
                child: SettingsCard(
                  children: [
                    // 自分から書きたい人の受け皿。OS のレビュー依頼はクォータ
                    // (年 3 回)で出ないことがあるため、常設の導線を別に置く。
                    SettingsLinkRow(
                      label: 'App Store でレビューを書く',
                      onTap: () =>
                          ref.read(reviewPrompterProvider).openStoreListing(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SettingsCaption('感想やご要望はレビューでお知らせください。'),
              const SizedBox(height: 22),
              SettingsSection(
                title: '情報',
                child: SettingsCard(
                  children: [
                    SettingsValueRow(
                      label: 'バージョン',
                      // 取得前は空欄にする(一瞬のプレースホルダの方が目に付く)。
                      value: ref.watch(appVersionProvider).value ?? '',
                    ),
                    // ライセンスは最後に置く。カード下の説明文がこの行に掛かる。
                    SettingsLinkRow(
                      label: 'ライセンス',
                      onTap: () => showLicenseDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SettingsCaption(
                '本アプリが利用しているオープンソースソフトウェアの一覧です。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
