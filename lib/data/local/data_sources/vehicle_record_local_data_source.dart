import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Abstract local data source contract for vehicle records.
abstract class VehicleRecordLocalDataSource {
  /// Returns all records for [vehicleId], sorted by date descending.
  List<VehicleRecord> getAllRecords(String vehicleId);

  /// Returns up to [limit] recent records for [vehicleId], sorted by date descending.
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10});

  /// Returns records within [startDate] and [endDate] for [vehicleId].
  List<VehicleRecord> getRecordsByDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  );

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

  /// Seeds initial mock records on first launch only.
  Future<void> seedInitialRecords(List<VehicleRecord> records);
}

/// Hive CE implementation of [VehicleRecordLocalDataSource].
///
/// Stores all [VehicleRecord] polymorphic subtypes inside [HiveBoxes.vehicleRecords].
class HiveVehicleRecordLocalDataSource implements VehicleRecordLocalDataSource {
  HiveVehicleRecordLocalDataSource({
    Box<VehicleRecord>? recordBox,
    Box<dynamic>? settingsBox,
  })  : _recordBox =
            recordBox ?? Hive.box<VehicleRecord>(HiveBoxes.vehicleRecords),
        _settingsBox = settingsBox ?? Hive.box<dynamic>(HiveBoxes.appSettings);

  final Box<VehicleRecord> _recordBox;
  final Box<dynamic> _settingsBox;

  static const String _isRecordsSeededKey = 'is_records_seeded';

  @override
  List<VehicleRecord> getAllRecords(String vehicleId) {
    final records = _recordBox.values
        .where((r) => r.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) {
    final records = getAllRecords(vehicleId);
    return records.take(limit).toList();
  }

  @override
  List<VehicleRecord> getRecordsByDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final records = _recordBox.values
        .where((r) =>
            r.vehicleId == vehicleId &&
            !r.date.isBefore(start) &&
            !r.date.isAfter(end))
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

  @override
  Future<void> seedInitialRecords(List<VehicleRecord> records) async {
    final isSeeded = _settingsBox.get(_isRecordsSeededKey, defaultValue: false);
    if (isSeeded == true) return;

    final map = {for (final r in records) r.id: r};
    await _recordBox.putAll(map);
    await _settingsBox.put(_isRecordsSeededKey, true);
  }
}
