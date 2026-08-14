import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_caption.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/presentation/sync_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」セクションのうち、iCloud 同期の部分。
class MobileSyncSection extends ConsumerWidget {
  const MobileSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final state = ref.watch(syncProvider);
    final notifier = ref.read(syncProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.borderAlpha(10)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MobileSettingsToggleRow(
                label: 'iCloud 同期',
                value: state.enabled,
                onChanged: (value) => notifier.setEnabled(enabled: value),
              ),
              if (state.enabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: palette.borderAlpha(7),
                  ),
                ),
                _SyncNowRow(syncing: state.syncing, onTap: notifier.syncNow),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        MobileSettingsCaption(
          syncStatusText(state),
          color: state.errorMessage != null ? palette.danger : null,
        ),
      ],
    );
  }
}

class _SyncNowRow extends StatelessWidget {
  const _SyncNowRow({required this.syncing, required this.onTap});

  final bool syncing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: syncing ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '今すぐ同期',
                style: TextStyle(
                  fontSize: 14,
                  color: syncing ? palette.textAlpha(40) : palette.accent,
                ),
              ),
            ),
            if (syncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
