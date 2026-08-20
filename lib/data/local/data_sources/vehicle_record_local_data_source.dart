import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Abstract local data source contract for vehicle records.
abstract class VehicleRecordLocalDataSource {
  /// Returns all records for [vehicleId], sorted by date descending.
  List<VehicleRecord> getAllRecords(String vehicleId);

  /// Returns all odometer records for [vehicleId].
  List<OdometerRecord> getOdometerRecords(String vehicleId);

  /// Returns all fuel refill records for [vehicleId].
  List<FuelRecord> getFuelRecords(String vehicleId);

  /// Returns all service records for [vehicleId].
  List<ServiceRecord> getServiceRecords(String vehicleId);

  /// Returns all oil change records for [vehicleId].
  List<OilChangeRecord> getOilChangeRecords(String vehicleId);

  /// Persists [record] into local storage.
  Future<void> addRecord(VehicleRecord record);

  /// Deletes all records belonging to [vehicleId] (cascading delete).
  Future<void> deleteRecordsForVehicle(String vehicleId);
}

/// Hive CE implementation of [VehicleRecordLocalDataSource].
///
/// Stores all [VehicleRecord] polymorphic subtypes inside [HiveBoxes.vehicleRecords].
class HiveVehicleRecordLocalDataSource implements VehicleRecordLocalDataSource {
  HiveVehicleRecordLocalDataSource({
    Box<VehicleRecord>? recordBox,
  }) : _recordBox = recordBox ?? Hive.box<VehicleRecord>(HiveBoxes.vehicleRecords);

  final Box<VehicleRecord> _recordBox;

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) {
    final records = _recordBox.values
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  List<OdometerRecord> getOdometerRecords(String vehicleId) {
    return _recordBox.values
        .whereType<OdometerRecord>()
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<FuelRecord> getFuelRecords(String vehicleId) {
    return _recordBox.values
        .whereType<FuelRecord>()
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<ServiceRecord> getServiceRecords(String vehicleId) {
    return _recordBox.values
        .whereType<ServiceRecord>()
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<OilChangeRecord> getOilChangeRecords(String vehicleId) {
    return _recordBox.values
        .whereType<OilChangeRecord>()
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addRecord(VehicleRecord record) async {
    await _recordBox.put(record.id, record);
  }

  @override
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    final keysToDelete = _recordBox.values
        .where((r) => r.vehicleId == vehicleId)
        .map((r) => r.id)
        .toList();

    await _recordBox.deleteAll(keysToDelete);
  }
}
