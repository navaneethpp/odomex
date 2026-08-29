import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_durations.dart';

/// Inherited scope providing a shared animation progress [0.0 -> 1.0]
/// to synchronize all descendant [AnimatedNumberText] widgets on a single timeline.
class SynchronizedCounterScope extends InheritedWidget {
  const SynchronizedCounterScope({
    super.key,
    required this.animation,
    required super.child,
  });

  /// The shared [Animation<double>] driving synchronized counter progression.
  final Animation<double> animation;

  /// Retrieves the nearest [SynchronizedCounterScope] animation, or null if standalone.
  static Animation<double>? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SynchronizedCounterScope>();
    return scope?.animation;
  }

  @override
  bool updateShouldNotify(SynchronizedCounterScope oldWidget) {
    return animation != oldWidget.animation;
  }
}

/// Highly optimized, frame-driven animated number text widget with synchronized timing.
///
/// Features:
/// - Smooth count-up animation from 0 (or previous value) to the exact target value.
/// - Synchronized execution: Automatically attaches to [SynchronizedCounterScope] if available,
///   or accepts an explicit [animation] controller so all numbers start and finish together.
/// - Comprehensive formatting: Supports integer, decimal, currency prefix, and unit suffix.
/// - Accessibility: Respects [MediaQuery.disableAnimations] (reduced motion).
/// - Overflow safety: Wrapped in [FittedBox] with [BoxFit.scaleDown] to prevent layout overflow.
class AnimatedNumberText extends StatefulWidget {
  const AnimatedNumberText({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.unit,
    this.style,
    this.prefixStyle,
    this.suffixStyle,
    this.unitStyle,
    this.decimalDigits,
    this.duration,
    this.curve = AppDurations.counterCurve,
    this.animation,
    this.textAlign,
    this.alignment = Alignment.centerLeft,
  });

  /// The target numerical value to animate to.
  final num value;

  /// Optional prefix string (e.g. '₹', '$').
  final String? prefix;

  /// Optional suffix string (e.g. ' km', ' L').
  final String? suffix;

  /// Optional unit suffix (alias for [suffix]).
  final String? unit;

  /// Text style for the animated number digits.
  final TextStyle? style;

  /// Text style for the prefix string.
  final TextStyle? prefixStyle;

  /// Text style for the suffix string.
  final TextStyle? suffixStyle;

  /// Text style for the unit string.
  final TextStyle? unitStyle;

  /// Fixed number of decimal digits to display (e.g. 0, 1, 2).
  /// If null, whole numbers format as integers ('#,##0') and fractional values as '#,##0.#'.
  final int? decimalDigits;

  /// Standalone animation duration (ignored when using a shared [animation] or [SynchronizedCounterScope]).
  final Duration? duration;

  /// Animation curve (defaults to [AppDurations.counterCurve]).
  final Curve curve;

  /// Explicit shared animation progress [0.0 -> 1.0] to synchronize with other counters.
  final Animation<double>? animation;

  /// Text alignment.
  final TextAlign? textAlign;

  /// Layout alignment within the [FittedBox].
  final Alignment alignment;

  static final _intFormatter = NumberFormat('#,##0');
  static final _decimal1Formatter = NumberFormat('#,##0.0');
  static final _decimal2Formatter = NumberFormat('#,##0.00');
  static final _autoDecimalFormatter = NumberFormat('#,##0.#');

  /// Formats a numerical value for display.
  static String formatNumber(double val, {int? decimalDigits}) {
    if (val.isNaN || val.isInfinite) return '0';
    if (decimalDigits == 0) {
      return _intFormatter.format(val.round());
    } else if (decimalDigits == 1) {
      return _decimal1Formatter.format(val);
    } else if (decimalDigits == 2) {
      return _decimal2Formatter.format(val);
    } else if (decimalDigits != null && decimalDigits > 2) {
      return NumberFormat.currency(
        customPattern: '#,##0.${'0' * decimalDigits}',
        decimalDigits: decimalDigits,
      ).format(val);
    }

    if (val % 1 == 0) {
      return _intFormatter.format(val.toInt());
    }
    return _autoDecimalFormatter.format(val);
  }

  @override
  State<AnimatedNumberText> createState() => _AnimatedNumberTextState();
}

class _AnimatedNumberTextState extends State<AnimatedNumberText>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;
  Animation<double>? _internalAnimation;
  late double _fromValue;

  @override
  void initState() {
    super.initState();
    _fromValue = 0.0;
    if (widget.animation == null) {
      _initInternalController();
    }
  }

  void _initInternalController() {
    final controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppDurations.counterAnimation,
    );
    _internalController = controller;
    _internalAnimation = Tween<double>(
      begin: _fromValue,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.curve,
    ));
    controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sharedAnimation = SynchronizedCounterScope.maybeOf(context);
    if (sharedAnimation != null && _internalController != null) {
      _internalController?.dispose();
      _internalController = null;
      _internalAnimation = null;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedNumberText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (_internalController != null && _internalAnimation != null) {
        _fromValue = _internalAnimation!.value;
        _internalAnimation = Tween<double>(
          begin: _fromValue,
          end: widget.value.toDouble(),
        ).animate(CurvedAnimation(
          parent: _internalController!,
          curve: widget.curve,
        ));
        _internalController!
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final sharedAnimation =
        widget.animation ?? SynchronizedCounterScope.maybeOf(context);

    if (sharedAnimation == null && _internalController == null) {
      _initInternalController();
    }

    final activeAnimation = sharedAnimation ?? _internalAnimation;
    final resolvedSuffix = widget.suffix ?? widget.unit;
    final resolvedSuffixStyle = widget.suffixStyle ?? widget.unitStyle;

    if (reduceMotion || activeAnimation == null || widget.value == 0) {
      return _buildFormattedContent(
        widget.value.toDouble(),
        resolvedSuffix: resolvedSuffix,
        resolvedSuffixStyle: resolvedSuffixStyle,
      );
    }

    return AnimatedBuilder(
      animation: activeAnimation,
      builder: (context, child) {
        double currentVal;
        if (sharedAnimation != null) {
          // Driven by shared timeline [0.0 -> 1.0]
          final progress = activeAnimation.value.clamp(0.0, 1.0);
          currentVal = progress * widget.value.toDouble();
        } else {
          // Self-managed tween value
          currentVal = (_internalController?.isCompleted ?? false)
              ? widget.value.toDouble()
              : activeAnimation.value;
        }

        return _buildFormattedContent(
          currentVal,
          resolvedSuffix: resolvedSuffix,
          resolvedSuffixStyle: resolvedSuffixStyle,
        );
      },
    );
  }

  Widget _buildFormattedContent(
    double currentVal, {
    required String? resolvedSuffix,
    required TextStyle? resolvedSuffixStyle,
  }) {
    final formattedDigits = AnimatedNumberText.formatNumber(
      currentVal,
      decimalDigits: widget.decimalDigits,
    );

    final hasPrefix = widget.prefix != null && widget.prefix!.isNotEmpty;
    final hasSuffix = resolvedSuffix != null && resolvedSuffix.isNotEmpty;

    Widget content;

    if (!hasPrefix && !hasSuffix) {
      content = Text(
        formattedDigits,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (hasPrefix) ...[
            Text(
              widget.prefix!,
              style: widget.prefixStyle ?? widget.style,
            ),
            if (!widget.prefix!.endsWith(' ') &&
                !widget.prefix!.endsWith('₹') &&
                !widget.prefix!.endsWith('\$'))
              const SizedBox(width: 2),
          ],
          Text(
            formattedDigits,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
          if (hasSuffix) ...[
            const SizedBox(width: 3),
            Text(
              resolvedSuffix.trim(),
              style: resolvedSuffixStyle ?? widget.style,
            ),
          ],
        ],
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: widget.alignment,
      child: content,
    );
  }
}
