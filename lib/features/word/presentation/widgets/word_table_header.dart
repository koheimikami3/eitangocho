import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全単語テーブルのヘッダ行。カラム幅は word_table_row.dart と揃える。
class WordTableHeader extends ConsumerWidget {
  const WordTableHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final language = ref.watch(translationLanguageProvider);
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: colors.textTertiary,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors.tableHeaderBackground,
        border: Border(bottom: BorderSide(color: colors.borderStrong)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(l10n.tableLearned, style: headerStyle),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 140, child: Text(l10n.tableWord, style: headerStyle)),
          const SizedBox(width: 12),
          SizedBox(width: 130, child: Text(l10n.tableIpa, style: headerStyle)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(l10n.tablePartOfSpeech, style: headerStyle),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(language.meaningColumnLabel(l10n), style: headerStyle),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text(l10n.tableExample, style: headerStyle)),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(l10n.tablePronunciation, style: headerStyle),
          ),
        ],
      ),
    );
  }
}
