import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/dashboard_header.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  AppThemeMode _themeMode = AppThemeMode.system;
  GlobalVehicleSettings _globalSettings = const GlobalVehicleSettings();
  VehicleSortOption _sortOption = VehicleSortOption.lastAccessed;

  @override
  AppThemeMode getThemeMode() => _themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async => _themeMode = mode;

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() => _globalSettings;

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async =>
      _globalSettings = settings;

  @override
  VehicleSortOption getVehicleSortOption() => _sortOption;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async =>
      _sortOption = option;

  @override
  bool isOnboardingCompleted() => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  bool getNotificationsEnabled() => false;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {}

  @override
  NotificationSettings getNotificationSettings() =>
      const NotificationSettings();

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {}
}

class FakeVehicleLocalDataSource implements VehicleLocalDataSource {
  FakeVehicleLocalDataSource(List<Vehicle> initial)
      : _vehicles = {for (final v in initial) v.id: v};

  final Map<String, Vehicle> _vehicles;

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) => _vehicles[vehicleId];

  @override
  Future<void> addVehicle(Vehicle vehicle) async => _vehicles[vehicle.id] = vehicle;

  @override
  Future<void> updateVehicle(Vehicle vehicle) async => _vehicles[vehicle.id] = vehicle;

  @override
  Future<void> deleteVehicle(String vehicleId) async => _vehicles.remove(vehicleId);

  @override
  Future<void> seedInitialVehicles(List<Vehicle> initialVehicles) async {}
}

class FakeVehiclePreferencesLocalDataSource
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

class FakeVehicleRecordLocalDataSource implements VehicleRecordLocalDataSource {
  final List<VehicleRecord> _records = [];

  @override
  Future<void> addRecord(VehicleRecord record) async => _records.add(record);

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async =>
      _records.removeWhere((r) => r.vehicleId == vehicleId);

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) =>
      _records.where((r) => r.vehicleId == vehicleId).toList();

  @override
  List<FuelRecord> getFuelRecords(String vehicleId) =>
      _records.whereType<FuelRecord>().where((r) => r.vehicleId == vehicleId).toList();

  @override
  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      _records.whereType<OilChangeRecord>().where((r) => r.vehicleId == vehicleId).toList();

  @override
  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      _records.whereType<OdometerRecord>().where((r) => r.vehicleId == vehicleId).toList();

  @override
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) =>
      getAllRecords(vehicleId).take(limit).toList();

  @override
  List<VehicleRecord> getRecordsByDateRange(
          String vehicleId, DateTime startDate, DateTime endDate) =>
      getAllRecords(vehicleId);

  @override
  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      _records.whereType<ServiceRecord>().where((r) => r.vehicleId == vehicleId).toList();

  @override
  Future<void> seedInitialRecords(List<VehicleRecord> records) async {}
}

class FakeVehicleSettingsLocalDataSource
    implements VehicleSettingsLocalDataSource {
  final Map<String, VehicleSettings> _settings = {};

  @override
  Future<void> deleteSettings(String vehicleId) async =>
      _settings.remove(vehicleId);

  @override
  VehicleSettings? getSettings(String vehicleId) => _settings[vehicleId];

  @override
  Future<void> saveSettings(VehicleSettings settings) async =>
      _settings[settings.vehicleId] = settings;
}

void main() {
  final testVehicle = Vehicle(
    id: 'veh_test_123',
    brand: VehicleBrand.honda,
    model: 'Activa 5G',
    manufacturingYear: 2020,
    odometerReading: 25000,
    registrationNumber: 'KL 10 AB 1234',
    color: 'Black',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
  );

  group('Animation Constants Tests', () {
    test('AppDurations are configured within recommended 200-450ms ranges', () {
      expect(AppDurations.fast, const Duration(milliseconds: 200));
      expect(AppDurations.normal, const Duration(milliseconds: 300));
      expect(AppDurations.slow, const Duration(milliseconds: 450));
      expect(AppDurations.defaultCurve, Curves.easeOutCubic);
      expect(AppDurations.reverseCurve, Curves.easeInCubic);
    });
  });

  group('Hero Widget Identity Tests', () {
    testWidgets('VehicleCard contains Hero with stable tag vehicle_\${id}',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: testVehicle,
              isPinned: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final heroWidget = tester.widget<Hero>(heroFinder);
      expect(heroWidget.tag, 'vehicle_veh_test_123');
    });

    testWidgets('DashboardHeader contains matching Hero with stable tag vehicle_\${id}',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              vehicle: testVehicle,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final heroWidget = tester.widget<Hero>(heroFinder);
      expect(heroWidget.tag, 'vehicle_veh_test_123');
    });
  });

  group('Route & Hero Navigation Transition Tests', () {
    test('AppRoutes.onGenerateRoute builds vehicleDashboard with custom transition', () {
      const settings = RouteSettings(
        name: AppRoutes.vehicleDashboard,
        arguments: 'veh_test_123',
      );

      final route = AppRoutes.onGenerateRoute(settings);
      expect(route, isA<PageRouteBuilder<dynamic>>());

      final pageRoute = route! as PageRouteBuilder<dynamic>;
      expect(pageRoute.transitionDuration, AppDurations.normal);
      expect(pageRoute.reverseTransitionDuration, AppDurations.normal);
    });

    testWidgets('Tapping vehicle card performs smooth transition to Dashboard and back',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicleDataSource =
          FakeVehicleLocalDataSource([testVehicle]);
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();
      final fakeRecordDataSource = FakeVehicleRecordLocalDataSource();
      final fakeSettingsDataSource = FakeVehicleSettingsLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
            vehicleRecordLocalDataSourceProvider
                .overrideWithValue(fakeRecordDataSource),
            vehicleSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettingsDataSource),
          ],
          child: const MaterialApp(
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.text('Activa 5G'), findsOneWidget);

      // Tap on the vehicle card
      await tester.tap(find.text('Activa 5G'));
      await tester.pumpAndSettle();

      // Now on Vehicle Dashboard
      expect(find.text('CURRENT ODOMETER'), findsOneWidget);
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('25,000'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Returned to Home Screen
      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.text('Activa 5G'), findsOneWidget);
    });
  });
}
