import 'package:intl/intl.dart';
import 'package:odomex/features/vehicle_records/models/cost_summary.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Pure domain service calculating period-based vehicle financial expenses.
class CostSummaryCalculator {
  const CostSummaryCalculator._();

  static final _dailyFormat = DateFormat('d MMM yyyy');
  static final _monthlyFormat = DateFormat('MMMM yyyy');

  /// Formats the human-readable label for a given period and anchor date.
  static String formatPeriodLabel(CostPeriod period, DateTime date) {
    switch (period) {
      case CostPeriod.daily:
        return _dailyFormat.format(date);
      case CostPeriod.monthly:
        return _monthlyFormat.format(date);
      case CostPeriod.yearly:
        return date.year.toString();
    }
  }

  /// Calculates the previous step date based on the active [CostPeriod].
  static DateTime previousPeriod(DateTime current, CostPeriod period) {
    switch (period) {
      case CostPeriod.daily:
        return DateTime(current.year, current.month, current.day - 1);
      case CostPeriod.monthly:
        return DateTime(current.year, current.month - 1, 1);
      case CostPeriod.yearly:
        return DateTime(current.year - 1, 1, 1);
    }
  }

  /// Calculates the next step date based on the active [CostPeriod].
  static DateTime nextPeriod(DateTime current, CostPeriod period) {
    switch (period) {
      case CostPeriod.daily:
        return DateTime(current.year, current.month, current.day + 1);
      case CostPeriod.monthly:
        return DateTime(current.year, current.month + 1, 1);
      case CostPeriod.yearly:
        return DateTime(current.year + 1, 1, 1);
    }
  }

  /// Checks if [recordDate] falls into the calendar boundary of [selectedDate] under [period].
  static bool isDateInPeriod({
    required DateTime recordDate,
    required DateTime selectedDate,
    required CostPeriod period,
  }) {
    switch (period) {
      case CostPeriod.daily:
        return recordDate.year == selectedDate.year &&
            recordDate.month == selectedDate.month &&
            recordDate.day == selectedDate.day;
      case CostPeriod.monthly:
        return recordDate.year == selectedDate.year &&
            recordDate.month == selectedDate.month;
      case CostPeriod.yearly:
        return recordDate.year == selectedDate.year;
    }
  }

  /// Aggregates all monetary expenses for [records] matching [period] and [selectedDate].
  static CostSummary calculateCostSummary({
    required List<VehicleRecord> records,
    required CostPeriod period,
    required DateTime selectedDate,
  }) {
    final periodLabel = formatPeriodLabel(period, selectedDate);

    double fuelSum = 0.0;
    double serviceSum = 0.0;
    double oilSum = 0.0;
    int costBearingCount = 0;
    int totalCount = 0;

    for (final record in records) {
      if (!isDateInPeriod(
        recordDate: record.date,
        selectedDate: selectedDate,
        period: period,
      )) {
        continue;
      }

      totalCount++;

      switch (record) {
        case FuelRecord(cost: final c):
          if (c > 0) {
            fuelSum += c;
            costBearingCount++;
          }
        case ServiceRecord(cost: final c):
          if (c != null && c > 0) {
            serviceSum += c;
            costBearingCount++;
          }
        case OilChangeRecord(cost: final c):
          if (c != null && c > 0) {
            oilSum += c;
            costBearingCount++;
          }
        case OdometerRecord():
          // Odometer-only logs do not incur monetary expenses
          break;
        case ChargingRecord(cost: final c):
          if (c > 0) {
            fuelSum += c; // Grouping charging under fuel/energy for now
            costBearingCount++;
          }
      }
    }

    final roundedFuel = _roundFinancial(fuelSum);
    final roundedService = _roundFinancial(serviceSum);
    final roundedOil = _roundFinancial(oilSum);
    final total = _roundFinancial(roundedFuel + roundedService + roundedOil);

    return CostSummary(
      period: period,
      selectedDate: selectedDate,
      periodLabel: periodLabel,
      totalCost: total,
      fuelCost: roundedFuel,
      serviceCost: roundedService,
      oilChangeCost: roundedOil,
      costBearingRecordCount: costBearingCount,
      totalRecordCount: totalCount,
    );
  }

  static double _roundFinancial(double val) {
    if (val <= 0 || !val.isFinite) return 0.0;
    return double.parse(val.toStringAsFixed(2));
  }
}
