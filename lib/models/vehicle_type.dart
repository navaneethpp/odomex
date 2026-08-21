import 'package:flutter/material.dart';

/// Supported vehicle categories in Odomex.
enum VehicleType {
  motorcycle,
  scooter,
  autoRickshaw,
  car,
  pickup,
  van,
  bus;

  /// User-facing display title for the vehicle type.
  String get displayName {
    switch (this) {
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.scooter:
        return 'Scooter';
      case VehicleType.autoRickshaw:
        return 'Auto Rickshaw';
      case VehicleType.car:
        return 'Car';
      case VehicleType.pickup:
        return 'Pickup Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.bus:
        return 'Bus';
    }
  }

  /// Theme-adaptive icon representing this vehicle category.
  IconData get icon {
    switch (this) {
      case VehicleType.motorcycle:
        return Icons.two_wheeler_rounded;
      case VehicleType.scooter:
        return Icons.moped_rounded;
      case VehicleType.autoRickshaw:
        return Icons.electric_rickshaw_rounded;
      case VehicleType.car:
        return Icons.directions_car_rounded;
      case VehicleType.pickup:
        return Icons.local_shipping_rounded;
      case VehicleType.van:
        return Icons.airport_shuttle_rounded;
      case VehicleType.bus:
        return Icons.directions_bus_rounded;
    }
  }

  /// Stable string identifier for persistence and serialization.
  String get storageKey {
    switch (this) {
      case VehicleType.motorcycle:
        return 'motorcycle';
      case VehicleType.scooter:
        return 'scooter';
      case VehicleType.autoRickshaw:
        return 'auto_rickshaw';
      case VehicleType.car:
        return 'car';
      case VehicleType.pickup:
        return 'pickup';
      case VehicleType.van:
        return 'van';
      case VehicleType.bus:
        return 'bus';
    }
  }

  /// Parses a string key to a [VehicleType] with fallback to [defaultType].
  static VehicleType fromStorageKey(
    String? key, {
    VehicleType defaultType = VehicleType.motorcycle,
  }) {
    if (key == null) return defaultType;
    for (final type in VehicleType.values) {
      if (type.storageKey == key || type.name == key) {
        return type;
      }
    }
    return defaultType;
  }
}
