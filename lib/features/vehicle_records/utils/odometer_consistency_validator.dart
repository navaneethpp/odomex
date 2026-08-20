import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Result of evaluating odometer chronological consistency.
enum OdometerConsistencyStatus {
  valid,
  lessThanPrevious,
  greaterThanSubsequent,
}

class OdometerConsistencyResult {
  const OdometerConsistencyResult({
    required this.status,
    this.conflictingDate,
    this.conflictingOdometer,
  });

  final OdometerConsistencyStatus status;
  final DateTime? conflictingDate;
  final double? conflictingOdometer;

  bool get isValid => status == OdometerConsistencyStatus.valid;

  String? get errorMessage {
    switch (status) {
      case OdometerConsistencyStatus.valid:
        return null;
      case OdometerConsistencyStatus.lessThanPrevious:
        return 'Reading cannot be lower than previous reading of ${conflictingOdometer?.toStringAsFixed(0)} km on ${conflictingDate?.toLocal().toString().split(' ')[0]}';
      case OdometerConsistencyStatus.greaterThanSubsequent:
        return 'Reading cannot be higher than later reading of ${conflictingOdometer?.toStringAsFixed(0)} km on ${conflictingDate?.toLocal().toString().split(' ')[0]}';
    }
  }
}

/// Chronological validator that checks whether a historical odometer entry
/// fits logically with preceding and succeeding historical records.
class OdometerConsistencyValidator {
  OdometerConsistencyValidator._();

  /// Validates [newOdometer] at [newDate] against [existingRecords].
  static OdometerConsistencyResult validate({
    required double newOdometer,
    required DateTime newDate,
    required List<VehicleRecord> existingRecords,
  }) {
    // 1. Extract all odometer readings from existing records
    final entries = <({DateTime date, double odometer})>[];

    for (final r in existingRecords) {
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
        entries.add((date: r.date, odometer: odo));
      }
    }

    // Sort ascending by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    // Check prior entries (recorded before newDate)
    final prior = entries.where((e) => e.date.isBefore(newDate)).toList();
    if (prior.isNotEmpty) {
      final latestPrior = prior.last;
      if (newOdometer < latestPrior.odometer) {
        return OdometerConsistencyResult(
          status: OdometerConsistencyStatus.lessThanPrevious,
          conflictingDate: latestPrior.date,
          conflictingOdometer: latestPrior.odometer,
        );
      }
    }

    // Check subsequent entries (recorded after newDate)
    final subsequent = entries.where((e) => e.date.isAfter(newDate)).toList();
    if (subsequent.isNotEmpty) {
      final earliestSubsequent = subsequent.first;
      if (newOdometer > earliestSubsequent.odometer) {
        return OdometerConsistencyResult(
          status: OdometerConsistencyStatus.greaterThanSubsequent,
          conflictingDate: earliestSubsequent.date,
          conflictingOdometer: earliestSubsequent.odometer,
        );
      }
    }

    return const OdometerConsistencyResult(
      status: OdometerConsistencyStatus.valid,
    );
  }
}
