/// Sealed base class for all vehicle historical activity records.
///
/// Using a sealed class allows exhaustive pattern matching on record types
/// throughout the application. Adding a new record type is a compile-time
/// checked operation — the analyser will flag any switch that does not handle
/// the new subtype.
///
/// All subclasses are defined in this file to keep the sealed hierarchy unified.
sealed class VehicleRecord {
  const VehicleRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    this.createdAt,
  });

  /// Unique record identifier.
  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// The date the real-world activity occurred.
  final DateTime date;

  /// When this record was entered into the application.
  final DateTime? createdAt;

  /// Alias for [date], indicating when the physical event occurred.
  DateTime get recordedAt => date;

  /// Generates a unique, stable ID for new records.
  static String generateId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
}

// ─────────────────────────────────────────────────────────────────────────────
// ODOMETER RECORD
// ─────────────────────────────────────────────────────────────────────────────

/// A single odometer reading logged for a vehicle.
class OdometerRecord extends VehicleRecord {
  const OdometerRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    super.createdAt,
    required this.odometer,
    this.notes,
  });

  /// Factory that auto-generates a record ID and sets creation timestamp.
  factory OdometerRecord.create({
    required String vehicleId,
    required DateTime date,
    required double odometer,
    String? notes,
    DateTime? createdAt,
  }) =>
      OdometerRecord(
        id: VehicleRecord.generateId('odo'),
        vehicleId: vehicleId,
        date: date,
        createdAt: createdAt ?? DateTime.now(),
        odometer: odometer,
        notes: notes,
      );

  /// Odometer reading in kilometres.
  final double odometer;

  /// Alias for [odometer] reading in km.
  double get odometerReading => odometer;

  /// Optional free-form notes.
  final String? notes;
}

// ─────────────────────────────────────────────────────────────────────────────
// FUEL REFILL RECORD
// ─────────────────────────────────────────────────────────────────────────────

/// A fuel refill event for a vehicle.
class FuelRecord extends VehicleRecord {
  const FuelRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    super.createdAt,
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
    DateTime? createdAt,
  }) =>
      FuelRecord(
        id: VehicleRecord.generateId('fuel'),
        vehicleId: vehicleId,
        date: date,
        createdAt: createdAt ?? DateTime.now(),
        quantity: quantity,
        cost: cost,
        odometerReading: odometerReading,
        station: station,
        notes: notes,
      );

  /// Fuel quantity added, in litres.
  final double quantity;

  /// Alias for [quantity] in litres.
  double get fuelQuantity => quantity;

  /// Total cost of the refill, in INR.
  final double cost;

  /// Alias for [cost] in INR.
  double get fuelCost => cost;

  /// Odometer reading at the time of refill (km).
  final double? odometerReading;

  /// Name of the fuel station.
  final String? station;

  /// Alias for [station].
  String? get fuelStation => station;

  /// Optional notes.
  final String? notes;

  /// Cost per litre, computed from [cost] and [quantity].
  double get costPerLitre => quantity > 0 ? cost / quantity : 0;

  /// Alias for [costPerLitre].
  double get fuelPricePerUnit => costPerLitre;
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE RECORD
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
    super.createdAt,
    required this.serviceType,
    required this.description,
    this.odometerReading,
    this.cost,
    this.notes,
  });

  factory ServiceRecord.create({
    required String vehicleId,
    required DateTime date,
    required ServiceType serviceType,
    required String description,
    double? odometerReading,
    double? cost,
    String? notes,
    DateTime? createdAt,
  }) =>
      ServiceRecord(
        id: VehicleRecord.generateId('svc'),
        vehicleId: vehicleId,
        date: date,
        createdAt: createdAt ?? DateTime.now(),
        serviceType: serviceType,
        description: description,
        odometerReading: odometerReading,
        cost: cost,
        notes: notes,
      );

  /// Category of service performed.
  final ServiceType serviceType;

  /// Description of the service.
  final String description;

  /// Odometer reading at the time of service (km).
  final double? odometerReading;

  /// Total service cost, in INR.
  final double? cost;

  /// Optional notes.
  final String? notes;
}

// ─────────────────────────────────────────────────────────────────────────────
// OIL CHANGE RECORD
// ─────────────────────────────────────────────────────────────────────────────

/// An oil change event for a vehicle.
class OilChangeRecord extends VehicleRecord {
  const OilChangeRecord({
    required super.id,
    required super.vehicleId,
    required super.date,
    super.createdAt,
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
    DateTime? createdAt,
  }) =>
      OilChangeRecord(
        id: VehicleRecord.generateId('oil'),
        vehicleId: vehicleId,
        date: date,
        createdAt: createdAt ?? DateTime.now(),
        odometerReading: odometerReading,
        oilType: oilType,
        quantity: quantity,
        cost: cost,
        notes: notes,
      );

  /// Odometer reading at which the oil was changed (km).
  final double odometerReading;

  /// Oil specification, e.g. '10W-40'.
  final String? oilType;

  /// Oil quantity used, in litres.
  final double? quantity;

  /// Alias for [quantity].
  double? get oilQuantity => quantity;

  /// Total cost, in INR.
  final double? cost;

  /// Optional notes.
  final String? notes;
}
