import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

/// Provides the [VehicleLocalDataSource] backed by Hive.
final vehicleLocalDataSourceProvider = Provider<VehicleLocalDataSource>((ref) {
  return HiveVehicleLocalDataSource();
});

/// Provides the [VehiclesRepository] instance.
final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  final localDataSource = ref.watch(vehicleLocalDataSourceProvider);
  return VehiclesRepository(localDataSource: localDataSource);
});

// ─────────────────────────────────────────────
// VEHICLE STATE NOTIFIER
// ─────────────────────────────────────────────

/// Manages the application's vehicle list as immutable Riverpod state.
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  VehicleNotifier(this._repository) : super([]) {
    state = _sorted(_repository.getAll());
  }

  final VehiclesRepository _repository;

  static List<Vehicle> _sorted(List<Vehicle> vehicles) {
    final copy = List<Vehicle>.of(vehicles);
    copy.sort((a, b) {
      final aTime = a.lastAccessedAt;
      final bTime = b.lastAccessedAt;

      if (aTime == null && bTime == null) {
        return a.id.compareTo(b.id);
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      final cmp = bTime.compareTo(aTime);
      if (cmp != 0) return cmp;

      return a.id.compareTo(b.id);
    });
    return copy;
  }

  // ─────────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────────

  /// Adds [vehicle] to the collection and returns its assigned [Vehicle.id].
  Future<String> addVehicle(Vehicle vehicle) async {
    await _repository.add(vehicle);
    state = _sorted(_repository.getAll());
    return vehicle.id;
  }

  /// Replaces the existing vehicle whose id matches [vehicle.id].
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repository.update(vehicle);
    state = _sorted(_repository.getAll());
  }

  /// Updates the vehicle's odometer reading if [newOdometer] is greater than current.
  Future<void> updateOdometerIfHigher(
      String vehicleId, double newOdometer) async {
    final index = state.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;
    final vehicle = state[index];
    if (newOdometer > vehicle.odometerReading) {
      final updated = vehicle.copyWith(odometerReading: newOdometer);
      await _repository.update(updated);
      state = _sorted(_repository.getAll());
    }
  }

  /// Removes the vehicle with [vehicleId] from the collection.
  Future<void> removeVehicle(String vehicleId) async {
    await _repository.delete(vehicleId);
    state = _sorted(List.of(state.where((v) => v.id != vehicleId)));
  }

  /// Records that the user just opened the Vehicle Details screen for [vehicleId].
  void markVehicleAsAccessed(String vehicleId) {
    final index = state.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    final updated = state[index].copyWith(
      lastAccessedAt: DateTime.now(),
    );

    _repository.update(updated);

    final newList = List<Vehicle>.of(state);
    newList[index] = updated;
    state = _sorted(newList);
  }
}

// ─────────────────────────────────────────────
// VEHICLE PROVIDERS
// ─────────────────────────────────────────────

final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, List<Vehicle>>((ref) {
  final repository = ref.watch(vehiclesRepositoryProvider);
  return VehicleNotifier(repository);
});

final vehicleByIdProvider =
    Provider.family<Vehicle?, String>((ref, vehicleId) {
  final vehicles = ref.watch(vehicleProvider);
  for (final v in vehicles) {
    if (v.id == vehicleId) return v;
  }
  return null;
});
