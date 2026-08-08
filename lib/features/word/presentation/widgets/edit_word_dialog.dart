import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/components/pos_chip_selector.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word/presentation/widgets/delete_confirm_dialog.dart';
import 'package:eitangocho/providers/database_provider.dart';
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
  late final _japaneseController = TextEditingController(
    text: widget.word.japanese,
  );
  late final _exampleEnController = TextEditingController(
    text: widget.word.exampleEn,
  );
  late final _exampleJaController = TextEditingController(
    text: widget.word.exampleJa,
  );
  late Set<PartOfSpeech> _selectedPartsOfSpeech = widget.word.partsOfSpeech
      .toSet();
  String? _errorMessage;

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
    final word = _wordController.text.trim();
    final japanese = _japaneseController.text.trim();
    if (word.isEmpty || japanese.isEmpty) {
      setState(() => _errorMessage = '英単語と日本語訳は必須です。');
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
        setState(() => _errorMessage = '「${duplicate.word}」は既に登録されています。');
      }
      return;
    }

    await widget.ref.read(databaseProvider).wordDao.updateWord(
      widget.word.id,
      WordsCompanion(
        word: Value(word),
        ipa: Value(_ipaController.text.trim()),
        japanese: Value(japanese),
        // 編集前の並びを保ち、足した品詞だけ規定順で後ろに置く
        // (タップ順で保存すると、付け外しだけでバッジ色が変わる)。
        partsOfSpeech: Value(
          _selectedPartsOfSpeech.ordered(basedOn: widget.word.partsOfSpeech),
        ),
        exampleEn: Value(_exampleEnController.text.trim()),
        exampleJa: Value(_exampleJaController.text.trim()),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: SizedBox(
            width: AppDimensions.formWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '単語を編集',
                  style: TextStyle(
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
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '日本語訳 *',
                  controller: _japaneseController,
                ),
                const SizedBox(height: 16),
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
                      selected: _selectedPartsOfSpeech,
                      onToggle: (pos) => setState(() {
                        _selectedPartsOfSpeech = _selectedPartsOfSpeech
                                .contains(pos)
                            ? (Set<PartOfSpeech>.from(_selectedPartsOfSpeech)
                                ..remove(pos))
                            : (Set<PartOfSpeech>.from(_selectedPartsOfSpeech)
                                ..add(pos));
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '英例文',
                  controller: _exampleEnController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '日本語例文',
                  controller: _exampleJaController,
                  maxLines: 2,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppFilledButton(label: '保存', onPressed: _save),
                    const SizedBox(width: 10),
                    AppOutlinedButton(
                      label: 'キャンセル',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    AppOutlinedButton(
                      label: '削除...',
                      textColor: AppColors.danger,
                      hoverBackground: AppColors.dangerHoverBackground,
                      onPressed: _delete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
