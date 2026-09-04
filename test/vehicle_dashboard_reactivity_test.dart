import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_dashboard/providers/vehicle_dashboard_provider.dart';
import 'package:odomex/features/vehicle_dashboard/screens/vehicle_dashboard_screen.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

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

class FakePreferencesLocalDataSource
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

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  VehicleSortOption _sortOption = VehicleSortOption.lastAccessed;
  AppThemeMode _themeMode = AppThemeMode.system;

  @override
  VehicleSortOption getVehicleSortOption() => _sortOption;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption sortOption) async {
    _sortOption = sortOption;
  }

  @override
  AppThemeMode getThemeMode() => _themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  bool isOnboardingCompleted() => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  String? getPrivacyPolicyAcceptedVersion() => '1.0.0';

  @override
  Future<void> savePrivacyPolicyAcceptedVersion(String version) async {}

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      const GlobalVehicleSettings();

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {}

  @override
  NotificationSettings getNotificationSettings() =>
      const NotificationSettings();

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {}
  @override
  bool getAutoFillCurrentOdometer() => true;

  @override
  Future<void> saveAutoFillCurrentOdometer(bool enabled) async {}


  @override
  bool getNotificationsEnabled() => false;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {}
}

class FakeReactivityRecordLocalDataSource
    implements VehicleRecordLocalDataSource {
  final Map<String, List<VehicleRecord>> _records = {};

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) {
    final list = _records[vehicleId] ?? [];
    return List.of(list)..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) =>
      getAllRecords(vehicleId).take(limit).toList();

  @override
  List<VehicleRecord> getRecordsByDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return getAllRecords(vehicleId).where((r) {
      return (r.date.isAfter(startDate) ||
              r.date.isAtSameMomentAs(startDate)) &&
          (r.date.isBefore(endDate) || r.date.isAtSameMomentAs(endDate));
    }).toList();
  }

  @override
  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      getAllRecords(vehicleId).whereType<OdometerRecord>().toList();

  @override
  List<FuelRecord> getFuelRecords(String vehicleId) =>
      getAllRecords(vehicleId).whereType<FuelRecord>().toList();

  @override
  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      getAllRecords(vehicleId).whereType<ServiceRecord>().toList();

  @override
  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      getAllRecords(vehicleId).whereType<OilChangeRecord>().toList();

  @override
  Future<void> addRecord(VehicleRecord record) async {
    final list = _records.putIfAbsent(record.vehicleId, () => []);
    list.removeWhere((r) => r.id == record.id);
    list.add(record);
  }

  @override
  Future<void> deleteRecord(String vehicleId, String recordId) async {
    _records[vehicleId]?.removeWhere((r) => r.id == recordId);
  }

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    _records.remove(vehicleId);
  }
}

void main() {
  group('Vehicle Dashboard Reactivity & Instant Updates Tests', () {
    late FakeVehicleLocalDataSource fakeVehicleDataSource;
    late FakePreferencesLocalDataSource fakePrefsDataSource;
    late FakeAppSettingsLocalDataSource fakeSettingsDataSource;
    late FakeReactivityRecordLocalDataSource fakeRecordDataSource;

    late VehiclesRepository vehiclesRepository;
    late VehiclePreferencesRepository preferencesRepository;
    late AppSettingsRepository settingsRepository;
    late VehicleRecordsRepository recordsRepository;

    late Vehicle testVehicle;

    setUp(() async {
      fakeVehicleDataSource = FakeVehicleLocalDataSource();
      fakePrefsDataSource = FakePreferencesLocalDataSource();
      fakeSettingsDataSource = FakeAppSettingsLocalDataSource();
      fakeRecordDataSource = FakeReactivityRecordLocalDataSource();

      vehiclesRepository =
          VehiclesRepository(localDataSource: fakeVehicleDataSource);
      preferencesRepository = VehiclePreferencesRepository(
          localDataSource: fakePrefsDataSource);
      settingsRepository =
          AppSettingsRepository(localDataSource: fakeSettingsDataSource);
      recordsRepository =
          VehicleRecordsRepository(localDataSource: fakeRecordDataSource);

      testVehicle = Vehicle(
        id: 'veh_test_1',
        brand: VehicleBrand.honda,
        model: 'CB350 RS',
        manufacturingYear: 2024,
        odometerReading: 25430.0,
        registrationNumber: 'KA 01 AB 1234',
        color: 'Pearl Nightstar Black',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2024, 1, 1),
      );

      await vehiclesRepository.add(testVehicle);
    });

    List<Override> buildOverrides() => [
          vehicleLocalDataSourceProvider
              .overrideWithValue(fakeVehicleDataSource),
          vehiclePreferencesLocalDataSourceProvider
              .overrideWithValue(fakePrefsDataSource),
          appSettingsLocalDataSourceProvider
              .overrideWithValue(fakeSettingsDataSource),
          vehicleRecordLocalDataSourceProvider
              .overrideWithValue(fakeRecordDataSource),
          vehiclesRepositoryProvider.overrideWithValue(vehiclesRepository),
          vehiclePreferencesRepositoryProvider
              .overrideWithValue(preferencesRepository),
          appSettingsRepositoryProvider.overrideWithValue(settingsRepository),
          vehicleRecordRepositoryProvider.overrideWithValue(recordsRepository),
        ];

    testWidgets('Adding an Odometer record immediately updates dashboard odometer',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial odometer displayed
      expect(find.text('25,430'), findsOneWidget);

      // Add new Odometer record: 25,450 km
      await container.read(vehicleRecordProvider.notifier).addRecord(
            OdometerRecord(
              id: 'odo_new_1',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              odometer: 25450.0,
            ),
          );

      await tester.pumpAndSettle();

      // Immediately reflects 25,450 km
      expect(find.text('25,450'), findsOneWidget);
    });

    testWidgets(
        'Adding a Fuel record immediately updates Fuel Used and Fuel Cost metrics',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add fuel refill: 20 L @ ₹2,000
      await container.read(vehicleRecordProvider.notifier).addRecord(
            FuelRecord(
              id: 'fuel_1',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              quantity: 20.0,
              cost: 2000.0,
              odometerReading: 25440.0,
            ),
          );

      await tester.pumpAndSettle();

      expect(find.text('20.0'), findsOneWidget); // Fuel Used 20.0 L
      expect(find.text('2,000'), findsOneWidget); // Total Fuel Cost ₹2,000

      // Add additional fuel refill: 5 L @ ₹500
      await container.read(vehicleRecordProvider.notifier).addRecord(
            FuelRecord(
              id: 'fuel_2',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              quantity: 5.0,
              cost: 500.0,
              odometerReading: 25450.0,
            ),
          );

      await tester.pumpAndSettle();

      expect(find.text('25.0'), findsOneWidget); // Fuel Used 25.0 L
      expect(find.text('2,500'), findsOneWidget); // Total Cost ₹2,500
      expect(find.text('25,450'), findsOneWidget); // Odometer also updated
    });

    testWidgets('Editing a record immediately updates dashboard totals',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      await container.read(vehicleRecordProvider.notifier).addRecord(
            FuelRecord(
              id: 'fuel_edit_1',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              quantity: 10.0,
              cost: 1000.0,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('1,000'), findsOneWidget);

      // Edit record: cost ₹1,000 -> ₹1,500
      await container.read(vehicleRecordProvider.notifier).updateRecord(
            FuelRecord(
              id: 'fuel_edit_1',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              quantity: 15.0,
              cost: 1500.0,
            ),
          );

      await tester.pumpAndSettle();
      expect(find.text('1,500'), findsOneWidget);
    });

    testWidgets('Deleting a record immediately reverts dashboard values',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Base record: 25,430 km
      await container.read(vehicleRecordProvider.notifier).addRecord(
            OdometerRecord(
              id: 'odo_base',
              vehicleId: 'veh_test_1',
              date: DateTime(2024, 1, 1),
              odometer: 25430.0,
            ),
          );

      // Add high odometer reading 26,000 km
      await container.read(vehicleRecordProvider.notifier).addRecord(
            OdometerRecord(
              id: 'odo_high',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              odometer: 26000.0,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('26,000'), findsOneWidget);

      // Delete high reading record
      await container
          .read(vehicleRecordProvider.notifier)
          .deleteRecord('veh_test_1', 'odo_high');

      await tester.pumpAndSettle();

      // Immediately reverts back to base 25,430 km
      expect(find.text('25,430'), findsOneWidget);
    });

    testWidgets('Multi-vehicle updates remain strictly isolated',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      final vehicleB = Vehicle(
        id: 'veh_b',
        brand: VehicleBrand.suzuki,
        model: 'Access 125',
        manufacturingYear: 2023,
        odometerReading: 12000.0,
        registrationNumber: 'DL 01 CD 5678',
        color: 'Silver',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2023, 5, 1),
      );
      await vehiclesRepository.add(vehicleB);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Add record to Vehicle A only
      await container.read(vehicleRecordProvider.notifier).addRecord(
            OdometerRecord(
              id: 'odo_a',
              vehicleId: 'veh_test_1',
              date: DateTime.now(),
              odometer: 27000.0,
            ),
          );

      await tester.pumpAndSettle();

      final dashboardDataA =
          container.read(vehicleDashboardProvider('veh_test_1'));
      final dashboardDataB =
          container.read(vehicleDashboardProvider('veh_b'));

      expect(dashboardDataA?.effectiveOdometerReading, 27000.0);
      expect(dashboardDataB?.effectiveOdometerReading, 12000.0);
    });

    testWidgets('Add Record Sheet save flow completes and updates dashboard UI',
        (tester) async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('25,430'), findsOneWidget);

      // Tap floating 'Add Record' button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddVehicleRecordSheet), findsOneWidget);
      expect(find.text('Save Odometer Record'), findsOneWidget);

      // Enter new odometer: 25500
      final odoField = find.byType(TextFormField).first;
      await tester.enterText(odoField, '25500');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Odometer Record'));
      await tester.pumpAndSettle();

      // Returned to dashboard with updated odometer
      expect(find.text('25,500'), findsOneWidget);
    });
  });
}
