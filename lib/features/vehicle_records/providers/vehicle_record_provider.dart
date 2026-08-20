import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

/// Provides the [VehicleRecordLocalDataSource] backed by Hive.
final vehicleRecordLocalDataSourceProvider =
    Provider<VehicleRecordLocalDataSource>((ref) {
  return HiveVehicleRecordLocalDataSource();
});

/// Provides the [VehicleRecordsRepository] instance.
///
/// Kept separate from the notifier provider so it can be independently
/// overridden in tests.
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
///
/// Widgets watch this map to be notified whenever any record is added for any
/// vehicle.
typedef VehicleRecordState = Map<String, List<VehicleRecord>>;

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

/// Manages vehicle records for all vehicles backed by Hive persistence.
///
/// ### Adding a record
/// ```dart
/// ref.read(vehicleRecordProvider.notifier).addRecord(record);
/// ```
///
/// ### Querying records
/// ```dart
/// final notifier = ref.read(vehicleRecordProvider.notifier);
/// final odometerRecords = notifier.getOdometerRecords(vehicleId);
/// ```
class VehicleRecordNotifier extends StateNotifier<VehicleRecordState> {
  VehicleRecordNotifier(this._repository) : super({});

  final VehicleRecordsRepository _repository;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Rebuilds the state entry for [vehicleId] by pulling all records from the
  /// repository. Returns a new immutable map to trigger a provider rebuild.
  VehicleRecordState _stateAfterAdd(String vehicleId) {
    return Map.of(state)
      ..[vehicleId] = _repository.getAllRecords(vehicleId);
  }

  // ── Unified write ─────────────────────────────────────────────────────────

  /// Adds [record] to the repository and updates reactive state.
  Future<void> addRecord(VehicleRecord record) async {
    await _repository.addRecord(record);
    state = _stateAfterAdd(record.vehicleId);
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

  /// Returns all records for [vehicleId] sorted by date descending.
  List<VehicleRecord> getAllRecords(String vehicleId) =>
      _repository.getAllRecords(vehicleId);

  /// Returns the most recent odometer record for [vehicleId], or null.
  OdometerRecord? getLatestOdometerRecord(String vehicleId) =>
      _repository.getLatestOdometerRecord(vehicleId);
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

/// Exposes [VehicleRecordNotifier] as reactive Riverpod state.
///
/// Any widget watching this provider rebuilds whenever a record is added for
/// any vehicle.
final vehicleRecordProvider = StateNotifierProvider<
    VehicleRecordNotifier, VehicleRecordState>((ref) {
  final repository = ref.watch(vehicleRecordRepositoryProvider);
  return VehicleRecordNotifier(repository);
});

// ─────────────────────────────────────────────
// RECORDS BY VEHICLE PROVIDER
// ─────────────────────────────────────────────

/// Reactively provides all records for a specific vehicle, sorted by date
/// descending.
final recordsByVehicleProvider =
    Provider.family<List<VehicleRecord>, String>((ref, vehicleId) {
  final state = ref.watch(vehicleRecordProvider);
  if (state.containsKey(vehicleId)) {
    return state[vehicleId]!;
  }
  // If not yet in state cache, fetch from repository.
  final repository = ref.watch(vehicleRecordRepositoryProvider);
  return repository.getAllRecords(vehicleId);
});
