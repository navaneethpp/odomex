import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// In-memory repository for all vehicle records.
///
/// Records are stored per-vehicle using the vehicle's [String] ID as the key.
/// This class is owned by the Riverpod [vehicleRecordRepositoryProvider] and
/// can later be swapped for a persistent implementation without touching
/// providers or UI widgets.
///
/// Uses the sealed [VehicleRecord] hierarchy so that all record types are
/// handled uniformly while still being individually type-safe via pattern
/// matching.
class VehicleRecordsRepository {
  VehicleRecordsRepository();

  // ── Storage ────────────────────────────────────────────────────────────────
  //
  // Each record type has its own typed list keyed by vehicleId. Keeping types
  // separate makes type-specific queries (e.g. latest odometer) cheap and
  // avoids casting at the call site.

  final Map<String, List<OdometerRecord>> _odometer = {};
  final Map<String, List<FuelRecord>> _fuel = {};
  final Map<String, List<ServiceRecord>> _service = {};
  final Map<String, List<OilChangeRecord>> _oilChange = {};

  // ── Unified write ──────────────────────────────────────────────────────────

  /// Adds [record] to the appropriate typed store.
  ///
  /// Uses exhaustive pattern matching so the analyser will flag any new
  /// [VehicleRecord] subtype that is not yet handled here.
  void addRecord(VehicleRecord record) {
    switch (record) {
      case OdometerRecord():
        _odometer.putIfAbsent(record.vehicleId, () => []).add(record);
      case FuelRecord():
        _fuel.putIfAbsent(record.vehicleId, () => []).add(record);
      case ServiceRecord():
        _service.putIfAbsent(record.vehicleId, () => []).add(record);
      case OilChangeRecord():
        _oilChange.putIfAbsent(record.vehicleId, () => []).add(record);
    }
  }

  // ── Typed reads ────────────────────────────────────────────────────────────

  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      List.unmodifiable(_odometer[vehicleId] ?? []);

  List<FuelRecord> getFuelRecords(String vehicleId) =>
      List.unmodifiable(_fuel[vehicleId] ?? []);

  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      List.unmodifiable(_service[vehicleId] ?? []);

  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      List.unmodifiable(_oilChange[vehicleId] ?? []);

  /// Returns all records for [vehicleId] as a flat list, sorted by date
  /// descending (most recent first).
  List<VehicleRecord> getAllRecords(String vehicleId) {
    final all = <VehicleRecord>[
      ...(_odometer[vehicleId] ?? []),
      ...(_fuel[vehicleId] ?? []),
      ...(_service[vehicleId] ?? []),
      ...(_oilChange[vehicleId] ?? []),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(all);
  }

  // ── Convenience queries ────────────────────────────────────────────────────

  /// Returns the most recent [OdometerRecord] for [vehicleId], or null if
  /// no odometer records exist.
  OdometerRecord? getLatestOdometerRecord(String vehicleId) {
    final records = _odometer[vehicleId];
    if (records == null || records.isEmpty) return null;
    return records.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
  }
}
