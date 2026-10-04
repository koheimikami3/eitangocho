import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/components/pos_chip_selector.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/presentation/registration_messages.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/auto_fill_badge.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/dictionary_warning_banner.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/registration_input_step.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/registration_loading_step.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語登録の 2 ステップフロー(単語入力 → 自動入力 → 確認フォーム)。
class WordRegistrationView extends ConsumerStatefulWidget {
  const WordRegistrationView({super.key});

  @override
  ConsumerState<WordRegistrationView> createState() =>
      _WordRegistrationViewState();
}

class _WordRegistrationViewState extends ConsumerState<WordRegistrationView> {
  final _wordController = TextEditingController();
  final _ipaController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleEnController = TextEditingController();
  final _exampleTranslationController = TextEditingController();

  // 「自動入力」バッジの表示フラグ。プレフィル時に立て、ユーザーが
  // その項目を空にしたら消す(プロトタイプ準拠)。View の揮発状態でよい。
  var _autoIpa = false;
  var _autoMeaning = false;
  var _autoPos = false;
  var _autoExampleEn = false;
  var _autoExampleTranslation = false;

  @override
  void initState() {
    super.initState();
    _ipaController.addListener(
      () => _clearBadgeIfEmpty(
        _ipaController,
        () => _autoIpa,
        (v) => _autoIpa = v,
      ),
    );
    _meaningController.addListener(
      () => _clearBadgeIfEmpty(
        _meaningController,
        () => _autoMeaning,
        (v) => _autoMeaning = v,
      ),
    );
    _exampleEnController.addListener(
      () => _clearBadgeIfEmpty(
        _exampleEnController,
        () => _autoExampleEn,
        (v) => _autoExampleEn = v,
      ),
    );
    _exampleTranslationController.addListener(
      () => _clearBadgeIfEmpty(
        _exampleTranslationController,
        () => _autoExampleTranslation,
        (v) => _autoExampleTranslation = v,
      ),
    );
  }

  void _clearBadgeIfEmpty(
    TextEditingController controller,
    bool Function() getFlag,
    void Function(bool) setFlag,
  ) {
    if (getFlag() && controller.text.isEmpty) {
      setState(() => setFlag(false));
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _ipaController.dispose();
    _meaningController.dispose();
    _exampleEnController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  /// form 遷移時に取得結果を controller へ反映する(英単語はステップ 1 と
  /// 同じ controller を共有しているため、未収録・スキップ時もそのまま残る)。
  void _applyPrefill(WordInfo info) {
    setState(() {
      _wordController.text = info.word;
      _ipaController.text = info.ipa;
      _meaningController.text = info.meaning;
      _exampleEnController.text = info.exampleEn;
      _exampleTranslationController.text = info.exampleTranslation;
      _autoIpa = info.ipa.isNotEmpty;
      _autoMeaning = info.meaning.isNotEmpty;
      _autoPos = info.partsOfSpeech.isNotEmpty;
      _autoExampleEn = info.exampleEn.isNotEmpty;
      _autoExampleTranslation = info.exampleTranslation.isNotEmpty;
    });
  }

  /// ステップ 1 に戻ったとき、破棄された取得結果に対応する入力とバッジを消す。
  void _resetFormFields() {
    setState(() {
      _ipaController.clear();
      _meaningController.clear();
      _exampleEnController.clear();
      _exampleTranslationController.clear();
      _autoIpa = false;
      _autoMeaning = false;
      _autoPos = false;
      _autoExampleEn = false;
      _autoExampleTranslation = false;
    });
  }

  Future<void> _save() async {
    final saved = await ref
        .read(wordRegistrationProvider.notifier)
        .save(
          word: _wordController.text,
          ipa: _ipaController.text,
          meaning: _meaningController.text,
          exampleEn: _exampleEnController.text,
          exampleTranslation: _exampleTranslationController.text,
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
    ref.listen(wordRegistrationProvider, (previous, next) {
      if (previous?.step == next.step) return;
      if (next.step == RegistrationStep.form) {
        final fetched = next.fetched;
        if (fetched != null) {
          _applyPrefill(fetched);
        } else {
          _resetFormFields();
        }
      } else if (next.step == RegistrationStep.input) {
        _resetFormFields();
      }
    });
    final state = ref.watch(wordRegistrationProvider);
    final language = ref.watch(translationLanguageProvider);
    final error = state.error;
    final errorMessage = error == null
        ? null
        : registrationErrorText(context.l10n, error, language);

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: SizedBox(
          width: AppDimensions.formWidth,
          child: switch (state.step) {
            RegistrationStep.input => RegistrationInputStep(
              wordController: _wordController,
              errorMessage: errorMessage,
              onAutoFill: () => ref
                  .read(wordRegistrationProvider.notifier)
                  .autoFill(_wordController.text),
              onSkip: () =>
                  ref.read(wordRegistrationProvider.notifier).skipToManual(),
            ),
            RegistrationStep.loading => const RegistrationLoadingStep(),
            RegistrationStep.form => _buildForm(state, language, errorMessage),
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    WordRegistrationState state,
    TranslationLanguage language,
    String? errorMessage,
  ) {
    final l10n = context.l10n;
    final notice = state.notice;
    final languageLabel = language.shortLabel(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notice != null) ...[
          DictionaryWarningBanner(
            message: registrationNoticeText(l10n, notice, language),
          ),
          const SizedBox(height: 16),
        ],
        if (state.translationFailed) ...[
          Text(
            l10n.exampleTranslationFailedShort,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.warningBannerForeground,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledTextField(
                label: l10n.fieldWord,
                controller: _wordController,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LabeledTextField(
                label: l10n.fieldIpa,
                controller: _ipaController,
                trailing: _autoIpa ? const AutoFillBadge() : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: l10n.fieldMeaning(languageLabel),
          controller: _meaningController,
          maxLines: null,
          trailing: _autoMeaning ? const AutoFillBadge() : null,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.fieldPartsOfSpeech,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                // 品詞は「空にしたら消す」= 選択が 0 件になったらバッジを消す
                if (_autoPos && state.selectedPartsOfSpeech.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  const AutoFillBadge(),
                ],
              ],
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
        const SizedBox(height: 16),
        LabeledTextField(
          label: l10n.fieldExampleEn,
          controller: _exampleEnController,
          minLines: 2,
          maxLines: null,
          trailing: _autoExampleEn ? const AutoFillBadge() : null,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: l10n.fieldExampleTranslation(languageLabel),
          controller: _exampleTranslationController,
          minLines: 2,
          maxLines: null,
          trailing: _autoExampleTranslation ? const AutoFillBadge() : null,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            AppFilledButton(label: l10n.registerButton, onPressed: _save),
            const SizedBox(width: 10),
            AppOutlinedButton(
              label: l10n.back,
              onPressed: () =>
                  ref.read(wordRegistrationProvider.notifier).backToInput(),
            ),
            const SizedBox(width: 12),
            _TextActionButton(label: l10n.cancel, onTap: _cancel),
          ],
        ),
      ],
    );
  }
}

/// 「戻る」「キャンセル」用のテキストボタン(hover で濃色)。
class _TextActionButton extends StatefulWidget {
  const _TextActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TextActionButton> createState() => _TextActionButtonState();
}

class _TextActionButtonState extends State<_TextActionButton> {
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
            widget.label,
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
