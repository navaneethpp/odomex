import 'package:flutter/animation.dart';

/// Centralized animation durations and curves for Odomex.
class AppDurations {
  AppDurations._();

  /// Fast transition duration (200ms).
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transition duration (300ms) for screen and Hero transitions.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow / emphasized duration (450ms).
  static const Duration slow = Duration(milliseconds: 450);

  /// Smooth, readable odometer reading count-up animation duration (1800ms).
  static const Duration odometerCountUp = Duration(milliseconds: 1800);

  /// Alias for odometer animation duration.
  static const Duration odometer = odometerCountUp;

  /// Natural ease-out curve for entering screen transitions and odometer count-up.
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Smooth ease-in curve for reverse / exiting transitions.
  static const Curve reverseCurve = Curves.easeInCubic;
}
