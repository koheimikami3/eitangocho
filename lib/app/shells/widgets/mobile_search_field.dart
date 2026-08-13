import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版ヘッダの検索フィールド。入力を MainPageNotifier に流す。
///
/// macOS 版の [ToolbarSearchField] と違い FocusNode は共有しない
/// (⌘F に相当する導線が無いため)。
class MobileSearchField extends ConsumerWidget {
  const MobileSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: palette.borderAlpha(12)),
    );

    return TextField(
      onChanged: ref.read(mainPageProvider.notifier).updateSearchQuery,
      cursorWidth: AppDimensions.mobileCursorWidth,
      cursorColor: palette.accent,
      style: TextStyle(fontSize: 15, color: palette.text),
      decoration: InputDecoration(
        isDense: true,
        hintText: '検索',
        hintStyle: TextStyle(color: palette.textAlpha(30)),
        filled: true,
        fillColor: palette.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
