import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 全単語テーブルのヘッダ行。カラム幅は word_table_row.dart と揃える。
class WordTableHeader extends StatelessWidget {
  const WordTableHeader({super.key});

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.textTertiary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.tableHeaderBackground,
        border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 64, child: Text('学習済み', style: _headerStyle)),
          SizedBox(width: 12),
          SizedBox(width: 140, child: Text('単語', style: _headerStyle)),
          SizedBox(width: 12),
          SizedBox(width: 130, child: Text('発音記号', style: _headerStyle)),
          SizedBox(width: 12),
          SizedBox(width: 100, child: Text('品詞', style: _headerStyle)),
          SizedBox(width: 12),
          Expanded(flex: 2, child: Text('日本語訳', style: _headerStyle)),
          SizedBox(width: 12),
          Expanded(flex: 3, child: Text('例文', style: _headerStyle)),
        ],
      ),
    );
  }
}
