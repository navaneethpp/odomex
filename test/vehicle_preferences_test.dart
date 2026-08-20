import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_settings_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_preferences/widgets/confirm_remove_vehicle_dialog.dart';
import 'package:odomex/features/vehicle_preferences/widgets/vehicle_action_sheet.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';

class FakeVehicleLocalDataSource implements VehicleLocalDataSource {
  FakeVehicleLocalDataSource(List<Vehicle> initial)
      : _vehicles = {for (final v in initial) v.id: v};

  final Map<String, Vehicle> _vehicles;

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

  @override
  Future<void> seedInitialVehicles(List<Vehicle> initialVehicles) async {}
}

class FakeVehiclePreferencesLocalDataSource
    implements VehiclePreferencesLocalDataSource {
  FakeVehiclePreferencesLocalDataSource([Map<String, VehiclePreferences>? initial])
      : _prefs = initial ?? {};

  final Map<String, VehiclePreferences> _prefs;

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

class FakeVehicleRecordLocalDataSource implements VehicleRecordLocalDataSource {
  final List<VehicleRecord> _records = [];

  @override
  Future<void> addRecord(VehicleRecord record) async {
    _records.add(record);
  }

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    _records.removeWhere((r) => r.vehicleId == vehicleId);
  }

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
  Future<void> deleteSettings(String vehicleId) async {
    _settings.remove(vehicleId);
  }

  @override
  VehicleSettings? getSettings(String vehicleId) => _settings[vehicleId];

  @override
  Future<void> saveSettings(VehicleSettings settings) async {
    _settings[settings.vehicleId] = settings;
  }
}

void main() {
  final vehicleA = Vehicle(
    id: 'vA',
    brand: VehicleBrand.honda,
    model: 'Activa 5G',
    manufacturingYear: 2020,
    odometerReading: 25000,
    registrationNumber: 'KL 10 AB 1234',
    color: 'Black',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 19, 10, 0), // yesterday
  );

  final vehicleB = Vehicle(
    id: 'vB',
    brand: VehicleBrand.ktm,
    model: 'Duke 200',
    manufacturingYear: 2021,
    odometerReading: 15000,
    registrationNumber: 'KL 10 CD 5678',
    color: 'Orange',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2021, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 18, 10, 0), // 2 days ago
  );

  final vehicleC = Vehicle(
    id: 'vC',
    brand: VehicleBrand.hero,
    model: 'Splendor Plus',
    manufacturingYear: 2022,
    odometerReading: 8000,
    registrationNumber: 'KL 10 EF 9012',
    color: 'Blue',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2022, 1, 1),
    lastAccessedAt: DateTime(2026, 8, 20, 12, 0), // 10 minutes ago
  );

  group('VehiclePreferences Model & Persistence Tests', () {
    late Directory tempDir;
    late Box<dynamic> box;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('pref_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<dynamic>(HiveBoxes.vehiclePreferences);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('persists and loads vehicle preferences', () async {
      final dataSource =
          HiveVehiclePreferencesLocalDataSource(preferencesBox: box);
      final repo =
          VehiclePreferencesRepository(localDataSource: dataSource);

      expect(repo.getPreference('vA').isPinned, false);

      await repo.savePreference(
        const VehiclePreferences(vehicleId: 'vA', isPinned: true),
      );

      expect(repo.getPreference('vA').isPinned, true);
      expect(repo.getAllPreferences()['vA']?.isPinned, true);

      await repo.deletePreference('vA');
      expect(repo.getPreference('vA').isPinned, false);
    });
  });

  group('Combined Sorting Rules (Pinned first, then last accessed)', () {
    test('places pinned vehicles first regardless of last access time', () {
      final vehicles = [vehicleA, vehicleB, vehicleC];
      final prefs = {
        'vA': const VehiclePreferences(vehicleId: 'vA', isPinned: true),
        'vB': const VehiclePreferences(vehicleId: 'vB', isPinned: true),
        'vC': const VehiclePreferences(vehicleId: 'vC', isPinned: false),
      };

      final sorted = VehicleNotifier.sort(vehicles, prefs);

      expect(sorted.map((v) => v.id).toList(), ['vA', 'vB', 'vC']);
    });

    test('pinning unpinned vehicle dynamically moves it to top', () {
      final vehicles = [vehicleA, vehicleB, vehicleC];

      var sorted = VehicleNotifier.sort(vehicles, {});
      expect(sorted.map((v) => v.id).toList(), ['vC', 'vA', 'vB']);

      final prefs = {
        'vB': const VehiclePreferences(vehicleId: 'vB', isPinned: true),
      };
      sorted = VehicleNotifier.sort(vehicles, prefs);
      expect(sorted.map((v) => v.id).toList(), ['vB', 'vC', 'vA']);
    });
  });

  group('VehicleCard & Contextual Action Menu Widget Tests', () {
    testWidgets('VehicleCard displays push pin icon when pinned and three-dot menu button',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: vehicleA,
              isPinned: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
      expect(find.text('Activa 5G'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('Tapping three-dot button triggers onActions callback',
        (tester) async {
      bool actionsTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: vehicleA,
              isPinned: false,
              onActions: () => actionsTriggered = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(actionsTriggered, true);
    });

    testWidgets('Long press on VehicleCard triggers action sheet',
        (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleCard(
              vehicle: vehicleA,
              isPinned: false,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(VehicleCard));
      await tester.pumpAndSettle();

      expect(longPressed, true);
    });

    testWidgets('VehicleActionSheet displays Pin, Remove, and Cancel actions',
        (tester) async {
      bool pinToggled = false;
      bool removeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleActionSheet(
              vehicle: vehicleA,
              isPinned: false,
              onTogglePin: () => pinToggled = true,
              onRemove: () => removeTriggered = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pin Vehicle'), findsOneWidget);
      expect(find.text('Remove Vehicle'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Honda Activa 5G'), findsOneWidget);
      expect(find.text('KL 10 AB 1234'), findsOneWidget);

      await tester.tap(find.text('Pin Vehicle'));
      expect(pinToggled, true);
    });

    testWidgets('VehicleActionSheet triggers onRemove when Remove Vehicle is tapped',
        (tester) async {
      bool removeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleActionSheet(
              vehicle: vehicleA,
              isPinned: false,
              onTogglePin: () {},
              onRemove: () => removeTriggered = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove Vehicle'));
      expect(removeTriggered, true);
    });

    testWidgets('ConfirmRemoveVehicleDialog shows vehicle details and buttons',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmRemoveVehicleDialog(
              vehicle: vehicleA,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remove Vehicle?'), findsOneWidget);
      expect(find.textContaining('Honda Activa 5G (KL 10 AB 1234)'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('HomeScreen renders vehicle list and three-dot opens action sheet to remove vehicle',
        (tester) async {
      final fakeVehicleDataSource =
          FakeVehicleLocalDataSource([vehicleA, vehicleB]);
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();
      final fakeRecordDataSource = FakeVehicleRecordLocalDataSource();
      final fakeSettingsDataSource = FakeVehicleSettingsLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.text('Activa 5G'), findsOneWidget);
      expect(find.text('Duke 200'), findsOneWidget);

      // Tap three-dot menu on first vehicle
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Pin Vehicle'), findsOneWidget);
      expect(find.text('Remove Vehicle'), findsOneWidget);

      // Tap Remove Vehicle -> opens confirmation dialog
      await tester.tap(find.text('Remove Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Vehicle?'), findsOneWidget);

      // Confirm Remove
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Vehicle removed'), findsOneWidget);
      expect(find.text('Activa 5G'), findsNothing);
      expect(find.text('Duke 200'), findsOneWidget);
    });
  });
}
