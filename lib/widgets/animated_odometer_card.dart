import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/widgets/animated_odometer_text.dart';

/// Reusable animated card displaying a vehicle's odometer reading with count-up animation.
class AnimatedOdometerCard extends StatelessWidget {
  const AnimatedOdometerCard({
    super.key,
    required this.value,
    this.subtitle = 'Current Odometer',
    this.duration,
    this.centerAlign = true,
    this.icon,
    this.backgroundColor,
  });

  /// Current odometer reading in km.
  final double value;

  /// Subtitle label (e.g. 'Current Odometer').
  final String subtitle;

  /// Custom animation duration.
  final Duration? duration;

  /// Whether text and contents are center-aligned.
  final bool centerAlign;

  /// Optional leading/header icon.
  final IconData? icon;

  /// Custom background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final crossAxisAlignment = centerAlign
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centerAlign ? TextAlign.center : TextAlign.start;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        elevation: AppSizes.elevationMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppSizes.iconMd,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSizes.spacingSm),
              ],
              Text(
                subtitle,
                textAlign: textAlign,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spacingXs),
              AnimatedOdometerText(
                value: value,
                duration: duration,
                unit: 'km',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                unitStyle: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
