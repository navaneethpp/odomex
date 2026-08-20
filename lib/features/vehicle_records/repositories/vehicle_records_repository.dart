import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Repository for all vehicle records.
///
/// Backed by a [VehicleRecordLocalDataSource] (e.g. Hive). Provides polymorphic
/// and type-specific query access for vehicle records while isolating
/// providers and widgets from local database mechanics.
class VehicleRecordsRepository {
  VehicleRecordsRepository({
    required this.localDataSource,
  });

  final VehicleRecordLocalDataSource localDataSource;

  /// Persists [record] into the local store.
  Future<void> addRecord(VehicleRecord record) {
    return localDataSource.addRecord(record);
  }

  /// Returns all records for [vehicleId] sorted by date descending.
  List<VehicleRecord> getAllRecords(String vehicleId) =>
      localDataSource.getAllRecords(vehicleId);

  /// Returns up to [limit] most recent records for [vehicleId].
  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) =>
      localDataSource.getRecentRecords(vehicleId, limit: limit);

  /// Returns records within [startDate] and [endDate] for [vehicleId].
  List<VehicleRecord> getRecordsByDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) =>
      localDataSource.getRecordsByDateRange(vehicleId, startDate, endDate);

  /// Returns all odometer records for [vehicleId].
  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      localDataSource.getOdometerRecords(vehicleId);

  /// Returns all fuel records for [vehicleId].
  List<FuelRecord> getFuelRecords(String vehicleId) =>
      localDataSource.getFuelRecords(vehicleId);

  /// Returns all service records for [vehicleId].
  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      localDataSource.getServiceRecords(vehicleId);

  /// Returns all oil change records for [vehicleId].
  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      localDataSource.getOilChangeRecords(vehicleId);

  /// Returns the most recent [OdometerRecord] for [vehicleId], or null.
  OdometerRecord? getLatestOdometerRecord(String vehicleId) {
    final records = localDataSource.getOdometerRecords(vehicleId);
    if (records.isEmpty) return null;
    return records.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Deletes all records for [vehicleId] (used during cascading vehicle deletion).
  Future<void> deleteRecordsForVehicle(String vehicleId) {
    return localDataSource.deleteRecordsForVehicle(vehicleId);
  }
}
