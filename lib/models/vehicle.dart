import 'package:odomex/models/vehicle_type.dart';
import 'package:odomex/models/powertrain_type.dart';
import 'package:odomex/models/energy_source.dart';

export 'package:odomex/models/vehicle_type.dart';
export 'package:odomex/models/powertrain_type.dart';
export 'package:odomex/models/energy_source.dart';

enum VehicleBrand {
  // ── Existing Two-Wheeler Baseline (Index 0-5 for Hive compatibility) ──
  honda,
  hero,
  suzuki,
  ktm,
  royalEnfield,
  triumph,

  // ── Motorcycles & Scooters ──
  bajaj,
  tvs,
  yamaha,
  jawa,
  yezdi,
  kawasaki,
  harleyDavidson,
  bmwMotorrad,
  aprilia,
  husqvarna,
  benelli,
  ducati,
  revolt,
  ultraviolette,
  olaElectric,
  ather,
  vespa,
  heroElectric,
  simpleEnergy,
  river,
  vida,
  chetak,

  // ── Auto Rickshaws & Three Wheelers ──
  piaggio,
  atulAuto,
  euler,
  saarthi,
  lohia,

  // ── Cars & Passenger Vehicles ──
  marutiSuzuki,
  hyundai,
  tataMotors,
  mahindra,
  toyota,
  kia,
  renault,
  nissan,
  volkswagen,
  skoda,
  mg,
  jeep,
  citroen,
  bmw,
  mercedesBenz,
  audi,
  volvo,
  lexus,
  landRover,
  byd,
  vinfast,
  porsche,
  jaguar,
  mini,

  // ── Pickups, Vans, LCVs & Commercial ──
  isuzu,
  forceMotors,

  // ── Buses & Heavy Commercial ──
  ashokLeyland,
  eicher,
  bharatBenz,
  smlIsuzu,
  scania,

  // ── Fallback / Custom ──
  other,
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
      case VehicleBrand.bajaj:
        return 'Bajaj';
      case VehicleBrand.tvs:
        return 'TVS';
      case VehicleBrand.yamaha:
        return 'Yamaha';
      case VehicleBrand.jawa:
        return 'Jawa';
      case VehicleBrand.yezdi:
        return 'Yezdi';
      case VehicleBrand.kawasaki:
        return 'Kawasaki';
      case VehicleBrand.harleyDavidson:
        return 'Harley-Davidson';
      case VehicleBrand.bmwMotorrad:
        return 'BMW Motorrad';
      case VehicleBrand.aprilia:
        return 'Aprilia';
      case VehicleBrand.husqvarna:
        return 'Husqvarna';
      case VehicleBrand.benelli:
        return 'Benelli';
      case VehicleBrand.ducati:
        return 'Ducati';
      case VehicleBrand.revolt:
        return 'Revolt';
      case VehicleBrand.ultraviolette:
        return 'Ultraviolette';
      case VehicleBrand.olaElectric:
        return 'Ola Electric';
      case VehicleBrand.ather:
        return 'Ather';
      case VehicleBrand.vespa:
        return 'Vespa';
      case VehicleBrand.heroElectric:
        return 'Hero Electric';
      case VehicleBrand.simpleEnergy:
        return 'Simple Energy';
      case VehicleBrand.river:
        return 'River';
      case VehicleBrand.vida:
        return 'Vida';
      case VehicleBrand.chetak:
        return 'Chetak';
      case VehicleBrand.piaggio:
        return 'Piaggio';
      case VehicleBrand.atulAuto:
        return 'Atul Auto';
      case VehicleBrand.euler:
        return 'Euler Motors';
      case VehicleBrand.saarthi:
        return 'Saarthi';
      case VehicleBrand.lohia:
        return 'Lohia Auto';
      case VehicleBrand.marutiSuzuki:
        return 'Maruti Suzuki';
      case VehicleBrand.hyundai:
        return 'Hyundai';
      case VehicleBrand.tataMotors:
        return 'Tata Motors';
      case VehicleBrand.mahindra:
        return 'Mahindra';
      case VehicleBrand.toyota:
        return 'Toyota';
      case VehicleBrand.kia:
        return 'Kia';
      case VehicleBrand.renault:
        return 'Renault';
      case VehicleBrand.nissan:
        return 'Nissan';
      case VehicleBrand.volkswagen:
        return 'Volkswagen';
      case VehicleBrand.skoda:
        return 'Skoda';
      case VehicleBrand.mg:
        return 'MG';
      case VehicleBrand.jeep:
        return 'Jeep';
      case VehicleBrand.citroen:
        return 'Citroën';
      case VehicleBrand.bmw:
        return 'BMW';
      case VehicleBrand.mercedesBenz:
        return 'Mercedes-Benz';
      case VehicleBrand.audi:
        return 'Audi';
      case VehicleBrand.volvo:
        return 'Volvo';
      case VehicleBrand.lexus:
        return 'Lexus';
      case VehicleBrand.landRover:
        return 'Land Rover';
      case VehicleBrand.byd:
        return 'BYD';
      case VehicleBrand.vinfast:
        return 'VinFast';
      case VehicleBrand.porsche:
        return 'Porsche';
      case VehicleBrand.jaguar:
        return 'Jaguar';
      case VehicleBrand.mini:
        return 'MINI';
      case VehicleBrand.isuzu:
        return 'Isuzu';
      case VehicleBrand.forceMotors:
        return 'Force Motors';
      case VehicleBrand.ashokLeyland:
        return 'Ashok Leyland';
      case VehicleBrand.eicher:
        return 'Eicher';
      case VehicleBrand.bharatBenz:
        return 'BharatBenz';
      case VehicleBrand.smlIsuzu:
        return 'SML Isuzu';
      case VehicleBrand.scania:
        return 'Scania';
      case VehicleBrand.other:
        return 'Other';
    }
  }

  /// Stable string identifier for persistence and serialization.
  String get id => name;
}

/// Measurement unit for vehicle engine displacement.
enum EngineCapacityUnit {
  cc,
  litres,
}

/// Presentation and formatting helpers for [EngineCapacityUnit].
extension EngineCapacityUnitExtension on EngineCapacityUnit {
  /// User-facing label for selectors (e.g. 'CC', 'Litres').
  String get displayName {
    switch (this) {
      case EngineCapacityUnit.cc:
        return 'CC';
      case EngineCapacityUnit.litres:
        return 'Litres';
    }
  }

  /// Compact unit abbreviation (e.g. 'cc', 'L').
  String get shortName {
    switch (this) {
      case EngineCapacityUnit.cc:
        return 'cc';
      case EngineCapacityUnit.litres:
        return 'L';
    }
  }
}

class Vehicle {
  Vehicle({
    String? id,
    VehicleType? vehicleType,
    required this.brand,
    this.customBrand,
    required this.model,
    required this.manufacturingYear,
    required this.odometerReading,
    required this.registrationNumber,
    required this.color,
    required this.fuelType, // Legacy compatibility, prefer powertrainType
    PowertrainType? powertrainType,
    this.engineCapacity,
    EngineCapacityUnit? engineCapacityUnit,
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
    this.oilChangeInterval,
    this.lastOilChangeOdometer,
    this.lastOilChangeDate,

    // Access tracking
    this.lastAccessedAt,
  })  : id = id ?? _generateId(),
        vehicleType = vehicleType ?? _inferVehicleType(model, brand),
        powertrainType = powertrainType ?? _inferPowertrainType(fuelType),
        engineCapacityUnit = engineCapacityUnit ??
            (engineCapacity != null ? EngineCapacityUnit.cc : null);

  // ─────────────────────────────────────────────
  // UNIQUE IDENTIFIER
  // ─────────────────────────────────────────────

  /// Stable, unique identifier for this vehicle.
  final String id;

  static String _generateId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final salt = Object().hashCode;
    return '${ts ^ salt}';
  }

  /// Infers the appropriate [VehicleType] for legacy vehicles where vehicleType was not stored.
  static VehicleType _inferVehicleType(String model, VehicleBrand brand) {
    final lower = model.toLowerCase();
    if (lower.contains('activa') ||
        lower.contains('jupiter') ||
        lower.contains('access') ||
        lower.contains('ntorq') ||
        lower.contains('pleasure') ||
        lower.contains('dio') ||
        lower.contains('burgman') ||
        lower.contains('ray') ||
        lower.contains('fascino') ||
        lower.contains('destini') ||
        lower.contains('maestro') ||
        lower.contains('ather') ||
        lower.contains('ola') ||
        lower.contains('chetak') ||
        lower.contains('vespa') ||
        lower.contains('aerox')) {
      return VehicleType.scooter;
    }
    if (lower.contains('swift') ||
        lower.contains('nexon') ||
        lower.contains('city') ||
        lower.contains('creta') ||
        lower.contains('innova') ||
        lower.contains('i20') ||
        lower.contains('baleno') ||
        lower.contains('fortuner') ||
        lower.contains('harrier') ||
        lower.contains('thar') ||
        lower.contains('scorpio')) {
      return VehicleType.car;
    }
    if (lower.contains('ace') ||
        lower.contains('bolero maxi') ||
        lower.contains('d-max') ||
        lower.contains('dmax') ||
        lower.contains('hilux')) {
      return VehicleType.pickup;
    }
    if (lower.contains('traveller') ||
        lower.contains('eeco') ||
        lower.contains('omni') ||
        lower.contains('winger')) {
      return VehicleType.van;
    }
    if (lower.contains('bus') ||
        lower.contains('viking') ||
        lower.contains('starbus') ||
        lower.contains('skyliner')) {
      return VehicleType.bus;
    }
    if (lower.contains('auto') ||
        lower.contains('rickshaw') ||
        lower.contains('ape') ||
        lower.contains('compact') ||
        lower.contains('maxima') ||
        lower.contains('alfa')) {
      return VehicleType.autoRickshaw;
    }
    return VehicleType.motorcycle;
  }

  /// Infers the appropriate [PowertrainType] from a legacy fuel type string.
  static PowertrainType _inferPowertrainType(String fuelType) {
    final lower = fuelType.toLowerCase();
    if (lower.contains('diesel')) {
      return PowertrainType.diesel;
    }
    if (lower.contains('cng')) {
      return PowertrainType.cngPetrol;
    }
    if (lower.contains('electric')) {
      return PowertrainType.ev;
    }
    if (lower.contains('hybrid')) {
      return PowertrainType.hybrid; // Safe default for unknown legacy
    }
    return PowertrainType.petrol;
  }

  // ─────────────────────────────────────────────
  // VEHICLE IDENTIFICATION
  // ─────────────────────────────────────────────

  final VehicleType vehicleType;
  final VehicleBrand brand;
  final String? customBrand;
  final String model;
  final int manufacturingYear;

  final String registrationNumber;
  final String color;

  /// Returns the effective display name for the brand (supports custom brands).
  String get brandDisplayName {
    if (brand == VehicleBrand.other &&
        customBrand != null &&
        customBrand!.trim().isNotEmpty) {
      return customBrand!.trim();
    }
    return brand.displayName;
  }

  // ─────────────────────────────────────────────
  // ODOMETER
  // ─────────────────────────────────────────────

  final double odometerReading;

  // ─────────────────────────────────────────────
  // ENGINE
  // ─────────────────────────────────────────────

  /// The legacy fuel type string. Prefer [powertrainType].
  final String fuelType;
  
  /// The selected powertrain for this vehicle.
  final PowertrainType? powertrainType;

  /// Available energy sources for this vehicle based on its powertrain.
  List<EnergySource> get availableEnergySources {
    final pt = powertrainType ?? Vehicle._inferPowertrainType(fuelType);
    switch (pt) {
      case PowertrainType.petrol:
        return [EnergySource.petrol];
      case PowertrainType.diesel:
        return [EnergySource.diesel];
      case PowertrainType.cngPetrol:
        return [EnergySource.cng, EnergySource.petrol];
      case PowertrainType.hybrid:
        return [EnergySource.petrol, EnergySource.electricity];
      case PowertrainType.plugInHybrid:
        return [EnergySource.petrol, EnergySource.electricity];
      case PowertrainType.ev:
        return [EnergySource.electricity];
    }
  }

  /// Whether this vehicle supports external charging (plug-in).
  bool get supportsCharging {
    final pt = powertrainType ?? Vehicle._inferPowertrainType(fuelType);
    return pt == PowertrainType.plugInHybrid;
  }

  /// Engine displacement value (numeric in CC or decimal in Litres).
  /// Null for electric vehicles, which have no displacement.
  final double? engineCapacity;

  /// The unit associated with [engineCapacity] (CC or Litres).
  /// Null for electric vehicles.
  final EngineCapacityUnit? engineCapacityUnit;

  // ─────────────────────────────────────────────
  // USAGE
  // ─────────────────────────────────────────────

  final DateTime purchaseDate;

  // ─────────────────────────────────────────────
  // SERVICE INFORMATION
  // ─────────────────────────────────────────────

  final DateTime? lastServiceDate;
  final double? nextServiceOdometer;

  // ─────────────────────────────────────────────
  // INSURANCE INFORMATION
  // ─────────────────────────────────────────────

  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceEndDate;

  // ─────────────────────────────────────────────
  // PUC (POLLUTION UNDER CONTROL) INFORMATION
  // ─────────────────────────────────────────────

  final String? pucCertificateNumber;
  final DateTime? pucStartDate;
  final DateTime? pucEndDate;

  // ─────────────────────────────────────────────
  // OIL CHANGE INFORMATION
  // ─────────────────────────────────────────────

  /// Oil change interval in kilometres.
  final double? oilChangeInterval;

  /// Odometer reading at the last oil change (km).
  final double? lastOilChangeOdometer;

  final DateTime? lastOilChangeDate;

  // ─────────────────────────────────────────────
  // ACCESS TRACKING
  // ─────────────────────────────────────────────

  final DateTime? lastAccessedAt;

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
  bool get hasInsurance =>
      insuranceProvider != null ||
      insurancePolicyNumber != null ||
      insuranceStartDate != null ||
      insuranceEndDate != null;

  /// Whether this vehicle has PUC information recorded.
  bool get hasPuc =>
      pucCertificateNumber != null ||
      pucStartDate != null ||
      pucEndDate != null;

  /// Whether this vehicle has oil change information recorded.
  bool get hasOilChange => lastOilChangeDate != null;

  // ─────────────────────────────────────────────
  // COPY WITH
  // ─────────────────────────────────────────────

  Vehicle copyWith({
    VehicleType? vehicleType,
    VehicleBrand? brand,
    String? customBrand,
    String? model,
    int? manufacturingYear,
    double? odometerReading,
    String? registrationNumber,
    String? color,
    String? fuelType,
    PowertrainType? powertrainType,
    double? engineCapacity,
    EngineCapacityUnit? engineCapacityUnit,
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
    Object? lastAccessedAt = _kUnset,
  }) {
    return Vehicle(
      id: id,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      customBrand: customBrand ?? this.customBrand,
      model: model ?? this.model,
      manufacturingYear: manufacturingYear ?? this.manufacturingYear,
      odometerReading: odometerReading ?? this.odometerReading,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      powertrainType: powertrainType ?? this.powertrainType,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      engineCapacityUnit: engineCapacityUnit ?? this.engineCapacityUnit,
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
      lastAccessedAt: identical(lastAccessedAt, _kUnset)
          ? this.lastAccessedAt
          : lastAccessedAt as DateTime?,
    );
  }
}

/// Sentinel value used by [Vehicle.copyWith] to distinguish between
/// "caller did not pass lastAccessedAt" and "caller explicitly passed null".
const Object _kUnset = Object();
