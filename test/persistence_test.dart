import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';

void main() {
  late Directory tempDir;
  late Box<Vehicle> vehicleBox;
  late Box<VehicleRecord> recordBox;
  late Box<dynamic> settingsBox;

  setUpAll(() {
    registerHiveAdapters();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    vehicleBox = await Hive.openBox<Vehicle>(HiveBoxes.vehicles);
    recordBox = await Hive.openBox<VehicleRecord>(HiveBoxes.vehicleRecords);
    settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveVehicleLocalDataSource & VehiclesRepository Tests', () {
    test('addVehicle, getVehicles, and getById work persistently', () async {
      final dataSource = HiveVehicleLocalDataSource(
        vehicleBox: vehicleBox,
        settingsBox: settingsBox,
      );
      final repository = VehiclesRepository(localDataSource: dataSource);

      final vehicle = Vehicle(
        id: 'test_veh_1',
        brand: VehicleBrand.honda,
        model: 'Activa 6G',
        manufacturingYear: 2022,
        odometerReading: 12500,
        registrationNumber: 'KL 01 ZZ 9999',
        color: 'Black',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2022, 1, 1),
      );

      await repository.add(vehicle);

      final all = repository.getAll();
      expect(all.length, 1);
      expect(all.first.model, 'Activa 6G');

      final fetched = repository.getById('test_veh_1');
      expect(fetched, isNotNull);
      expect(fetched!.registrationNumber, 'KL 01 ZZ 9999');
    });

    test('updateVehicle updates stored fields including lastAccessedAt', () async {
      final dataSource = HiveVehicleLocalDataSource(
        vehicleBox: vehicleBox,
        settingsBox: settingsBox,
      );
      final repository = VehiclesRepository(localDataSource: dataSource);

      final vehicle = Vehicle(
        id: 'test_veh_2',
        brand: VehicleBrand.ktm,
        model: 'Duke 390',
        manufacturingYear: 2023,
        odometerReading: 5000,
        registrationNumber: 'KL 07 AA 1111',
        color: 'Orange',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2023, 5, 10),
      );

      await repository.add(vehicle);

      final accessTime = DateTime(2026, 8, 20, 10, 30);
      final updated = vehicle.copyWith(
        odometerReading: 5500,
        lastAccessedAt: accessTime,
      );

      await repository.update(updated);

      final retrieved = repository.getById('test_veh_2');
      expect(retrieved!.odometerReading, 5500);
      expect(retrieved.lastAccessedAt, accessTime);
    });

    test('seedInitialVehicles seeds only once', () async {
      final dataSource = HiveVehicleLocalDataSource(
        vehicleBox: vehicleBox,
        settingsBox: settingsBox,
      );

      final mockVehicles = [
        Vehicle(
          id: 'mock_1',
          brand: VehicleBrand.hero,
          model: 'Splendor',
          manufacturingYear: 2020,
          odometerReading: 10000,
          registrationNumber: 'KL 10 BB 2222',
          color: 'Blue',
          fuelType: 'Petrol',
          purchaseDate: DateTime(2020, 1, 1),
        ),
      ];

      await dataSource.seedInitialVehicles(mockVehicles);
      expect(dataSource.getVehicles().length, 1);

      // Delete the vehicle
      await dataSource.deleteVehicle('mock_1');
      expect(dataSource.getVehicles().length, 0);

      // Re-running seed should NOT recreate it because is_seeded is true
      await dataSource.seedInitialVehicles(mockVehicles);
      expect(dataSource.getVehicles().length, 0);
    });
  });

  group('HiveVehicleRecordLocalDataSource & VehicleRecordsRepository Tests', () {
    test('stores and retrieves polymorphic vehicle records', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);
      final repository = VehicleRecordsRepository(localDataSource: dataSource);

      final now = DateTime.now();

      final odoRecord = OdometerRecord.create(
        vehicleId: 'veh_x',
        date: now.subtract(const Duration(days: 2)),
        odometer: 15000,
      );

      final fuelRecord = FuelRecord.create(
        vehicleId: 'veh_x',
        date: now.subtract(const Duration(days: 1)),
        quantity: 10.5,
        cost: 1100,
        odometerReading: 15200,
      );

      final serviceRecord = ServiceRecord.create(
        vehicleId: 'veh_x',
        date: now,
        serviceType: ServiceType.oilService,
        description: 'Oil and filter replacement',
        cost: 750,
      );

      final oilRecord = OilChangeRecord.create(
        vehicleId: 'veh_x',
        date: now,
        odometerReading: 15000,
        oilType: '10W-40',
        quantity: 1.0,
        cost: 650,
      );

      await repository.addRecord(odoRecord);
      await repository.addRecord(fuelRecord);
      await repository.addRecord(serviceRecord);
      await repository.addRecord(oilRecord);

      final allRecords = repository.getAllRecords('veh_x');
      expect(allRecords.length, 4);

      expect(repository.getOdometerRecords('veh_x').length, 1);
      expect(repository.getFuelRecords('veh_x').length, 1);
      expect(repository.getServiceRecords('veh_x').length, 1);
      expect(repository.getOilChangeRecords('veh_x').length, 1);
    });

    test('deleteRecordsForVehicle cascades cleanly', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);
      final repository = VehicleRecordsRepository(localDataSource: dataSource);

      await repository.addRecord(
        OdometerRecord.create(
          vehicleId: 'veh_A',
          date: DateTime.now(),
          odometer: 1000,
        ),
      );
      await repository.addRecord(
        OdometerRecord.create(
          vehicleId: 'veh_B',
          date: DateTime.now(),
          odometer: 2000,
        ),
      );

      expect(repository.getAllRecords('veh_A').length, 1);
      expect(repository.getAllRecords('veh_B').length, 1);

      await repository.deleteRecordsForVehicle('veh_A');

      expect(repository.getAllRecords('veh_A').length, 0);
      expect(repository.getAllRecords('veh_B').length, 1);
    });
  });
}
