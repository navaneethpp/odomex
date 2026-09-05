enum PowertrainType {
  petrol,
  diesel,
  cngPetrol,
  hybrid,
  plugInHybrid,
  ev,
}

extension PowertrainTypeExtension on PowertrainType {
  String get displayName {
    switch (this) {
      case PowertrainType.petrol:
        return 'Petrol';
      case PowertrainType.diesel:
        return 'Diesel';
      case PowertrainType.cngPetrol:
        return 'CNG + Petrol';
      case PowertrainType.hybrid:
        return 'Hybrid';
      case PowertrainType.plugInHybrid:
        return 'Plug-in Hybrid';
      case PowertrainType.ev:
        return 'Electric Vehicle (EV)';
    }
  }

  String get description {
    switch (this) {
      case PowertrainType.petrol:
        return 'Standard petrol engine';
      case PowertrainType.diesel:
        return 'Standard diesel engine';
      case PowertrainType.cngPetrol:
        return 'Uses both CNG and petrol';
      case PowertrainType.hybrid:
        return 'Petrol + electric power';
      case PowertrainType.plugInHybrid:
        return 'Petrol + electric power with external charging';
      case PowertrainType.ev:
        return 'Pure electric motor power';
    }
  }

  /// Whether Pollution Under Control (PUC) certification is applicable.
  /// Electric Vehicles (EVs) do not require PUC.
  bool get isPucApplicable {
    return this != PowertrainType.ev;
  }

  /// Whether conventional engine oil changes are applicable.
  /// Pure Electric Vehicles (EVs) do not have conventional engine oil.
  bool get isOilChangeApplicable {
    return this != PowertrainType.ev;
  }
}
