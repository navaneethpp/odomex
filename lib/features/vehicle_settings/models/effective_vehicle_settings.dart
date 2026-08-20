/// Represents the final resolved configuration for a vehicle after merging
/// global defaults and any vehicle-specific overrides.
class EffectiveVehicleSettings {
  const EffectiveVehicleSettings({
    required this.vehicleId,
    required this.serviceIntervalKm,
    required this.oilChangeIntervalKm,
    required this.serviceReminderEnabled,
    required this.oilChangeReminderEnabled,
    required this.maintenanceReminderThresholdKm,
    required this.pucReminderEnabled,
    required this.pucReminderDays,
    required this.insuranceReminderEnabled,
    required this.insuranceReminderDays,
    required this.isUsingGlobalServiceInterval,
    required this.isUsingGlobalOilChangeInterval,
    required this.isUsingGlobalServiceReminder,
    required this.isUsingGlobalOilChangeReminder,
    required this.isUsingGlobalMaintenanceThreshold,
    required this.isUsingGlobalPucReminder,
    required this.isUsingGlobalPucReminderDays,
    required this.isUsingGlobalInsuranceReminder,
    required this.isUsingGlobalInsuranceReminderDays,
  });

  final String vehicleId;

  final int serviceIntervalKm;
  final int oilChangeIntervalKm;
  final bool serviceReminderEnabled;
  final bool oilChangeReminderEnabled;
  final int maintenanceReminderThresholdKm;
  final bool pucReminderEnabled;
  final int pucReminderDays;
  final bool insuranceReminderEnabled;
  final int insuranceReminderDays;

  // Inheritance origins
  final bool isUsingGlobalServiceInterval;
  final bool isUsingGlobalOilChangeInterval;
  final bool isUsingGlobalServiceReminder;
  final bool isUsingGlobalOilChangeReminder;
  final bool isUsingGlobalMaintenanceThreshold;
  final bool isUsingGlobalPucReminder;
  final bool isUsingGlobalPucReminderDays;
  final bool isUsingGlobalInsuranceReminder;
  final bool isUsingGlobalInsuranceReminderDays;

  bool get isUsingAllDefaults =>
      isUsingGlobalServiceInterval &&
      isUsingGlobalOilChangeInterval &&
      isUsingGlobalServiceReminder &&
      isUsingGlobalOilChangeReminder &&
      isUsingGlobalMaintenanceThreshold &&
      isUsingGlobalPucReminder &&
      isUsingGlobalPucReminderDays &&
      isUsingGlobalInsuranceReminder &&
      isUsingGlobalInsuranceReminderDays;
}
