import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/vehicles.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

// ─────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────

/// Provides the [VehiclesRepository] instance, seeded with the local mock
/// data. Screens and notifiers must never instantiate the repository directly;
/// they should always read it through this provider so it can be overridden
/// in tests or replaced with a persistent backend later.
final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  return VehiclesRepository(initial: Vehicles.vehicles);
});

// ─────────────────────────────────────────────
// VEHICLE STATE NOTIFIER
// ─────────────────────────────────────────────

/// Manages the application's vehicle list as immutable Riverpod state.
///
/// All state mutations go through this notifier — widgets must never mutate
/// the vehicle list directly.
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  VehicleNotifier(this._repository) : super(_repository.getAll());

  final VehiclesRepository _repository;

  /// Adds [vehicle] to the collection and returns its assigned [Vehicle.id].
  String addVehicle(Vehicle vehicle) {
    _repository.add(vehicle);
    state = _repository.getAll();
    return vehicle.id;
  }

  /// Replaces the existing vehicle whose id matches [vehicle.id].
  void updateVehicle(Vehicle vehicle) {
    _repository.update(vehicle);
    state = _repository.getAll();
  }

  /// Removes the vehicle with [vehicleId] from the collection.
  void removeVehicle(String vehicleId) {
    _repository.delete(vehicleId);
    // Return a new list to trigger rebuild.
    state = List.of(state.where((v) => v.id != vehicleId));
  }
}

// ─────────────────────────────────────────────
// VEHICLE PROVIDER
// ─────────────────────────────────────────────

/// Exposes the current vehicle list as reactive state.
///
/// Screens watch this provider to receive automatic rebuilds whenever the list
/// changes (e.g. after adding or removing a vehicle).
///
/// Usage:
/// ```dart
/// final vehicles = ref.watch(vehicleProvider);
/// ref.read(vehicleProvider.notifier).addVehicle(vehicle);
/// ```
final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, List<Vehicle>>((ref) {
  final repository = ref.watch(vehiclesRepositoryProvider);
  return VehicleNotifier(repository);
});

// ─────────────────────────────────────────────
// VEHICLE BY ID PROVIDER
// ─────────────────────────────────────────────

/// Returns a single [Vehicle] by its unique [id], or null if not found.
///
/// This provider is reactive — if the underlying vehicle list changes (e.g.
/// because the vehicle was updated via [VehicleNotifier.updateVehicle]), the
/// details screen watching this provider will rebuild automatically.
///
/// Usage:
/// ```dart
/// final vehicle = ref.watch(vehicleByIdProvider(vehicleId));
/// if (vehicle == null) return _buildNotFound();
/// ```
final vehicleByIdProvider =
    Provider.family<Vehicle?, String>((ref, vehicleId) {
  final vehicles = ref.watch(vehicleProvider);
  for (final v in vehicles) {
    if (v.id == vehicleId) return v;
  }
  return null;
});
