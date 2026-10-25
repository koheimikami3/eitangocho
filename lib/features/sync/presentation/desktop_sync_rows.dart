import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/presentation/sync_status_text.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面「データ」カードのうち、iCloud 同期の行。
///
/// カード枠は [SettingsCard] が描くため、ここは行だけを返す(同じカードに
/// 書き出し / 読み込みの行が続く)。
///
/// 同期状態はカードの外に出さず「今すぐ同期」行の右端に出す。カードの下に
/// 置くと、間に書き出し / 読み込みの行が挟まって何に掛かる文か読めないため。
/// エラーだけは長く折り返しが要るので独立した行にする。
class DesktopSyncRows extends ConsumerWidget {
  const DesktopSyncRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncProvider);
    final notifier = ref.read(syncProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsToggleRow(
          label: context.l10n.icloudSync,
          value: state.enabled,
          onChanged: (value) => notifier.setEnabled(enabled: value),
        ),
        if (state.enabled) ...[
          const SettingsDivider(),
          _SyncNowRow(
            syncing: state.syncing,
            status: syncStatusText(context.l10n, state),
            onTap: notifier.syncNow,
          ),
          if (state.failure case final failure?) ...[
            const SettingsDivider(),
            _SyncErrorRow(message: syncFailureText(context.l10n, failure)),
          ],
        ],
      ],
    );
  }
}

/// 「今すぐ同期」行。iOS 版と同じくカード内の行として組む
/// (カードの外にボタンだけ取り残さないため)。
class _SyncNowRow extends StatefulWidget {
  const _SyncNowRow({
    required this.syncing,
    required this.status,
    required this.onTap,
  });

  final bool syncing;
  final String status;
  final VoidCallback onTap;

  @override
  State<_SyncNowRow> createState() => _SyncNowRowState();
}

class _SyncNowRowState extends State<_SyncNowRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      cursor: widget.syncing
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.syncing ? null : widget.onTap,
        child: Container(
          color: _hovered && !widget.syncing ? colors.inputBackground : null,
          // 寸法は SettingsLinkRow に合わせる(同じカードに並ぶため)。
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.syncNow,
                  style: TextStyle(
                    fontSize: 13,
                    // カード地に載るアクセント文字は accentOnSoft を使う
                    // (accent のままだと 4.5:1 に届かない)。
                    color: widget.syncing
                        ? colors.textDisabled
                        : colors.accentOnSoft,
                  ),
                ),
              ),
              // 右端の状態はバージョン行(SettingsValueRow)と同じ体裁。
              Text(
                widget.status,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              if (widget.syncing) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                ),
              ],
            ],
          ),
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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Text(
        message,
        // 行というより注記なので、他の行(13px)より小さくする。
        style: TextStyle(fontSize: 12, height: 1.5, color: colors.danger),
      ),
    );
  }
}
