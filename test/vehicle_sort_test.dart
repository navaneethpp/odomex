import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/widgets/vehicle_sort_setting_tile.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_preferences/utils/vehicle_list_sorter.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

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
  final Map<String, Vehicle> _vehicles = {};

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

void main() {
  final activa = Vehicle(
    id: 'v1',
    brand: VehicleBrand.honda,
    model: 'Honda Activa 5G',
    manufacturingYear: 2020,
    odometerReading: 25000,
    registrationNumber: 'KL 10 AB 1234',
    color: 'Black',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 20, 12, 0), // most recent
  );

  final duke = Vehicle(
    id: 'v2',
    brand: VehicleBrand.ktm,
    model: 'KTM Duke 200',
    manufacturingYear: 2021,
    odometerReading: 15000,
    registrationNumber: 'KL 10 CD 5678',
    color: 'Orange',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2021, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 19, 10, 0), // yesterday
  );

  final splendor = Vehicle(
    id: 'v3',
    brand: VehicleBrand.hero,
    model: 'Hero Splendor Plus',
    manufacturingYear: 2022,
    odometerReading: 8000,
    registrationNumber: 'KL 10 EF 9012',
    color: 'Blue',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2022, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 20, 10, 0), // 2 hours ago
  );

  final bullet = Vehicle(
    id: 'v4',
    brand: VehicleBrand.royalEnfield,
    model: 'Royal Enfield Classic 350',
    manufacturingYear: 2019,
    odometerReading: 32000,
    registrationNumber: 'KL 10 GH 3456',
    color: 'Grey',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2019, 1, 1),
    lastAccessedAt: null, // never accessed
  );

  final access = Vehicle(
    id: 'v5',
    brand: VehicleBrand.suzuki,
    model: 'Suzuki Access 125',
    manufacturingYear: 2021,
    odometerReading: 12000,
    registrationNumber: 'KL 10 IJ 7890',
    color: 'White',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2021, 1, 1),
    lastAccessedAt: null, // never accessed
  );

  group('VehicleSortOption Enum & Persistence Tests', () {
    late Directory tempDir;
    late Box<dynamic> box;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sort_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('defaults to lastAccessed when no saved preference exists', () {
      final dataSource = HiveAppSettingsLocalDataSource(settingsBox: box);
      final repo = AppSettingsRepository(localDataSource: dataSource);

      expect(repo.getVehicleSortOption(), VehicleSortOption.lastAccessed);
    });

    test('persists and restores alphabetical sort preference', () async {
      final dataSource = HiveAppSettingsLocalDataSource(settingsBox: box);
      final repo = AppSettingsRepository(localDataSource: dataSource);

      await repo.saveVehicleSortOption(VehicleSortOption.alphabetical);
      expect(repo.getVehicleSortOption(), VehicleSortOption.alphabetical);
    });
  });

  group('VehicleListSorter Rules Tests', () {
    test('Last Accessed sort puts recently accessed first, followed by never-accessed alphabetically', () {
      final vehicles = [bullet, access, activa, duke, splendor];
      final prefs = <String, VehiclePreferences>{};

      final sorted = VehicleListSorter.sort(
        vehicles: vehicles,
        sortOption: VehicleSortOption.lastAccessed,
        preferences: prefs,
      );

      expect(
        sorted.map((v) => v.id).toList(),
        ['v1', 'v3', 'v2', 'v4', 'v5'],
      );
    });

    test('Alphabetical sort orders by model name case-insensitively', () {
      final vehicles = [bullet, access, activa, duke, splendor];
      final prefs = <String, VehiclePreferences>{};

      final sorted = VehicleListSorter.sort(
        vehicles: vehicles,
        sortOption: VehicleSortOption.alphabetical,
        preferences: prefs,
      );

      expect(
        sorted.map((v) => v.id).toList(),
        ['v3', 'v1', 'v2', 'v4', 'v5'],
      );
    });

    test('Pinned vehicles always appear before unpinned vehicles regardless of sort mode', () {
      final vehicles = [bullet, access, activa, duke, splendor];

      // Pin Duke (v2)
      final prefs = {
        'v2': const VehiclePreferences(vehicleId: 'v2', isPinned: true),
      };

      // 1. Last Accessed with pinned Duke
      final sortedByAccess = VehicleListSorter.sort(
        vehicles: vehicles,
        sortOption: VehicleSortOption.lastAccessed,
        preferences: prefs,
      );
      expect(
        sortedByAccess.map((v) => v.id).toList(),
        ['v2', 'v1', 'v3', 'v4', 'v5'],
      );

      // 2. Alphabetical with pinned Duke
      final sortedAlphabetical = VehicleListSorter.sort(
        vehicles: vehicles,
        sortOption: VehicleSortOption.alphabetical,
        preferences: prefs,
      );
      expect(
        sortedAlphabetical.map((v) => v.id).toList(),
        ['v2', 'v3', 'v1', 'v4', 'v5'],
      );
    });
  });

  group('VehicleSortSettingTile & SelectionSheet Widget Tests', () {
    testWidgets('VehicleSortSettingTile displays active sort option and opens selection sheet',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicles = FakeVehicleLocalDataSource();
      final fakePrefs = FakeVehiclePreferencesLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider.overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider.overrideWithValue(fakeVehicles),
            vehiclePreferencesLocalDataSourceProvider.overrideWithValue(fakePrefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VehicleSortSettingTile(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sort Vehicles'), findsOneWidget);
      expect(find.text('Last Accessed'), findsOneWidget);
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);

      // Tap tile to open bottom sheet
      await tester.tap(find.byType(VehicleSortSettingTile));
      await tester.pumpAndSettle();

      expect(find.text('Sort Vehicles'), findsNWidgets(2));
      expect(find.text('Alphabetical'), findsOneWidget);
      expect(find.text('Sort vehicles by their model name'), findsOneWidget);

      // Tap Alphabetical
      await tester.tap(find.text('Alphabetical'));
      await tester.pumpAndSettle();

      // Sheet dismissed, tile updated to Alphabetical
      expect(find.text('Alphabetical'), findsOneWidget);
    });
  });
}
