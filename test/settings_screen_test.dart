import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/settings/widgets/about_app_card.dart';
import 'package:odomex/features/settings/widgets/appearance_setting_tile.dart';
import 'package:odomex/features/settings/widgets/developer_badge.dart';
import 'package:odomex/features/settings/widgets/notification_setting_tile.dart';
import 'package:odomex/features/settings/widgets/vehicle_defaults_setting_tile.dart';
import 'package:odomex/features/settings/widgets/vehicle_sort_setting_tile.dart';

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Odomex',
      packageName: 'com.hexakode.odomex',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('SettingsScreen Tests', () {
    testWidgets('renders About, DeveloperBadge, Appearance, Notifications, Vehicle Defaults, and Vehicle List sections',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('VEHICLE DEFAULTS'), findsOneWidget);
      expect(find.text('VEHICLE LIST'), findsOneWidget);
      expect(find.text('DEVELOPER'), findsNothing);
      expect(find.byType(AboutAppCard), findsOneWidget);
      expect(find.byType(DeveloperBadge), findsOneWidget);
      expect(find.byType(AppearanceSettingTile), findsOneWidget);
      expect(find.byType(NotificationSettingTile), findsOneWidget);
      expect(find.byType(VehicleDefaultsSettingTile), findsOneWidget);
      expect(find.byType(VehicleSortSettingTile), findsOneWidget);
    });

    testWidgets('AboutAppCard displays app name, tagline, description and version',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AboutAppCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Odomex'), findsOneWidget);
      expect(find.text('Your vehicle, your journey.'), findsOneWidget);
      expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
      expect(
        find.textContaining('Odomex helps you monitor your vehicle usage'),
        findsOneWidget,
      );
    });

    testWidgets('DeveloperBadge displays subtle attribution and HexaKode chip',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeveloperBadge(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Developed by'), findsOneWidget);
      expect(find.text('HexaKode'), findsOneWidget);
    });
  });
}
