/// A service / maintenance record for a vehicle.
class ServiceRecord {
  ServiceRecord({
    String? id,
    required this.vehicleId,
    required this.description,
    required this.recordedAt,
  }) : id = id ?? _generateId();

  final String id;

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// Free-form description of the service performed.
  final String description;

  /// When the service was recorded.
  final DateTime recordedAt;

  static String _generateId() =>
      'svc_${DateTime.now().microsecondsSinceEpoch}';
}
