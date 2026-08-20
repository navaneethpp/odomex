/// Stores mutable user preferences for a vehicle (e.g. pinned state).
class VehiclePreferences {
  const VehiclePreferences({
    required this.vehicleId,
    this.isPinned = false,
  });

  final String vehicleId;
  final bool isPinned;

  VehiclePreferences copyWith({
    String? vehicleId,
    bool? isPinned,
  }) {
    return VehiclePreferences(
      vehicleId: vehicleId ?? this.vehicleId,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'isPinned': isPinned,
    };
  }

  factory VehiclePreferences.fromMap(
    Map<dynamic, dynamic>? map,
    String vehicleId,
  ) {
    if (map == null) {
      return VehiclePreferences(vehicleId: vehicleId);
    }
    return VehiclePreferences(
      vehicleId: map['vehicleId'] as String? ?? vehicleId,
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }
}
