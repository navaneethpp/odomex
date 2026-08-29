import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/widgets/animated_number_text.dart';

export 'package:odomex/widgets/animated_number_text.dart';

/// Frame-driven count-up text widget for vehicle odometer readings.
///
/// Refactored to leverage the generalized, synchronized [AnimatedNumberText] system.
class AnimatedOdometerText extends StatelessWidget {
  const AnimatedOdometerText({
    super.key,
    required this.value,
    this.style,
    this.duration,
    this.curve = AppDurations.defaultCurve,
    this.unit,
    this.unitStyle,
    this.animation,
  });

  /// The target odometer reading in kilometers.
  final double value;

  /// Text style for the animated number.
  final TextStyle? style;

  /// Animation duration (defaults to [AppDurations.counterAnimation]).
  final Duration? duration;

  /// Animation curve (defaults to [AppDurations.defaultCurve]).
  final Curve curve;

  /// Optional unit suffix (e.g. 'km') placed next to the number.
  final String? unit;

  /// Text style for the unit suffix.
  final TextStyle? unitStyle;

  /// Optional shared synchronized animation progress.
  final Animation<double>? animation;

  /// Formatting helper preserving backward-compatibility with unit tests.
  static String formatReading(double reading) {
    return AnimatedNumberText.formatNumber(reading);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedNumberText(
      value: value,
      unit: unit,
      style: style,
      unitStyle: unitStyle,
      duration: duration ?? AppDurations.counterAnimation,
      curve: curve,
      animation: animation,
    );
  }
}
