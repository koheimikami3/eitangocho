import 'package:eitangocho/components/mobile_field_label.dart';
import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/components/mobile_form_rows.dart';
import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_labeled_field.dart';
import 'package:eitangocho/components/mobile_pos_chip_selector.dart';
import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_sheet_banner_ad.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の単語登録シート(単語入力 → 自動入力 → 確認フォームの 2 ステップ)。
///
/// macOS 版の [WordRegistrationView] と同じ [WordRegistrationNotifier] を使い、
/// 見た目とナビゲーション(ビュー切替ではなくシートの開閉)だけが異なる。
Future<void> showWordRegistrationSheet(BuildContext context) {
  return showMobileSheet<void>(
    context: context,
    builder: (context) => const _WordRegistrationSheet(),
  );
}

class _WordRegistrationSheet extends ConsumerStatefulWidget {
  const _WordRegistrationSheet();

  @override
  ConsumerState<_WordRegistrationSheet> createState() =>
      _WordRegistrationSheetState();
}

class _WordRegistrationSheetState
    extends ConsumerState<_WordRegistrationSheet> {
  final _wordController = TextEditingController();
  final _ipaController = TextEditingController();
  final _japaneseController = TextEditingController();
  final _exampleEnController = TextEditingController();
  final _exampleJaController = TextEditingController();

  // 「自動入力」バッジの表示フラグ。プレフィル時に立て、ユーザーが
  // その項目を空にしたら消す(macOS 版と同じ方針)。
  var _autoIpa = false;
  var _autoJapanese = false;
  var _autoPos = false;
  var _autoExampleEn = false;
  var _autoExampleJa = false;

  @override
  void initState() {
    super.initState();
    // 開くたびに前回の状態が残らないようステップを初期化する
    // (Notifier は keepAlive ではないが、同一セッション中の再オープンに備える)。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordRegistrationProvider.notifier).backToInput();
    });
    _ipaController.addListener(
      () => _clearBadgeIfEmpty(
        _ipaController,
        () => _autoIpa,
        (v) => _autoIpa = v,
      ),
    );
    _japaneseController.addListener(
      () => _clearBadgeIfEmpty(
        _japaneseController,
        () => _autoJapanese,
        (v) => _autoJapanese = v,
      ),
    );
    _exampleEnController.addListener(
      () => _clearBadgeIfEmpty(
        _exampleEnController,
        () => _autoExampleEn,
        (v) => _autoExampleEn = v,
      ),
    );
    _exampleJaController.addListener(
      () => _clearBadgeIfEmpty(
        _exampleJaController,
        () => _autoExampleJa,
        (v) => _autoExampleJa = v,
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
    final saved = await ref
        .read(wordRegistrationProvider.notifier)
        .save(
          word: _wordController.text,
          ipa: _ipaController.text,
          japanese: _japaneseController.text,
          exampleEn: _exampleEnController.text,
          exampleJa: _exampleJaController.text,
        );
    // macOS 版はビューを切り替えるが、iOS はシートを閉じるだけでよい
    // (背後の学習中リストは Stream で自動更新される)。
    if (saved && mounted) Navigator.of(context).pop();
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
    final notifier = ref.read(wordRegistrationProvider.notifier);
    final isForm = state.step == RegistrationStep.form;

    return MobileSheet(
      title: '単語を登録',
      footer: const MobileSheetBannerAd(),
      // フォームまで進んでいれば入力ステップへ戻す、そうでなければ閉じる。
      leftLabel: isForm ? '戻る' : 'キャンセル',
      onLeft: isForm ? notifier.backToInput : () => Navigator.of(context).pop(),
      rightLabel: isForm ? '登録' : null,
      onRight: isForm ? _save : null,
      child: switch (state.step) {
        RegistrationStep.input => _InputStep(
          controller: _wordController,
          errorMessage: state.errorMessage,
          onAutoFill: () => notifier.autoFill(_wordController.text),
          onSkip: notifier.skipToManual,
        ),
        RegistrationStep.loading => const _LoadingStep(),
        RegistrationStep.form => _FormStep(
          warningMessage: state.warningMessage,
          translationFailed: state.translationFailed,
          errorMessage: state.errorMessage,
          wordController: _wordController,
          ipaController: _ipaController,
          japaneseController: _japaneseController,
          exampleEnController: _exampleEnController,
          exampleJaController: _exampleJaController,
          autoIpa: _autoIpa,
          autoJapanese: _autoJapanese,
          autoPos: _autoPos,
          autoExampleEn: _autoExampleEn,
          autoExampleJa: _autoExampleJa,
          selectedPartsOfSpeech: state.selectedPartsOfSpeech,
          onTogglePartOfSpeech: notifier.togglePartOfSpeech,
        ),
      },
    );
  }
}

class _InputStep extends StatelessWidget {
  const _InputStep({
    required this.controller,
    required this.errorMessage,
    required this.onAutoFill,
    required this.onSkip,
  });

  final TextEditingController controller;
  final String? errorMessage;
  final VoidCallback onAutoFill;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '英単語を入力すると、発音記号・日本語訳・例文などを辞書から自動取得します。',
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            color: palette.textAlpha(50),
          ),
        ),
        const SizedBox(height: 12),
        MobileLabeledField(
          label: '英単語 *',
          controller: controller,
          hintText: 'apple',
          asciiOnly: true,
          onSubmitted: (_) => onAutoFill(),
        ),
        const SizedBox(height: 12),
        MobileFilledButton(
          label: '自動入力',
          onPressed: onAutoFill,
          padding: const EdgeInsets.all(13),
          borderRadius: 11,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 12, color: palette.danger),
          ),
        ],
        const SizedBox(height: 14),
        MobilePressable(
          onTap: onSkip,
          style: MobilePressStyle.text,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'スキップして手動で入力する',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: palette.accentOnSoft),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: palette.accent,
              backgroundColor: palette.borderAlpha(10),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '辞書データを取得中...',
            style: TextStyle(fontSize: 13, color: palette.textAlpha(50)),
          ),
        ],
      ),
    );
  }
}

class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.warningMessage,
    required this.translationFailed,
    required this.errorMessage,
    required this.wordController,
    required this.ipaController,
    required this.japaneseController,
    required this.exampleEnController,
    required this.exampleJaController,
    required this.autoIpa,
    required this.autoJapanese,
    required this.autoPos,
    required this.autoExampleEn,
    required this.autoExampleJa,
    required this.selectedPartsOfSpeech,
    required this.onTogglePartOfSpeech,
  });

  final String? warningMessage;
  final bool translationFailed;
  final String? errorMessage;
  final TextEditingController wordController;
  final TextEditingController ipaController;
  final TextEditingController japaneseController;
  final TextEditingController exampleEnController;
  final TextEditingController exampleJaController;
  final bool autoIpa;
  final bool autoJapanese;
  final bool autoPos;
  final bool autoExampleEn;
  final bool autoExampleJa;
  final Set<PartOfSpeech> selectedPartsOfSpeech;
  final ValueChanged<PartOfSpeech> onTogglePartOfSpeech;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (warningMessage != null) ...[
          _WarningBanner(message: warningMessage!),
          const SizedBox(height: 14),
        ],
        if (translationFailed) ...[
          _WarningBanner(message: '例文の日本語訳を取得できませんでした。手動で入力できます。'),
          const SizedBox(height: 14),
        ],
        MobileFormRows(
          children: [
            MobileLabeledField(
              label: '英単語 *',
              controller: wordController,
              asciiOnly: true,
            ),
            // IPA は非 ASCII なので asciiOnly を付けない。
            MobileLabeledField(
              label: '発音記号 (IPA)',
              controller: ipaController,
              autoFilled: autoIpa,
            ),
            MobileLabeledField(
              label: '日本語訳 *',
              controller: japaneseController,
              maxLines: null,
              autoFilled: autoJapanese,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileFieldLabel(label: '品詞(複数選択可)', autoFilled: autoPos),
                const SizedBox(height: 7),
                MobilePosChipSelector(
                  selected: selectedPartsOfSpeech,
                  onToggle: onTogglePartOfSpeech,
                ),
              ],
            ),
            MobileLabeledField(
              label: '英例文',
              controller: exampleEnController,
              minLines: 2,
              maxLines: null,
              autoFilled: autoExampleEn,
            ),
            MobileLabeledField(
              label: '日本語例文',
              controller: exampleJaController,
              minLines: 2,
              maxLines: null,
              autoFilled: autoExampleJa,
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 12, color: palette.danger),
          ),
        ],
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: palette.warningBannerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.warningBannerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828), // rgba(16,24,40,0.06)
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: palette.warningBannerForeground,
        ),
      ),
    );
  }
}
