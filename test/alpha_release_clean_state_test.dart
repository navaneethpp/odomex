import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_permission_state.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/notification_settings_provider.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/startup/app_startup_screen.dart';

class FakeNotificationService implements NotificationService {
  bool mockPermissionGranted = true;
  bool mockPlatformEnabled = false;
  int scheduleDailyCallCount = 0;
  int cancelCallCount = 0;

  @override
  bool get isInitialized => true;

  @override
  NotificationTapCallback? onNotificationTapped;

  @override
  String get localTimeZoneName => 'UTC';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => mockPermissionGranted;

  @override
  Future<bool> areNotificationsEnabled() async => mockPlatformEnabled;

  @override
  Future<NotificationPermissionState> checkPermissions() async {
    return NotificationPermissionState(
      notificationGranted: mockPlatformEnabled,
      exactAlarmGranted: true,
    );
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {}

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {
    scheduleDailyCallCount++;
  }

  @override
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required dynamic scheduledDate,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {}

  @override
  Future<bool> scheduleDevTestReminder({int minutesFromNow = 2}) async => true;

  @override
  Future<void> syncDailyActivitySchedule({
    required bool masterEnabled,
    required bool dailyActivityEnabled,
    required int hour,
    required int minute,
  }) async {
    if (masterEnabled && dailyActivityEnabled && mockPlatformEnabled) {
      scheduleDailyCallCount++;
    } else {
      cancelCallCount++;
    }
  }

  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> cancel(int id) async {
    cancelCallCount++;
  }

  @override
  Future<void> cancelAll() async {
    cancelCallCount++;
  }
}

class FakeVehicleLocalDataSource implements VehicleLocalDataSource {
  final Map<String, Vehicle> _vehicles = {};

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) => _vehicles[vehicleId];

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

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  bool _onboardingCompleted = false;
  AppThemeMode _themeMode = AppThemeMode.system;
  NotificationSettings _notificationSettings = const NotificationSettings();
  VehicleSortOption _sortOption = VehicleSortOption.lastAccessed;
  GlobalVehicleSettings _globalSettings = const GlobalVehicleSettings();

  @override
  bool isOnboardingCompleted() => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
  }

  @override
  bool getNotificationsEnabled() => _notificationSettings.enabled;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    _notificationSettings = _notificationSettings.copyWith(enabled: enabled);
  }

  @override
  NotificationSettings getNotificationSettings() => _notificationSettings;

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    _notificationSettings = settings;
  }

  @override
  AppThemeMode getThemeMode() => _themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() => _globalSettings;

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {
    _globalSettings = settings;
  }

  @override
  VehicleSortOption getVehicleSortOption() => _sortOption;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async {
    _sortOption = option;
  }
}

class FakeVehiclePreferencesLocalDataSource
    implements VehiclePreferencesLocalDataSource {
  final Map<String, VehiclePreferences> _prefs = {};

  @override
  VehiclePreferences? getPreference(String vehicleId) => _prefs[vehicleId];

  @override
  Map<String, VehiclePreferences> getAllPreferences() => Map.of(_prefs);

  @override
  Future<void> savePreference(VehiclePreferences preference) async {
    _prefs[preference.vehicleId] = preference;
  }

  @override
  Future<void> deletePreference(String vehicleId) async {
    _prefs.remove(vehicleId);
  }
}

void main() {
  late FakeVehicleLocalDataSource fakeVehicleDataSource;
  late FakeAppSettingsLocalDataSource fakeAppSettingsDataSource;
  late FakeVehiclePreferencesLocalDataSource fakePrefsDataSource;
  late FakeNotificationService fakeNotificationService;

  setUp(() {
    fakeVehicleDataSource = FakeVehicleLocalDataSource();
    fakeAppSettingsDataSource = FakeAppSettingsLocalDataSource();
    fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();
    fakeNotificationService = FakeNotificationService();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        vehicleLocalDataSourceProvider
            .overrideWithValue(fakeVehicleDataSource),
        appSettingsLocalDataSourceProvider
            .overrideWithValue(fakeAppSettingsDataSource),
        vehiclePreferencesLocalDataSourceProvider
            .overrideWithValue(fakePrefsDataSource),
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AppStartupScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }

  group('Alpha Release Clean State & Pre-Release Audits', () {
    testWidgets('Fresh installation starts clean: 0 vehicles, 0 schedules, and opens Onboarding', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 1. Verify 0 vehicles stored
      expect(fakeVehicleDataSource.getVehicles().isEmpty, true);

      // 2. Verify 0 notifications scheduled
      expect(fakeNotificationService.scheduleDailyCallCount, 0);

      // 3. Verify Onboarding is displayed
      expect(find.text('Meet your vehicle.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Skipping Onboarding takes user to clean Home screen with empty state', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Home Screen with empty state
      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.text('No vehicles yet'), findsOneWidget);
      expect(find.text('Tap + to add your first vehicle'), findsOneWidget);
      expect(fakeAppSettingsDataSource.isOnboardingCompleted(), true);
    });

    testWidgets('Subsequent app launch after onboarding opens Home screen directly without demo data', (tester) async {
      fakeAppSettingsDataSource.setOnboardingCompleted(true);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should open directly to Home screen
      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.text('No vehicles yet'), findsOneWidget);
      expect(fakeVehicleDataSource.getVehicles().isEmpty, true);
    });
  });
}
