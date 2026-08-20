/// A single odometer reading recorded for a vehicle.
class OdometerRecord {
  OdometerRecord({
    String? id,
    required this.vehicleId,
    required this.odometerReading,
    required this.recordedAt,
  }) : id = id ?? _generateId();

  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// Odometer reading at time of record (km).
  final double odometerReading;

  /// When the record was created.
  final DateTime recordedAt;

  static String _generateId() =>
      'odo_${DateTime.now().microsecondsSinceEpoch}';
}
