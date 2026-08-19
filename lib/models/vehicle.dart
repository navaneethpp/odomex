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
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.odometerReading,
    required this.registrationNumber,
    required this.color,
    required this.fuelType,
    required this.engineCapacity,
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
  });

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
  final int engineCapacity;

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
}
