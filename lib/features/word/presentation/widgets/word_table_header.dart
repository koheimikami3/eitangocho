import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全単語テーブルのヘッダ行。カラム幅は word_table_row.dart と揃える。
class WordTableHeader extends ConsumerWidget {
  const WordTableHeader({super.key});

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.textTertiary,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final languageLabel = ref
        .watch(translationLanguageProvider)
        .shortLabel(l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.tableHeaderBackground,
        border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(l10n.tableLearned, style: _headerStyle),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(l10n.tableWord, style: _headerStyle),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 130, child: Text(l10n.tableIpa, style: _headerStyle)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(l10n.tablePartOfSpeech, style: _headerStyle),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(l10n.tableMeaning(languageLabel), style: _headerStyle),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(l10n.tableExample, style: _headerStyle),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(l10n.tablePronunciation, style: _headerStyle),
          ),
        ],
      ),
    );
  }
}
