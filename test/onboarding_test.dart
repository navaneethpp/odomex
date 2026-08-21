import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/onboarding/data/onboarding_story_pages.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/startup/app_startup_screen.dart';

class FakeOnboardingAppSettingsDataSource implements AppSettingsLocalDataSource {
  bool _onboardingCompleted = false;

  @override
  bool isOnboardingCompleted() => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
  }

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
  bool getNotificationsEnabled() => false;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {}
}

void main() {
  group('Onboarding Story Pages & Models Tests', () {
    test('contains exactly 5 story pages in the specified progression', () {
      expect(onboardingPages.length, 5);
      expect(onboardingPages[0].title, 'Meet your vehicle.');
      expect(onboardingPages[1].title, 'Every journey adds a story.');
      expect(onboardingPages[2].title, "But it's easy to forget.");
      expect(onboardingPages[3].title, 'Odomex keeps it all together.');
      expect(onboardingPages[4].title, contains('Your vehicle'));
      expect(onboardingPages[4].primaryButtonText, 'Get Started');
    });
  });

  group('AppStartupScreen Dispatcher Tests', () {
    testWidgets('renders OnboardingScreen when onboarding is not completed',
        (tester) async {
      final fakeSettings = FakeOnboardingAppSettingsDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
          ],
          child: const MaterialApp(
            home: AppStartupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Meet your vehicle.'), findsOneWidget);
    });
  });

  group('OnboardingScreen Flow Widget Tests', () {
    testWidgets(
        'steps through all 5 story pages and finishes with Get Started',
        (tester) async {
      final fakeSettings = FakeOnboardingAppSettingsDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
          ],
          child: MaterialApp(
            initialRoute: AppRoutes.onboarding,
            routes: {
              AppRoutes.onboarding: (_) => const OnboardingScreen(),
              AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
              AppRoutes.addVehicle: (_) =>
                  const Scaffold(body: Text('Add Vehicle Screen')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Meet your vehicle.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next -> Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Every journey adds a story.'), findsOneWidget);

      // Tap Next -> Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text("But it's easy to forget."), findsOneWidget);

      // Tap Next -> Page 4
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Odomex keeps it all together.'), findsOneWidget);

      // Tap Next -> Page 5 (Final CTA)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Your vehicle.\nYour journey.\nYour records.'),
          findsOneWidget);
      expect(find.text('Skip'), findsNothing); // Skip hidden on final page
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started -> navigates to Add Vehicle & completes onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(fakeSettings.isOnboardingCompleted(), isTrue);
      expect(find.text('Add Vehicle Screen'), findsOneWidget);
    });

    testWidgets('tapping Skip completes onboarding and navigates to Home',
        (tester) async {
      final fakeSettings = FakeOnboardingAppSettingsDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
          ],
          child: MaterialApp(
            initialRoute: AppRoutes.onboarding,
            routes: {
              AppRoutes.onboarding: (_) => const OnboardingScreen(),
              AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meet your vehicle.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(fakeSettings.isOnboardingCompleted(), isTrue);
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
