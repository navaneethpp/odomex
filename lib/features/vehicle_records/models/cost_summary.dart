/// Supported time periods for vehicle cost aggregation.
enum CostPeriod {
  daily,
  monthly,
  yearly,
}

extension CostPeriodExtension on CostPeriod {
  String get label {
    switch (this) {
      case CostPeriod.daily:
        return 'Daily';
      case CostPeriod.monthly:
        return 'Monthly';
      case CostPeriod.yearly:
        return 'Yearly';
    }
  }
}

/// Consolidated financial cost summary for a vehicle across a specified period.
class CostSummary {
  const CostSummary({
    required this.period,
    required this.selectedDate,
    required this.periodLabel,
    required this.totalCost,
    required this.fuelCost,
    required this.serviceCost,
    required this.oilChangeCost,
    required this.costBearingRecordCount,
    required this.totalRecordCount,
  });

  /// The active aggregation timeframe (Daily, Monthly, or Yearly).
  final CostPeriod period;

  /// The anchor date for the selected period.
  final DateTime selectedDate;

  /// Human-readable label for the period (e.g. '29 Aug 2026', 'August 2026', '2026').
  final String periodLabel;

  /// Total combined monetary expense in INR for the period.
  final double totalCost;

  /// Fuel subtotal in INR.
  final double fuelCost;

  /// Service / repair subtotal in INR.
  final double serviceCost;

  /// Oil change subtotal in INR.
  final double oilChangeCost;

  /// Count of records in this period that contributed a non-zero financial cost.
  final int costBearingRecordCount;

  /// Total count of all records falling into this period (including zero-cost odometer logs).
  final int totalRecordCount;

  /// Whether any monetary expenses were recorded in this period.
  bool get hasCost => totalCost > 0;

  /// Percentage of total spending attributed to fuel (0.0 to 100.0).
  double get fuelPercentage =>
      totalCost > 0 ? (fuelCost / totalCost) * 100 : 0.0;

  /// Percentage of total spending attributed to services (0.0 to 100.0).
  double get servicePercentage =>
      totalCost > 0 ? (serviceCost / totalCost) * 100 : 0.0;

  /// Percentage of total spending attributed to oil changes (0.0 to 100.0).
  double get oilChangePercentage =>
      totalCost > 0 ? (oilChangeCost / totalCost) * 100 : 0.0;

  /// Factory creating an empty summary with zero expenses.
  factory CostSummary.empty({
    required CostPeriod period,
    required DateTime selectedDate,
    required String periodLabel,
  }) =>
      CostSummary(
        period: period,
        selectedDate: selectedDate,
        periodLabel: periodLabel,
        totalCost: 0.0,
        fuelCost: 0.0,
        serviceCost: 0.0,
        oilChangeCost: 0.0,
        costBearingRecordCount: 0,
        totalRecordCount: 0,
      );
}
