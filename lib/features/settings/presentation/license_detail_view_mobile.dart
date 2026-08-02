import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/domain/license_item.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_push_header.dart';
import 'package:flutter/material.dart';

/// iOS 版のライセンス全文(ライセンス一覧からプッシュ遷移)。
class LicenseDetailViewMobile extends StatelessWidget {
  const LicenseDetailViewMobile({required this.item, super.key});

  final LicenseItem item;

  static Future<void> push(BuildContext context, LicenseItem item) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LicenseDetailViewMobile(item: item),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.mobileContentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MobilePushHeader(
                title: 'ライセンス',
                backLabel: 'ライセンス',
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    40 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < item.texts.length; i++) ...[
                      if (i > 0) ...[
                        const SizedBox(height: 20),
                        Divider(height: 1, color: palette.borderAlpha(10)),
                        const SizedBox(height: 20),
                      ],
                      SelectableText(
                        item.texts[i],
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.7,
                          color: palette.textAlpha(70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
