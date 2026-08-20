import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/models/fuel_record.dart';
import 'package:odomex/models/odometer_record.dart';
import 'package:odomex/models/oil_change_record.dart';
import 'package:odomex/models/service_record.dart';
import 'package:odomex/repositories/vehicle_records_repository.dart';

// ─────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────

/// Provides the [VehicleRecordsRepository] instance.
final vehicleRecordRepositoryProvider =
    Provider<VehicleRecordsRepository>((ref) {
  return VehicleRecordsRepository();
});

// ─────────────────────────────────────────────
// STATE TYPE
// ─────────────────────────────────────────────

/// The record state for the entire application: a map from vehicleId to a
/// list of typed record objects.
///
/// Records are held as [Object] because each vehicle may have a mixed list of
/// [OdometerRecord], [FuelRecord], [ServiceRecord], and [OilChangeRecord].
/// Widgets cast to the appropriate type based on `runtimeType` or use
/// dedicated `getXxxRecords()` accessors on the notifier.
typedef VehicleRecordState = Map<String, List<Object>>;

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

/// Manages in-memory vehicle records for all vehicles.
///
/// Each record type is stored separately in the underlying
/// [VehicleRecordsRepository]. The state map gives widgets a single place
/// to watch for any record changes.
///
/// Usage:
/// ```dart
/// ref.read(vehicleRecordProvider.notifier).addOdometerRecord(record);
/// ```
class VehicleRecordNotifier
    extends StateNotifier<VehicleRecordState> {
  VehicleRecordNotifier(this._repository) : super({});

  final VehicleRecordsRepository _repository;

  // ── Helpers ──────────────────────────────────────────

  /// Builds a fresh state map by pulling all records for a specific vehicle
  /// from the repository and merging them into the current state.
  VehicleRecordState _stateAfterUpdate(String vehicleId) {
    return Map.of(state)
      ..[vehicleId] = [
        ..._repository.getOdometerRecords(vehicleId),
        ..._repository.getFuelRecords(vehicleId),
        ..._repository.getServiceRecords(vehicleId),
        ..._repository.getOilChangeRecords(vehicleId),
      ];
  }

  // ── Accessors ─────────────────────────────────────────

  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      _repository.getOdometerRecords(vehicleId);

  List<FuelRecord> getFuelRecords(String vehicleId) =>
      _repository.getFuelRecords(vehicleId);

  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      _repository.getServiceRecords(vehicleId);

  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      _repository.getOilChangeRecords(vehicleId);

  // ── Mutations ─────────────────────────────────────────

  void addOdometerRecord(OdometerRecord record) {
    _repository.addOdometerRecord(record);
    state = _stateAfterUpdate(record.vehicleId);
  }

  void addFuelRecord(FuelRecord record) {
    _repository.addFuelRecord(record);
    state = _stateAfterUpdate(record.vehicleId);
  }

  void addServiceRecord(ServiceRecord record) {
    _repository.addServiceRecord(record);
    state = _stateAfterUpdate(record.vehicleId);
  }

  void addOilChangeRecord(OilChangeRecord record) {
    _repository.addOilChangeRecord(record);
    state = _stateAfterUpdate(record.vehicleId);
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

/// Exposes [VehicleRecordNotifier] as reactive state.
///
/// Widgets and screens that need to display or add records watch/read this
/// provider.
final vehicleRecordProvider = StateNotifierProvider<
    VehicleRecordNotifier, VehicleRecordState>((ref) {
  final repository = ref.watch(vehicleRecordRepositoryProvider);
  return VehicleRecordNotifier(repository);
});
