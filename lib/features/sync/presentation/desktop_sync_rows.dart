import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_toggle_row.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面「データ」カードのうち、iCloud 同期の行。
///
/// カード枠は [SettingsCard] が描くため、ここは行だけを返す(同じカードに
/// 書き出し / 読み込みの行が続く)。同期状態の説明文はカードの外に出るので
/// [DesktopSyncStatusCaption] が持つ。
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
          label: 'iCloud 同期',
          value: state.enabled,
          onChanged: (value) => notifier.setEnabled(enabled: value),
        ),
        if (state.enabled) ...[
          const SettingsDivider(),
          _SyncNowRow(syncing: state.syncing, onTap: notifier.syncNow),
        ],
      ],
    );
  }
}

/// 「今すぐ同期」行。iOS 版と同じくカード内の行として組む
/// (カードの外にボタンだけ取り残さないため)。
class _SyncNowRow extends StatefulWidget {
  const _SyncNowRow({required this.syncing, required this.onTap});

  final bool syncing;
  final VoidCallback onTap;

  @override
  State<_SyncNowRow> createState() => _SyncNowRowState();
}

class _SyncNowRowState extends State<_SyncNowRow> {
  bool _hovered = false;

  /// ホバー背景(プロトタイプの #f7f7f8)。他のリンク行と同じ。
  static const _hoverBackground = AppColors.inputBackground;

  @override
  Widget build(BuildContext context) {
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
          color: _hovered && !widget.syncing ? _hoverBackground : null,
          // 寸法は SettingsLinkRow に合わせる(同じカードに並ぶため)。
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '今すぐ同期',
                  style: TextStyle(
                    fontSize: 13,
                    // カード地に載るアクセント文字は accentOnSoft を使う
                    // (accent のままだと 4.5:1 に届かない)。
                    color: widget.syncing
                        ? AppColors.textDisabled
                        : AppColors.accentOnSoft,
                  ),
                ),
              ),
              if (widget.syncing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
