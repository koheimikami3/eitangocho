import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/components/pos_chip_selector.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/delete_confirm_dialog.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:eitangocho/utils/headword.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語の編集モーダルを表示する。
Future<void> showEditWordDialog(
  BuildContext context,
  WidgetRef ref,
  Word word,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditWordDialog(word: word, ref: ref),
  );
}

class _EditWordDialog extends StatefulWidget {
  const _EditWordDialog({required this.word, required this.ref});

  final Word word;
  final WidgetRef ref;

  @override
  State<_EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<_EditWordDialog> {
  late final _wordController = TextEditingController(text: widget.word.word);
  late final _ipaController = TextEditingController(text: widget.word.ipa);
  late final _meaningController = TextEditingController(
    text: widget.word.meaning,
  );
  late final _exampleEnController = TextEditingController(
    text: widget.word.exampleEn,
  );
  late final _exampleTranslationController = TextEditingController(
    text: widget.word.exampleTranslation,
  );
  late Set<PartOfSpeech> _selectedPartsOfSpeech = widget.word.partsOfSpeech
      .toSet();
  String? _errorMessage;

  @override
  void dispose() {
    _wordController.dispose();
    _ipaController.dispose();
    _meaningController.dispose();
    _exampleEnController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  /// 訳の言語の短い名前(「日本語訳」の「日本語」)。
  ///
  /// ダイアログは呼び出し元の ref を借りているため watch せず read で引く
  /// (開いている間に訳の言語が変わることはない)。
  String _languageLabel(BuildContext context) =>
      widget.ref.read(translationLanguageProvider).shortLabel(context.l10n);

  Future<void> _save() async {
    final word = normalizeHeadword(_wordController.text);
    final meaning = _meaningController.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      setState(
        () => _errorMessage = context.l10n.errorRequiredFields(
          _languageLabel(context),
        ),
      );
      return;
    }
    // 単語名を既存の単語に書き換えられると重複ができるため、登録時と同じく止める
    // (自分自身は除外する)。
    final duplicate = await widget.ref
        .read(databaseProvider)
        .wordDao
        .findByWord(word, excludeId: widget.word.id);
    if (duplicate != null) {
      if (mounted) {
        setState(
          () => _errorMessage = context.l10n.errorDuplicate(duplicate.word),
        );
      }
      return;
    }

    await widget.ref
        .read(databaseProvider)
        .wordDao
        .updateWord(
          widget.word.id,
          WordsCompanion(
            word: Value(word),
            ipa: Value(_ipaController.text.trim()),
            meaning: Value(meaning),
            // 編集前の並びを保ち、足した品詞だけ規定順で後ろに置く
            // (タップ順で保存すると、付け外しだけでバッジ色が変わる)。
            partsOfSpeech: Value(
              _selectedPartsOfSpeech.ordered(
                basedOn: widget.word.partsOfSpeech,
              ),
            ),
            exampleEn: Value(_exampleEnController.text.trim()),
            exampleTranslation: Value(
              _exampleTranslationController.text.trim(),
            ),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final deleted = await showDeleteConfirmDialog(
      context,
      widget.ref,
      widget.word,
    );
    if (deleted && mounted) Navigator.of(context).pop();
  }

  static const _horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageLabel = _languageLabel(context);
    // 高さは固定の上限を持たず、ウィンドウに収まる範囲まで広げる(Dialog が
    // 画面の縁に余白を残して制約する)。それでも入り切らないときは入力欄だけを
    // スクロールさせ、保存・キャンセル・削除は常に下端に見えるようにする
    // (以前は上限 640 の中で全体をスクロールしており、ボタンが見切れていた)。
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: SizedBox(
        width: AppDimensions.formWidth + _horizontalPadding * 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  22,
                  _horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.editWordTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LabeledTextField(
                      label: l10n.fieldMeaning(languageLabel),
                      controller: _meaningController,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fieldPartsOfSpeech,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        PosChipSelector(
                          selected: _selectedPartsOfSpeech,
                          onToggle: (pos) => setState(() {
                            _selectedPartsOfSpeech =
                                _selectedPartsOfSpeech.contains(pos)
                                ? (Set<PartOfSpeech>.from(
                                    _selectedPartsOfSpeech,
                                  )..remove(pos))
                                : (Set<PartOfSpeech>.from(
                                    _selectedPartsOfSpeech,
                                  )..add(pos));
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LabeledTextField(
                      label: l10n.fieldExampleEn,
                      controller: _exampleEnController,
                      minLines: 2,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    LabeledTextField(
                      label: l10n.fieldExampleTranslation(languageLabel),
                      controller: _exampleTranslationController,
                      minLines: 2,
                      maxLines: null,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                16,
                _horizontalPadding,
                22,
              ),
              child: Row(
                children: [
                  AppFilledButton(label: l10n.save, onPressed: _save),
                  const SizedBox(width: 10),
                  AppOutlinedButton(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  AppOutlinedButton(
                    label: l10n.deleteEllipsis,
                    textColor: AppColors.danger,
                    hoverBackground: AppColors.dangerHoverBackground,
                    onPressed: _delete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
