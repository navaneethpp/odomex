/// Centralized Hive box names for the application.
///
/// Keeps box names consistent and prevents hardcoded strings throughout the app.
class HiveBoxes {
  HiveBoxes._();

  /// Box storing all [Vehicle] entities, keyed by [Vehicle.id].
  static const String vehicles = 'vehicles';

  /// Box storing all [VehicleRecord] entities, keyed by [VehicleRecord.id].
  static const String vehicleRecords = 'vehicle_records';

  /// Box storing general app settings / flags (e.g. first-time seed status).
  static const String appSettings = 'app_settings';
}
