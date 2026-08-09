import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/components/pos_chip_selector.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/auto_fill_badge.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/dictionary_warning_banner.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/registration_input_step.dart';
import 'package:eitangocho/features/word_registration/presentation/widgets/registration_loading_step.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
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
  final _japaneseController = TextEditingController();
  final _exampleEnController = TextEditingController();
  final _exampleJaController = TextEditingController();

  // 「自動入力」バッジの表示フラグ。プレフィル時に立て、ユーザーが
  // その項目を空にしたら消す(プロトタイプ準拠)。View の揮発状態でよい。
  var _autoIpa = false;
  var _autoJapanese = false;
  var _autoPos = false;
  var _autoExampleEn = false;
  var _autoExampleJa = false;

  @override
  void initState() {
    super.initState();
    _ipaController.addListener(() => _clearBadgeIfEmpty(
        _ipaController, () => _autoIpa, (v) => _autoIpa = v));
    _japaneseController.addListener(() => _clearBadgeIfEmpty(
        _japaneseController, () => _autoJapanese, (v) => _autoJapanese = v));
    _exampleEnController.addListener(() => _clearBadgeIfEmpty(
        _exampleEnController, () => _autoExampleEn, (v) => _autoExampleEn = v));
    _exampleJaController.addListener(() => _clearBadgeIfEmpty(
        _exampleJaController, () => _autoExampleJa, (v) => _autoExampleJa = v));
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
    _japaneseController.dispose();
    _exampleEnController.dispose();
    _exampleJaController.dispose();
    super.dispose();
  }

  /// form 遷移時に取得結果を controller へ反映する(英単語はステップ 1 と
  /// 同じ controller を共有しているため、未収録・スキップ時もそのまま残る)。
  void _applyPrefill(WordInfo info) {
    setState(() {
      _wordController.text = info.word;
      _ipaController.text = info.ipa;
      _japaneseController.text = info.japanese;
      _exampleEnController.text = info.exampleEn;
      _exampleJaController.text = info.exampleJa;
      _autoIpa = info.ipa.isNotEmpty;
      _autoJapanese = info.japanese.isNotEmpty;
      _autoPos = info.partsOfSpeech.isNotEmpty;
      _autoExampleEn = info.exampleEn.isNotEmpty;
      _autoExampleJa = info.exampleJa.isNotEmpty;
    });
  }

  /// ステップ 1 に戻ったとき、破棄された取得結果に対応する入力とバッジを消す。
  void _resetFormFields() {
    setState(() {
      _ipaController.clear();
      _japaneseController.clear();
      _exampleEnController.clear();
      _exampleJaController.clear();
      _autoIpa = false;
      _autoJapanese = false;
      _autoPos = false;
      _autoExampleEn = false;
      _autoExampleJa = false;
    });
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

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: SizedBox(
          width: AppDimensions.formWidth,
          child: switch (state.step) {
            RegistrationStep.input => RegistrationInputStep(
                wordController: _wordController,
                errorMessage: state.errorMessage,
                onAutoFill: () => ref
                    .read(wordRegistrationProvider.notifier)
                    .autoFill(_wordController.text),
                onSkip: () => ref
                    .read(wordRegistrationProvider.notifier)
                    .skipToManual(),
              ),
            RegistrationStep.loading => const RegistrationLoadingStep(),
            RegistrationStep.form => _buildForm(state),
          },
        ),
      ),
    );
  }

  Widget _buildForm(WordRegistrationState state) {
    final banner = _bannerMessage(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (banner != null) ...[
          DictionaryWarningBanner(message: banner),
          const SizedBox(height: 16),
        ],
        if (state.translationFailed) ...[
          const Text(
            '例文の翻訳に失敗しました(手動で入力できます)',
            style: TextStyle(
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
                label: '英単語 *',
                controller: _wordController,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LabeledTextField(
                label: '発音記号 (IPA)',
                controller: _ipaController,
                trailing: _autoIpa ? const AutoFillBadge() : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: '日本語訳 *',
          controller: _japaneseController,
          maxLines: null,
          trailing: _autoJapanese ? const AutoFillBadge() : null,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '品詞(複数選択可)',
                  style: TextStyle(
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
          label: '英例文',
          controller: _exampleEnController,
          minLines: 2,
          maxLines: null,
          trailing: _autoExampleEn ? const AutoFillBadge() : null,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: '日本語例文',
          controller: _exampleJaController,
          minLines: 2,
          maxLines: null,
          trailing: _autoExampleJa ? const AutoFillBadge() : null,
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            state.errorMessage!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.danger,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            AppFilledButton(label: '登録する', onPressed: _save),
            const SizedBox(width: 10),
            AppOutlinedButton(
              label: '戻る',
              onPressed: () =>
                  ref.read(wordRegistrationProvider.notifier).backToInput(),
            ),
            const SizedBox(width: 4),
            _TextActionButton(label: 'キャンセル', onTap: _cancel),
          ],
        ),
      ],
    );
  }

  /// フォーム上部の警告バナー文言。未収録(全項目手動)と
  /// EJDict のみヒット(訳のみ自動入力)で文言を変える。
  String? _bannerMessage(WordRegistrationState state) {
    if (state.notFound) {
      return '辞書に見つかりませんでした。手動で入力できます。';
    }
    final fetched = state.fetched;
    // audioUrl は画面に出さないので、文言どおり IPA と例文だけで判定する。
    if (fetched != null &&
        fetched.japanese.isNotEmpty &&
        fetched.ipa.isEmpty &&
        fetched.exampleEn.isEmpty) {
      return '発音記号・例文は辞書に見つかりませんでした(訳のみ自動入力)';
    }
    return null;
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
