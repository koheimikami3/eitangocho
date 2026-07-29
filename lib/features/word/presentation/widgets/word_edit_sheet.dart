import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/components/mobile_labeled_field.dart';
import 'package:eitangocho/components/mobile_pos_chip_selector.dart';
import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_delete_confirm_dialog.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の単語編集シート。
///
/// macOS 版の [showEditWordDialog] に対応する。削除はこのシート最下部の
/// 「この単語を削除...」からのみ到達する(iOS には右クリックが無く、
/// デザイン上も長押しメニューを持たないため、ここが唯一の削除導線)。
Future<void> showWordEditSheet(
  BuildContext context,
  WidgetRef ref,
  Word word,
) {
  return showMobileSheet<void>(
    context: context,
    builder: (context) => _WordEditSheet(word: word, ref: ref),
  );
}

class _WordEditSheet extends StatefulWidget {
  const _WordEditSheet({required this.word, required this.ref});

  final Word word;
  final WidgetRef ref;

  @override
  State<_WordEditSheet> createState() => _WordEditSheetState();
}

class _WordEditSheetState extends State<_WordEditSheet> {
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
  bool _hasError = false;

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
      setState(() => _hasError = true);
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
    final deleted = await showMobileDeleteConfirmDialog(
      context,
      widget.ref,
      widget.word,
    );
    if (deleted && mounted) Navigator.of(context).pop();
  }

  void _togglePartOfSpeech(PartOfSpeech pos) {
    setState(() {
      _selectedPartsOfSpeech = _selectedPartsOfSpeech.contains(pos)
          ? (Set<PartOfSpeech>.from(_selectedPartsOfSpeech)..remove(pos))
          : (Set<PartOfSpeech>.from(_selectedPartsOfSpeech)..add(pos));
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MobileSheet(
      title: '単語を編集',
      leftLabel: 'キャンセル',
      onLeft: () => Navigator.of(context).pop(),
      rightLabel: '保存',
      onRight: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileLabeledField(
            label: '英単語 *',
            controller: _wordController,
          ),
          const SizedBox(height: 14),
          MobileLabeledField(
            label: '発音記号 (IPA)',
            controller: _ipaController,
          ),
          const SizedBox(height: 14),
          MobileLabeledField(
            label: '日本語訳 *',
            controller: _japaneseController,
          ),
          const SizedBox(height: 14),
          Text(
            '品詞(複数選択可)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textAlpha(60),
            ),
          ),
          const SizedBox(height: 6),
          MobilePosChipSelector(
            selected: _selectedPartsOfSpeech,
            onToggle: _togglePartOfSpeech,
          ),
          const SizedBox(height: 14),
          MobileLabeledField(
            label: '英例文',
            controller: _exampleEnController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          MobileLabeledField(
            label: '日本語例文',
            controller: _exampleJaController,
            maxLines: 2,
          ),
          if (_hasError) ...[
            const SizedBox(height: 14),
            Text(
              '英単語と日本語訳は必須です。',
              style: TextStyle(fontSize: 12, color: palette.danger),
            ),
          ],
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _delete,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: palette.danger.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'この単語を削除',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
