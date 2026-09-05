import 'package:flutter/material.dart';

/// All supported vehicle record types.
///
/// Adding a new record type requires:
///   1. Adding an entry to this enum.
///   2. Adding a [VehicleRecordTypeConfig] entry in [VehicleRecordTypeExtension.config].
///   3. Creating the corresponding form widget and record model.
///
/// No changes are required in HomeScreen, VehicleCard, or VehicleDetailsScreen.
enum VehicleRecordType {
  odometer,
  fuelRefill,
  charging,
  service,
  oilChange,
}

/// Display metadata for a [VehicleRecordType].
///
/// Centralises all user-facing labels and icons so they are defined once and
/// referenced everywhere.
class VehicleRecordTypeConfig {
  const VehicleRecordTypeConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.chipLabel,
  });

  /// Full display title, e.g. "Odometer Reading".
  final String title;

  /// Short description shown in the type selector chip, e.g. "Odometer".
  final String chipLabel;

  /// Longer description shown as a subtitle where space allows.
  final String description;

  /// Representative icon.
  final IconData icon;
}

/// Provides [VehicleRecordTypeConfig] and convenience accessors for every
/// [VehicleRecordType] value.
extension VehicleRecordTypeExtension on VehicleRecordType {
  /// The single source of truth for all type metadata.
  VehicleRecordTypeConfig get config {
    switch (this) {
      case VehicleRecordType.odometer:
        return const VehicleRecordTypeConfig(
          title: 'Odometer Reading',
          chipLabel: 'Odometer',
          description: 'Log the current kilometre reading.',
          icon: Icons.speed_rounded,
        );
      case VehicleRecordType.fuelRefill:
        return const VehicleRecordTypeConfig(
          title: 'Fuel Refill',
          chipLabel: 'Fuel',
          description: 'Record a fuel refill with cost and quantity.',
          icon: Icons.local_gas_station_rounded,
        );
      case VehicleRecordType.charging:
        return const VehicleRecordTypeConfig(
          title: 'Charging Session',
          chipLabel: 'Charge',
          description: 'Record an EV charging session.',
          icon: Icons.electrical_services_rounded,
        );
      case VehicleRecordType.service:
        return const VehicleRecordTypeConfig(
          title: 'Service',
          chipLabel: 'Service',
          description: 'Log a maintenance or service event.',
          icon: Icons.build_rounded,
        );
      case VehicleRecordType.oilChange:
        return const VehicleRecordTypeConfig(
          title: 'Oil Change',
          chipLabel: 'Oil',
          description: 'Record an oil change with type and quantity.',
          icon: Icons.oil_barrel_rounded,
        );
    }
  }

  String get title => config.title;
  String get chipLabel => config.chipLabel;
  String get description => config.description;
  IconData get icon => config.icon;
}
