import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/translation_language_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ステップ 1: 英単語の入力(自動入力 or 手動入力へスキップ)。
class RegistrationInputStep extends ConsumerWidget {
  const RegistrationInputStep({
    required this.wordController,
    required this.onAutoFill,
    required this.onSkip,
    super.key,
    this.errorMessage,
  });

  final TextEditingController wordController;
  final VoidCallback onAutoFill;
  final VoidCallback onSkip;
  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registrationIntro(
            ref.watch(translationLanguageProvider).shortLabel(l10n),
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LabeledTextField(
                label: l10n.fieldWord,
                controller: wordController,
                hintText: 'apple',
                onSubmitted: (_) => onAutoFill(),
              ),
            ),
            const SizedBox(width: 10),
            AppFilledButton(label: l10n.autoFill, onPressed: onAutoFill),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 14),
        _SkipLink(onTap: onSkip),
      ],
    );
  }
}

/// 「スキップして手動で入力する」リンク。
///
/// hover では下線ではなく色を濃い青に変える(下線は 2.2.0 でやめた。
/// ユーザー判断)。
class _SkipLink extends StatefulWidget {
  const _SkipLink({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<_SkipLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          context.l10n.skipToManual,
          style: TextStyle(
            fontSize: 13,
            color: _isHovered ? AppColors.accentOnSoft : AppColors.accent,
          ),
        ),
      ),
    );
  }
}
