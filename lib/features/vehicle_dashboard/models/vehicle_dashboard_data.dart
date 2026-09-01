import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';

/// Immutable consolidated view model for the Vehicle Dashboard.
class VehicleDashboardData {
  const VehicleDashboardData({
    required this.vehicle,
    required this.effectiveOdometerReading,
    required this.recentRecords,
    required this.totalRecordsCount,
    required this.reminders,
    required this.periodSummary,
  });

  /// The active vehicle.
  final Vehicle vehicle;

  /// Authoritative current odometer reading derived from records and baseline.
  final double effectiveOdometerReading;

  /// The most recent vehicle records (up to 10), sorted newest first.
  final List<VehicleRecord> recentRecords;

  /// Total count of all records available for this vehicle.
  final int totalRecordsCount;

  /// Reminders prioritized by urgency (Overdue -> Due Today -> Due Soon -> Upcoming).
  final List<VehicleReminder> reminders;

  /// Period-based usage, fuel, and cost summary computed for the active range.
  final PeriodUsageSummary periodSummary;

  bool get hasRecords => recentRecords.isNotEmpty;
  bool get hasReminders => reminders.isNotEmpty;
}
