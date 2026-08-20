import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/models/vehicle.dart';

/// Repository for vehicle data.
///
/// Backed by a [VehicleLocalDataSource] (e.g. Hive). Provides clean access
/// to vehicles while isolating Riverpod notifiers and UI components from
/// direct database dependencies.
class VehiclesRepository {
  VehiclesRepository({
    required this.localDataSource,
  });

  final VehicleLocalDataSource localDataSource;

  /// Returns all vehicles currently stored.
  List<Vehicle> getAll() => localDataSource.getVehicles();

  /// Returns the vehicle with [id], or null if not found.
  Vehicle? getById(String id) => localDataSource.getVehicle(id);

  /// Persists a new [vehicle].
  Future<void> add(Vehicle vehicle) => localDataSource.addVehicle(vehicle);

  /// Updates an existing [vehicle].
  Future<void> update(Vehicle vehicle) => localDataSource.updateVehicle(vehicle);

  /// Deletes the vehicle with [vehicleId].
  Future<void> delete(String vehicleId) => localDataSource.deleteVehicle(vehicleId);
}
