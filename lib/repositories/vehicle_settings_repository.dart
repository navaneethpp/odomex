import 'package:odomex/data/local/data_sources/vehicle_settings_local_data_source.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';

/// Repository managing vehicle-specific configurations.
class VehicleSettingsRepository {
  VehicleSettingsRepository({
    required this.localDataSource,
  });

  final VehicleSettingsLocalDataSource localDataSource;

  /// Retrieves custom override settings for [vehicleId], or returns empty overrides (uses global defaults).
  VehicleSettings getSettingsForVehicle(Vehicle vehicle) {
    final existing = localDataSource.getSettings(vehicle.id);
    if (existing != null) return existing;
    return VehicleSettings(vehicleId: vehicle.id);
  }

  /// Persists [settings] locally.
  Future<void> saveSettings(VehicleSettings settings) =>
      localDataSource.saveSettings(settings);

  /// Deletes settings for [vehicleId] (e.g. when vehicle is deleted or reset to defaults).
  Future<void> deleteSettings(String vehicleId) =>
      localDataSource.deleteSettings(vehicleId);
}
