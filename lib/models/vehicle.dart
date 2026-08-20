
enum VehicleBrand {
  honda,
  hero,
  suzuki,
  ktm,
  royalEnfield,
  triumph,
}

/// Returns a human-friendly display name for a [VehicleBrand] value.
extension VehicleBrandExtension on VehicleBrand {
  String get displayName {
    switch (this) {
      case VehicleBrand.honda:
        return 'Honda';
      case VehicleBrand.hero:
        return 'Hero';
      case VehicleBrand.suzuki:
        return 'Suzuki';
      case VehicleBrand.ktm:
        return 'KTM';
      case VehicleBrand.royalEnfield:
        return 'Royal Enfield';
      case VehicleBrand.triumph:
        return 'Triumph';
    }
  }
}

class Vehicle {
  Vehicle({
    String? id,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.odometerReading,
    required this.registrationNumber,
    required this.color,
    required this.fuelType,
    this.engineCapacity,
    required this.purchaseDate,
    this.lastServiceDate,
    this.nextServiceOdometer,

    // Insurance information
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.insuranceStartDate,
    this.insuranceEndDate,

    // PUC (Pollution Under Control) information
    this.pucCertificateNumber,
    this.pucStartDate,
    this.pucEndDate,

    // Oil change information
    // These store the latest values; historical records will later move to OilChangeRecord
    this.oilChangeInterval,
    this.lastOilChangeOdometer,
    this.lastOilChangeDate,
  }) : id = id ?? _generateId();

  // ─────────────────────────────────────────────
  // UNIQUE IDENTIFIER
  // ─────────────────────────────────────────────

  /// Stable, unique identifier for this vehicle.
  ///
  /// Generated automatically when not supplied. Uses a microsecond timestamp
  /// combined with a hashCode salt to avoid collisions when multiple vehicles
  /// are created in quick succession.
  ///
  /// When persisting to a database, store and restore this value so that all
  /// related records (OdometerRecord, FuelRecord, etc.) can keep referencing
  /// the same vehicleId without re-generating it.
  final String id;

  static String _generateId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    // XOR with a pseudo-random value for extra uniqueness within the same µs.
    final salt = Object().hashCode;
    return '${ts ^ salt}';
  }

  // ─────────────────────────────────────────────
  // VEHICLE IDENTIFICATION
  // ─────────────────────────────────────────────

  final VehicleBrand brand;
  final String model;
  final int manufacturingYear;

  final String registrationNumber;
  final String color;

  // ─────────────────────────────────────────────
  // ODOMETER
  // ─────────────────────────────────────────────

  final double odometerReading;

  // ─────────────────────────────────────────────
  // ENGINE
  // ─────────────────────────────────────────────

  final String fuelType;

  /// Engine displacement in cubic centimetres (cc).
  /// Null for electric vehicles, which have no cc displacement.
  final int? engineCapacity;

  // ─────────────────────────────────────────────
  // USAGE
  // ─────────────────────────────────────────────

  final DateTime purchaseDate;

  // ─────────────────────────────────────────────
  // SERVICE INFORMATION
  // Nullable: new vehicles may not have service records yet.
  // Historical records will later move to a dedicated ServiceRecord model.
  // ─────────────────────────────────────────────

  final DateTime? lastServiceDate;
  final double? nextServiceOdometer;

  // ─────────────────────────────────────────────
  // INSURANCE INFORMATION
  // Nullable: insurance details are optional at vehicle creation.
  // ─────────────────────────────────────────────

  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceEndDate;

  // ─────────────────────────────────────────────
  // PUC (POLLUTION UNDER CONTROL) INFORMATION
  // Nullable: PUC details are optional at vehicle creation.
  // ─────────────────────────────────────────────

  final String? pucCertificateNumber;
  final DateTime? pucStartDate;
  final DateTime? pucEndDate;

  // ─────────────────────────────────────────────
  // OIL CHANGE INFORMATION
  // Nullable: oil change details are optional at vehicle creation.
  // Stores the current/latest values only.
  // Historical oil change records will later move to an OilChangeRecord model.
  // ─────────────────────────────────────────────

  /// Oil change interval in kilometres.
  final double? oilChangeInterval;

  /// Odometer reading at the last oil change (km).
  final double? lastOilChangeOdometer;

  final DateTime? lastOilChangeDate;

  // ─────────────────────────────────────────────
  // COMPUTED PROPERTIES
  // ─────────────────────────────────────────────

  /// Odometer reading at which the next oil change is due.
  /// Returns null if oil change information is not available.
  double? get nextOilChangeOdometer {
    if (lastOilChangeOdometer == null || oilChangeInterval == null) return null;
    return lastOilChangeOdometer! + oilChangeInterval!;
  }

  /// Whether this vehicle has insurance information recorded.
  bool get hasInsurance => insuranceProvider != null;

  /// Whether this vehicle has PUC information recorded.
  bool get hasPuc => pucCertificateNumber != null;

  /// Whether this vehicle has oil change information recorded.
  bool get hasOilChange => lastOilChangeDate != null;

  // ─────────────────────────────────────────────
  // COPY WITH
  // ─────────────────────────────────────────────

  /// Returns a copy of this vehicle with the given fields replaced.
  ///
  /// The [id] is preserved so that all related records still reference the
  /// correct vehicle after an update.
  Vehicle copyWith({
    VehicleBrand? brand,
    String? model,
    int? manufacturingYear,
    double? odometerReading,
    String? registrationNumber,
    String? color,
    String? fuelType,
    int? engineCapacity,
    DateTime? purchaseDate,
    DateTime? lastServiceDate,
    double? nextServiceOdometer,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime? insuranceStartDate,
    DateTime? insuranceEndDate,
    String? pucCertificateNumber,
    DateTime? pucStartDate,
    DateTime? pucEndDate,
    double? oilChangeInterval,
    double? lastOilChangeOdometer,
    DateTime? lastOilChangeDate,
  }) {
    return Vehicle(
      id: id, // always preserved
      brand: brand ?? this.brand,
      model: model ?? this.model,
      manufacturingYear: manufacturingYear ?? this.manufacturingYear,
      odometerReading: odometerReading ?? this.odometerReading,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber:
          insurancePolicyNumber ?? this.insurancePolicyNumber,
      insuranceStartDate: insuranceStartDate ?? this.insuranceStartDate,
      insuranceEndDate: insuranceEndDate ?? this.insuranceEndDate,
      pucCertificateNumber: pucCertificateNumber ?? this.pucCertificateNumber,
      pucStartDate: pucStartDate ?? this.pucStartDate,
      pucEndDate: pucEndDate ?? this.pucEndDate,
      oilChangeInterval: oilChangeInterval ?? this.oilChangeInterval,
      lastOilChangeOdometer:
          lastOilChangeOdometer ?? this.lastOilChangeOdometer,
      lastOilChangeDate: lastOilChangeDate ?? this.lastOilChangeDate,
    );
  }
}
