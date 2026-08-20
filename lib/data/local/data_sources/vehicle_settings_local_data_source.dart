import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';

/// Abstract data source for persisting vehicle-specific settings.
abstract class VehicleSettingsLocalDataSource {
  VehicleSettings? getSettings(String vehicleId);
  Future<void> saveSettings(VehicleSettings settings);
  Future<void> deleteSettings(String vehicleId);
}

/// Hive CE implementation of [VehicleSettingsLocalDataSource].
class HiveVehicleSettingsLocalDataSource
    implements VehicleSettingsLocalDataSource {
  HiveVehicleSettingsLocalDataSource({
    Box<dynamic>? settingsBox,
  }) : _customBox = settingsBox;

  final Box<dynamic>? _customBox;

  Box<dynamic>? get _settingsBox =>
      _customBox ??
      (Hive.isBoxOpen(HiveBoxes.vehicleSettings)
          ? Hive.box<dynamic>(HiveBoxes.vehicleSettings)
          : null);

  @override
  VehicleSettings? getSettings(String vehicleId) {
    final box = _settingsBox;
    if (box == null) return null;

    final raw = box.get(vehicleId);
    if (raw is Map) {
      return VehicleSettings.fromMap(raw, vehicleId);
    }
    return null;
  }

  @override
  Future<void> saveSettings(VehicleSettings settings) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(settings.vehicleId, settings.toMap());
    }
  }

  @override
  Future<void> deleteSettings(String vehicleId) async {
    final box = _settingsBox;
    if (box != null) {
      await box.delete(vehicleId);
    }
  }
}
