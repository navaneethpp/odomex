import 'package:odomex/models/vehicle.dart';

/// In-memory repository for vehicles.
///
/// This class is deliberately free of singletons and static state — it is
/// created and owned by the Riverpod [vehiclesRepositoryProvider] so it can
/// be overridden in tests or replaced with a persistent implementation later.
///
/// Responsibility boundary:
///   - Stores and retrieves [Vehicle] objects.
///   - Does NOT notify listeners; that is the provider's job.
class VehiclesRepository {
  VehiclesRepository({List<Vehicle>? initial})
      : _vehicles = initial != null ? List.of(initial) : [];

  final List<Vehicle> _vehicles;

  /// Returns an unmodifiable snapshot of all vehicles.
  List<Vehicle> getAll() => List.unmodifiable(_vehicles);

  /// Returns the vehicle with [id], or null if not found.
  Vehicle? getById(String id) {
    for (final v in _vehicles) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// Appends [vehicle] to the collection.
  void add(Vehicle vehicle) {
    _vehicles.add(vehicle);
  }

  /// Replaces the vehicle whose [Vehicle.id] matches [vehicle.id].
  /// Does nothing if no matching vehicle is found.
  void update(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index == -1) return;
    _vehicles[index] = vehicle;
  }

  /// Removes the vehicle with [vehicleId].
  void delete(String vehicleId) {
    _vehicles.removeWhere((v) => v.id == vehicleId);
  }
}
