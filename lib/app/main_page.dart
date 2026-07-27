import 'package:eitangocho/app/shells/sidebar_shell.dart';
import 'package:eitangocho/app/shells/tab_bar_shell.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェル。プラットフォームに応じてサイドバー版 / タブバー版を選ぶ。
///
/// 画面幅では分岐しない。uiScale(既定 1.5)により macOS の論理幅は実測の
/// 2/3 になり、幅を基準にすると macOS でタブバー版に落ちてしまうため。
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EJDict の初回取込をバックグラウンドでキックする(UI はブロックしない。
    // 自動入力側が完了を await するため、起動直後から開始しておく)。
    ref.watch(ejdictImportProvider);

    return AppPlatform.isMacOS ? const SidebarShell() : const TabBarShell();
  }
}
