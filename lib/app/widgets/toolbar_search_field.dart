import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ツールバーの検索フィールド。入力を MainPageNotifier に流す。
class ToolbarSearchField extends ConsumerWidget {
  const ToolbarSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: TextField(
        onChanged: (value) => ref
            .read(mainPageProvider.notifier)
            .updateSearchQuery(value),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: '検索',
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
