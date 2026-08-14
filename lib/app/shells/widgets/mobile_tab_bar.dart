import 'dart:ui';

import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の下タブバー(学習中 / 全単語 / クイズ / 設定)。
///
/// 単語登録はタブに置かない(ヘッダの「＋ 登録」から開く)。そのため
/// [MainView.registration] のときはどのタブも選択状態にならない。
///
/// 半透明 + ぼかしでコンテンツの上に重なる。コンテンツ側は下端が隠れないよう
/// [height] 分の余白を確保すること。
class MobileTabBar extends ConsumerWidget {
  const MobileTabBar({super.key});

  /// ホームインジケータ領域を除いた、タブバー本体の高さ。
  static const _contentHeight = 54.0;

  /// ホームインジケータが無い端末でも確保する下余白。
  static const _minBottomInset = 12.0;

  /// コンテンツ側が確保すべき下余白。
  static double heightOf(BuildContext context) =>
      _contentHeight +
      (MediaQuery.paddingOf(context).bottom).clamp(_minBottomInset, 40.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final view = ref.watch(mainPageProvider.select((s) => s.view));
    final bottomInset = (MediaQuery.paddingOf(
      context,
    ).bottom).clamp(_minBottomInset, 40.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset),
          decoration: BoxDecoration(
            color: palette.tabBar,
            border: Border(top: BorderSide(color: palette.borderAlpha(8))),
          ),
          child: Row(
            children: [
              _TabItem(
                // デザインは「カードが 2 枚重なった」線画。style(扇状に開いた
                // カード)より、同じ大きさのカードが 2 枚ずれて重なる
                // filter_none の方が近い。
                icon: Icons.filter_none,
                label: '学習中',
                selected: view == MainView.learning,
                onTap: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.learning),
              ),
              _TabItem(
                icon: Icons.format_list_bulleted,
                label: '全単語',
                selected: view == MainView.allWords,
                onTap: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.allWords),
              ),
              _TabItem(
                icon: Icons.bolt,
                label: 'クイズ',
                selected: view == MainView.quiz,
                // サイドバー版と同じく、遷移前に出題をシャッフルし直す。
                onTap: () {
                  ref.read(quizPageProvider.notifier).startQuiz();
                  ref.read(mainPageProvider.notifier).selectView(MainView.quiz);
                },
              ),
              _TabItem(
                icon: Icons.tune,
                label: '設定',
                selected: view == MainView.settings,
                onTap: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.accent : palette.textAlpha(40);

    return Expanded(
      child: GestureDetector(
        // 余白部分をタップしても反応するように、透明部分もヒット対象にする。
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
