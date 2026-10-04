import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DeepL API キーの入力欄。変更は即保存する(他の設定項目と同じ方針)。
/// ローカルアプリとして平文保存を許容するため obscureText にはしない。
class DeeplApiKeyField extends ConsumerStatefulWidget {
  const DeeplApiKeyField({required this.initialValue, super.key});

  /// 設定ロード済みの現在値(controller の初期値にのみ使う)
  final String initialValue;

  @override
  ConsumerState<DeeplApiKeyField> createState() => _DeeplApiKeyFieldState();
}

class _DeeplApiKeyFieldState extends ConsumerState<DeeplApiKeyField> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) =>
              ref.read(settingsProvider.notifier).setDeeplApiKey(value),
          // 既定のカーソルは行高いっぱい・太めで存在感が強いため、
          // 少し低く・細くする。
          cursorHeight: 15,
          cursorWidth: 1,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: context.l10n.deeplKeyHint,
            // LabeledTextField と同様、ヒント色は明示的に薄くする
            hintStyle: const TextStyle(color: AppColors.textDisabled),
            // LabeledTextField と同様、地のグレーが透けないよう白で塗る。
            filled: true,
            fillColor: Colors.white,
            // 他の一行フィールドと同様に上下へ余裕を持たせる
            // (プロトタイプの 8px から拡張)。
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
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
        const SizedBox(height: 6),
        Text(
          context.l10n.deeplDescription(
            ref.watch(translationLanguageProvider).shortLabel(context.l10n),
          ),
          style: const TextStyle(
            fontSize: 11,
            height: 1.6,
            color: AppColors.textQuaternary,
          ),
        ),
      ],
    );
  }
}
