import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の DeepL API キー入力欄。変更は即保存する。
///
/// macOS 版の [DeeplApiKeyField] と違い、説明文は呼び出し側(設定画面の
/// セクション)が持つ。ローカルアプリとして平文保存を許容するため
/// obscureText にはしない。
class MobileDeeplApiKeyField extends ConsumerStatefulWidget {
  const MobileDeeplApiKeyField({required this.initialValue, super.key});

  /// 設定ロード済みの現在値(controller の初期値にのみ使う)
  final String initialValue;

  @override
  ConsumerState<MobileDeeplApiKeyField> createState() =>
      _MobileDeeplApiKeyFieldState();
}

class _MobileDeeplApiKeyFieldState
    extends ConsumerState<MobileDeeplApiKeyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: palette.inputBorder),
    );

    return TextField(
      controller: _controller,
      onChanged: ref.read(settingsProvider.notifier).setDeeplApiKey,
      cursorWidth: AppDimensions.mobileCursorWidth,
      cursorColor: palette.accent,
      style: TextStyle(fontSize: 14, color: palette.text),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'DeepL API キーを入力',
        hintStyle: TextStyle(color: palette.textAlpha(30)),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
