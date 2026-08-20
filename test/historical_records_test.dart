import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/data/sample_vehicle_records.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/services/vehicle_usage_analytics.dart';
import 'package:odomex/features/vehicle_records/utils/odometer_consistency_validator.dart';

void main() {
  group('VehicleUsageAnalytics Tests', () {
    final now = DateTime(2026, 8, 20);

    final records = [
      OdometerRecord(
        id: '1',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 30)),
        odometer: 10000,
      ),
      FuelRecord(
        id: '2',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 20)),
        quantity: 10.0,
        cost: 1000.0, // 100/L
        odometerReading: 10500, // +500 km
      ),
      OilChangeRecord(
        id: '3',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 15)),
        odometerReading: 10750,
        cost: 650.0,
      ),
      ServiceRecord(
        id: '4',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 10)),
        serviceType: ServiceType.generalService,
        description: 'Brake check',
        cost: 1200.0,
        odometerReading: 10900,
      ),
      FuelRecord(
        id: '5',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 5)),
        quantity: 10.0,
        cost: 1050.0, // 105/L
        odometerReading: 11000, // +500 km on 10L = 50 km/L
      ),
    ];

    test('calculateTotalDistance calculates total span correctly', () {
      final total = VehicleUsageAnalytics.calculateTotalDistance(records);
      expect(total, 1000.0); // 11000 - 10000
    });

    test('calculateFuelAnalytics computes litres, cost, and efficiency', () {
      final fuelStats = VehicleUsageAnalytics.calculateFuelAnalytics(records);
      expect(fuelStats.totalLitres, 20.0);
      expect(fuelStats.totalCost, 2050.0);
      expect(fuelStats.averagePricePerLitre, 102.5);
      expect(fuelStats.refillCount, 2);
      expect(fuelStats.estimatedKmPerLitre, 50.0); // 500km / 10L
    });

    test('calculateMaintenanceAnalytics computes service and oil spend', () {
      final maint = VehicleUsageAnalytics.calculateMaintenanceAnalytics(records);
      expect(maint.totalServiceCost, 1200.0);
      expect(maint.totalOilChangeCost, 650.0);
      expect(maint.totalMaintenanceCost, 1850.0);
      expect(maint.serviceCount, 1);
      expect(maint.oilChangeCount, 1);
    });

    test('getRecordsByDateRange filters accurately', () {
      final rangeRecords = VehicleUsageAnalytics.getRecordsByDateRange(
        records: records,
        startDate: now.subtract(const Duration(days: 18)),
        endDate: now.subtract(const Duration(days: 8)),
      );
      expect(rangeRecords.length, 2); // items 3 & 4
    });
  });

  group('OdometerConsistencyValidator Tests', () {
    final now = DateTime(2026, 8, 20);

    final existingRecords = [
      OdometerRecord(
        id: '1',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 10)),
        odometer: 10000,
      ),
      OdometerRecord(
        id: '2',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 2)),
        odometer: 10500,
      ),
    ];

    test('accepts valid in-between and latest readings', () {
      // In-between
      final res1 = OdometerConsistencyValidator.validate(
        newOdometer: 10250,
        newDate: now.subtract(const Duration(days: 5)),
        existingRecords: existingRecords,
      );
      expect(res1.isValid, isTrue);

      // Latest
      final res2 = OdometerConsistencyValidator.validate(
        newOdometer: 10600,
        newDate: now,
        existingRecords: existingRecords,
      );
      expect(res2.isValid, isTrue);
    });

    test('rejects readings lower than previous historical reading', () {
      final res = OdometerConsistencyValidator.validate(
        newOdometer: 9800,
        newDate: now.subtract(const Duration(days: 5)),
        existingRecords: existingRecords,
      );
      expect(res.isValid, isFalse);
      expect(res.status, OdometerConsistencyStatus.lessThanPrevious);
    });

    test('rejects readings higher than subsequent historical reading', () {
      final res = OdometerConsistencyValidator.validate(
        newOdometer: 10800,
        newDate: now.subtract(const Duration(days: 5)),
        existingRecords: existingRecords,
      );
      expect(res.isValid, isFalse);
      expect(res.status, OdometerConsistencyStatus.greaterThanSubsequent);
    });
  });

  group('SampleVehicleRecords Integrity Tests', () {
    test('sample records are logically increasing in odometer per vehicle', () {
      final sample = SampleVehicleRecords.records;
      final byVehicle = <String, List<VehicleRecord>>{};

      for (final r in sample) {
        byVehicle.putIfAbsent(r.vehicleId, () => []).add(r);
      }

      for (final entry in byVehicle.entries) {
        final records = entry.value..sort((a, b) => a.date.compareTo(b.date));

        double lastOdo = 0;
        for (final r in records) {
          double? odo;
          switch (r) {
            case OdometerRecord():
              odo = r.odometer;
            case FuelRecord():
              odo = r.odometerReading;
            case ServiceRecord():
              odo = r.odometerReading;
            case OilChangeRecord():
              odo = r.odometerReading;
          }
          if (odo != null) {
            expect(odo >= lastOdo, isTrue,
                reason: 'Odometer for ${entry.key} decreased at ${r.date}');
            lastOdo = odo;
          }
        }
      }
    });
  });
}
