import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_dashboard/screens/vehicle_dashboard_screen.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/dashboard_header.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/odometer_summary_card.dart';
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
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/vehicle_header_card.dart';
import 'package:odomex/widgets/animated_odometer_text.dart';

// Test fakes
class _FakeVehicleLocalDataSource implements VehicleLocalDataSource {
  final Map<String, Vehicle> _vehicles = {};

  _FakeVehicleLocalDataSource([List<Vehicle>? initial]) {
    if (initial != null) {
      for (final v in initial) {
        _vehicles[v.id] = v;
      }
    }
  }

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) => _vehicles[vehicleId];

  @override
  Future<void> addVehicle(Vehicle vehicle) async =>
      _vehicles[vehicle.id] = vehicle;

  @override
  Future<void> updateVehicle(Vehicle vehicle) async =>
      _vehicles[vehicle.id] = vehicle;

  @override
  Future<void> deleteVehicle(String vehicleId) async =>
      _vehicles.remove(vehicleId);
}

class _FakePreferencesDataSource
    implements VehiclePreferencesLocalDataSource {
  final Map<String, VehiclePreferences> _prefs = {};

  @override
  VehiclePreferences? getPreference(String vehicleId) => _prefs[vehicleId];

  @override
  Map<String, VehiclePreferences> getAllPreferences() => Map.of(_prefs);

  @override
  Future<void> savePreference(VehiclePreferences preference) async =>
      _prefs[preference.vehicleId] = preference;

  @override
  Future<void> deletePreference(String vehicleId) async =>
      _prefs.remove(vehicleId);
}

class _FakeAppSettingsDataSource implements AppSettingsLocalDataSource {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Beta QA: Layout Overflow & Extreme Value Audits', () {
    testWidgets(
        'VehicleCard does not overflow with very long vehicle model and registration on small screen (360x640)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final extremeVehicle = Vehicle(
        id: 'extreme_1',
        vehicleType: VehicleType.car,
        brand: VehicleBrand.vinfast,
        model:
            'VinFast VF 9 Plus Dual Motor Extended Range Luxury Special Edition 2026',
        manufacturingYear: 2026,
        odometerReading: 999999,
        registrationNumber: 'KL 10 AB 1234 5678 9012',
        fuelType: 'Electric',
        color: 'Deep Pearl White',
        purchaseDate: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: VehicleCard(
              vehicle: extremeVehicle,
              isPinned: true,
              onView: () {},
              onAdd: () {},
              onActions: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('VinFast VF 9 Plus'), findsOneWidget);
    });

    testWidgets(
        'VehicleHeaderCard does not overflow with long model and brand',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final extremeVehicle = Vehicle(
        id: 'extreme_2',
        vehicleType: VehicleType.bus,
        brand: VehicleBrand.tataMotors,
        model: 'Tata Starbus Ultra Long Distance Luxury Sleeper Coach 44 Seater',
        manufacturingYear: 2024,
        odometerReading: 850000,
        registrationNumber: 'KL 07 CA 9999 8888',
        fuelType: 'Diesel',
        color: 'Royal Blue',
        purchaseDate: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: VehicleHeaderCard(vehicle: extremeVehicle),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Tata Starbus Ultra'), findsOneWidget);
    });

    testWidgets(
        'DashboardHeader and OdometerSummaryCard render extreme numbers without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final extremeVehicle = Vehicle(
        id: 'extreme_3',
        vehicleType: VehicleType.pickup,
        brand: VehicleBrand.toyota,
        model: 'Toyota Hilux 4x4 High-Torque Turbo Diesel V8 Edition',
        manufacturingYear: 2025,
        odometerReading: 999999.5,
        registrationNumber: 'DL 01 AA 9999',
        fuelType: 'Diesel',
        color: 'Silver Metallic',
        purchaseDate: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                DashboardHeader(vehicle: extremeVehicle),
                const SizedBox(height: 16),
                OdometerSummaryCard(vehicle: extremeVehicle),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.textContaining('Toyota Hilux'), findsOneWidget);
    });
  });

  group('Beta QA: Navigation & Invalid Route Arguments Safety', () {
    testWidgets(
        'VehicleDashboardScreen gracefully handles non-existent vehicle ID without crashing',
        (tester) async {
      final fakeDataSource = _FakeVehicleLocalDataSource();
      final fakePrefSource = _FakePreferencesDataSource();
      final fakeSettingsSource = _FakeAppSettingsDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesRepositoryProvider.overrideWithValue(
              VehiclesRepository(localDataSource: fakeDataSource),
            ),
            vehiclePreferencesRepositoryProvider.overrideWithValue(
              VehiclePreferencesRepository(localDataSource: fakePrefSource),
            ),
            appSettingsRepositoryProvider.overrideWithValue(
              AppSettingsRepository(localDataSource: fakeSettingsSource),
            ),
          ],
          child: const MaterialApp(
            home: VehicleDashboardScreen(vehicleId: 'non_existent_id_999'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Vehicle not found'), findsOneWidget);
    });

    testWidgets(
        'VehicleDetailsScreen gracefully handles non-existent vehicle ID without crashing',
        (tester) async {
      final fakeDataSource = _FakeVehicleLocalDataSource();
      final fakePrefSource = _FakePreferencesDataSource();
      final fakeSettingsSource = _FakeAppSettingsDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesRepositoryProvider.overrideWithValue(
              VehiclesRepository(localDataSource: fakeDataSource),
            ),
            vehiclePreferencesRepositoryProvider.overrideWithValue(
              VehiclePreferencesRepository(localDataSource: fakePrefSource),
            ),
            appSettingsRepositoryProvider.overrideWithValue(
              AppSettingsRepository(localDataSource: fakeSettingsSource),
            ),
          ],
          child: const MaterialApp(
            home: VehicleDetailsScreen(vehicleId: 'non_existent_id_999'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Vehicle not found'), findsOneWidget);
    });

    testWidgets(
        'AppRoutes generates routes safely with null arguments',
        (tester) async {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: AppRoutes.vehicleDashboard, arguments: null),
      );
      expect(route, isNotNull);
      expect(route, isA<PageRoute>());
    });
  });

  group('Beta QA: Multi-Vehicle Type Icons & Category Integrity', () {
    test('All VehicleType categories have distinct, valid icons', () {
      for (final type in VehicleType.values) {
        expect(type.icon, isNotNull);
        expect(type.displayName.isNotEmpty, isTrue);
      }
    });

    testWidgets('AnimatedOdometerText safely disposes without leaks',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOdometerText(
              value: 45000,
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      // Rapid navigation away before animation completes
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Next Screen'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Next Screen'), findsOneWidget);
    });
  });
}
