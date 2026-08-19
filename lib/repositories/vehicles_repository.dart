import 'package:odomex/data/vehicles.dart';
import 'package:odomex/models/vehicle.dart';

/// In-memory repository for vehicles.
///
/// Seeded with the existing mock vehicle data from [Vehicles.vehicles].
/// This is intentionally a simple in-memory implementation; it can later be
/// replaced with a persistent backend (SQLite, Hive, REST API, etc.) without
/// changing the rest of the app — only this class needs to change.
class VehiclesRepository {
  VehiclesRepository._();

  /// Singleton instance.
  static final VehiclesRepository instance = VehiclesRepository._();

  final List<Vehicle> _vehicles = List.of(Vehicles.vehicles);

  /// Returns an unmodifiable snapshot of the current vehicle list.
  List<Vehicle> getVehicles() => List.unmodifiable(_vehicles);

  /// Adds a new [vehicle] to the in-memory collection.
  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
  }
}
