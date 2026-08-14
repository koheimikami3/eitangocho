import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_caption.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_card.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/presentation/sync_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面「データ」セクションのうち、iCloud 同期の部分。
class DesktopSyncSection extends ConsumerWidget {
  const DesktopSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncProvider);
    final notifier = ref.read(syncProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsCard(
          children: [
            SettingsToggleRow(
              label: 'iCloud 同期',
              value: state.enabled,
              onChanged: (value) => notifier.setEnabled(enabled: value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (state.enabled)
              AppOutlinedButton(
                label: state.syncing ? '同期中...' : '今すぐ同期',
                verticalPadding: 8,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                onPressed: state.syncing ? () {} : notifier.syncNow,
              ),
            if (state.enabled) const SizedBox(width: 10),
            Expanded(
              child: SettingsCaption(
                syncStatusText(state),
                color: state.errorMessage != null ? AppColors.danger : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
