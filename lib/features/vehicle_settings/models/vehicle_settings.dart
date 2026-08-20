/// Vehicle-specific maintenance configuration and optional overrides over global defaults.
///
/// If a field is `null`, the vehicle dynamically inherits that property from [GlobalVehicleSettings].
class VehicleSettings {
  const VehicleSettings({
    required this.vehicleId,
    this.serviceIntervalKm,
    this.oilChangeIntervalKm,
    this.serviceReminderEnabled,
    this.oilChangeReminderEnabled,
    this.maintenanceReminderThresholdKm,
    this.pucReminderEnabled,
    this.pucReminderDays,
    this.insuranceReminderEnabled,
    this.insuranceReminderDays,
  });

  final String vehicleId;

  /// Custom distance interval between general services in kilometres (null = use global default).
  final int? serviceIntervalKm;

  /// Custom distance interval between oil changes in kilometres (null = use global default).
  final int? oilChangeIntervalKm;

  /// Custom service reminder switch (null = use global default).
  final bool? serviceReminderEnabled;

  /// Custom oil change reminder switch (null = use global default).
  final bool? oilChangeReminderEnabled;

  /// Custom warning threshold before due distance (null = use global default).
  final int? maintenanceReminderThresholdKm;

  /// Custom PUC reminder switch (null = use global default).
  final bool? pucReminderEnabled;

  /// Custom PUC warning threshold days (null = use global default).
  final int? pucReminderDays;

  /// Custom insurance reminder switch (null = use global default).
  final bool? insuranceReminderEnabled;

  /// Custom insurance warning threshold days (null = use global default).
  final int? insuranceReminderDays;

  /// Whether this vehicle inherits all settings from global defaults without any custom overrides.
  bool get isUsingAllDefaults =>
      serviceIntervalKm == null &&
      oilChangeIntervalKm == null &&
      serviceReminderEnabled == null &&
      oilChangeReminderEnabled == null &&
      maintenanceReminderThresholdKm == null &&
      pucReminderEnabled == null &&
      pucReminderDays == null &&
      insuranceReminderEnabled == null &&
      insuranceReminderDays == null;

  VehicleSettings copyWith({
    String? vehicleId,
    int? serviceIntervalKm,
    int? oilChangeIntervalKm,
    bool? serviceReminderEnabled,
    bool? oilChangeReminderEnabled,
    int? maintenanceReminderThresholdKm,
    bool? pucReminderEnabled,
    int? pucReminderDays,
    bool? insuranceReminderEnabled,
    int? insuranceReminderDays,
    bool clearServiceInterval = false,
    bool clearOilChangeInterval = false,
    bool clearServiceReminder = false,
    bool clearOilChangeReminder = false,
    bool clearMaintenanceThreshold = false,
    bool clearPucReminder = false,
    bool clearPucReminderDays = false,
    bool clearInsuranceReminder = false,
    bool clearInsuranceReminderDays = false,
  }) {
    return VehicleSettings(
      vehicleId: vehicleId ?? this.vehicleId,
      serviceIntervalKm: clearServiceInterval
          ? null
          : (serviceIntervalKm ?? this.serviceIntervalKm),
      oilChangeIntervalKm: clearOilChangeInterval
          ? null
          : (oilChangeIntervalKm ?? this.oilChangeIntervalKm),
      serviceReminderEnabled: clearServiceReminder
          ? null
          : (serviceReminderEnabled ?? this.serviceReminderEnabled),
      oilChangeReminderEnabled: clearOilChangeReminder
          ? null
          : (oilChangeReminderEnabled ?? this.oilChangeReminderEnabled),
      maintenanceReminderThresholdKm: clearMaintenanceThreshold
          ? null
          : (maintenanceReminderThresholdKm ??
              this.maintenanceReminderThresholdKm),
      pucReminderEnabled: clearPucReminder
          ? null
          : (pucReminderEnabled ?? this.pucReminderEnabled),
      pucReminderDays: clearPucReminderDays
          ? null
          : (pucReminderDays ?? this.pucReminderDays),
      insuranceReminderEnabled: clearInsuranceReminder
          ? null
          : (insuranceReminderEnabled ?? this.insuranceReminderEnabled),
      insuranceReminderDays: clearInsuranceReminderDays
          ? null
          : (insuranceReminderDays ?? this.insuranceReminderDays),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'serviceIntervalKm': serviceIntervalKm,
      'oilChangeIntervalKm': oilChangeIntervalKm,
      'serviceReminderEnabled': serviceReminderEnabled,
      'oilChangeReminderEnabled': oilChangeReminderEnabled,
      'maintenanceReminderThresholdKm': maintenanceReminderThresholdKm,
      'pucReminderEnabled': pucReminderEnabled,
      'pucReminderDays': pucReminderDays,
      'insuranceReminderEnabled': insuranceReminderEnabled,
      'insuranceReminderDays': insuranceReminderDays,
    };
  }

  factory VehicleSettings.fromMap(Map<dynamic, dynamic> map, String vehicleId) {
    return VehicleSettings(
      vehicleId: map['vehicleId'] as String? ?? vehicleId,
      serviceIntervalKm: map['serviceIntervalKm'] as int?,
      oilChangeIntervalKm: map['oilChangeIntervalKm'] as int?,
      serviceReminderEnabled: map['serviceReminderEnabled'] as bool?,
      oilChangeReminderEnabled: map['oilChangeReminderEnabled'] as bool?,
      maintenanceReminderThresholdKm:
          map['maintenanceReminderThresholdKm'] as int?,
      pucReminderEnabled: map['pucReminderEnabled'] as bool?,
      pucReminderDays: map['pucReminderDays'] as int?,
      insuranceReminderEnabled: map['insuranceReminderEnabled'] as bool?,
      insuranceReminderDays: map['insuranceReminderDays'] as int?,
    );
  }
}
