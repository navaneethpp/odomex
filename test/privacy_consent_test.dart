import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:odomex/core/constants/app_constants.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/features/privacy/screens/privacy_consent_screen.dart';
import 'package:odomex/features/privacy/widgets/privacy_policy_content.dart';
import 'package:odomex/features/privacy/widgets/privacy_policy_dialog.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/settings/widgets/privacy_setting_tile.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';
import 'package:odomex/repositories/vehicles_repository.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/startup/app_startup_screen.dart';

class FakePrivacyAppSettingsDataSource
    implements AppSettingsLocalDataSource {
  bool _onboardingCompleted = false;
  String? _privacyPolicyAcceptedVersion;
  AppThemeMode _themeMode = AppThemeMode.system;
  NotificationSettings _notificationSettings =
      const NotificationSettings();
  VehicleSortOption _sortOption =
      VehicleSortOption.lastAccessed;
  GlobalVehicleSettings _globalSettings =
      const GlobalVehicleSettings();

  @override
  bool isOnboardingCompleted() => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(
    bool completed,
  ) async {
    _onboardingCompleted = completed;
  }

  @override
  String? getPrivacyPolicyAcceptedVersion() =>
      _privacyPolicyAcceptedVersion;

  @override
  Future<void> savePrivacyPolicyAcceptedVersion(
    String version,
  ) async {
    _privacyPolicyAcceptedVersion = version;
  }

  @override
  AppThemeMode getThemeMode() => _themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      _globalSettings;

  @override
  Future<void> saveGlobalVehicleSettings(
    GlobalVehicleSettings settings,
  ) async {
    _globalSettings = settings;
  }

  @override
  VehicleSortOption getVehicleSortOption() => _sortOption;

  @override
  Future<void> saveVehicleSortOption(
    VehicleSortOption option,
  ) async {
    _sortOption = option;
  }

  @override
  bool getNotificationsEnabled() =>
      _notificationSettings.enabled;

  @override
  Future<void> saveNotificationsEnabled(
    bool enabled,
  ) async {
    _notificationSettings = _notificationSettings.copyWith(
      enabled: enabled,
    );
  }

  @override
  NotificationSettings getNotificationSettings() =>
      _notificationSettings;

  @override
  Future<void> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    _notificationSettings = settings;
  }
}

class FakePrivacyVehicleDataSource
    implements VehicleLocalDataSource {
  final Map<String, Vehicle> _vehicles = {};

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) =>
      _vehicles[vehicleId];

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.remove(vehicleId);
  }
}

class FakePrivacyPreferencesDataSource
    implements VehiclePreferencesLocalDataSource {
  final Map<String, VehiclePreferences> _prefs = {};

  @override
  VehiclePreferences? getPreference(String vehicleId) =>
      _prefs[vehicleId];

  @override
  Map<String, VehiclePreferences> getAllPreferences() =>
      Map.of(_prefs);

  @override
  Future<void> savePreference(
    VehiclePreferences preference,
  ) async {
    _prefs[preference.vehicleId] = preference;
  }

  @override
  Future<void> deletePreference(String vehicleId) async {
    _prefs.remove(vehicleId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePrivacyAppSettingsDataSource fakeSettings;
  late FakePrivacyVehicleDataSource fakeVehicles;
  late FakePrivacyPreferencesDataSource fakePreferences;
  late AppSettingsRepository settingsRepo;
  late VehiclesRepository vehiclesRepo;
  late VehiclePreferencesRepository preferencesRepo;

  setUp(() {
    fakeSettings = FakePrivacyAppSettingsDataSource();
    fakeVehicles = FakePrivacyVehicleDataSource();
    fakePreferences = FakePrivacyPreferencesDataSource();
    settingsRepo = AppSettingsRepository(
      localDataSource: fakeSettings,
    );
    vehiclesRepo = VehiclesRepository(
      localDataSource: fakeVehicles,
    );
    preferencesRepo = VehiclePreferencesRepository(
      localDataSource: fakePreferences,
    );
  });

  Widget buildTestApp({
    Widget? home,
    RouteFactory? onGenerateRoute,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          settingsRepo,
        ),
        vehiclesRepositoryProvider.overrideWithValue(
          vehiclesRepo,
        ),
        vehiclePreferencesRepositoryProvider
            .overrideWithValue(preferencesRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: home,
        onGenerateRoute:
            onGenerateRoute ?? AppRoutes.onGenerateRoute,
      ),
    );
  }

  group('Privacy Policy & Data Usage Consent Flow Tests', () {
    testWidgets(
      'Fresh install: AppStartupScreen opens OnboardingScreen when not completed',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const AppStartupScreen()),
        );
        await tester.pumpAndSettle();

        expect(
          find.byType(OnboardingScreen),
          findsOneWidget,
        );
        expect(find.byType(HomeScreen), findsNothing);
        expect(
          find.byType(PrivacyConsentScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Onboarding skip takes user to PrivacyConsentScreen on first launch',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const OnboardingScreen()),
        );
        await tester.pumpAndSettle();

        // Tap Skip on Onboarding
        final skipBtn = find.text('Skip');
        expect(skipBtn, findsOneWidget);
        await tester.tap(skipBtn);
        await tester.pumpAndSettle();

        // PrivacyConsentScreen should now be displayed
        expect(
          find.byType(PrivacyConsentScreen),
          findsOneWidget,
        );
        expect(
          find.text('Your Privacy Matters'),
          findsOneWidget,
        );
        expect(
          find.text('Stored Locally on Your Device'),
          findsOneWidget,
        );
        expect(
          find.text('What We Don’t Collect'),
          findsOneWidget,
        );
        expect(
          find.text('Device Data Notice'),
          findsOneWidget,
        );
        expect(
          find.text('Read Full Privacy Policy'),
          findsNothing,
        );
        expect(
          find.text('I Understand & Continue'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Onboarding story progression to Get Started opens PrivacyConsentScreen',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const OnboardingScreen()),
        );
        await tester.pumpAndSettle();

        // Navigate through 5 pages
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }

        // Tap Get Started on 5th page
        expect(find.text('Get Started'), findsOneWidget);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // PrivacyConsentScreen is shown
        expect(
          find.byType(PrivacyConsentScreen),
          findsOneWidget,
        );
        expect(
          find.text('Your Privacy Matters'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Tapping I Understand & Continue stores acceptance version and marks onboarding complete',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: const PrivacyConsentScreen(
              isFirstLaunch: true,
              targetRoute: AppRoutes.home,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          fakeSettings.getPrivacyPolicyAcceptedVersion(),
          isNull,
        );
        expect(
          fakeSettings.isOnboardingCompleted(),
          isFalse,
        );

        final acceptBtn = find.text(
          'I Understand & Continue',
        );
        expect(acceptBtn, findsOneWidget);
        await tester.tap(acceptBtn);
        await tester.pumpAndSettle();

        expect(
          fakeSettings.getPrivacyPolicyAcceptedVersion(),
          AppConstants.currentPrivacyPolicyVersion,
        );
        expect(
          fakeSettings.isOnboardingCompleted(),
          isTrue,
        );
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Returning user with valid accepted policy opens HomeScreen directly',
      (tester) async {
        fakeSettings._onboardingCompleted = true;
        fakeSettings._privacyPolicyAcceptedVersion =
            AppConstants.currentPrivacyPolicyVersion;

        await tester.pumpWidget(
          buildTestApp(home: const AppStartupScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          find.byType(PrivacyConsentScreen),
          findsNothing,
        );
        expect(find.byType(OnboardingScreen), findsNothing);
      },
    );

    testWidgets(
      'Policy version update prompts returning user with Updated Privacy Policy screen without deleting vehicle data',
      (tester) async {
        // Simulate existing user with vehicle data and older policy version '0.9'
        fakeSettings._onboardingCompleted = true;
        fakeSettings._privacyPolicyAcceptedVersion = '0.9';

        final sampleVehicle = Vehicle(
          id: 'v_existing',
          vehicleType: VehicleType.car,
          brand: VehicleBrand.honda,
          model: 'City ZX',
          manufacturingYear: 2023,
          odometerReading: 22000,
          registrationNumber: 'MH 02 CD 5678',
          fuelType: 'Petrol',
          color: 'Silver',
          purchaseDate: DateTime(2023, 5, 10),
        );
        await fakeVehicles.addVehicle(sampleVehicle);

        await tester.pumpWidget(
          buildTestApp(home: const AppStartupScreen()),
        );
        await tester.pumpAndSettle();

        // Should show Updated Privacy Policy screen without redirect webpage button
        expect(
          find.byType(PrivacyConsentScreen),
          findsOneWidget,
        );
        expect(
          find.text('Updated Privacy Policy'),
          findsOneWidget,
        );
        expect(
          find.text('Read Full Privacy Policy'),
          findsNothing,
        );

        // User accepts updated policy
        await tester.tap(
          find.text('I Understand & Continue'),
        );
        await tester.pumpAndSettle();

        // Returns to HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          fakeSettings.getPrivacyPolicyAcceptedVersion(),
          AppConstants.currentPrivacyPolicyVersion,
        );

        // Verify vehicle data is preserved
        final vehicles = fakeVehicles.getVehicles();
        expect(vehicles.length, 1);
        expect(vehicles.first.model, 'City ZX');
        expect(find.text('City ZX'), findsOneWidget);
      },
    );

    testWidgets(
      'Settings screen displays Privacy Policy tile and opens in-app PrivacyPolicyDialog without browser',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const SettingsScreen()),
        );
        await tester.pumpAndSettle();

        expect(
          find.byType(PrivacySettingTile),
          findsOneWidget,
        );
        expect(find.text('Privacy Policy'), findsOneWidget);
        expect(
          find.text('Read how Odomex handles your data'),
          findsOneWidget,
        );

        // Scroll to and tap Privacy Policy tile
        await tester.ensureVisible(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();

        // Verify in-app dialog is opened
        expect(
          find.byType(PrivacyPolicyDialog),
          findsOneWidget,
        );
        expect(
          find.byType(PrivacyPolicyContent),
          findsOneWidget,
        );
        expect(
          find.text('Privacy & Data Usage'),
          findsOneWidget,
        );
        expect(
          find.text('Stored Locally on Your Device'),
          findsOneWidget,
        );
        expect(
          find.text('What We Don’t Collect'),
          findsOneWidget,
        );
        expect(
          find.text('Device Data Notice'),
          findsOneWidget,
        );

        // Verify it is view-only (no consent action button)
        expect(
          find.text('I Understand & Continue'),
          findsNothing,
        );
        expect(find.text('Close'), findsOneWidget);

        // Tap Close button
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Dialog is dismissed and Settings remains active
        expect(
          find.byType(PrivacyPolicyDialog),
          findsNothing,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'PrivacyPolicyDialog close icon and back navigation dismiss cleanly without changing consent',
      (tester) async {
        fakeSettings.savePrivacyPolicyAcceptedVersion(
          '1.0',
        );
        await tester.pumpWidget(
          buildTestApp(home: const SettingsScreen()),
        );
        await tester.pumpAndSettle();

        // Scroll to and open dialog
        await tester.ensureVisible(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();
        expect(
          find.byType(PrivacyPolicyDialog),
          findsOneWidget,
        );

        // Dismiss via top-right close icon
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(
          find.byType(PrivacyPolicyDialog),
          findsNothing,
        );

        // Re-open and dismiss via back navigation
        await tester.ensureVisible(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PrivacySettingTile));
        await tester.pumpAndSettle();
        expect(
          find.byType(PrivacyPolicyDialog),
          findsOneWidget,
        );

        // Simulate back
        final dynamic widgetsAppState = tester.state(
          find.byType(WidgetsApp),
        );
        widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        expect(
          find.byType(PrivacyPolicyDialog),
          findsNothing,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);

        // Consent state remains completely untouched
        expect(
          fakeSettings.getPrivacyPolicyAcceptedVersion(),
          '1.0',
        );
      },
    );

    testWidgets(
      'PrivacyPolicyDialog renders responsively on small screen (360x640) in dark theme without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: PrivacyPolicyDialog(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Privacy & Data Usage'),
          findsOneWidget,
        );
        expect(
          find.text('Stored Locally on Your Device'),
          findsOneWidget,
        );
        expect(find.text('Close'), findsOneWidget);
      },
    );

    testWidgets(
      'PrivacyConsentScreen renders responsively on small screen (360x640) in dark theme without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsRepositoryProvider
                  .overrideWithValue(settingsRepo),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const PrivacyConsentScreen(
                isFirstLaunch: true,
                targetRoute: AppRoutes.home,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.byType(PrivacyPolicyContent),
          findsOneWidget,
        );
        expect(
          find.text('Your Privacy Matters'),
          findsOneWidget,
        );
        expect(
          find.text('Stored Locally on Your Device'),
          findsOneWidget,
        );
        expect(
          find.text('I Understand & Continue'),
          findsOneWidget,
        );
      },
    );
  });
}
