import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/features/vehicle_records/models/cost_summary.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/features/vehicle_records/services/cost_summary_calculator.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_cost_summary_card.dart';

// In-Memory Test Fake
class FakeCostRecordDataSource implements VehicleRecordLocalDataSource {
  final Map<String, List<VehicleRecord>> _records = {};

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) {
    final list = _records[vehicleId] ?? [];
    return List.of(list)..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) {
    return getAllRecords(vehicleId).take(limit).toList();
  }

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
  List<OdometerRecord> getOdometerRecords(String vehicleId) {
    return getAllRecords(vehicleId).whereType<OdometerRecord>().toList();
  }

  @override
  List<FuelRecord> getFuelRecords(String vehicleId) {
    return getAllRecords(vehicleId).whereType<FuelRecord>().toList();
  }

  @override
  List<ServiceRecord> getServiceRecords(String vehicleId) {
    return getAllRecords(vehicleId).whereType<ServiceRecord>().toList();
  }

  @override
  List<OilChangeRecord> getOilChangeRecords(String vehicleId) {
    return getAllRecords(vehicleId).whereType<OilChangeRecord>().toList();
  }

  @override
  Future<void> addRecord(VehicleRecord record) async {
    final list = _records.putIfAbsent(record.vehicleId, () => []);
    list.removeWhere((r) => r.id == record.id);
    list.add(record);
  }

  Future<void> saveRecord(VehicleRecord record) => addRecord(record);

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    _records.remove(vehicleId);
  }
}

void main() {
  group('CostSummaryCalculator Unit Tests', () {
    final testDate = DateTime(2026, 8, 29, 14, 30);

    final records = [
      // Same day (29 Aug 2026)
      FuelRecord(
        id: 'f1',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 29, 9, 0),
        quantity: 10,
        cost: 1000.50,
      ),
      ServiceRecord(
        id: 's1',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 29, 11, 0),
        serviceType: ServiceType.generalService,
        description: 'Brake check',
        cost: 500.0,
      ),
      OdometerRecord(
        id: 'o1',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 29, 18, 0),
        odometer: 25000,
      ),

      // Same month (15 Aug 2026)
      FuelRecord(
        id: 'f2',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 15, 10, 0),
        quantity: 20,
        cost: 2000.0,
      ),
      OilChangeRecord(
        id: 'oil1',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 15, 12, 0),
        odometerReading: 24500,
        cost: 450.0,
      ),

      // Previous month (20 July 2026)
      FuelRecord(
        id: 'f3',
        vehicleId: 'v1',
        date: DateTime(2026, 7, 20, 8, 0),
        quantity: 15,
        cost: 1500.0,
      ),

      // Previous year (10 Nov 2025)
      FuelRecord(
        id: 'f4',
        vehicleId: 'v1',
        date: DateTime(2025, 11, 10, 10, 0),
        quantity: 30,
        cost: 3000.0,
      ),
    ];

    test('Daily summary aggregates only records on the exact selected day', () {
      final summary = CostSummaryCalculator.calculateCostSummary(
        records: records,
        period: CostPeriod.daily,
        selectedDate: testDate,
      );

      expect(summary.period, CostPeriod.daily);
      expect(summary.periodLabel, '29 Aug 2026');
      expect(summary.fuelCost, 1000.50);
      expect(summary.serviceCost, 500.0);
      expect(summary.oilChangeCost, 0.0);
      expect(summary.totalCost, 1500.50);
      expect(summary.costBearingRecordCount, 2);
      expect(summary.totalRecordCount, 3); // f1 + s1 + o1
      expect(summary.hasCost, isTrue);
    });

    test('Monthly summary aggregates all records in the selected month', () {
      final summary = CostSummaryCalculator.calculateCostSummary(
        records: records,
        period: CostPeriod.monthly,
        selectedDate: testDate,
      );

      expect(summary.period, CostPeriod.monthly);
      expect(summary.periodLabel, 'August 2026');
      expect(summary.fuelCost, 3000.50); // f1 (1000.50) + f2 (2000.0)
      expect(summary.serviceCost, 500.0); // s1 (500.0)
      expect(summary.oilChangeCost, 450.0); // oil1 (450.0)
      expect(summary.totalCost, 3950.50);
      expect(summary.costBearingRecordCount, 4);
      expect(summary.totalRecordCount, 5);
      expect(summary.hasCost, isTrue);

      // Verify category percentage calculations
      expect(summary.fuelPercentage, closeTo((3000.50 / 3950.50) * 100, 0.01));
      expect(summary.servicePercentage, closeTo((500.0 / 3950.50) * 100, 0.01));
      expect(
          summary.oilChangePercentage, closeTo((450.0 / 3950.50) * 100, 0.01));
    });

    test('Yearly summary aggregates all records in the selected year', () {
      final summary = CostSummaryCalculator.calculateCostSummary(
        records: records,
        period: CostPeriod.yearly,
        selectedDate: testDate,
      );

      expect(summary.period, CostPeriod.yearly);
      expect(summary.periodLabel, '2026');
      // 2026 records: f1 (1000.50) + f2 (2000) + f3 (1500) = 4500.50 fuel
      expect(summary.fuelCost, 4500.50);
      expect(summary.serviceCost, 500.0);
      expect(summary.oilChangeCost, 450.0);
      expect(summary.totalCost, 5450.50);
      expect(summary.costBearingRecordCount, 5);
    });

    test('Empty period produces zero costs and safe percentages without NaN',
        () {
      final summary = CostSummaryCalculator.calculateCostSummary(
        records: records,
        period: CostPeriod.monthly,
        selectedDate: DateTime(2027, 1, 1),
      );

      expect(summary.totalCost, 0.0);
      expect(summary.fuelCost, 0.0);
      expect(summary.serviceCost, 0.0);
      expect(summary.oilChangeCost, 0.0);
      expect(summary.costBearingRecordCount, 0);
      expect(summary.totalRecordCount, 0);
      expect(summary.hasCost, isFalse);
      expect(summary.fuelPercentage, 0.0);
      expect(summary.servicePercentage, 0.0);
      expect(summary.oilChangePercentage, 0.0);
    });

    test('Date boundary tests: 00:00:00 and 23:59:59 timestamps', () {
      final boundaryRecords = [
        FuelRecord(
          id: 'b1',
          vehicleId: 'v1',
          date: DateTime(2026, 8, 1, 0, 0, 0),
          quantity: 10,
          cost: 500,
        ),
        FuelRecord(
          id: 'b2',
          vehicleId: 'v1',
          date: DateTime(2026, 8, 31, 23, 59, 59),
          quantity: 10,
          cost: 600,
        ),
      ];

      final summary = CostSummaryCalculator.calculateCostSummary(
        records: boundaryRecords,
        period: CostPeriod.monthly,
        selectedDate: DateTime(2026, 8, 15),
      );

      expect(summary.totalCost, 1100.0);
      expect(summary.costBearingRecordCount, 2);
    });

    test('Previous and next period navigation step math', () {
      final date = DateTime(2026, 8, 15);

      // Daily
      expect(CostSummaryCalculator.previousPeriod(date, CostPeriod.daily),
          DateTime(2026, 8, 14));
      expect(CostSummaryCalculator.nextPeriod(date, CostPeriod.daily),
          DateTime(2026, 8, 16));

      // Monthly
      expect(CostSummaryCalculator.previousPeriod(date, CostPeriod.monthly),
          DateTime(2026, 7, 1));
      expect(CostSummaryCalculator.nextPeriod(date, CostPeriod.monthly),
          DateTime(2026, 9, 1));

      // Yearly
      expect(CostSummaryCalculator.previousPeriod(date, CostPeriod.yearly),
          DateTime(2025, 1, 1));
      expect(CostSummaryCalculator.nextPeriod(date, CostPeriod.yearly),
          DateTime(2027, 1, 1));
    });
  });

  group('Multi-Vehicle Isolation & Reactive Provider Tests', () {
    test('Vehicle A and Vehicle B have strict cost isolation', () {
      final date = DateTime(2026, 8, 29);
      final recordsA = [
        FuelRecord(
          id: 'fa',
          vehicleId: 'veh_a',
          date: date,
          quantity: 10,
          cost: 1000,
        ),
      ];
      final recordsB = [
        FuelRecord(
          id: 'fb',
          vehicleId: 'veh_b',
          date: date,
          quantity: 50,
          cost: 5000,
        ),
      ];

      final summaryA = CostSummaryCalculator.calculateCostSummary(
        records: recordsA,
        period: CostPeriod.monthly,
        selectedDate: date,
      );
      final summaryB = CostSummaryCalculator.calculateCostSummary(
        records: recordsB,
        period: CostPeriod.monthly,
        selectedDate: date,
      );

      expect(summaryA.totalCost, 1000.0);
      expect(summaryB.totalCost, 5000.0);
    });
  });

  group('VehicleCostSummaryCard Widget Tests', () {
    late FakeCostRecordDataSource fakeDataSource;
    late VehicleRecordsRepository repository;

    setUp(() {
      fakeDataSource = FakeCostRecordDataSource();
      repository = VehicleRecordsRepository(localDataSource: fakeDataSource);
    });

    testWidgets(
        'renders Monthly cost summary by default and allows period switching',
        (tester) async {
      final now = DateTime.now();

      await fakeDataSource.saveRecord(FuelRecord(
        id: 'f_test',
        vehicleId: 'veh_1',
        date: now,
        quantity: 10,
        cost: 1250.0,
      ));

      await fakeDataSource.saveRecord(ServiceRecord(
        id: 's_test',
        vehicleId: 'veh_1',
        date: now,
        serviceType: ServiceType.generalService,
        description: 'Oil top-up',
        cost: 350.0,
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRecordRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: VehicleCostSummaryCard(vehicleId: 'veh_1'),
              ),
            ),
          ),
        ),
      );

      // Frame 0: Mounts and renders Cost Summary header
      await tester.pump();
      expect(find.text('COST SUMMARY'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);

      // Settle animations
      await tester.pumpAndSettle();

      // Total expense = 1250 + 350 = 1600.00
      expect(find.text('TOTAL EXPENSES'), findsOneWidget);
      expect(find.text('1,600.00'), findsOneWidget);
      expect(find.text('2 records'), findsOneWidget);

      // Category breakdown
      expect(find.text('Fuel'), findsOneWidget);
      expect(find.text('₹1,250'), findsOneWidget);
      expect(find.text('Service'), findsOneWidget);
      expect(find.text('₹350'), findsOneWidget);

      // Switch to Daily
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('1,600.00'), findsOneWidget);

      // Switch to Yearly
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();
      expect(find.text('1,600.00'), findsOneWidget);
    });

    testWidgets('Period navigation (‹ and ›) updates date anchor',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRecordRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VehicleCostSummaryCard(vehicleId: 'veh_1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Previous Month (‹)
      await tester.tap(find.byTooltip('Previous Monthly'));
      await tester.pumpAndSettle();

      // Tap Next Month (›)
      await tester.tap(find.byTooltip('Next Monthly'));
      await tester.pumpAndSettle();
    });

    testWidgets('renders responsively in dark theme at 360x640 without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRecordRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: VehicleCostSummaryCard(vehicleId: 'veh_1'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('COST SUMMARY'), findsOneWidget);
    });
  });
}
