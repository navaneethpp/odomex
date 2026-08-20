/// A fuel refill record for a vehicle.
class FuelRecord {
  FuelRecord({
    String? id,
    required this.vehicleId,
    required this.fuelAmount,
    required this.totalCost,
    required this.recordedAt,
  }) : id = id ?? _generateId();

  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// Fuel amount added in litres.
  final double fuelAmount;

  /// Total cost of the fuel in INR.
  final double totalCost;

  /// When the refill was recorded.
  final DateTime recordedAt;

  static String _generateId() =>
      'fuel_${DateTime.now().microsecondsSinceEpoch}';
}
