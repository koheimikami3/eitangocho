import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/components/mobile_well.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版ヘッダの検索フィールド。入力を MainPageNotifier に流す。
///
/// macOS 版の [ToolbarSearchField] と違い FocusNode は共有しない
/// (⌘F に相当する導線が無いため)。枠線は引かず、内側の影で沈めた面に置く。
class MobileSearchField extends ConsumerWidget {
  const MobileSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return MobileWell(
      color: palette.wellBackground,
      shadows: palette.wellShadow,
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        onChanged: ref.read(mainPageProvider.notifier).updateSearchQuery,
        cursorWidth: AppDimensions.mobileCursorWidth,
        cursorColor: palette.accent,
        style: TextStyle(fontSize: 15, color: palette.text),
        decoration: InputDecoration(
          isDense: true,
          hintText: '検索',
          hintStyle: TextStyle(color: palette.textAlpha(30)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
