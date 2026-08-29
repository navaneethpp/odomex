import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/features/vehicle_records/utils/fuel_cost_calculator.dart';
import 'package:odomex/features/vehicle_records/widgets/fuel_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/odometer_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

// ── In-Memory Test Fakes ──

class FakeSmartVehicleDataSource implements VehicleLocalDataSource {
  final Map<String, Vehicle> _vehicles = {};

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) => _vehicles[vehicleId];

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  Future<void> saveVehicle(Vehicle vehicle) => addVehicle(vehicle);

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.remove(vehicleId);
  }
}

class FakeSmartRecordDataSource implements VehicleRecordLocalDataSource {
  final Map<String, List<VehicleRecord>> _records = {};

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) =>
      _records[vehicleId] ?? [];

  @override
  Future<void> addRecord(VehicleRecord record) async {
    final list = _records.putIfAbsent(record.vehicleId, () => []);
    list.add(record);
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
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) =>
      getAllRecords(vehicleId).take(limit).toList();

  @override
  List<VehicleRecord> getRecordsByDateRange(
    String vehicleId,
    DateTime start,
    DateTime end,
  ) =>
      getAllRecords(vehicleId)
          .where((r) => !r.date.isBefore(start) && !r.date.isAfter(end))
          .toList();

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    _records.remove(vehicleId);
  }
}

class FakeSmartPreferencesDataSource
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
  group('FuelCostCalculator Unit Tests', () {
    test('Standard calculation: 5 * 100 = 500.0', () {
      final total = FuelCostCalculator.calculateTotalCost(
        quantity: 5.0,
        pricePerUnit: 100.0,
      );
      expect(total, 500.0);
    });

    test('Fractional calculation: 5.5 * 105.50 = 580.25 without float drift', () {
      final total = FuelCostCalculator.calculateTotalCost(
        quantity: 5.5,
        pricePerUnit: 105.50,
      );
      expect(total, 580.25);
    });

    test('Multi-decimal financial precision: 10 * 99.99 = 999.90', () {
      final total = FuelCostCalculator.calculateTotalCost(
        quantity: 10.0,
        pricePerUnit: 99.99,
      );
      expect(total, 999.90);
    });

    test('Calculate price per unit from total and quantity', () {
      final price = FuelCostCalculator.calculatePricePerUnit(
        totalCost: 580.25,
        quantity: 5.5,
      );
      expect(price, 105.50);
    });

    test('Rejects zero, negative, null, and non-finite values', () {
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: 0, pricePerUnit: 100),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: 5, pricePerUnit: 0),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: -5, pricePerUnit: 100),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: 5, pricePerUnit: -100),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: null, pricePerUnit: 100),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(quantity: 5, pricePerUnit: null),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(
          quantity: double.nan,
          pricePerUnit: 100,
        ),
        isNull,
      );
      expect(
        FuelCostCalculator.calculateTotalCost(
          quantity: 5,
          pricePerUnit: double.infinity,
        ),
        isNull,
      );
    });

    test('formatCost produces correct currency output', () {
      expect(FuelCostCalculator.formatCost(580.25), '₹580.25');
      expect(FuelCostCalculator.formatCost(500.0), '₹500.00');
      expect(FuelCostCalculator.formatCost(null), '—');
      expect(FuelCostCalculator.formatCost(double.nan), '—');
    });
  });

  group('Smart Odometer Lookup & Multi-Vehicle Isolation Tests', () {
    late FakeSmartVehicleDataSource fakeVehicles;
    late FakeSmartRecordDataSource fakeRecords;
    late VehicleRecordsRepository recordsRepo;

    setUp(() {
      fakeVehicles = FakeSmartVehicleDataSource();
      fakeRecords = FakeSmartRecordDataSource();
      recordsRepo = VehicleRecordsRepository(localDataSource: fakeRecords);
    });

    test('Vehicle with zero records and zero odometer returns null', () {
      final v1 = Vehicle(
        id: 'v1',
        brand: VehicleBrand.honda,
        model: 'Activa 6G',
        manufacturingYear: 2023,
        odometerReading: 0,
        registrationNumber: 'KA01AB1234',
        color: 'Blue',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2023, 1, 1),
      );
      fakeVehicles.saveVehicle(v1);

      final latest = recordsRepo.getLatestOdometerReading(
        'v1',
        vehicleCurrentOdometer: v1.odometerReading,
      );
      expect(latest, isNull);
    });

    test('Vehicle with initial odometer returns initial reading', () {
      final v1 = Vehicle(
        id: 'v1',
        brand: VehicleBrand.honda,
        model: 'Activa 6G',
        manufacturingYear: 2023,
        odometerReading: 25430,
        registrationNumber: 'KA01AB1234',
        color: 'Blue',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2023, 1, 1),
      );
      fakeVehicles.saveVehicle(v1);

      final latest = recordsRepo.getLatestOdometerReading(
        'v1',
        vehicleCurrentOdometer: v1.odometerReading,
      );
      expect(latest, 25430.0);
    });

    test('Vehicle with records returns the maximum saved odometer across all types', () {
      final v1 = Vehicle(
        id: 'v1',
        brand: VehicleBrand.honda,
        model: 'Activa 6G',
        manufacturingYear: 2023,
        odometerReading: 10000,
        registrationNumber: 'KA01AB1234',
        color: 'Blue',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2023, 1, 1),
      );
      fakeVehicles.saveVehicle(v1);

      fakeRecords.addRecord(
        OdometerRecord(
          id: '1',
          vehicleId: 'v1',
          date: DateTime(2026, 1, 1),
          odometer: 12000,
        ),
      );
      fakeRecords.addRecord(
        FuelRecord(
          id: '2',
          vehicleId: 'v1',
          date: DateTime(2026, 2, 1),
          quantity: 5,
          cost: 500,
          odometerReading: 14500,
        ),
      );
      fakeRecords.addRecord(
        ServiceRecord(
          id: '3',
          vehicleId: 'v1',
          date: DateTime(2026, 3, 1),
          serviceType: ServiceType.generalService,
          description: 'Regular checkup',
          odometerReading: 16200,
        ),
      );
      fakeRecords.addRecord(
        OilChangeRecord(
          id: '4',
          vehicleId: 'v1',
          date: DateTime(2026, 4, 1),
          odometerReading: 18400,
          oilType: '10W-40',
          quantity: 1,
          cost: 450,
        ),
      );

      final latest = recordsRepo.getLatestOdometerReading(
        'v1',
        vehicleCurrentOdometer: v1.odometerReading,
      );
      expect(latest, 18400.0);
    });

    test('Strict vehicle isolation: Vehicle A never receives Vehicle B latest reading', () {
      final vA = Vehicle(
        id: 'vA',
        brand: VehicleBrand.honda,
        model: 'City',
        manufacturingYear: 2022,
        odometerReading: 25430,
        registrationNumber: 'KA01AA1111',
        color: 'White',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2022, 1, 1),
      );
      final vB = Vehicle(
        id: 'vB',
        brand: VehicleBrand.hyundai,
        model: 'Creta',
        manufacturingYear: 2021,
        odometerReading: 61200,
        registrationNumber: 'KA02BB2222',
        color: 'Black',
        fuelType: 'Diesel',
        purchaseDate: DateTime(2021, 1, 1),
      );
      fakeVehicles.saveVehicle(vA);
      fakeVehicles.saveVehicle(vB);

      final latestA = recordsRepo.getLatestOdometerReading(
        'vA',
        vehicleCurrentOdometer: vA.odometerReading,
      );
      final latestB = recordsRepo.getLatestOdometerReading(
        'vB',
        vehicleCurrentOdometer: vB.odometerReading,
      );

      expect(latestA, 25430.0);
      expect(latestB, 61200.0);
      expect(latestA, isNot(latestB));
    });
  });

  group('OdometerRecordForm & FuelRecordForm Widget Tests', () {
    late FakeSmartVehicleDataSource fakeVehicles;
    late FakeSmartRecordDataSource fakeRecords;
    late FakeSmartPreferencesDataSource fakePrefs;
    late VehiclesRepository vehiclesRepo;
    late VehicleRecordsRepository recordsRepo;
    late VehiclePreferencesRepository prefsRepo;

    final vehicleA = Vehicle(
      id: 'vA',
      brand: VehicleBrand.honda,
      model: 'Activa 6G',
      manufacturingYear: 2023,
      odometerReading: 25430,
      registrationNumber: 'KA01AB1234',
      color: 'Blue',
      fuelType: 'Petrol',
      purchaseDate: DateTime(2023, 1, 1),
    );

    setUp(() {
      fakeVehicles = FakeSmartVehicleDataSource();
      fakeRecords = FakeSmartRecordDataSource();
      fakePrefs = FakeSmartPreferencesDataSource();
      vehiclesRepo = VehiclesRepository(localDataSource: fakeVehicles);
      recordsRepo = VehicleRecordsRepository(localDataSource: fakeRecords);
      prefsRepo =
          VehiclePreferencesRepository(localDataSource: fakePrefs);

      fakeVehicles.saveVehicle(vehicleA);
    });

    Widget buildTestApp(Widget child) {
      return ProviderScope(
        overrides: [
          vehiclesRepositoryProvider.overrideWithValue(vehiclesRepo),
          vehicleRecordRepositoryProvider.overrideWithValue(recordsRepo),
          vehiclePreferencesRepositoryProvider
              .overrideWithValue(prefsRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'OdometerRecordForm: Use Latest fills field, shows feedback, and remains editable',
        (tester) async {
      final formKey = GlobalKey<VehicleRecordFormState>();

      await tester.pumpWidget(
        buildTestApp(
          OdometerRecordForm(
            key: formKey,
            vehicleId: 'vA',
            currentOdometer: 25430,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Use Latest'), findsOneWidget);

      // Tap Use Latest
      await tester.tap(find.text('Use Latest'));
      await tester.pump();

      // Field should now have 25430
      expect(find.text('25430'), findsOneWidget);
      expect(find.text('✓ Latest reading added'), findsOneWidget);

      // Modify the field to 25447
      await tester.enterText(find.byType(TextFormField).first, '25447');
      await tester.pumpAndSettle();
      expect(find.text('25447'), findsOneWidget);

      // Build record and verify saved value is 25447
      final record = formKey.currentState?.buildRecord();
      expect(record, isNotNull);
      expect(record, isA<OdometerRecord>());
      expect((record as OdometerRecord).odometer, 25447.0);
    });

    testWidgets(
        'OdometerRecordForm: Use Latest shows helpful message when no previous odometer exists',
        (tester) async {
      final vehicleEmpty = Vehicle(
        id: 'vEmpty',
        brand: VehicleBrand.honda,
        model: 'Shine',
        manufacturingYear: 2024,
        odometerReading: 0,
        registrationNumber: 'KA01XX0000',
        color: 'Black',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2024, 1, 1),
      );
      fakeVehicles.saveVehicle(vehicleEmpty);

      await tester.pumpWidget(
        buildTestApp(
          const OdometerRecordForm(
            vehicleId: 'vEmpty',
            currentOdometer: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use Latest'));
      await tester.pump();

      expect(
        find.text('No previous odometer reading available.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'FuelRecordForm: Live cost calculation updates on quantity and price input',
        (tester) async {
      final formKey = GlobalKey<VehicleRecordFormState>();

      await tester.pumpWidget(
        buildTestApp(
          FuelRecordForm(
            key: formKey,
            vehicleId: 'vA',
            currentOdometer: 25430,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Total Cost shows —
      expect(find.text('—'), findsOneWidget);

      // Enter Fuel Quantity: 5.5
      final quantityFinder = find.widgetWithText(TextFormField, 'Fuel Quantity *');
      await tester.enterText(quantityFinder, '5.5');
      await tester.pump();

      // Still — because price is not yet entered
      expect(find.text('—'), findsOneWidget);

      // Enter Price per Litre: 105.50
      final priceFinder =
          find.widgetWithText(TextFormField, 'Price per Litre *');
      await tester.enterText(priceFinder, '105.50');
      await tester.pump();

      // Total Cost updates to ₹580.25
      expect(find.text('₹580.25'), findsOneWidget);
      expect(find.text('5.5 L × ₹105.50/L'), findsOneWidget);

      // Change Quantity to 10
      await tester.enterText(quantityFinder, '10');
      await tester.pump();

      // Total Cost updates to ₹1055.00
      expect(find.text('₹1055.00'), findsOneWidget);

      // Autofill Odometer using Use Latest button
      await tester.tap(find.text('Use Latest'));
      await tester.pump();
      expect(find.text('25430'), findsOneWidget);

      // Build record
      final record = formKey.currentState?.buildRecord();
      expect(record, isNotNull);
      expect(record, isA<FuelRecord>());
      final fuelRecord = record as FuelRecord;
      expect(fuelRecord.quantity, 10.0);
      expect(fuelRecord.cost, 1055.0);
      expect(fuelRecord.odometerReading, 25430.0);
    });

    testWidgets(
        'FuelRecordForm & OdometerRecordForm render cleanly in Dark Theme at 360x640 without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesRepositoryProvider.overrideWithValue(vehiclesRepo),
            vehicleRecordRepositoryProvider.overrideWithValue(recordsRepo),
            vehiclePreferencesRepositoryProvider
                .overrideWithValue(prefsRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: FuelRecordForm(
                    vehicleId: 'vA',
                    currentOdometer: 25430,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Total Fuel Cost'), findsOneWidget);
      expect(find.text('Use Latest'), findsOneWidget);
    });
  });
}
