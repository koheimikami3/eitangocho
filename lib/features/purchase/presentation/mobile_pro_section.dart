import 'package:eitangocho/features/purchase/presentation/widgets/mobile_pro_purchase_row.dart';
import 'package:eitangocho/features/purchase/presentation/widgets/mobile_pro_restore_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_section.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定画面「Pro」セクションの中身。
///
/// カード・区切り線は [MobileSettingsSection] が他のセクションと同じトークンで
/// 描くため、ここは行を 2 つ渡すだけでよい。
class MobileProSection extends StatelessWidget {
  const MobileProSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileSettingsSection(
      title: 'Pro',
      rows: [MobileProPurchaseRow(), MobileProRestoreRow()],
    );
  }
}
