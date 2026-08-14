import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」カードのうち、iCloud 同期の行。
///
/// カード枠は [MobileSettingsSection] が描くため、ここは行だけを返す
/// (同じカードに書き出し / 読み込みの行が続く)。同期状態の説明文は
/// カードの外に出るので [MobileSyncStatusCaption] が持つ。
class MobileSyncRows extends ConsumerWidget {
  const MobileSyncRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncProvider);
    final notifier = ref.read(syncProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileSettingsToggleRow(
          label: 'iCloud 同期',
          value: state.enabled,
          onChanged: (value) => notifier.setEnabled(enabled: value),
        ),
        if (state.enabled) ...[
          const MobileSettingsDivider(),
          _SyncNowRow(syncing: state.syncing, onTap: notifier.syncNow),
        ],
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
                  // カード地に載るアクセント文字は accentOnSoft を使う
                  // (accent のままだと 4.5:1 に届かない)。Pro の復元行と同じ。
                  color: syncing
                      ? palette.textAlpha(40)
                      : palette.accentOnSoft,
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
