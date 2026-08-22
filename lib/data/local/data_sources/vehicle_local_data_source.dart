import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/models/vehicle.dart';

/// Abstract local data source contract for vehicles.
///
/// Decouples the repository from direct Hive dependencies so that storage
/// implementations can be replaced or mocked in unit tests.
abstract class VehicleLocalDataSource {
  /// Returns all vehicles stored in the local data store.
  List<Vehicle> getVehicles();

  /// Returns a specific vehicle by its [vehicleId], or null if not found.
  Vehicle? getVehicle(String vehicleId);

  /// Persists a new [vehicle].
  Future<void> addVehicle(Vehicle vehicle);

  /// Updates an existing [vehicle].
  Future<void> updateVehicle(Vehicle vehicle);

  /// Deletes a vehicle by its [vehicleId].
  Future<void> deleteVehicle(String vehicleId);
}

/// Hive CE implementation of [VehicleLocalDataSource].
class HiveVehicleLocalDataSource implements VehicleLocalDataSource {
  HiveVehicleLocalDataSource({
    Box<Vehicle>? vehicleBox,
    Box<dynamic>? settingsBox,
  })  : _vehicleBox = vehicleBox ?? Hive.box<Vehicle>(HiveBoxes.vehicles);

  final Box<Vehicle> _vehicleBox;

  @override
  List<Vehicle> getVehicles() {
    return _vehicleBox.values.toList();
  }

  @override
  Vehicle? getVehicle(String vehicleId) {
    return _vehicleBox.get(vehicleId);
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    await _vehicleBox.put(vehicle.id, vehicle);
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehicleBox.put(vehicle.id, vehicle);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehicleBox.delete(vehicleId);
  }
}
