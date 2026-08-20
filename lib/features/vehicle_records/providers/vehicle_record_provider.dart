import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';

// ─────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────

/// Provides the [VehicleRecordsRepository] instance.
///
/// Kept separate from the notifier provider so it can be independently
/// overridden in tests.
final vehicleRecordRepositoryProvider =
    Provider<VehicleRecordsRepository>((ref) {
  return VehicleRecordsRepository();
});

// ─────────────────────────────────────────────
// STATE TYPE
// ─────────────────────────────────────────────

/// The complete record state: a map from vehicleId to an unordered list of all
/// typed [VehicleRecord] objects belonging to that vehicle.
///
/// Widgets watch this map to be notified whenever any record is added for any
/// vehicle. Vehicle-specific queries should use the typed accessors on the
/// notifier rather than filtering the map directly.
typedef VehicleRecordState = Map<String, List<VehicleRecord>>;

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

/// Manages in-memory vehicle records for all vehicles via the
/// [VehicleRecordsRepository].
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

  /// Adds [record] to the repository and updates state.
  ///
  /// This is the preferred entry point for all UI code. The repository uses
  /// exhaustive pattern matching internally so no switch is needed here.
  void addRecord(VehicleRecord record) {
    _repository.addRecord(record);
    state = _stateAfterAdd(record.vehicleId);
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
///
/// Usage:
/// ```dart
/// // Add a record:
/// ref.read(vehicleRecordProvider.notifier).addRecord(record);
///
/// // Query records (read-only, no rebuild):
/// final notifier = ref.read(vehicleRecordProvider.notifier);
/// final records = notifier.getOdometerRecords(vehicleId);
/// ```
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
///
/// Rebuilds whenever [vehicleRecordProvider] updates for any vehicle. If
/// per-vehicle rebuild granularity becomes a performance concern, consider
/// a family-scoped provider.
///
/// Usage:
/// ```dart
/// final records = ref.watch(recordsByVehicleProvider(vehicleId));
/// ```
final recordsByVehicleProvider =
    Provider.family<List<VehicleRecord>, String>((ref, vehicleId) {
  final state = ref.watch(vehicleRecordProvider);
  return state[vehicleId] ?? const [];
});
