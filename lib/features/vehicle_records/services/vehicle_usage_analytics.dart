import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Aggregated fuel consumption and spend statistics.
class FuelAnalytics {
  const FuelAnalytics({
    required this.totalLitres,
    required this.totalCost,
    required this.averagePricePerLitre,
    required this.refillCount,
    this.estimatedKmPerLitre,
  });

  final double totalLitres;
  final double totalCost;
  final double averagePricePerLitre;
  final int refillCount;

  /// Estimated fuel efficiency in km/L based on consecutive refills with odometer readings.
  final double? estimatedKmPerLitre;
}

/// Aggregated maintenance cost and frequency statistics.
class MaintenanceAnalytics {
  const MaintenanceAnalytics({
    required this.totalServiceCost,
    required this.totalOilChangeCost,
    required this.serviceCount,
    required this.oilChangeCount,
  });

  final double totalServiceCost;
  final double totalOilChangeCost;
  final int serviceCount;
  final int oilChangeCount;

  double get totalMaintenanceCost => totalServiceCost + totalOilChangeCost;
  int get totalEventsCount => serviceCount + oilChangeCount;
}

/// Core analytical engine for computing historical vehicle statistics and insights.
class VehicleUsageAnalytics {
  VehicleUsageAnalytics._();

  /// Filters [records] to those between [startDate] and [endDate] (inclusive).
  static List<VehicleRecord> getRecordsByDateRange({
    required List<VehicleRecord> records,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return records.where((r) {
      return !r.date.isBefore(start) && !r.date.isAfter(end);
    }).toList();
  }

  /// Returns up to [limit] most recent records sorted newest first.
  static List<VehicleRecord> getRecentRecords({
    required List<VehicleRecord> records,
    int limit = 10,
  }) {
    final sorted = List<VehicleRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Calculates total distance covered based on chronological odometer history.
  static double calculateTotalDistance(List<VehicleRecord> records) {
    final odoReadings = <double>[];

    // Sort chronologically
    final sorted = List<VehicleRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final r in sorted) {
      double? odo;
      switch (r) {
        case OdometerRecord():
          odo = r.odometer;
        case FuelRecord():
          odo = r.odometerReading;
        case ServiceRecord():
          odo = r.odometerReading;
        case OilChangeRecord():
        case ChargingRecord():
          odo = r.odometerReading;
      }
      if (odo != null && odo > 0) {
        odoReadings.add(odo);
      }
    }

    if (odoReadings.length < 2) return 0.0;
    final diff = odoReadings.last - odoReadings.first;
    return diff > 0 ? diff : 0.0;
  }

  /// Calculates fuel spend, quantity, and estimated efficiency.
  static FuelAnalytics calculateFuelAnalytics(List<VehicleRecord> records) {
    final fuelRecords = records.whereType<FuelRecord>().toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (fuelRecords.isEmpty) {
      return const FuelAnalytics(
        totalLitres: 0.0,
        totalCost: 0.0,
        averagePricePerLitre: 0.0,
        refillCount: 0,
      );
    }

    double totalLitres = 0.0;
    double totalCost = 0.0;

    for (final r in fuelRecords) {
      totalLitres += r.quantity;
      totalCost += r.cost;
    }

    final avgPrice = totalLitres > 0 ? totalCost / totalLitres : 0.0;

    // Estimate fuel efficiency between consecutive refills with odometer readings
    double totalDistance = 0.0;
    double totalFuelForDistance = 0.0;

    for (int i = 1; i < fuelRecords.length; i++) {
      final prev = fuelRecords[i - 1];
      final curr = fuelRecords[i];

      if (prev.odometerReading != null &&
          curr.odometerReading != null &&
          curr.odometerReading! > prev.odometerReading!) {
        totalDistance += (curr.odometerReading! - prev.odometerReading!);
        totalFuelForDistance += curr.quantity;
      }
    }

    final estimatedKmPerLitre = totalFuelForDistance > 0 && totalDistance > 0
        ? totalDistance / totalFuelForDistance
        : null;

    return FuelAnalytics(
      totalLitres: totalLitres,
      totalCost: totalCost,
      averagePricePerLitre: avgPrice,
      refillCount: fuelRecords.length,
      estimatedKmPerLitre: estimatedKmPerLitre,
    );
  }

  /// Calculates total service and maintenance expenses.
  static MaintenanceAnalytics calculateMaintenanceAnalytics(
      List<VehicleRecord> records) {
    final serviceRecords = records.whereType<ServiceRecord>().toList();
    final oilRecords = records.whereType<OilChangeRecord>().toList();

    double serviceSpend = 0.0;
    for (final s in serviceRecords) {
      if (s.cost != null) serviceSpend += s.cost!;
    }

    double oilSpend = 0.0;
    for (final o in oilRecords) {
      if (o.cost != null) oilSpend += o.cost!;
    }

    return MaintenanceAnalytics(
      totalServiceCost: serviceSpend,
      totalOilChangeCost: oilSpend,
      serviceCount: serviceRecords.length,
      oilChangeCount: oilRecords.length,
    );
  }
}
