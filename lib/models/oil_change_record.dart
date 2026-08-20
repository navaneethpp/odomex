/// An oil change record for a vehicle.
class OilChangeRecord {
  OilChangeRecord({
    String? id,
    required this.vehicleId,
    required this.odometerAtChange,
    required this.intervalKm,
    required this.recordedAt,
  }) : id = id ?? _generateId();

  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// Odometer reading at which the oil was changed (km).
  final double odometerAtChange;

  /// The service interval in km (next change is due at odometerAtChange + intervalKm).
  final double intervalKm;

  /// When the oil change was recorded.
  final DateTime recordedAt;

  /// Odometer reading at which the next oil change is due.
  double get nextChangeOdometer => odometerAtChange + intervalKm;

  static String _generateId() =>
      'oil_${DateTime.now().microsecondsSinceEpoch}';
}
