import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';

/// Abstract data source for reading and persisting [VehiclePreferences] locally.
abstract class VehiclePreferencesLocalDataSource {
  /// Retrieves preferences for [vehicleId], or null if not yet customized.
  VehiclePreferences? getPreference(String vehicleId);

  /// Retrieves all stored vehicle preferences keyed by vehicle ID.
  Map<String, VehiclePreferences> getAllPreferences();

  /// Persists [preference] keyed by [VehiclePreferences.vehicleId].
  Future<void> savePreference(VehiclePreferences preference);

  /// Deletes stored preferences for [vehicleId].
  Future<void> deletePreference(String vehicleId);
}

/// Hive CE implementation of [VehiclePreferencesLocalDataSource].
class HiveVehiclePreferencesLocalDataSource
    implements VehiclePreferencesLocalDataSource {
  HiveVehiclePreferencesLocalDataSource({
    Box<dynamic>? preferencesBox,
  }) : _customBox = preferencesBox;

  final Box<dynamic>? _customBox;

  Box<dynamic>? get _box =>
      _customBox ??
      (Hive.isBoxOpen(HiveBoxes.vehiclePreferences)
          ? Hive.box<dynamic>(HiveBoxes.vehiclePreferences)
          : null);

  @override
  VehiclePreferences? getPreference(String vehicleId) {
    final box = _box;
    if (box == null) return null;

    final raw = box.get(vehicleId);
    if (raw is Map) {
      return VehiclePreferences.fromMap(raw, vehicleId);
    }
    return null;
  }

  @override
  Map<String, VehiclePreferences> getAllPreferences() {
    final box = _box;
    if (box == null) return {};

    final map = <String, VehiclePreferences>{};
    for (final key in box.keys) {
      if (key is String) {
        final raw = box.get(key);
        if (raw is Map) {
          map[key] = VehiclePreferences.fromMap(raw, key);
        }
      }
    }
    return map;
  }

  @override
  Future<void> savePreference(VehiclePreferences preference) async {
    final box = _box;
    if (box != null) {
      await box.put(preference.vehicleId, preference.toMap());
    }
  }

  @override
  Future<void> deletePreference(String vehicleId) async {
    final box = _box;
    if (box != null) {
      await box.delete(vehicleId);
    }
  }
}
