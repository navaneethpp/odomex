/// Default vehicle maintenance configuration and reminder rules applicable globally.
class GlobalVehicleSettings {
  const GlobalVehicleSettings({
    this.serviceIntervalKm = 3000,
    this.oilChangeIntervalKm = 3000,
    this.serviceReminderEnabled = true,
    this.oilChangeReminderEnabled = true,
    this.maintenanceReminderThresholdKm = 500,
    this.pucReminderEnabled = true,
    this.pucReminderDays = 30,
    this.insuranceReminderEnabled = true,
    this.insuranceReminderDays = 30,
  });

  /// Default distance interval between general services in kilometres (e.g. 3,000 km).
  final int serviceIntervalKm;

  /// Default distance interval between engine oil changes in kilometres (e.g. 3,000 km).
  final int oilChangeIntervalKm;

  /// Whether scheduled service reminders are enabled by default.
  final bool serviceReminderEnabled;

  /// Whether oil change reminders are enabled by default.
  final bool oilChangeReminderEnabled;

  /// Default kilometre threshold before due odometer at which a warning is triggered.
  final int maintenanceReminderThresholdKm;

  /// Whether PUC expiry reminders are enabled by default.
  final bool pucReminderEnabled;

  /// Default days threshold before PUC expiry at which a warning is triggered.
  final int pucReminderDays;

  /// Whether insurance expiry reminders are enabled by default.
  final bool insuranceReminderEnabled;

  /// Default days threshold before insurance policy expiry at which a warning is triggered.
  final int insuranceReminderDays;

  GlobalVehicleSettings copyWith({
    int? serviceIntervalKm,
    int? oilChangeIntervalKm,
    bool? serviceReminderEnabled,
    bool? oilChangeReminderEnabled,
    int? maintenanceReminderThresholdKm,
    bool? pucReminderEnabled,
    int? pucReminderDays,
    bool? insuranceReminderEnabled,
    int? insuranceReminderDays,
  }) {
    return GlobalVehicleSettings(
      serviceIntervalKm: serviceIntervalKm ?? this.serviceIntervalKm,
      oilChangeIntervalKm: oilChangeIntervalKm ?? this.oilChangeIntervalKm,
      serviceReminderEnabled:
          serviceReminderEnabled ?? this.serviceReminderEnabled,
      oilChangeReminderEnabled:
          oilChangeReminderEnabled ?? this.oilChangeReminderEnabled,
      maintenanceReminderThresholdKm:
          maintenanceReminderThresholdKm ?? this.maintenanceReminderThresholdKm,
      pucReminderEnabled: pucReminderEnabled ?? this.pucReminderEnabled,
      pucReminderDays: pucReminderDays ?? this.pucReminderDays,
      insuranceReminderEnabled:
          insuranceReminderEnabled ?? this.insuranceReminderEnabled,
      insuranceReminderDays:
          insuranceReminderDays ?? this.insuranceReminderDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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

  factory GlobalVehicleSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const GlobalVehicleSettings();
    return GlobalVehicleSettings(
      serviceIntervalKm: map['serviceIntervalKm'] as int? ?? 3000,
      oilChangeIntervalKm: map['oilChangeIntervalKm'] as int? ?? 3000,
      serviceReminderEnabled: map['serviceReminderEnabled'] as bool? ?? true,
      oilChangeReminderEnabled:
          map['oilChangeReminderEnabled'] as bool? ?? true,
      maintenanceReminderThresholdKm:
          map['maintenanceReminderThresholdKm'] as int? ?? 500,
      pucReminderEnabled: map['pucReminderEnabled'] as bool? ?? true,
      pucReminderDays: map['pucReminderDays'] as int? ?? 30,
      insuranceReminderEnabled:
          map['insuranceReminderEnabled'] as bool? ?? true,
      insuranceReminderDays: map['insuranceReminderDays'] as int? ?? 30,
    );
  }
}
