import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';

/// Compact top header for the Vehicle Dashboard.
///
/// Displays the vehicle model, brand icon, and registration number badge.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand / Vehicle Icon Badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Icon(
            Icons.two_wheeler_rounded,
            color: colorScheme.onPrimaryContainer,
            size: AppSizes.iconLg,
          ),
        ),

        const SizedBox(width: AppSizes.spacingMd),

        // Vehicle info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.model,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Text(
                  vehicle.registrationNumber,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
