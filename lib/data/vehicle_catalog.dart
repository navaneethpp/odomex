import 'package:odomex/models/vehicle.dart';

/// Centralized catalog mapping vehicle types to supported manufacturers/brands.
class VehicleCatalog {
  VehicleCatalog._();

  static const Map<VehicleType, List<VehicleBrand>> _catalog = {
    VehicleType.motorcycle: [
      VehicleBrand.honda,
      VehicleBrand.hero,
      VehicleBrand.bajaj,
      VehicleBrand.tvs,
      VehicleBrand.yamaha,
      VehicleBrand.royalEnfield,
      VehicleBrand.ktm,
      VehicleBrand.suzuki,
      VehicleBrand.jawa,
      VehicleBrand.yezdi,
      VehicleBrand.triumph,
      VehicleBrand.bmwMotorrad,
      VehicleBrand.kawasaki,
      VehicleBrand.harleyDavidson,
      VehicleBrand.aprilia,
      VehicleBrand.husqvarna,
      VehicleBrand.benelli,
      VehicleBrand.ducati,
      VehicleBrand.revolt,
      VehicleBrand.ultraviolette,
      VehicleBrand.olaElectric,
      VehicleBrand.ather,
      VehicleBrand.other,
    ],
    VehicleType.scooter: [
      VehicleBrand.honda,
      VehicleBrand.tvs,
      VehicleBrand.suzuki,
      VehicleBrand.yamaha,
      VehicleBrand.hero,
      VehicleBrand.bajaj,
      VehicleBrand.ather,
      VehicleBrand.olaElectric,
      VehicleBrand.vespa,
      VehicleBrand.aprilia,
      VehicleBrand.heroElectric,
      VehicleBrand.simpleEnergy,
      VehicleBrand.river,
      VehicleBrand.vida,
      VehicleBrand.chetak,
      VehicleBrand.other,
    ],
    VehicleType.autoRickshaw: [
      VehicleBrand.bajaj,
      VehicleBrand.tvs,
      VehicleBrand.piaggio,
      VehicleBrand.mahindra,
      VehicleBrand.atulAuto,
      VehicleBrand.forceMotors,
      VehicleBrand.euler,
      VehicleBrand.saarthi,
      VehicleBrand.lohia,
      VehicleBrand.other,
    ],
    VehicleType.car: [
      VehicleBrand.marutiSuzuki,
      VehicleBrand.hyundai,
      VehicleBrand.tataMotors,
      VehicleBrand.mahindra,
      VehicleBrand.toyota,
      VehicleBrand.honda,
      VehicleBrand.kia,
      VehicleBrand.renault,
      VehicleBrand.nissan,
      VehicleBrand.volkswagen,
      VehicleBrand.skoda,
      VehicleBrand.mg,
      VehicleBrand.jeep,
      VehicleBrand.citroen,
      VehicleBrand.bmw,
      VehicleBrand.mercedesBenz,
      VehicleBrand.audi,
      VehicleBrand.volvo,
      VehicleBrand.lexus,
      VehicleBrand.landRover,
      VehicleBrand.byd,
      VehicleBrand.vinfast,
      VehicleBrand.porsche,
      VehicleBrand.jaguar,
      VehicleBrand.mini,
      VehicleBrand.other,
    ],
    VehicleType.pickup: [
      VehicleBrand.tataMotors,
      VehicleBrand.mahindra,
      VehicleBrand.isuzu,
      VehicleBrand.toyota,
      VehicleBrand.forceMotors,
      VehicleBrand.ashokLeyland,
      VehicleBrand.other,
    ],
    VehicleType.van: [
      VehicleBrand.marutiSuzuki,
      VehicleBrand.forceMotors,
      VehicleBrand.tataMotors,
      VehicleBrand.mahindra,
      VehicleBrand.ashokLeyland,
      VehicleBrand.toyota,
      VehicleBrand.other,
    ],
    VehicleType.bus: [
      VehicleBrand.tataMotors,
      VehicleBrand.ashokLeyland,
      VehicleBrand.eicher,
      VehicleBrand.volvo,
      VehicleBrand.bharatBenz,
      VehicleBrand.forceMotors,
      VehicleBrand.smlIsuzu,
      VehicleBrand.scania,
      VehicleBrand.other,
    ],
  };

  /// Returns all available [VehicleBrand] options for a specific [type].
  static List<VehicleBrand> getBrandsForType(VehicleType type) {
    return _catalog[type] ?? [VehicleBrand.other];
  }

  /// Checks if a [brand] is valid/supported for a given [type].
  static bool isBrandSupported(VehicleType type, VehicleBrand brand) {
    if (brand == VehicleBrand.other) return true;
    final supported = _catalog[type];
    return supported != null && supported.contains(brand);
  }

  /// Returns all vehicle categories supported by a given [brand].
  static Set<VehicleType> getSupportedTypesForBrand(VehicleBrand brand) {
    if (brand == VehicleBrand.other) return VehicleType.values.toSet();
    final result = <VehicleType>{};
    for (final entry in _catalog.entries) {
      if (entry.value.contains(brand)) {
        result.add(entry.key);
      }
    }
    return result;
  }
}
