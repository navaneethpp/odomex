import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';

/// Pure service resolving the effective configuration for a vehicle
/// by merging [GlobalVehicleSettings] with any custom [VehicleSettings] overrides.
class VehicleSettingsResolver {
  VehicleSettingsResolver._();

  /// Resolves the final [EffectiveVehicleSettings] for [vehicleId].
  static EffectiveVehicleSettings resolve({
    required GlobalVehicleSettings global,
    required VehicleSettings? vehicleOverride,
    required String vehicleId,
  }) {
    return EffectiveVehicleSettings(
      vehicleId: vehicleId,
      serviceIntervalKm:
          vehicleOverride?.serviceIntervalKm ?? global.serviceIntervalKm,
      oilChangeIntervalKm:
          vehicleOverride?.oilChangeIntervalKm ?? global.oilChangeIntervalKm,
      serviceReminderEnabled: vehicleOverride?.serviceReminderEnabled ??
          global.serviceReminderEnabled,
      oilChangeReminderEnabled: vehicleOverride?.oilChangeReminderEnabled ??
          global.oilChangeReminderEnabled,
      maintenanceReminderThresholdKm:
          vehicleOverride?.maintenanceReminderThresholdKm ??
              global.maintenanceReminderThresholdKm,
      pucReminderEnabled:
          vehicleOverride?.pucReminderEnabled ?? global.pucReminderEnabled,
      pucReminderDays:
          vehicleOverride?.pucReminderDays ?? global.pucReminderDays,
      insuranceReminderEnabled: vehicleOverride?.insuranceReminderEnabled ??
          global.insuranceReminderEnabled,
      insuranceReminderDays: vehicleOverride?.insuranceReminderDays ??
          global.insuranceReminderDays,
      isUsingGlobalServiceInterval: vehicleOverride?.serviceIntervalKm == null,
      isUsingGlobalOilChangeInterval:
          vehicleOverride?.oilChangeIntervalKm == null,
      isUsingGlobalServiceReminder:
          vehicleOverride?.serviceReminderEnabled == null,
      isUsingGlobalOilChangeReminder:
          vehicleOverride?.oilChangeReminderEnabled == null,
      isUsingGlobalMaintenanceThreshold:
          vehicleOverride?.maintenanceReminderThresholdKm == null,
      isUsingGlobalPucReminder: vehicleOverride?.pucReminderEnabled == null,
      isUsingGlobalPucReminderDays:
          vehicleOverride?.pucReminderDays == null,
      isUsingGlobalInsuranceReminder:
          vehicleOverride?.insuranceReminderEnabled == null,
      isUsingGlobalInsuranceReminderDays:
          vehicleOverride?.insuranceReminderDays == null,
    );
  }
}
