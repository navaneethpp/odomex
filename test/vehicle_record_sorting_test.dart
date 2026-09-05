import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

void main() {
  late Directory tempDir;
  late Box<VehicleRecord> recordBox;

  setUpAll(() {
    registerHiveAdapters();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_sort_test_');
    Hive.init(tempDir.path);
    recordBox = await Hive.openBox<VehicleRecord>(HiveBoxes.vehicleRecords);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('VehicleRecord Sorting Tests', () {
    test('Test 1 - Basic ordering: Newest to oldest date', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);

      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 1),
          odometer: 1000,
        ),
      );
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_2',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5),
          odometer: 1040,
        ),
      );
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_3',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 3),
          odometer: 1020,
        ),
      );

      final records = dataSource.getAllRecords('v1');
      expect(records.length, 3);
      expect(records[0].date.day, 5);
      expect(records[1].date.day, 3);
      expect(records[2].date.day, 1);
    });

    test('Test 2 - Same day with different times', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);

      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 9, 0),
          odometer: 1000,
        ),
      );
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_2',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 14, 0),
          odometer: 1040,
        ),
      );
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_3',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 11, 0),
          odometer: 1020,
        ),
      );

      final records = dataSource.getAllRecords('v1');
      expect(records[0].date.hour, 14);
      expect(records[1].date.hour, 11);
      expect(records[2].date.hour, 9);
    });

    test('Test 3 - Mixed record types', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);

      await dataSource.addRecord(
        FuelRecord(
          id: 'fuel_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 14, 0),
          quantity: 10,
          cost: 1000,
        ),
      );
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 10, 0),
          odometer: 1000,
        ),
      );
      await dataSource.addRecord(
        ServiceRecord(
          id: 'svc_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 12, 0),
          serviceType: ServiceType.other,
          description: '',
        ),
      );
      await dataSource.addRecord(
        OilChangeRecord(
          id: 'oil_1',
          vehicleId: 'v1',
          date: DateTime(2026, 9, 5, 9, 0),
          odometerReading: 1000,
        ),
      );

      final records = dataSource.getAllRecords('v1');
      expect(records[0] is FuelRecord, true);
      expect(records[1] is ServiceRecord, true);
      expect(records[2] is OdometerRecord, true);
      expect(records[3] is OilChangeRecord, true);
    });

    test('Test 4 - Same exact date falls back to createdAt deterministic sort', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);

      final exactDate = DateTime(2026, 9, 5, 10, 0);

      // Oldest created
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_1',
          vehicleId: 'v1',
          date: exactDate,
          createdAt: DateTime(2026, 9, 5, 10, 5),
          odometer: 1000,
        ),
      );
      // Newest created
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_2',
          vehicleId: 'v1',
          date: exactDate,
          createdAt: DateTime(2026, 9, 5, 10, 20),
          odometer: 1000,
        ),
      );
      // Middle created
      await dataSource.addRecord(
        OdometerRecord(
          id: 'odo_3',
          vehicleId: 'v1',
          date: exactDate,
          createdAt: DateTime(2026, 9, 5, 10, 15),
          odometer: 1000,
        ),
      );

      final records = dataSource.getAllRecords('v1');
      // odo_2 is newest created, then odo_3, then odo_1
      expect(records[0].id, 'odo_2');
      expect(records[1].id, 'odo_3');
      expect(records[2].id, 'odo_1');
    });
    
    test('Test 9 - Multiple vehicles', () async {
      final dataSource = HiveVehicleRecordLocalDataSource(recordBox: recordBox);

      // Vehicle 1
      await dataSource.addRecord(
        OdometerRecord(id: 'odo_v1_1', vehicleId: 'v1', date: DateTime(2026, 9, 5, 10), odometer: 100),
      );
      await dataSource.addRecord(
        OdometerRecord(id: 'odo_v1_2', vehicleId: 'v1', date: DateTime(2026, 9, 5, 14), odometer: 200),
      );

      // Vehicle 2
      await dataSource.addRecord(
        OdometerRecord(id: 'odo_v2_1', vehicleId: 'v2', date: DateTime(2026, 9, 5, 16), odometer: 300),
      );
      await dataSource.addRecord(
        OdometerRecord(id: 'odo_v2_2', vehicleId: 'v2', date: DateTime(2026, 9, 5, 9), odometer: 400),
      );

      final recordsV1 = dataSource.getAllRecords('v1');
      expect(recordsV1.length, 2);
      expect(recordsV1[0].id, 'odo_v1_2');
      expect(recordsV1[1].id, 'odo_v1_1');

      final recordsV2 = dataSource.getAllRecords('v2');
      expect(recordsV2.length, 2);
      expect(recordsV2[0].id, 'odo_v2_1');
      expect(recordsV2[1].id, 'odo_v2_2');
    });
  });
}
