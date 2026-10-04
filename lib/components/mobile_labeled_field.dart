import 'package:eitangocho/components/mobile_field_label.dart';
import 'package:eitangocho/components/mobile_well.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版のラベル付き入力欄。
///
/// [autoFilled] が true のときはラベル脇に「自動入力」バッジを出す
/// (単語登録で辞書から埋まった項目を示す。[MobileFieldLabel] 参照)。
///
/// [maxLines] に null を渡すと内容量に応じて欄が伸びる([minLines] が下限)。
class MobileLabeledField extends StatelessWidget {
  const MobileLabeledField({
    required this.label,
    required this.controller,
    super.key,
    this.hintText,
    this.minLines,
    this.maxLines = 1,
    this.autoFilled = false,
    this.asciiOnly = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;

  /// 空欄のときのヒント。省略時は「手動で入力してください」(manualInputHint)。
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool autoFilled;

  /// 半角英字キーボードに固定するか(英単語の入力欄で使う)。
  final bool asciiOnly;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileFieldLabel(label: label, autoFilled: autoFilled),
        const SizedBox(height: 5),
        // 枠線は引かず、内側の影で沈めた面に置く(立体案)。
        MobileWell(
          color: palette.wellBackground,
          shadows: palette.wellShadow,
          borderRadius: BorderRadius.circular(9),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            onSubmitted: onSubmitted,
            // 英単語欄で日本語 IME に切り替えられないようにする。
            // **visiblePassword でなければならない**: Flutter の iOS 実装
            // (ToUIKeyboardType)で UIKeyboardTypeASCIICapable にマップされるのは
            // これだけで、text は UIKeyboardTypeDefault(地球儀キーでかなに切替可)、
            // emailAddress / url は ASCII だが @ や .com キーが出る。
            // 入力内容を隠す指定ではない(obscureText は別)。
            keyboardType: asciiOnly ? TextInputType.visiblePassword : null,
            // 見出し語は入力どおりに保存されるため、勝手な補正・変換候補は出さない。
            autocorrect: !asciiOnly,
            enableSuggestions: !asciiOnly,
            cursorWidth: AppDimensions.mobileCursorWidth,
            cursorColor: palette.accent,
            // iOS で入力欄をタップしたときに拡大されないよう 16px 以上にする。
            style: TextStyle(fontSize: 16, color: palette.text),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText ?? context.l10n.manualInputHint,
              hintStyle: TextStyle(color: palette.textAlpha(30)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
