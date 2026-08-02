import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 設定カード内のリンク行(ラベル + 右端のシェブロン)。クリックで別画面を開く。
class SettingsLinkRow extends StatefulWidget {
  const SettingsLinkRow({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<SettingsLinkRow> createState() => _SettingsLinkRowState();
}

class _SettingsLinkRowState extends State<SettingsLinkRow> {
  bool _hovered = false;

  /// ホバー背景(プロトタイプの #f7f7f8)。
  static const _hoverBackground = AppColors.inputBackground;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          color: _hovered ? _hoverBackground : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Text(
                '›',
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
