import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/services/feedback_service.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/settings/widgets/send_review_tile.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  @override
  bool getNotificationsEnabled() => false;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {}

  @override
  NotificationSettings getNotificationSettings() => const NotificationSettings();

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {}

  @override
  AppThemeMode getThemeMode() => AppThemeMode.system;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {}

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      const GlobalVehicleSettings();

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {}

  @override
  VehicleSortOption getVehicleSortOption() => VehicleSortOption.lastAccessed;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async {}

  @override
  bool isOnboardingCompleted() => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  String? getPrivacyPolicyAcceptedVersion() => '1.0';

  @override
  Future<void> savePrivacyPolicyAcceptedVersion(String version) async {}
}

void main() {
  group('FeedbackService Unit Tests', () {
    test('generates canonical mailto URI with RFC 6068 percent-encoding (no + signs)', () {
      final uri = FeedbackService.feedbackMailtoUri;

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'contact@hexakode.in');
      expect(FeedbackService.feedbackEmail, 'contact@hexakode.in');
      expect(FeedbackService.feedbackSubject, 'Odomex Feedback');

      final uriString = uri.toString();

      // Subject must be percent-encoded with %20, NEVER '+'
      expect(uriString, contains('subject=Odomex%20Feedback'));
      expect(uriString, isNot(contains('subject=Odomex+Feedback')));

      // Body must be percent-encoded with %20 and %0A, NEVER '+'
      expect(uriString, contains('Hi%20HexaKode%20Team%2C%0A%0AI%20would%20like%20to%20share%20my%20feedback%20about%20Odomex.%0A%0AFeedback%3A%0A'));
      expect(uriString, isNot(contains('Hi+HexaKode+Team')));
      expect(uriString, isNot(contains('+')));

      // Decoded query parameters must match exact expected text and line breaks
      expect(
        uri.queryParameters['subject'],
        'Odomex Feedback',
      );
      expect(
        uri.queryParameters['body'],
        'Hi HexaKode Team,\n\nI would like to share my feedback about Odomex.\n\nFeedback:\n',
      );
    });

    test('preserves user input with special characters (&, +, %, #, ?, /, :, ,, ., \', ", ₹)', () {
      const customSubject = 'Odomex Review & Feedback + Questions?';
      const customBody = '''
Hi HexaKode Team,

Great app! Cost was ₹1,250.50 for petrol/diesel & service #101.
Checked: 100% accurate, C++ / Dart logic? Yes!

Feedback:
''';

      final uri = FeedbackService.buildFeedbackUri(
        subject: customSubject,
        body: customBody,
      );

      final uriString = uri.toString();

      // Spaces must be encoded as %20
      expect(uriString, isNot(contains('Odomex+Review')));
      expect(uriString, isNot(contains('Hi+HexaKode')));

      // Raw + symbol in user text must be safely percent-encoded as %2B
      expect(uriString, contains('%2B'));

      // Ampersand in user text must be safely percent-encoded as %26
      expect(uriString, contains('%26'));

      // Rupee symbol ₹ must be safely percent-encoded
      expect(uriString, contains(Uri.encodeComponent('₹')));

      // Decoded parameters match exact raw strings
      expect(uri.queryParameters['subject'], customSubject);
      expect(uri.queryParameters['body'], customBody);
    });

    test('encodeQueryParameters formats query string properly with & delimiter', () {
      final encoded = FeedbackService.encodeQueryParameters({
        'subject': 'Test Subject',
        'body': 'Line 1\nLine 2',
      });

      expect(encoded, 'subject=Test%20Subject&body=Line%201%0ALine%202');
      expect(encoded.contains('+'), isFalse);
    });
  });

  group('SendReviewTile Widget Tests', () {
    testWidgets('renders title, subtitle, and icon properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SendReviewTile(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send a Review'), findsOneWidget);
      expect(find.text('Share your feedback about Odomex'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('renders in SettingsScreen under FEEDBACK section in light & dark themes', (tester) async {
      final fakeDataSource = FakeAppSettingsLocalDataSource();
      final repository = AppSettingsRepository(localDataSource: fakeDataSource);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FEEDBACK'), findsOneWidget);
      expect(find.byType(SendReviewTile), findsOneWidget);
      expect(find.text('Send a Review'), findsOneWidget);
    });
  });
}
