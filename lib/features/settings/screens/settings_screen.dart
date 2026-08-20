import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/widgets/about_app_card.dart';
import 'package:odomex/features/settings/widgets/developer_badge.dart';
import 'package:odomex/features/settings/widgets/settings_section_title.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Application settings and information screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenContainer(
      title: 'Settings',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: AppSizes.paddingXxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. About Odomex ───────────────────────
            SettingsSectionTitle(title: 'ABOUT'),
            AboutAppCard(),

            SizedBox(height: AppSizes.spacingMd),

            // ── 2. Subtle Developer Attribution ───────
            Center(
              child: DeveloperBadge(),
            ),
          ],
        ),
      ),
    );
  }
}
