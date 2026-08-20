import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_durations.dart';

/// Frame-driven count-up text widget for vehicle odometer readings.
///
/// Animates smoothly from 0 (or previous value) to the exact target reading,
/// respecting user reduce-motion accessibility preferences.
class AnimatedOdometerText extends StatefulWidget {
  const AnimatedOdometerText({
    super.key,
    required this.value,
    this.style,
    this.duration,
    this.curve = AppDurations.defaultCurve,
    this.unit,
    this.unitStyle,
  });

  /// The target odometer reading in kilometers.
  final double value;

  /// Text style for the animated number.
  final TextStyle? style;

  /// Animation duration (defaults to [AppDurations.odometerCountUp]).
  final Duration? duration;

  /// Animation curve (defaults to [AppDurations.defaultCurve]).
  final Curve curve;

  /// Optional unit suffix (e.g. 'km') placed next to the number.
  final String? unit;

  /// Text style for the unit suffix.
  final TextStyle? unitStyle;

  @override
  State<AnimatedOdometerText> createState() => _AnimatedOdometerTextState();
}

class _AnimatedOdometerTextState extends State<AnimatedOdometerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _fromValue;

  static final _intFormatter = NumberFormat('#,##0');
  static final _decimalFormatter = NumberFormat('#,##0.#');

  static String formatReading(double reading) {
    if (reading % 1 == 0) {
      return _intFormatter.format(reading.toInt());
    }
    return _decimalFormatter.format(reading);
  }

  @override
  void initState() {
    super.initState();
    _fromValue = 0.0;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppDurations.odometerCountUp,
    );

    _animation = Tween<double>(
      begin: _fromValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedOdometerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _fromValue = _animation.value;
      _animation = Tween<double>(
        begin: _fromValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // If animation completed or reduced motion is enabled, display exact target value
        final currentReading = (_controller.isCompleted || reduceMotion)
            ? widget.value
            : _animation.value;

        final formattedText = formatReading(currentReading);

        if (widget.unit != null && widget.unit!.isNotEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formattedText,
                style: widget.style,
              ),
              const SizedBox(width: 4),
              Text(
                widget.unit!,
                style: widget.unitStyle,
              ),
            ],
          );
        }

        return Text(
          formattedText,
          style: widget.style,
        );
      },
    );
  }
}
