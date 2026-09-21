import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のクイズ空状態(学習済みが 0 件のとき)。
class MobileQuizEmptyState extends ConsumerWidget {
  const MobileQuizEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '復習対象の単語がまだありません。\n単語を学習済みにするとここに表示されます。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.8,
            color: palette.textAlpha(45),
          ),
        ),
        const SizedBox(height: 16),
        MobileFilledButton(
          label: '学習中リストへ',
          onPressed: () =>
              ref.read(mainPageProvider.notifier).selectView(MainView.learning),
          fontSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          borderRadius: 11,
        ),
      ],
    );
  }
}
