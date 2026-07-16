import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/components/pos_chip_selector.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語の手動登録フォーム(プロトタイプの「ステップ 2」相当)。
class WordRegistrationView extends ConsumerStatefulWidget {
  const WordRegistrationView({super.key});

  @override
  ConsumerState<WordRegistrationView> createState() =>
      _WordRegistrationViewState();
}

class _WordRegistrationViewState extends ConsumerState<WordRegistrationView> {
  final _wordController = TextEditingController();
  final _ipaController = TextEditingController();
  final _japaneseController = TextEditingController();
  final _exampleEnController = TextEditingController();
  final _exampleJaController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    _ipaController.dispose();
    _japaneseController.dispose();
    _exampleEnController.dispose();
    _exampleJaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref.read(wordRegistrationProvider.notifier).save(
      word: _wordController.text,
      ipa: _ipaController.text,
      japanese: _japaneseController.text,
      exampleEn: _exampleEnController.text,
      exampleJa: _exampleJaController.text,
    );
    if (saved && mounted) {
      ref.read(mainPageProvider.notifier).selectView(MainView.learning);
    }
  }

  void _cancel() {
    ref.read(mainPageProvider.notifier).selectView(MainView.allWords);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordRegistrationProvider);

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: SizedBox(
          width: AppDimensions.formWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledTextField(
                      label: '英単語 *',
                      controller: _wordController,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LabeledTextField(
                      label: '発音記号 (IPA)',
                      controller: _ipaController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LabeledTextField(
                label: '日本語訳 *',
                controller: _japaneseController,
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '品詞(複数選択可)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  PosChipSelector(
                    selected: state.selectedPartsOfSpeech,
                    onToggle: (pos) => ref
                        .read(wordRegistrationProvider.notifier)
                        .togglePartOfSpeech(pos),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LabeledTextField(
                label: '英例文',
                controller: _exampleEnController,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              LabeledTextField(
                label: '日本語例文',
                controller: _exampleJaController,
                maxLines: 2,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  AppFilledButton(label: '登録する', onPressed: _save),
                  const SizedBox(width: 10),
                  _CancelTextButton(onTap: _cancel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelTextButton extends StatefulWidget {
  const _CancelTextButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CancelTextButton> createState() => _CancelTextButtonState();
}

class _CancelTextButtonState extends State<_CancelTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          child: Text(
            'キャンセル',
            style: TextStyle(
              fontSize: 14,
              color: _isHovered
                  ? AppColors.textPrimary
                  : const Color(0x80000000),
            ),
          ),
        ),
      ),
    );
  }
}
