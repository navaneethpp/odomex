import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';

/// Supported analytics time ranges.
enum UsageRange {
  sevenDays,
  fourteenDays,
  thirtyDays,
  ninetyDays,
}

extension UsageRangeExtension on UsageRange {
  String get label {
    switch (this) {
      case UsageRange.sevenDays:
        return '7D';
      case UsageRange.fourteenDays:
        return '14D';
      case UsageRange.thirtyDays:
        return '30D';
      case UsageRange.ninetyDays:
        return '90D';
    }
  }

  int get days {
    switch (this) {
      case UsageRange.sevenDays:
        return 7;
      case UsageRange.fourteenDays:
        return 14;
      case UsageRange.thirtyDays:
        return 30;
      case UsageRange.ninetyDays:
        return 90;
    }
  }
}

/// Represents a single day's travel distance.
class DailyTravelPoint {
  const DailyTravelPoint({
    required this.date,
    required this.distanceKm,
    required this.isRecorded,
  });

  /// The calendar day of the point.
  final DateTime date;

  /// Travel distance in km for this day.
  final double distanceKm;

  /// Whether actual odometer readings were recorded on this day.
  final bool isRecorded;
}

/// Computed analytics summary for a time window.
class DailyTravelSummary {
  const DailyTravelSummary({
    required this.points,
    required this.totalDistanceKm,
    required this.averageDailyKm,
    required this.maxDailyKm,
    required this.recordedDaysCount,
  });

  final List<DailyTravelPoint> points;
  final double totalDistanceKm;
  final double averageDailyKm;
  final double maxDailyKm;
  final int recordedDaysCount;

  bool get hasSufficientData => recordedDaysCount > 0 && totalDistanceKm > 0;
}

/// Pure calculation utility for vehicle daily travel metrics.
class DailyTravelCalculator {
  DailyTravelCalculator._();

  /// Calculates daily travel distances from vehicle records over [range].
  ///
  /// Algorithm:
  ///   1. Extracts all chronological (date, odometer) readings from records.
  ///   2. For each day in [range], calculates difference between the day's
  ///      latest odometer and the previous recorded odometer.
  ///   3. Never sums cumulative odometer readings directly.
  static DailyTravelSummary calculate({
    required Vehicle vehicle,
    required List<VehicleRecord> records,
    required UsageRange range,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysCount = range.days;

    // 1. Extract all odometer readings from records
    final odometerEntries = <_OdoEntry>[];

    for (final r in records) {
      double? odo;
      switch (r) {
        case OdometerRecord():
          odo = r.odometer;
        case FuelRecord():
          odo = r.odometerReading;
        case ServiceRecord():
          odo = r.odometerReading;
        case OilChangeRecord():
          odo = r.odometerReading;
      }
      if (odo != null && odo > 0) {
        odometerEntries.add(_OdoEntry(r.date, odo));
      }
    }

    // Sort chronologically ascending
    odometerEntries.sort((a, b) => a.date.compareTo(b.date));

    // 2. Generate daily data points for the window
    final points = <DailyTravelPoint>[];
    double totalKm = 0.0;
    double maxKm = 0.0;
    int recordedDays = 0;

    for (int i = daysCount - 1; i >= 0; i--) {
      final currentDay = today.subtract(Duration(days: i));
      final nextDay = currentDay.add(const Duration(days: 1));

      // Readings recorded on this specific day
      final readingsOnDay = odometerEntries
          .where((e) => !e.date.isBefore(currentDay) && e.date.isBefore(nextDay))
          .toList();

      if (readingsOnDay.isNotEmpty) {
        final latestOnDay = readingsOnDay.last.odometer;

        // Find the latest reading recorded strictly before this day
        final readingsBeforeDay =
            odometerEntries.where((e) => e.date.isBefore(currentDay)).toList();

        double diff = 0.0;
        if (readingsBeforeDay.isNotEmpty) {
          final previousOdo = readingsBeforeDay.last.odometer;
          if (latestOnDay >= previousOdo) {
            diff = latestOnDay - previousOdo;
          }
        } else if (readingsOnDay.length > 1) {
          // If first record ever is on this day, use diff between earliest and latest on this day
          final firstOnDay = readingsOnDay.first.odometer;
          diff = latestOnDay - firstOnDay;
        }

        points.add(DailyTravelPoint(
          date: currentDay,
          distanceKm: diff,
          isRecorded: true,
        ));

        totalKm += diff;
        if (diff > maxKm) maxKm = diff;
        recordedDays++;
      } else {
        // No readings on this day
        points.add(DailyTravelPoint(
          date: currentDay,
          distanceKm: 0.0,
          isRecorded: false,
        ));
      }
    }

    final averageKm = recordedDays > 0 ? totalKm / recordedDays : 0.0;

    return DailyTravelSummary(
      points: points,
      totalDistanceKm: totalKm,
      averageDailyKm: averageKm,
      maxDailyKm: maxKm,
      recordedDaysCount: recordedDays,
    );
  }
}

class _OdoEntry {
  const _OdoEntry(this.date, this.odometer);
  final DateTime date;
  final double odometer;
}
