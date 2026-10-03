import 'package:eitangocho/app/shells/sidebar_shell.dart';
import 'package:eitangocho/app/shells/tab_bar_shell.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
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
    // 同期 Notifier をここで生成しておく。設定画面でしか watch していないと、
    // 設定を開くまで起動時同期が走らない(Provider が遅延生成されるため)。
    ref.watch(syncProvider);
    // クイズの開始(QuizPageNotifier.startQuiz)は学習済み一覧を ref.read で読む。
    // riverpod 3 はリスナーの無い Provider を一時停止し、その間の DB 更新
    // (drift の watch)を反映しないため、iOS のクイズ・設定タブのように誰も
    // 購読していない画面から読むと古い一覧になる(「忘れていた」単語が「続ける」で
    // また出る、答えた単語の日時が古いまま同じ単語が選ばれる)。常に購読しておく。
    // watch ではなく listen にするのは、単語の更新のたびにシェルを作り直さないため。
    ref.listen(learnedWordsProvider, (_, _) {});

    return AppPlatform.isMacOS ? const SidebarShell() : const TabBarShell();
  }
}
