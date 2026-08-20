import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/widgets/animated_odometer_text.dart';

/// Prominent card highlighting the vehicle's current odometer reading with smooth count-up animation.
class OdometerSummaryCard extends StatelessWidget {
  const OdometerSummaryCard({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  static final _dateFormat = DateFormat('d MMM yyyy');

  String _updatedSubtitle() {
    if (vehicle.lastAccessedAt != null) {
      final now = DateTime.now();
      final diff = now.difference(vehicle.lastAccessedAt!);
      if (diff.inDays == 0) {
        return 'Updated today';
      } else if (diff.inDays == 1) {
        return 'Updated yesterday';
      } else if (diff.inDays < 7) {
        return 'Updated ${diff.inDays} days ago';
      }
      return 'Updated ${_dateFormat.format(vehicle.lastAccessedAt!)}';
    }
    return 'Current reading';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.35),
              colorScheme.surface,
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT ODOMETER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  AnimatedOdometerText(
                    value: vehicle.odometerReading,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    unit: 'km',
                    unitStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    _updatedSubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_rounded,
                size: AppSizes.iconLg,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
