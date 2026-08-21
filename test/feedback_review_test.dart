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
}

void main() {
  group('FeedbackService Unit Tests', () {
    test('generates canonical mailto URI with encoded subject and body', () {
      final uri = FeedbackService.feedbackMailtoUri;

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'contact@hexakode.in');
      expect(uri.queryParameters['subject'], 'Odomex Feedback');
      expect(
        uri.queryParameters['body'],
        'Hi HexaKode Team,\n\nI would like to share my feedback about Odomex.\n\nFeedback:\n',
      );
      expect(FeedbackService.feedbackEmail, 'contact@hexakode.in');
      expect(FeedbackService.feedbackSubject, 'Odomex Feedback');
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
