import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/features/demo/services/demo_data_seeder.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

import 'smart_autofill_and_fuel_calculation_test.dart' show FakeSmartVehicleDataSource, FakeSmartRecordDataSource;

void main() {
  group('Demo Data Flow Tests', () {
    late VehiclesRepository vehicleRepo;
    late VehicleRecordsRepository recordsRepo;

    setUp(() {
      vehicleRepo = VehiclesRepository(
        localDataSource: FakeSmartVehicleDataSource(),
      );
      recordsRepo = VehicleRecordsRepository(
        localDataSource: FakeSmartRecordDataSource(),
      );
    });

    test('isDemo defaults to false for standard vehicles', () {
      final vehicle = Vehicle(
        brand: VehicleBrand.honda,
        model: 'Civic',
        manufacturingYear: 2020,
        odometerReading: 15000,
        registrationNumber: 'AB01C1234',
        color: 'White',
        fuelType: 'Petrol',
        purchaseDate: DateTime.now(),
      );
      expect(vehicle.isDemo, false);
    });

    test('Seed Demo Data idempotency', () async {
      // Seed once
      await DemoDataSeeder.seedDemoData(vehicleRepo, recordsRepo);
      
      final vehiclesAfterFirstSeed = vehicleRepo.getAll();
      expect(vehiclesAfterFirstSeed.length, 1);
      final demoVehicle = vehiclesAfterFirstSeed.first;
      expect(demoVehicle.isDemo, true);
      expect(demoVehicle.model, 'Activa 5G');

      final records = recordsRepo.getAllRecords(demoVehicle.id);
      expect(records.isNotEmpty, true);

      // Seed again
      await DemoDataSeeder.seedDemoData(vehicleRepo, recordsRepo);

      final vehiclesAfterSecondSeed = vehicleRepo.getAll();
      // Should still be exactly 1 vehicle
      expect(vehiclesAfterSecondSeed.length, 1);
    });

    test('Remove Demo Data leaves real vehicles untouched', () async {
      // Add a real vehicle
      final realVehicle = Vehicle(
        brand: VehicleBrand.toyota,
        model: 'Corolla',
        manufacturingYear: 2020,
        odometerReading: 20000,
        registrationNumber: 'KA01B1234',
        color: 'Black',
        fuelType: 'Diesel',
        purchaseDate: DateTime.now(),
      );
      await vehicleRepo.add(realVehicle);

      // Seed demo
      await DemoDataSeeder.seedDemoData(vehicleRepo, recordsRepo);
      expect(vehicleRepo.getAll().length, 2);

      // Remove demo
      await DemoDataSeeder.removeDemoData(vehicleRepo, recordsRepo);

      // Only real vehicle should remain
      final remainingVehicles = vehicleRepo.getAll();
      expect(remainingVehicles.length, 1);
      expect(remainingVehicles.first.isDemo, false);
      expect(remainingVehicles.first.model, 'Corolla');
    });
  });
}
