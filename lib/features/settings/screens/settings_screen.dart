import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/widgets/about_app_card.dart';
import 'package:odomex/features/settings/widgets/appearance_setting_tile.dart';
import 'package:odomex/features/settings/widgets/auto_fill_odometer_setting_tile.dart';
import 'package:odomex/features/settings/widgets/developer_badge.dart';
import 'package:odomex/features/settings/widgets/notification_master_tile.dart';
import 'package:odomex/features/settings/widgets/notification_reminders_card.dart';
import 'package:odomex/features/settings/widgets/notification_test_card.dart';
import 'package:odomex/features/settings/widgets/privacy_setting_tile.dart';
import 'package:odomex/features/settings/widgets/send_review_tile.dart';
import 'package:odomex/features/settings/widgets/settings_section_title.dart';
import 'package:odomex/features/settings/widgets/vehicle_defaults_setting_tile.dart';
import 'package:odomex/features/settings/widgets/vehicle_sort_setting_tile.dart';
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

            SizedBox(height: AppSizes.spacingXl),

            // ── 3. Feedback ───────────────────────────
            SettingsSectionTitle(title: 'FEEDBACK'),
            SendReviewTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 4. Privacy & Data ─────────────────────
            SettingsSectionTitle(title: 'PRIVACY'),
            PrivacySettingTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 5. Appearance Preference ───────────────
            SettingsSectionTitle(title: 'APPEARANCE'),
            AppearanceSettingTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 4. Notifications ───────────────────────
            SettingsSectionTitle(title: 'NOTIFICATIONS'),
            NotificationMasterTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 5. Reminder Preferences ───────────────
            SettingsSectionTitle(title: 'REMINDERS'),
            NotificationRemindersCard(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 6. Testing ────────────────────────────
            SettingsSectionTitle(title: 'TESTING'),
            NotificationTestCard(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 7. Record Defaults ────────────────────
            SettingsSectionTitle(title: 'RECORD DEFAULTS'),
            AutoFillOdometerSettingTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 8. Vehicle Defaults ───────────────────
            SettingsSectionTitle(title: 'VEHICLE DEFAULTS'),
            VehicleDefaultsSettingTile(),

            SizedBox(height: AppSizes.spacingXl),

            // ── 9. Vehicle List Preferences ───────────
            SettingsSectionTitle(title: 'VEHICLE LIST'),
            VehicleSortSettingTile(),
          ],
        ),
      ),
    );
  }
}
