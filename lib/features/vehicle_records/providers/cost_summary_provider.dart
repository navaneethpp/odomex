import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/vehicle_records/models/cost_summary.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/services/cost_summary_calculator.dart';

/// Tracks the active aggregation period (Daily, Monthly, or Yearly) for a vehicle.
final costPeriodProvider =
    StateProvider.family<CostPeriod, String>((ref, vehicleId) {
  return CostPeriod.monthly;
});

/// Tracks the currently selected anchor date for a vehicle's cost summary navigation.
final costSelectedDateProvider =
    StateProvider.family<DateTime, String>((ref, vehicleId) {
  return DateTime.now();
});

/// Reactively computes the [CostSummary] for [vehicleId] using authoritative records.
final costSummaryProvider =
    Provider.family<CostSummary, String>((ref, vehicleId) {
  final records = ref.watch(recordsByVehicleProvider(vehicleId));
  final period = ref.watch(costPeriodProvider(vehicleId));
  final selectedDate = ref.watch(costSelectedDateProvider(vehicleId));

  return CostSummaryCalculator.calculateCostSummary(
    records: records,
    period: period,
    selectedDate: selectedDate,
  );
});
