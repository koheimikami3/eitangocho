import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_caption.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/presentation/sync_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」カードの下に出す同期状態の説明文。
///
/// 同期の失敗をユーザーに伝える唯一の場所なので、デザインの図に無くても残す。
/// 設定画面本体で同期状態を購読すると画面全体が同期のたびに再ビルドされるため、
/// この小さなウィジェットに閉じている。
class MobileSyncStatusCaption extends ConsumerWidget {
  const MobileSyncStatusCaption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final state = ref.watch(syncProvider);

    return MobileSettingsCaption(
      syncStatusText(state),
      color: state.errorMessage != null ? palette.danger : null,
    );
  }
}
