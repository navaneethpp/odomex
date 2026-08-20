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
/// State is always exposed in **most-recently-accessed-first** order:
///   - Vehicles with a [Vehicle.lastAccessedAt] timestamp appear first,
///     sorted descending (most recent at the top).
///   - Vehicles that have never been accessed ([Vehicle.lastAccessedAt] == null)
///     appear after all accessed vehicles, in their original insertion order.
///
/// All state mutations go through this notifier — widgets must never mutate
/// the vehicle list directly.
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  VehicleNotifier(this._repository) : super([]) {
    // Initialise with a sorted snapshot of the seed data.
    state = _sorted(_repository.getAll());
  }

  final VehiclesRepository _repository;

  // ─────────────────────────────────────────────
  // SORTING
  // ─────────────────────────────────────────────

  /// Returns a new list sorted by [Vehicle.lastAccessedAt] descending.
  ///
  /// Sorting rules:
  ///   1. Vehicles with a non-null timestamp come first (newest first).
  ///   2. Vehicles with null timestamp come after all timestamped vehicles.
  ///   3. Ties (identical timestamps or both null) fall back to vehicle ID
  ///      comparison for a stable, deterministic order.
  static List<Vehicle> _sorted(List<Vehicle> vehicles) {
    final copy = List<Vehicle>.of(vehicles);
    copy.sort((a, b) {
      final aTime = a.lastAccessedAt;
      final bTime = b.lastAccessedAt;

      if (aTime == null && bTime == null) {
        // Both never accessed — maintain stable order by ID.
        return a.id.compareTo(b.id);
      }
      if (aTime == null) return 1;  // a goes after b
      if (bTime == null) return -1; // a goes before b

      // Both have timestamps — sort descending (most recent first).
      final cmp = bTime.compareTo(aTime);
      if (cmp != 0) return cmp;

      // Identical timestamps — fall back to ID for stability.
      return a.id.compareTo(b.id);
    });
    return copy;
  }

  // ─────────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────────

  /// Adds [vehicle] to the collection and returns its assigned [Vehicle.id].
  String addVehicle(Vehicle vehicle) {
    _repository.add(vehicle);
    state = _sorted(_repository.getAll());
    return vehicle.id;
  }

  /// Replaces the existing vehicle whose id matches [vehicle.id].
  void updateVehicle(Vehicle vehicle) {
    _repository.update(vehicle);
    state = _sorted(_repository.getAll());
  }

  /// Removes the vehicle with [vehicleId] from the collection.
  void removeVehicle(String vehicleId) {
    _repository.delete(vehicleId);
    state = _sorted(List.of(state.where((v) => v.id != vehicleId)));
  }

  /// Records that the user just opened the Vehicle Details screen for
  /// [vehicleId].
  ///
  /// Updates [Vehicle.lastAccessedAt] to [DateTime.now()] and re-sorts the
  /// vehicle list so the accessed vehicle immediately rises to the top of
  /// HomeScreen.
  ///
  /// This method should be called from the UI layer *before* (or just after)
  /// navigating to the Vehicle Details screen. It must NOT be called on
  /// automatic rebuilds, scrolls, or any event other than an intentional
  /// vehicle view.
  void markVehicleAsAccessed(String vehicleId) {
    final index = state.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    final updated = state[index].copyWith(
      lastAccessedAt: DateTime.now(),
    );

    // Persist the update so the repository reflects the new timestamp.
    _repository.update(updated);

    // Rebuild state immutably and re-sort.
    final newList = List<Vehicle>.of(state);
    newList[index] = updated;
    state = _sorted(newList);
  }
}

// ─────────────────────────────────────────────
// VEHICLE PROVIDER
// ─────────────────────────────────────────────

/// Exposes the current vehicle list as reactive, sorted state.
///
/// The list is always in most-recently-accessed-first order.
/// Screens watch this provider to receive automatic rebuilds whenever the list
/// changes (e.g. after adding a vehicle or marking one as accessed).
///
/// Usage:
/// ```dart
/// final vehicles = ref.watch(vehicleProvider);
/// ref.read(vehicleProvider.notifier).addVehicle(vehicle);
/// ref.read(vehicleProvider.notifier).markVehicleAsAccessed(vehicle.id);
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
/// because the vehicle was updated via [VehicleNotifier.updateVehicle] or
/// [VehicleNotifier.markVehicleAsAccessed]), the details screen watching this
/// provider will rebuild automatically.
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
