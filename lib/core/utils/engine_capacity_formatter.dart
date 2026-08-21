import 'package:odomex/models/vehicle.dart';

/// Conversion and formatting utilities for vehicle engine capacity.
class EngineCapacityFormatter {
  EngineCapacityFormatter._();

  /// Converts cubic centimetres (CC) to litres (L).
  static double ccToLitres(double cc) => cc / 1000.0;

  /// Converts litres (L) to cubic centimetres (CC).
  static double litresToCc(double litres) => litres * 1000.0;

  /// Formats an engine capacity value with its unit.
  ///
  /// Examples:
  /// - `109`, `cc` $\rightarrow$ `'109 cc'`
  /// - `1.09`, `litres` $\rightarrow$ `'1.09 L'`
  /// - `1.5`, `litres` $\rightarrow$ `'1.5 L'`
  /// - `null` $\rightarrow$ `fallback` (defaults to `'Electric'`)
  static String format(
    double? capacity, [
    EngineCapacityUnit? unit,
    String fallback = 'Electric',
  ]) {
    if (capacity == null) return fallback;

    final resolvedUnit = unit ?? EngineCapacityUnit.cc;
    switch (resolvedUnit) {
      case EngineCapacityUnit.cc:
        return '${capacity.round()} cc';
      case EngineCapacityUnit.litres:
        // Format with up to 2 decimal places, trimming redundant trailing zero (e.g. 1.50 -> 1.5, 2.00 -> 2.0)
        final fixed = capacity.toStringAsFixed(2);
        final trimmed = fixed.replaceAll(RegExp(r'(?<=\.\d)0$'), '');
        return '$trimmed L';
    }
  }

  /// Formats the engine capacity for a given [vehicle].
  static String formatVehicle(Vehicle vehicle, {String fallback = 'Electric'}) {
    return format(vehicle.engineCapacity, vehicle.engineCapacityUnit, fallback);
  }
}

/// Standalone helper function for formatting engine capacity.
String formatEngineCapacity(
  double? capacity, [
  EngineCapacityUnit? unit,
  String fallback = 'Electric',
]) =>
    EngineCapacityFormatter.format(capacity, unit, fallback);

/// Standalone helper function for converting CC to Litres.
double ccToLitres(double cc) => EngineCapacityFormatter.ccToLitres(cc);

/// Standalone helper function for converting Litres to CC.
double litresToCc(double litres) => EngineCapacityFormatter.litresToCc(litres);
