/// Sealed base class for all vehicle records.
///
/// Using a sealed class allows exhaustive pattern matching on record types
/// throughout the application. Adding a new record type is a compile-time
/// checked operation — the analyser will flag any switch that does not handle
/// the new subtype.
///
/// All subclasses are defined in this file to keep the sealed hierarchy in one
/// place.
sealed class VehicleRecord {
  const VehicleRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
  });

  /// Unique record identifier.
  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// The date the real-world event occurred (not necessarily when the record
  /// was created in the app).
  final DateTime date;

  /// Generates a simple unique ID. When persistent storage is introduced,
  /// the database should supply stable IDs instead.
  static String generateId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
}

// ─────────────────────────────────────────────────────────────────────────────
// ODOMETER
// ─────────────────────────────────────────────────────────────────────────────

/// A single odometer reading logged for a vehicle.
class OdometerRecord extends VehicleRecord {
  const OdometerRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    required this.odometer,
    this.notes,
  });

  /// Factory that auto-generates a record ID.
  factory OdometerRecord.create({
    required String vehicleId,
    required DateTime date,
    required double odometer,
    String? notes,
  }) =>
      OdometerRecord(
        id: VehicleRecord.generateId('odo'),
        vehicleId: vehicleId,
        date: date,
        odometer: odometer,
        notes: notes,
      );

  /// Odometer reading in kilometres.
  final double odometer;

  /// Optional free-form notes.
  final String? notes;
}

// ─────────────────────────────────────────────────────────────────────────────
// FUEL REFILL
// ─────────────────────────────────────────────────────────────────────────────

/// A fuel refill event for a vehicle.
class FuelRecord extends VehicleRecord {
  const FuelRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    required this.quantity,
    required this.cost,
    this.odometerReading,
    this.station,
    this.notes,
  });

  factory FuelRecord.create({
    required String vehicleId,
    required DateTime date,
    required double quantity,
    required double cost,
    double? odometerReading,
    String? station,
    String? notes,
  }) =>
      FuelRecord(
        id: VehicleRecord.generateId('fuel'),
        vehicleId: vehicleId,
        date: date,
        quantity: quantity,
        cost: cost,
        odometerReading: odometerReading,
        station: station,
        notes: notes,
      );

  /// Fuel quantity added, in litres.
  final double quantity;

  /// Total cost of the refill, in INR.
  final double cost;

  /// Odometer reading at the time of refill (km). Optional.
  final double? odometerReading;

  /// Name of the fuel station. Optional.
  final String? station;

  /// Optional notes.
  final String? notes;

  /// Cost per litre, computed from [cost] and [quantity].
  double get costPerLitre => quantity > 0 ? cost / quantity : 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

/// Predefined service categories.
enum ServiceType {
  generalService,
  oilService,
  brakeService,
  engineService,
  electrical,
  other,
}

extension ServiceTypeExtension on ServiceType {
  String get displayName {
    switch (this) {
      case ServiceType.generalService:
        return 'General Service';
      case ServiceType.oilService:
        return 'Oil Service';
      case ServiceType.brakeService:
        return 'Brake Service';
      case ServiceType.engineService:
        return 'Engine Service';
      case ServiceType.electrical:
        return 'Electrical';
      case ServiceType.other:
        return 'Other';
    }
  }
}

/// A service or maintenance event for a vehicle.
class ServiceRecord extends VehicleRecord {
  const ServiceRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    required this.serviceType,
    required this.description,
    this.odometerReading,
    this.cost,
  });

  factory ServiceRecord.create({
    required String vehicleId,
    required DateTime date,
    required ServiceType serviceType,
    required String description,
    double? odometerReading,
    double? cost,
  }) =>
      ServiceRecord(
        id: VehicleRecord.generateId('svc'),
        vehicleId: vehicleId,
        date: date,
        serviceType: serviceType,
        description: description,
        odometerReading: odometerReading,
        cost: cost,
      );

  /// Category of service performed.
  final ServiceType serviceType;

  /// Description of the service, especially relevant when [serviceType] is
  /// [ServiceType.other].
  final String description;

  /// Odometer reading at the time of service (km). Optional.
  final double? odometerReading;

  /// Total service cost, in INR. Optional.
  final double? cost;
}

// ─────────────────────────────────────────────────────────────────────────────
// OIL CHANGE
// ─────────────────────────────────────────────────────────────────────────────

/// An oil change event for a vehicle.
class OilChangeRecord extends VehicleRecord {
  const OilChangeRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    required this.odometerReading,
    this.oilType,
    this.quantity,
    this.cost,
    this.notes,
  });

  factory OilChangeRecord.create({
    required String vehicleId,
    required DateTime date,
    required double odometerReading,
    String? oilType,
    double? quantity,
    double? cost,
    String? notes,
  }) =>
      OilChangeRecord(
        id: VehicleRecord.generateId('oil'),
        vehicleId: vehicleId,
        date: date,
        odometerReading: odometerReading,
        oilType: oilType,
        quantity: quantity,
        cost: cost,
        notes: notes,
      );

  /// Odometer reading at which the oil was changed (km).
  final double odometerReading;

  /// Oil specification, e.g. '10W-40'. Optional.
  final String? oilType;

  /// Oil quantity used, in litres. Optional.
  final double? quantity;

  /// Total cost, in INR. Optional.
  final double? cost;

  /// Optional notes.
  final String? notes;
}
