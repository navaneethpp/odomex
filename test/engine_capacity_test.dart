import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/core/utils/engine_capacity_formatter.dart';
import 'package:odomex/core/validation/vehicle_validators.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/vehicles_repository.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/date_picker_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/searchable_brand_picker.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  @override
  bool isOnboardingCompleted() => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

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
  group('EngineCapacityUnit Enum & Extension Tests', () {
    test('displayName returns presentation string', () {
      expect(EngineCapacityUnit.cc.displayName, 'CC');
      expect(EngineCapacityUnit.litres.displayName, 'Litres');
    });

    test('shortName returns unit abbreviation', () {
      expect(EngineCapacityUnit.cc.shortName, 'cc');
      expect(EngineCapacityUnit.litres.shortName, 'L');
    });
  });

  group('EngineCapacityFormatter Tests', () {
    test('formats CC values correctly', () {
      expect(formatEngineCapacity(109, EngineCapacityUnit.cc), '109 cc');
      expect(formatEngineCapacity(200, EngineCapacityUnit.cc), '200 cc');
      expect(formatEngineCapacity(998, EngineCapacityUnit.cc), '998 cc');
    });

    test('formats Litres values correctly with decimal precision', () {
      expect(formatEngineCapacity(1.09, EngineCapacityUnit.litres), '1.09 L');
      expect(formatEngineCapacity(1.5, EngineCapacityUnit.litres), '1.5 L');
      expect(formatEngineCapacity(2.0, EngineCapacityUnit.litres), '2.0 L');
      expect(formatEngineCapacity(0.20, EngineCapacityUnit.litres), '0.2 L');
      expect(formatEngineCapacity(6.2, EngineCapacityUnit.litres), '6.2 L');
    });

    test('formats null capacity as Electric fallback', () {
      expect(formatEngineCapacity(null), 'Electric');
      expect(formatEngineCapacity(null, null, 'N/A'), 'N/A');
    });

    test('conversions between CC and Litres are accurate', () {
      expect(ccToLitres(109), closeTo(0.109, 0.0001));
      expect(ccToLitres(1000), 1.0);
      expect(litresToCc(1.09), closeTo(1090.0, 0.0001));
      expect(litresToCc(1.5), 1500.0);
    });

    test('formatVehicle helper works for vehicle instances', () {
      final v1 = Vehicle(
        brand: VehicleBrand.honda,
        model: 'Activa 5G',
        manufacturingYear: 2019,
        odometerReading: 25000,
        registrationNumber: 'KL 10 AB 1234',
        color: 'White',
        fuelType: 'Petrol',
        engineCapacity: 109,
        engineCapacityUnit: EngineCapacityUnit.cc,
        purchaseDate: DateTime(2019),
      );
      expect(EngineCapacityFormatter.formatVehicle(v1), '109 cc');

      final v2 = Vehicle(
        brand: VehicleBrand.ktm,
        model: 'Duke 200',
        manufacturingYear: 2022,
        odometerReading: 15000,
        registrationNumber: 'KL 08 GH 1357',
        color: 'Orange',
        fuelType: 'Petrol',
        engineCapacity: 0.20,
        engineCapacityUnit: EngineCapacityUnit.litres,
        purchaseDate: DateTime(2022),
      );
      expect(EngineCapacityFormatter.formatVehicle(v2), '0.2 L');
    });
  });

  group('validateEngineCapacity Validator Tests', () {
    test('Electric vehicles bypass validation', () {
      expect(
        validateEngineCapacity(null, isElectric: true),
        isNull,
      );
      expect(
        validateEngineCapacity('', isElectric: true),
        isNull,
      );
    });

    test('CC validation: valid values', () {
      expect(
        validateEngineCapacity('109',
            isElectric: false, unit: EngineCapacityUnit.cc),
        isNull,
      );
      expect(
        validateEngineCapacity('125',
            isElectric: false, unit: EngineCapacityUnit.cc),
        isNull,
      );
      expect(
        validateEngineCapacity('1998',
            isElectric: false, unit: EngineCapacityUnit.cc),
        isNull,
      );
    });

    test('CC validation: invalid values', () {
      expect(
        validateEngineCapacity('',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Engine capacity is required.',
      );
      expect(
        validateEngineCapacity('0',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Engine capacity must be greater than 0.',
      );
      expect(
        validateEngineCapacity('-109',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Engine capacity must be greater than 0.',
      );
      expect(
        validateEngineCapacity('abc',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Please enter a valid engine capacity in CC.',
      );
      expect(
        validateEngineCapacity('1.09',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Please enter a valid engine capacity in CC.',
      );
      expect(
        validateEngineCapacity('15000',
            isElectric: false, unit: EngineCapacityUnit.cc),
        'Enter a realistic engine capacity (max 10000 cc).',
      );
    });

    test('Litres validation: valid decimal values', () {
      expect(
        validateEngineCapacity('1.09',
            isElectric: false, unit: EngineCapacityUnit.litres),
        isNull,
      );
      expect(
        validateEngineCapacity('0.11',
            isElectric: false, unit: EngineCapacityUnit.litres),
        isNull,
      );
      expect(
        validateEngineCapacity('1.5',
            isElectric: false, unit: EngineCapacityUnit.litres),
        isNull,
      );
      expect(
        validateEngineCapacity('2.0',
            isElectric: false, unit: EngineCapacityUnit.litres),
        isNull,
      );
      expect(
        validateEngineCapacity('6.2',
            isElectric: false, unit: EngineCapacityUnit.litres),
        isNull,
      );
    });

    test('Litres validation: invalid values and precision limits', () {
      expect(
        validateEngineCapacity('',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Engine capacity is required.',
      );
      expect(
        validateEngineCapacity('0',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Engine capacity must be greater than 0.',
      );
      expect(
        validateEngineCapacity('-1.5',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Engine capacity must be greater than 0.',
      );
      expect(
        validateEngineCapacity('abc',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Please enter a valid engine capacity in litres.',
      );
      expect(
        validateEngineCapacity('1.234',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Engine capacity in litres can have at most 2 decimal places.',
      );
      expect(
        validateEngineCapacity('15.0',
            isElectric: false, unit: EngineCapacityUnit.litres),
        'Enter a realistic engine capacity (max 12 L).',
      );
    });
  });

  group('Hive Persistence & Engine Capacity Unit Storage Tests', () {
    late Directory tempDir;
    late Box<Vehicle> vehicleBox;
    late Box<dynamic> settingsBox;

    setUpAll(() {
      registerHiveAdapters();
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_engine_test_');
      Hive.init(tempDir.path);
      vehicleBox = await Hive.openBox<Vehicle>(HiveBoxes.vehicles);
      settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Stores and retrieves vehicles with CC and Litres units persistently',
        () async {
      final dataSource = HiveVehicleLocalDataSource(
        vehicleBox: vehicleBox,
        settingsBox: settingsBox,
      );
      final repository = VehiclesRepository(localDataSource: dataSource);

      final vCC = Vehicle(
        id: 'veh_cc',
        brand: VehicleBrand.honda,
        model: 'Activa 6G',
        manufacturingYear: 2022,
        odometerReading: 12000,
        registrationNumber: 'KL 10 AB 1234',
        color: 'Blue',
        fuelType: 'Petrol',
        engineCapacity: 109,
        engineCapacityUnit: EngineCapacityUnit.cc,
        purchaseDate: DateTime(2022, 1, 1),
      );

      final vLitres = Vehicle(
        id: 'veh_litres',
        brand: VehicleBrand.ktm,
        model: 'Duke 390',
        manufacturingYear: 2023,
        odometerReading: 6000,
        registrationNumber: 'KL 07 CD 5678',
        color: 'Orange',
        fuelType: 'Petrol',
        engineCapacity: 0.39,
        engineCapacityUnit: EngineCapacityUnit.litres,
        purchaseDate: DateTime(2023, 1, 1),
      );

      await repository.add(vCC);
      await repository.add(vLitres);

      final fetchedCC = repository.getById('veh_cc');
      expect(fetchedCC, isNotNull);
      expect(fetchedCC!.engineCapacity, 109.0);
      expect(fetchedCC.engineCapacityUnit, EngineCapacityUnit.cc);

      final fetchedLitres = repository.getById('veh_litres');
      expect(fetchedLitres, isNotNull);
      expect(fetchedLitres!.engineCapacity, 0.39);
      expect(fetchedLitres.engineCapacityUnit, EngineCapacityUnit.litres);
    });

    test('Backward compatibility: defaults legacy records without unit to CC',
        () async {
      final dataSource = HiveVehicleLocalDataSource(
        vehicleBox: vehicleBox,
        settingsBox: settingsBox,
      );
      final repository = VehiclesRepository(localDataSource: dataSource);

      final legacyVehicle = Vehicle(
        id: 'legacy_veh',
        brand: VehicleBrand.hero,
        model: 'Splendor',
        manufacturingYear: 2020,
        odometerReading: 15000,
        registrationNumber: 'KL 11 EF 9999',
        color: 'Black',
        fuelType: 'Petrol',
        engineCapacity: 97,
        purchaseDate: DateTime(2020, 1, 1),
      );

      await repository.add(legacyVehicle);

      final retrieved = repository.getById('legacy_veh');
      expect(retrieved, isNotNull);
      expect(retrieved!.engineCapacity, 97.0);
      expect(retrieved.engineCapacityUnit, EngineCapacityUnit.cc);
    });
  });

  group('AddVehicleScreen & VehicleDetailsScreen Unit Selector Widget Tests', () {
    testWidgets(
        'AddVehicleScreen shows CC and Litres SegmentedButton and defaults to CC',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicleDataSource = FakeVehicleLocalDataSource();
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
          ],
          child: const MaterialApp(
            home: AddVehicleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify SegmentedButton exists
      expect(find.byType(SegmentedButton<EngineCapacityUnit>), findsOneWidget);
      expect(find.text('CC'), findsOneWidget);
      expect(find.text('Litres'), findsOneWidget);
      expect(find.text('cc'), findsOneWidget); // suffixText

      // Switch to Litres
      await tester.ensureVisible(find.text('Litres'));
      await tester.tap(find.text('Litres'));
      await tester.pumpAndSettle();

      expect(find.text('L'), findsOneWidget); // updated suffixText
      expect(find.widgetWithText(TextFormField, 'Engine Capacity *'),
          findsOneWidget);
    });

    testWidgets(
        'Add vehicle with Litres unit saves vehicle properly to repository',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicleDataSource = FakeVehicleLocalDataSource();
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
          ],
          child: const MaterialApp(
            initialRoute: AppRoutes.root,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Add Vehicle screen from FloatingActionButton
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill brand
      await tester.tap(find.byType(SearchableBrandPicker));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('brand_search_field')), 'KTM');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'KTM'));
      await tester.pumpAndSettle();

      // Model
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Model *'), 'Duke 200');

      // Manufacturing Year
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Manufacturing Year *'), '2023');

      // Registration Number
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration Number *'),
          'KL 07 GH 1234');

      // Color
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Color *'), 'Orange');

      // Fuel Type
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Petrol').last);
      await tester.pumpAndSettle();

      // Switch Engine Capacity Unit to Litres
      await tester.ensureVisible(find.text('Litres'));
      await tester.tap(find.text('Litres'));
      await tester.pumpAndSettle();

      // Enter Litres value
      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Engine Capacity *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Engine Capacity *'), '1.09');

      // Purchase Date
      await tester.ensureVisible(find.byType(DatePickerField).first);
      await tester.tap(find.byType(DatePickerField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Odometer
      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Current Odometer *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Current Odometer *'), '5000');

      // Save Vehicle
      await tester.ensureVisible(find.text('Save Vehicle'));
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      // Verify stored vehicle in repository
      final savedVehicles = fakeVehicleDataSource.getVehicles();
      expect(savedVehicles.length, 1);
      expect(savedVehicles.first.model, 'Duke 200');
      expect(savedVehicles.first.engineCapacity, 1.09);
      expect(savedVehicles.first.engineCapacityUnit, EngineCapacityUnit.litres);
    });

    testWidgets(
        'VehicleDetailsScreen displays formatted Engine Capacity for Litres and CC',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicleDataSource = FakeVehicleLocalDataSource();
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();

      final vehicleLitres = Vehicle(
        id: 'test_duke',
        brand: VehicleBrand.ktm,
        model: 'Duke 200',
        manufacturingYear: 2023,
        odometerReading: 5000,
        registrationNumber: 'KL 07 GH 1234',
        color: 'Orange',
        fuelType: 'Petrol',
        engineCapacity: 1.09,
        engineCapacityUnit: EngineCapacityUnit.litres,
        purchaseDate: DateTime(2023, 1, 1),
      );
      await fakeVehicleDataSource.addVehicle(vehicleLitres);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
          ],
          child: const MaterialApp(
            home: VehicleDetailsScreen(vehicleId: 'test_duke'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify vehicle model appears in AppBar and header card
      expect(find.text('Duke 200'), findsNWidgets(2));

      // Scroll down to engine section and verify formatted '1.09 L'
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.text('1.09 L'), findsOneWidget);
    });
  });
}
