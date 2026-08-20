import 'package:odomex/models/fuel_record.dart';
import 'package:odomex/models/odometer_record.dart';
import 'package:odomex/models/oil_change_record.dart';
import 'package:odomex/models/service_record.dart';

/// In-memory repository for all vehicle records (odometer, fuel, service,
/// oil change).
///
/// Records are stored per-vehicle using the vehicle's [String] ID as the key.
/// This class is owned by the Riverpod [vehicleRecordRepositoryProvider] and
/// can later be swapped for a persistent implementation without touching
/// providers or screens.
class VehicleRecordsRepository {
  VehicleRecordsRepository();

  // ── Odometer ───────────────────────────────────────
  final Map<String, List<OdometerRecord>> _odometerRecords = {};

  List<OdometerRecord> getOdometerRecords(String vehicleId) =>
      List.unmodifiable(_odometerRecords[vehicleId] ?? []);

  void addOdometerRecord(OdometerRecord record) {
    _odometerRecords
        .putIfAbsent(record.vehicleId, () => [])
        .add(record);
  }

  // ── Fuel ───────────────────────────────────────────
  final Map<String, List<FuelRecord>> _fuelRecords = {};

  List<FuelRecord> getFuelRecords(String vehicleId) =>
      List.unmodifiable(_fuelRecords[vehicleId] ?? []);

  void addFuelRecord(FuelRecord record) {
    _fuelRecords.putIfAbsent(record.vehicleId, () => []).add(record);
  }

  // ── Service ────────────────────────────────────────
  final Map<String, List<ServiceRecord>> _serviceRecords = {};

  List<ServiceRecord> getServiceRecords(String vehicleId) =>
      List.unmodifiable(_serviceRecords[vehicleId] ?? []);

  void addServiceRecord(ServiceRecord record) {
    _serviceRecords
        .putIfAbsent(record.vehicleId, () => [])
        .add(record);
  }

  // ── Oil Change ─────────────────────────────────────
  final Map<String, List<OilChangeRecord>> _oilChangeRecords = {};

  List<OilChangeRecord> getOilChangeRecords(String vehicleId) =>
      List.unmodifiable(_oilChangeRecords[vehicleId] ?? []);

  void addOilChangeRecord(OilChangeRecord record) {
    _oilChangeRecords
        .putIfAbsent(record.vehicleId, () => [])
        .add(record);
  }
}
