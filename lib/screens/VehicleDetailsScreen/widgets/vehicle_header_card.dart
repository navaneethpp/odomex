import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';

/// Compact header card identifying the vehicle: name, brand/type/year, and
/// registration number. Shown at the very top of the details screen.
class VehicleHeaderCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleHeaderCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vehicle category icon badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Icon(
                vehicle.vehicleType.icon,
                size: AppSizes.iconXl,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: AppSizes.spacingLg),

            // Vehicle name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.model,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSizes.spacingXs),

                  Text(
                    '${vehicle.brandDisplayName} · ${vehicle.vehicleType.displayName} · ${vehicle.manufacturingYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSizes.spacingXs),

                  // Registration number — treated as a strong identifier
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSm,
                      vertical: AppSizes.paddingXs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      vehicle.registrationNumber,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
