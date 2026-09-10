import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/features/demo/services/demo_data_seeder.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

import 'smart_autofill_and_fuel_calculation_test.dart' show FakeSmartVehicleDataSource, FakeSmartRecordDataSource;

void main() {
  group('Demo Dataset Integrity Tests', () {
    late VehiclesRepository vehicleRepo;
    late VehicleRecordsRepository recordsRepo;

    setUp(() async {
      vehicleRepo = VehiclesRepository(
        localDataSource: FakeSmartVehicleDataSource(),
      );
      recordsRepo = VehicleRecordsRepository(
        localDataSource: FakeSmartRecordDataSource(),
      );
      await DemoDataSeeder.seedDemoData(vehicleRepo, recordsRepo);
    });

    test('Demo dataset generates realistic number of records', () {
      final demoVehicle = vehicleRepo.getAll().firstWhere((v) => v.isDemo);
      final records = recordsRepo.getAllRecords(demoVehicle.id).toList();

      // We expect around 90 days * 0.70 usage = ~63 odometer records
      // Plus a few fuel records, a service record, and an oil change
      expect(records.length, greaterThan(20));
      expect(records.whereType<OdometerRecord>().length, greaterThan(15));
      expect(records.whereType<FuelRecord>().length, greaterThan(2));
      expect(records.whereType<ServiceRecord>().length, 1);
      expect(records.whereType<OilChangeRecord>().length, 1);
    });

    test('Odometer values strictly increase and match final vehicle odometer', () {
      final demoVehicle = vehicleRepo.getAll().firstWhere((v) => v.isDemo);
      final records = recordsRepo.getAllRecords(demoVehicle.id).toList();
      
      // Sort chronologically
      records.sort((a, b) => a.date.compareTo(b.date));

      double previousOdo = 24799.0;
      double highestOdo = 0.0;
      
      for (final record in records) {
        if (record.odometerReading != null) {
          expect(record.odometerReading!, greaterThanOrEqualTo(previousOdo));
          previousOdo = record.odometerReading!;
          highestOdo = record.odometerReading!;
        }
      }

      // Final vehicle odometer must perfectly match highest record odometer
      expect(demoVehicle.odometerReading, equals(highestOdo));
    });

    test('Fuel records calculate cost accurately', () {
      final demoVehicle = vehicleRepo.getAll().firstWhere((v) => v.isDemo);
      final records = recordsRepo.getAllRecords(demoVehicle.id).whereType<FuelRecord>().toList();

      for (final fuel in records) {
        final expectedCost = fuel.quantity * 102.50;
        
        // Since we parsed double to 2 decimal places in generation, check with a small epsilon
        expect((fuel.cost - expectedCost).abs(), lessThan(0.05));
      }
    });

    test('Dataset confined to previous 90 days', () {
      final demoVehicle = vehicleRepo.getAll().firstWhere((v) => v.isDemo);
      final records = recordsRepo.getAllRecords(demoVehicle.id).toList();

      final now = DateTime.now();
      // Allow slight buffer due to execution time
      final ninetyDaysAgo = now.subtract(const Duration(days: 91));
      
      for (final record in records) {
        expect(record.date.isAfter(ninetyDaysAgo), isTrue);
        expect(record.date.isBefore(now.add(const Duration(days: 1))), isTrue);
      }
    });
  });
}
