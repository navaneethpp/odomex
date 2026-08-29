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

  /// Smooth, readable numeric count-up animation duration (1500ms).
  static const Duration counterAnimation = Duration(milliseconds: 1500);

  /// Smooth, readable odometer reading count-up animation duration (1500ms).
  static const Duration odometerCountUp = counterAnimation;

  /// Alias for odometer animation duration.
  static const Duration odometer = odometerCountUp;

  /// Smooth ease-out cubic curve for numerical counter animations.
  static const Curve counterCurve = Curves.easeOutCubic;

  /// Natural ease-out curve for entering screen transitions and odometer count-up.
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Smooth ease-in curve for reverse / exiting transitions.
  static const Curve reverseCurve = Curves.easeInCubic;
}
