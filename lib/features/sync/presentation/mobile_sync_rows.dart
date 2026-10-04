import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/presentation/sync_status_text.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」カードのうち、iCloud 同期の行。
///
/// カード枠は [MobileSettingsSection] が描くため、ここは行だけを返す
/// (同じカードに書き出し / 読み込みの行が続く)。
///
/// 同期状態はカードの外に出さず「今すぐ同期」行の右端に出す。カードの下に
/// 置くと、間に書き出し / 読み込みの行が挟まって何に掛かる文か読めないため。
/// エラーだけは長く折り返しが要るので独立した行にする。
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
          label: context.l10n.icloudSync,
          value: state.enabled,
          onChanged: (value) => notifier.setEnabled(enabled: value),
        ),
        if (state.enabled) ...[
          const MobileSettingsDivider(),
          _SyncNowRow(
            syncing: state.syncing,
            status: syncStatusText(context.l10n, state),
            onTap: notifier.syncNow,
          ),
          if (state.failure case final failure?) ...[
            const MobileSettingsDivider(),
            _SyncErrorRow(message: syncFailureText(context.l10n, failure)),
          ],
        ],
      ],
    );
  }
}

class _SyncNowRow extends StatelessWidget {
  const _SyncNowRow({
    required this.syncing,
    required this.status,
    required this.onTap,
  });

  final bool syncing;
  final String status;
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
                context.l10n.syncNow,
                style: TextStyle(
                  fontSize: 14,
                  // カード地に載るアクセント文字は accentOnSoft を使う
                  // (accent のままだと 4.5:1 に届かない)。Pro の復元行と同じ。
                  color: syncing ? palette.textAlpha(40) : palette.accentOnSoft,
                ),
              ),
            ),
            // 右端の状態はバージョン行(MobileSettingsValueRow)と同じ体裁。
            Text(
              status,
              style: TextStyle(fontSize: 13, color: palette.textAlpha(40)),
            ),
            if (syncing) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncErrorRow extends StatelessWidget {
  const _SyncErrorRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        message,
        // 行というより注記なので、他の行(14px)より小さくする。
        style: TextStyle(fontSize: 12, height: 1.5, color: palette.danger),
      ),
    );
  }
}
