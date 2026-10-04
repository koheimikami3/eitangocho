import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/utils/l10n_context.dart';
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
        onChanged: (value) =>
            ref.read(mainPageProvider.notifier).updateSearchQuery(value),
        // 既定のカーソルは行高いっぱい・太めで存在感が強いため、
        // 少し低く・細くする。
        cursorHeight: 15,
        cursorWidth: 1,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: context.l10n.search,
          // 他の入力欄(LabeledTextField)と同じく白地 + 枠線にする。
          // 以前は枠なしの塗り潰しだったが、ツールバーの地と色が近く
          // 欄の範囲が分からなかった。
          filled: true,
          fillColor: Colors.white,
          // 上下に余裕を持たせる(ツールバー高さ 52 に収まる範囲)。
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          // フォーカス時も枠色は変えず通常時と同じにする
          // (Material 既定の太い黒枠が出るのを防ぐ)。
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
        ),
      ),
    );
  }
}
