import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/vehicle_dashboard/models/vehicle_dashboard_data.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/utils/period_usage_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';

/// Manages the currently selected usage time range on the dashboard.
final dashboardRangeProvider = StateProvider.autoDispose
    .family<UsageRange, String>((ref, vehicleId) {
  return UsageRange.sevenDays;
});

/// Reactively computes and provides the complete [VehicleDashboardData] for [vehicleId].
///
/// Combines:
///   1. Vehicle state from [vehicleByIdProvider]
///   2. All vehicle records from [recordsByVehicleProvider]
///   3. Effective vehicle settings from [effectiveVehicleSettingsProvider]
///   4. Active time range from [dashboardRangeProvider]
///   5. Urgency-sorted reminders from [VehicleReminderCalculator]
///   6. Period-based usage, distance, fuel, and cost summaries from [PeriodUsageCalculator]
final vehicleDashboardProvider =
    Provider.family<VehicleDashboardData?, String>((
  ref,
  vehicleId,
) {
  final vehicle = ref.watch(
    vehicleByIdProvider(vehicleId),
  );
  if (vehicle == null) return null;

  final records = ref.watch(
    recordsByVehicleProvider(vehicleId),
  );
  final effectiveSettings = ref.watch(
    effectiveVehicleSettingsProvider(vehicleId),
  );
  final selectedRange = ref.watch(
    dashboardRangeProvider(vehicleId),
  );

  // Up to 10 most recent records
  final recentRecords = records.take(10).toList();

  // Prioritized reminders dynamically derived from vehicle records & effective settings
  final reminders = VehicleReminderCalculator.calculateReminders(
    vehicle,
    settings: effectiveSettings,
    records: records,
  );

  final effectiveOdometer =
      ref.watch(latestOdometerReadingProvider(vehicleId)) ??
          vehicle.odometerReading;

  // Period usage, distance, fuel, and cost analytics
  final periodSummary = PeriodUsageCalculator.calculate(
    vehicle: vehicle,
    records: records,
    range: selectedRange,
  );

  return VehicleDashboardData(
    vehicle: vehicle,
    effectiveOdometerReading: effectiveOdometer,
    recentRecords: recentRecords,
    totalRecordsCount: records.length,
    reminders: reminders,
    periodSummary: periodSummary,
  );
});
