import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/components/pronunciation_web_view.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// macOS 版の発音確認モーダル。Google 翻訳をアプリ内の WebView で開く。
///
/// iOS はボトムシート([showMobilePronunciationSheet])だが、macOS は他の
/// モーダル(単語編集・ライセンス)と同じダイアログに揃える。外部ブラウザに
/// 飛ばすと学習が途切れるため、確認はアプリ内で完結させる。
Future<void> showPronunciationDialog(BuildContext context, String word) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PronunciationDialog(word: word),
  );
}

class _PronunciationDialog extends StatelessWidget {
  const _PronunciationDialog({required this.word});

  final String word;

  /// ライセンスのモーダル(520)より広げる。Google 翻訳は 520 だと
  /// 入力欄と訳文が窮屈になる。
  static const _maxWidth = 640.0;

  /// ウィンドウ高に対する上限。WebView は自分から高さを主張しないため、
  /// ここで決めないとダイアログが潰れる。
  static const _heightFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * _heightFactor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(word: word),
            Expanded(child: PronunciationWebView(word: word)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppOutlinedButton(
            label: '閉じる',
            verticalPadding: 6,
            fontSize: 13,
            fontWeight: FontWeight.normal,
            borderRadius: 7,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
