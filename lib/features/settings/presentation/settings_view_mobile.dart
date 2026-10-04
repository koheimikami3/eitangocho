import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/presentation/mobile_pro_section.dart';
import 'package:eitangocho/features/review/data/review_prompter.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/author_app.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/presentation/license_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_author_app_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_card_layout_preview.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_data_backup_rows.dart';
// DeepL の欄を隠している間だけ未使用になる(下のコメントアウト箇所を参照)。
// ignore: unused_import
import 'package:eitangocho/features/settings/presentation/widgets/mobile_deepl_api_key_field.dart';
// 同上(DeepL の欄の説明文で使う)。セクション下の説明文はデザイン刷新で
// 無くなり、残る説明文は MobileSyncStatusCaption が自前で組んでいる。
// ignore: unused_import
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_caption.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_link_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_radio_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_section.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_subheader.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_value_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_toggle_row.dart';
import 'package:eitangocho/features/sync/presentation/mobile_sync_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面。変更は即保存。
///
/// macOS 版との差分は 2 つ:
/// - 「表示」に外観(ライト / ダーク)と学習中カードの並びを持つ。
///   macOS はライト固定・カードの並びは 1 種類のため無い
/// - 「表示サイズ」(uiScale)を持たない。iOS は OS の文字サイズ設定に委ねる
///
/// 並びは「表示 → クイズ → データ → サポート → 情報」。見た目に関わるものを
/// 1 枚のカードにまとめ、セクション内はアプリ全体(テーマ)→ 一覧のレイアウト
/// → 表示項目(IPA)の順にする。
class SettingsViewMobile extends ConsumerWidget {
  const SettingsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ロード前は既定値でフォールバックする。
    final settings = ref.watch(settingsProvider).value ?? const SettingsState();
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        // タブバーが重なる分の余白(シェルが MediaQuery で渡している)。
        // 最後のカードがタブバーに近づきすぎないよう、設定画面だけ余分に空ける。
        AppDimensions.mobilePadding * 2 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        // 課金を扱えない環境(SDK キーが未設定・iOS 以外)ではセクションごと
        // 出さない。間隔の SizedBox も一緒に畳まないと余白だけが残る。
        if (ref.watch(purchaseProvider).available) ...[
          const MobileProSection(),
          const SizedBox(height: 22),
        ],
        MobileSettingsSection(
          title: '表示',
          rows: [
            const MobileSettingsSubheader(label: 'テーマ'),
            for (final appearance in AppAppearance.values)
              MobileSettingsRadioRow(
                label: appearance.label,
                selected: settings.appearance == appearance,
                onTap: () => notifier.setAppearance(appearance),
              ),
            const MobileSettingsSubheader(label: '学習中カードの並び'),
            for (final layout in LearningCardLayout.values)
              MobileSettingsRadioRow(
                label: layout.label,
                selected: settings.cardLayout == layout,
                onTap: () => notifier.setCardLayout(layout),
                trailing: MobileCardLayoutPreview(layout: layout),
              ),
            MobileSettingsToggleRow(
              label: '発音記号(IPA)を表示',
              value: settings.showIpa,
              onChanged: notifier.setShowIpa,
            ),
          ],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: 'クイズ',
          rows: [
            for (final direction in QuizDirection.values)
              MobileSettingsRadioRow(
                label: direction.label,
                selected: settings.quizDirection == direction,
                onTap: () => notifier.setQuizDirection(direction),
              ),
          ],
        ),
        // DeepL API キーの欄は様子見で隠している。例文の和訳は Tatoeba が
        // 対で返すようになり、キーを用意できる利用者もほぼいないため
        // (欄があるだけで何のことか分からず混乱を招く)。設定値と
        // DeeplClient は残してあるので、戻すならここを外すだけでよい。
        // const SizedBox(height: 22),
        // MobileSettingsSection(
        //   title: 'DeepL API キー(例文の自動和訳)',
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       MobileDeeplApiKeyField(
        //         // controller の初期値は初回 build でしか反映されないため、
        //         // 設定のロード完了(hasValue の変化)で作り直して保存値を映す。
        //         key: ValueKey(ref.watch(settingsProvider).hasValue),
        //         initialValue: settings.deeplApiKey,
        //       ),
        //       const SizedBox(height: 8),
        //       MobileSettingsCaption(
        //         'DeepL API Free のキーを設定すると、自動入力時に英例文の日本語訳を'
        //         '取得します。未設定の場合、例文の和訳はスキップされます。',
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 22),
        // iCloud 同期と書き出し / 読み込みは、どちらも単語帳そのものの持ち出しを
        // 扱うため 1 枚のカードにまとめる(デザイン準拠)。
        const MobileSettingsSection(
          title: 'データ',
          rows: [MobileSyncRows(), MobileDataBackupRows()],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: 'サポート',
          rows: [
            // 自分から書きたい人の受け皿。OS のレビュー依頼はクォータ
            // (年 3 回)で出ないことがあるため、常設の導線を別に置く。
            MobileSettingsLinkRow(
              label: 'App Store でレビューを書く',
              onTap: () => ref.read(reviewPrompterProvider).openStoreListing(),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // 紹介先が iPhone 専用アプリのため、この枠は iOS 版にしか無い
        // (macOS から踏んでもインストールできない)。
        MobileSettingsSection(
          title: '作者の他のアプリ',
          rows: [for (final app in AuthorApp.all) MobileAuthorAppRow(app: app)],
        ),
        const SizedBox(height: 22),
        MobileSettingsSection(
          title: '情報',
          rows: [
            MobileSettingsValueRow(
              label: 'バージョン',
              // 取得前は空欄にする(一瞬のプレースホルダの方が目に付く)。
              value: ref.watch(appVersionProvider).value ?? '',
            ),
            MobileSettingsLinkRow(
              label: 'ライセンス',
              onTap: () => LicenseViewMobile.push(context),
            ),
          ],
        ),
      ],
    );
  }
}
