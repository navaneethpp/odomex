import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/widgets/animated_number_text.dart';

/// Reusable metric card displaying a single period-based usage value (Distance, Fuel, or Cost).
///
/// Supports smooth, synchronized count-up animation when [numericValue] is provided.
class PeriodMetricCard extends StatelessWidget {
  const PeriodMetricCard({
    super.key,
    required this.title,
    this.value,
    this.numericValue,
    this.prefix,
    this.unit,
    this.decimalDigits,
    required this.icon,
    this.accentColor,
    this.subtitle,
  }) : assert(value != null || numericValue != null,
            'Either value or numericValue must be provided');

  final String title;
  final String? value;
  final num? numericValue;
  final String? prefix;
  final String? unit;
  final int? decimalDigits;
  final IconData icon;
  final Color? accentColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = accentColor ?? colorScheme.primary;

    return Card(
      elevation: AppSizes.elevationSm,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingMd,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon & Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, size: AppSizes.iconSm, color: accent),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // Value + Unit
            if (numericValue != null)
              AnimatedNumberText(
                value: numericValue!,
                prefix: prefix,
                unit: unit,
                decimalDigits: decimalDigits,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                prefixStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                unitStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unit != null && unit!.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      unit!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
