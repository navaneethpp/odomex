enum EnergySource {
  petrol,
  diesel,
  cng,
  electricity,
}

extension EnergySourceExtension on EnergySource {
  String get displayName {
    switch (this) {
      case EnergySource.petrol:
        return 'Petrol';
      case EnergySource.diesel:
        return 'Diesel';
      case EnergySource.cng:
        return 'CNG';
      case EnergySource.electricity:
        return 'Electricity';
    }
  }

  String get unit {
    switch (this) {
      case EnergySource.petrol:
      case EnergySource.diesel:
        return 'L';
      case EnergySource.cng:
        return 'kg';
      case EnergySource.electricity:
        return 'kWh';
    }
  }
}
