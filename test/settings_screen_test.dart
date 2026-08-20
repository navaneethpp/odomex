import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/settings/widgets/about_app_card.dart';
import 'package:odomex/features/settings/widgets/developer_badge.dart';

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
    testWidgets('renders About section and subtle DeveloperBadge without separate section',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('DEVELOPER'), findsNothing); // No separate DEVELOPER header
      expect(find.byType(AboutAppCard), findsOneWidget);
      expect(find.byType(DeveloperBadge), findsOneWidget);
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
