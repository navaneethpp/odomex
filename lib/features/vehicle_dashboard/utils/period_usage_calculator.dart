import 'package:intl/intl.dart';
import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';

/// Pure calculation utility for period-based usage, fuel, and cost summaries.
class PeriodUsageCalculator {
  PeriodUsageCalculator._();

  static final _dateFormat = DateFormat('d MMM');

  /// Computes the complete [PeriodUsageSummary] for [vehicle] and [records] over [range].
  static PeriodUsageSummary calculate({
    required Vehicle vehicle,
    required List<VehicleRecord> records,
    required UsageRange range,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysCount = range.days;
    final startDate = today.subtract(Duration(days: daysCount - 1));
    final endDate = today;

    final periodLabel =
        'Last $daysCount days • ${_dateFormat.format(startDate)} – ${_dateFormat.format(endDate)}';

    // 1. Calculate travel distance using the dedicated cumulative odometer calculator
    final travelSummary = DailyTravelCalculator.calculate(
      vehicle: vehicle,
      records: records,
      range: range,
      referenceDate: now,
    );

    // 2. Filter records within the period
    final endOfWindow = endDate.add(const Duration(days: 1));
    final periodRecords = records.where((r) {
      return !r.date.isBefore(startDate) && r.date.isBefore(endOfWindow);
    }).toList();

    // 3. Compute totals and breakdown
    double totalFuelLitres = 0.0;
    double totalFuelCost = 0.0;
    double totalServiceCost = 0.0;
    double totalOilChangeCost = 0.0;

    for (final r in periodRecords) {
      switch (r) {
        case FuelRecord():
          totalFuelLitres += r.quantity;
          totalFuelCost += r.cost;
        case ServiceRecord():
          if (r.cost != null) totalServiceCost += r.cost!;
        case OilChangeRecord():
          if (r.cost != null) totalOilChangeCost += r.cost!;
        case OdometerRecord():
          break;
      case ChargingRecord():
        break;
      }
    }

    final totalCost = totalFuelCost + totalServiceCost + totalOilChangeCost;

    // 4. Compute daily costs for each day in the window
    final dailyCosts = <DailyCostPoint>[];

    for (int i = daysCount - 1; i >= 0; i--) {
      final currentDay = today.subtract(Duration(days: i));
      final nextDay = currentDay.add(const Duration(days: 1));

      final recordsOnDay = periodRecords.where((r) {
        return !r.date.isBefore(currentDay) && r.date.isBefore(nextDay);
      }).toList();

      double dayFuel = 0.0;
      double dayService = 0.0;
      double dayOil = 0.0;

      for (final r in recordsOnDay) {
        switch (r) {
          case FuelRecord():
            dayFuel += r.cost;
          case ServiceRecord():
            if (r.cost != null) dayService += r.cost!;
          case OilChangeRecord():
            if (r.cost != null) dayOil += r.cost!;
          case OdometerRecord():
            break;
      case ChargingRecord():
        break;
        }
      }

      dailyCosts.add(
        DailyCostPoint(
          date: currentDay,
          fuelCost: dayFuel,
          serviceCost: dayService,
          oilChangeCost: dayOil,
        ),
      );
    }

    final costBreakdown = CostBreakdown(
      fuelCost: totalFuelCost,
      serviceCost: totalServiceCost,
      oilChangeCost: totalOilChangeCost,
    );

    return PeriodUsageSummary(
      range: range,
      startDate: startDate,
      endDate: endDate,
      periodLabel: periodLabel,
      totalDistanceKm: travelSummary.totalDistanceKm,
      totalFuelLitres: totalFuelLitres,
      totalCost: totalCost,
      travelSummary: travelSummary,
      dailyCosts: dailyCosts,
      costBreakdown: costBreakdown,
    );
  }
}
