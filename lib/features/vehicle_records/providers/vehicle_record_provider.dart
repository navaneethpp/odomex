import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';
import 'package:odomex/features/vehicle_records/services/vehicle_usage_analytics.dart';
import 'package:odomex/providers/vehicle_provider.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

/// Provides the [VehicleRecordLocalDataSource] backed by Hive.
final vehicleRecordLocalDataSourceProvider =
    Provider<VehicleRecordLocalDataSource>((ref) {
  return HiveVehicleRecordLocalDataSource();
});

/// Provides the [VehicleRecordsRepository] instance.
final vehicleRecordRepositoryProvider =
    Provider<VehicleRecordsRepository>((ref) {
  final localDataSource = ref.watch(vehicleRecordLocalDataSourceProvider);
  return VehicleRecordsRepository(localDataSource: localDataSource);
});

// ─────────────────────────────────────────────
// STATE TYPE
// ─────────────────────────────────────────────

/// The complete record state: a map from vehicleId to a list of all
/// typed [VehicleRecord] objects belonging to that vehicle.
typedef VehicleRecordState = Map<String, List<VehicleRecord>>;

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

/// Manages vehicle records for all vehicles backed by Hive persistence.
class VehicleRecordNotifier extends StateNotifier<VehicleRecordState> {
  VehicleRecordNotifier(this._repository, this._ref) : super({});

  final VehicleRecordsRepository _repository;
  final Ref _ref;

  VehicleRecordState _stateAfterAdd(String vehicleId) {
    return Map.of(state)
      ..[vehicleId] = _repository.getAllRecords(vehicleId);
  }

  /// Adds [record] to the repository and updates reactive state.
  /// Also synchronizes the vehicle's current odometer if this record has a higher reading.
  Future<void> addRecord(VehicleRecord record) async {
    await _repository.addRecord(record);
    state = _stateAfterAdd(record.vehicleId);

    // Extract odometer if present
    double? odo;
    switch (record) {
      case OdometerRecord():
        odo = record.odometer;
      case FuelRecord():
        odo = record.odometerReading;
      case ServiceRecord():
        odo = record.odometerReading;
      case OilChangeRecord():
        odo = record.odometerReading;
    }

    if (odo != null && odo > 0) {
      await _ref
          .read(vehicleProvider.notifier)
          .updateOdometerIfHigher(record.vehicleId, odo);
    }
  }

  /// Removes all records for [vehicleId] (used during cascading vehicle deletion).
  Future<void> deleteRecordsForVehicle(String vehicleId) async {
    await _repository.deleteRecordsForVehicle(vehicleId);
    final newState = Map<String, List<VehicleRecord>>.of(state);
    newState.remove(vehicleId);
    state = newState;
  }

  // ── Typed reads ───────────────────────────────────────────────────────────

  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      _repository.getOdometerRecords(vehicleId);

  List<FuelRecord> getFuelRecords(String vehicleId) =>
      _repository.getFuelRecords(vehicleId);

  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      _repository.getServiceRecords(vehicleId);

  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      _repository.getOilChangeRecords(vehicleId);

  List<VehicleRecord> getAllRecords(String vehicleId) =>
      _repository.getAllRecords(vehicleId);

  List<VehicleRecord> getRecentRecords(String vehicleId, {int limit = 10}) =>
      _repository.getRecentRecords(vehicleId, limit: limit);

  OdometerRecord? getLatestOdometerRecord(String vehicleId) =>
      _repository.getLatestOdometerRecord(vehicleId);
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

/// Exposes [VehicleRecordNotifier] as reactive Riverpod state.
final vehicleRecordProvider = StateNotifierProvider<
    VehicleRecordNotifier, VehicleRecordState>((ref) {
  final repository = ref.watch(vehicleRecordRepositoryProvider);
  return VehicleRecordNotifier(repository, ref);
});

/// Reactively provides all records for a specific vehicle, sorted by date descending.
final recordsByVehicleProvider =
    Provider.family<List<VehicleRecord>, String>((ref, vehicleId) {
  final state = ref.watch(vehicleRecordProvider);
  if (state.containsKey(vehicleId)) {
    return state[vehicleId]!;
  }
  final repository = ref.watch(vehicleRecordRepositoryProvider);
  return repository.getAllRecords(vehicleId);
});

/// Reactively provides the last 10 records for a specific vehicle.
final recentRecordsProvider =
    Provider.family<List<VehicleRecord>, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return VehicleUsageAnalytics.getRecentRecords(records: records, limit: 10);
});

/// Reactively provides all odometer records for [vehicleId].
final odometerRecordsProvider =
    Provider.family<List<OdometerRecord>, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return records.whereType<OdometerRecord>().toList();
});

/// Reactively provides all fuel records for [vehicleId].
final fuelRecordsProvider =
    Provider.family<List<FuelRecord>, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return records.whereType<FuelRecord>().toList();
});

/// Reactively provides all service records for [vehicleId].
final serviceRecordsProvider =
    Provider.family<List<ServiceRecord>, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return records.whereType<ServiceRecord>().toList();
});

/// Reactively provides all oil change records for [vehicleId].
final oilChangeRecordsProvider =
    Provider.family<List<OilChangeRecord>, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return records.whereType<OilChangeRecord>().toList();
});

/// Reactively provides aggregated fuel statistics for [vehicleId].
final fuelAnalyticsProvider =
    Provider.family<FuelAnalytics, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return VehicleUsageAnalytics.calculateFuelAnalytics(records);
});

/// Reactively provides aggregated maintenance statistics for [vehicleId].
final maintenanceAnalyticsProvider =
    Provider.family<MaintenanceAnalytics, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  return VehicleUsageAnalytics.calculateMaintenanceAnalytics(records);
});
