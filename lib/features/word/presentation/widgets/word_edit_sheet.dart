import 'package:drift/drift.dart' show Value;
import 'package:eitangocho/components/mobile_field_label.dart';
import 'package:eitangocho/components/mobile_form_rows.dart';
import 'package:eitangocho/components/mobile_labeled_field.dart';
import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_pos_chip_selector.dart';
import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_sheet_banner_ad.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_delete_confirm_dialog.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:eitangocho/utils/headword.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の単語編集シート。
///
/// macOS 版の [showEditWordDialog] に対応する。削除はこのシート最下部の
/// 「この単語を削除...」からのみ到達する(iOS には右クリックが無く、
/// デザイン上も長押しメニューを持たないため、ここが唯一の削除導線)。
Future<void> showWordEditSheet(BuildContext context, WidgetRef ref, Word word) {
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
  /// シートは呼び出し元の ref を借りているため watch せず read で引く
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
    final l10n = context.l10n;
    final languageLabel = _languageLabel(context);

    return MobileSheet(
      title: l10n.editWordTitle,
      // デザインにあるのは登録シートだけだが、作りが同じでユーザー判断により
      // こちらにも出す(開く頻度はこちらの方が高い)。
      footer: const MobileSheetBannerAd(),
      leftLabel: l10n.cancel,
      onLeft: () => Navigator.of(context).pop(),
      rightLabel: l10n.save,
      onRight: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileFormRows(
            children: [
              MobileLabeledField(
                label: l10n.fieldWord,
                controller: _wordController,
                asciiOnly: true,
              ),
              // IPA は非 ASCII なので asciiOnly を付けない。
              MobileLabeledField(
                label: l10n.fieldIpa,
                controller: _ipaController,
              ),
              MobileLabeledField(
                label: l10n.fieldMeaning(languageLabel),
                controller: _meaningController,
                maxLines: null,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MobileFieldLabel(label: l10n.fieldPartsOfSpeech),
                  const SizedBox(height: 7),
                  MobilePosChipSelector(
                    selected: _selectedPartsOfSpeech,
                    onToggle: _togglePartOfSpeech,
                  ),
                ],
              ),
              MobileLabeledField(
                label: l10n.fieldExampleEn,
                controller: _exampleEnController,
                minLines: 2,
                maxLines: null,
              ),
              MobileLabeledField(
                label: l10n.fieldExampleTranslation(languageLabel),
                controller: _exampleTranslationController,
                minLines: 2,
                maxLines: null,
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 12, color: palette.danger),
            ),
          ],
          const SizedBox(height: 24),
          MobilePressable(
            onTap: _delete,
            builder: (context, pressed) => Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: pressed ? palette.dangerSoft : palette.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: palette.dangerLine),
              ),
              child: Text(
                l10n.deleteThisWord,
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
