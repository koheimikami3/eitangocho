import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ⌘F で検索フィールドにフォーカスを当てるために共有する FocusNode。
/// FocusNode は dispose が必要なため onDispose で解放する(手書き Provider)。
final toolbarSearchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'toolbarSearchField');
  ref.onDispose(node.dispose);
  return node;
});

/// ツールバーの検索フィールド。入力を MainPageNotifier に流す。
class ToolbarSearchField extends ConsumerWidget {
  const ToolbarSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: TextField(
        focusNode: ref.watch(toolbarSearchFocusProvider),
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
