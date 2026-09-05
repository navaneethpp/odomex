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
  /// Synchronizes the vehicle's derived fields (odometer, service date, oil change).
  Future<void> addRecord(VehicleRecord record) async {
    await _repository.addRecord(record);
    state = _stateAfterAdd(record.vehicleId);
    await _syncVehicleDerivedState(record.vehicleId);
  }

  /// Updates an existing [record] in the repository and updates reactive state.
  Future<void> updateRecord(VehicleRecord record) async {
    await _repository.updateRecord(record);
    state = _stateAfterAdd(record.vehicleId);
    await _syncVehicleDerivedState(record.vehicleId);
  }

  /// Deletes a specific [recordId] belonging to [vehicleId] and updates reactive state.
  Future<void> deleteRecord(String vehicleId, String recordId) async {
    await _repository.deleteRecord(vehicleId, recordId);
    state = _stateAfterAdd(vehicleId);
    await _syncVehicleDerivedState(vehicleId);
  }

  /// Synchronizes dynamic properties on the vehicle entity when records change.
  Future<void> _syncVehicleDerivedState(String vehicleId) async {
    final vehicle = _ref.read(vehicleByIdProvider(vehicleId));
    if (vehicle == null) return;

    final records = _repository.getAllRecords(vehicleId);

    // 1. Calculate latest odometer reading
    double? latestOdometer;
    for (final r in records) {
      double? odo;
      switch (r) {
        case OdometerRecord():
          odo = r.odometer;
        case FuelRecord():
          odo = r.odometerReading;
        case ServiceRecord():
          odo = r.odometerReading;
        case OilChangeRecord():
        case ChargingRecord():
          odo = r.odometerReading;
      }
      if (odo != null && odo > 0) {
        if (latestOdometer == null || odo > latestOdometer) {
          latestOdometer = odo;
        }
      }
    }

    // 2. Calculate latest service date
    final serviceRecords = records.whereType<ServiceRecord>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestServiceDate =
        serviceRecords.isNotEmpty ? serviceRecords.first.date : null;

    // 3. Calculate latest oil change date & odometer
    final oilRecords = records.whereType<OilChangeRecord>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestOilRecord = oilRecords.isNotEmpty ? oilRecords.first : null;

    var updated = vehicle;
    if (latestOdometer != null && latestOdometer != vehicle.odometerReading) {
      updated = updated.copyWith(odometerReading: latestOdometer);
    }
    if (latestServiceDate != null &&
        latestServiceDate != vehicle.lastServiceDate) {
      updated = updated.copyWith(lastServiceDate: latestServiceDate);
    }
    if (latestOilRecord != null) {
      updated = updated.copyWith(
        lastOilChangeDate: latestOilRecord.date,
        lastOilChangeOdometer: latestOilRecord.odometerReading,
      );
    }

    if (updated != vehicle) {
      await _ref.read(vehicleProvider.notifier).updateVehicle(updated);
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

  double? getLatestOdometerReading(
    String vehicleId, {
    double? vehicleCurrentOdometer,
  }) =>
      _repository.getLatestOdometerReading(
        vehicleId,
        vehicleCurrentOdometer: vehicleCurrentOdometer,
      );
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

/// Reactively provides the latest saved odometer reading for a specific vehicle.
final latestOdometerReadingProvider =
    Provider.family<double?, String>((ref, vehicleId) {
  final vehicle = ref.watch(vehicleByIdProvider(vehicleId));
  final records = ref.watch(recordsByVehicleProvider(vehicleId));

  double? latestFromRecords;

  for (final r in records) {
    double? odo;
    switch (r) {
      case OdometerRecord():
        odo = r.odometer;
      case FuelRecord():
        odo = r.odometerReading;
      case ServiceRecord():
        odo = r.odometerReading;
      case OilChangeRecord():
      case ChargingRecord():
        odo = r.odometerReading;
    }
    if (odo != null && odo > 0) {
      if (latestFromRecords == null || odo > latestFromRecords) {
        latestFromRecords = odo;
      }
    }
  }

  return latestFromRecords ??
      ((vehicle != null && vehicle.odometerReading > 0)
          ? vehicle.odometerReading
          : null);
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
