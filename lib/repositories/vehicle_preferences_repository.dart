import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';

/// Repository managing vehicle-specific user preferences (such as pin state).
class VehiclePreferencesRepository {
  VehiclePreferencesRepository({
    required this.localDataSource,
  });

  final VehiclePreferencesLocalDataSource localDataSource;

  /// Retrieves user preferences for [vehicleId], defaulting to unpinned if none stored.
  VehiclePreferences getPreference(String vehicleId) {
    return localDataSource.getPreference(vehicleId) ??
        VehiclePreferences(vehicleId: vehicleId);
  }

  /// Retrieves all vehicle preferences keyed by vehicle ID.
  Map<String, VehiclePreferences> getAllPreferences() {
    return localDataSource.getAllPreferences();
  }

  /// Persists [preference].
  Future<void> savePreference(VehiclePreferences preference) =>
      localDataSource.savePreference(preference);

  /// Deletes preferences for [vehicleId].
  Future<void> deletePreference(String vehicleId) =>
      localDataSource.deletePreference(vehicleId);
}
