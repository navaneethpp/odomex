import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';

/// Single day's vehicle-related expenses.
class DailyCostPoint {
  const DailyCostPoint({
    required this.date,
    required this.fuelCost,
    required this.serviceCost,
    required this.oilChangeCost,
  });

  final DateTime date;
  final double fuelCost;
  final double serviceCost;
  final double oilChangeCost;

  double get totalCost => fuelCost + serviceCost + oilChangeCost;
  bool get hasExpense => totalCost > 0;
}

/// Breakdown of vehicle spending by category during a time window.
class CostBreakdown {
  const CostBreakdown({
    required this.fuelCost,
    required this.serviceCost,
    required this.oilChangeCost,
  });

  final double fuelCost;
  final double serviceCost;
  final double oilChangeCost;

  double get totalCost => fuelCost + serviceCost + oilChangeCost;

  double get fuelPercentage =>
      totalCost > 0 ? (fuelCost / totalCost) * 100 : 0.0;

  double get servicePercentage =>
      totalCost > 0 ? (serviceCost / totalCost) * 100 : 0.0;

  double get oilPercentage =>
      totalCost > 0 ? (oilChangeCost / totalCost) * 100 : 0.0;

  bool get hasAnyCost => totalCost > 0;
}

/// Consolidated period-based usage and cost summary.
class PeriodUsageSummary {
  const PeriodUsageSummary({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.periodLabel,
    required this.totalDistanceKm,
    required this.totalFuelLitres,
    required this.totalCost,
    required this.travelSummary,
    required this.dailyCosts,
    required this.costBreakdown,
  });

  final UsageRange range;
  final DateTime startDate;
  final DateTime endDate;
  final String periodLabel;

  /// Total distance in km over the period.
  final double totalDistanceKm;

  /// Total fuel refilled in litres over the period.
  final double totalFuelLitres;

  /// Total expenses in INR over the period.
  final double totalCost;

  /// Daily travel points and travel metrics.
  final DailyTravelSummary travelSummary;

  /// Daily cost points for each day in the window.
  final List<DailyCostPoint> dailyCosts;

  /// Category breakdown of total cost.
  final CostBreakdown costBreakdown;

  bool get hasAnyData =>
      totalDistanceKm > 0 || totalFuelLitres > 0 || totalCost > 0;
}
