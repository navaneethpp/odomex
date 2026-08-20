import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_colors.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// An alert item model used in [AlertsCard].
class VehicleAlert {
  final IconData icon;
  final String title;
  final String? subtitle;
  final AlertSeverity severity;

  const VehicleAlert({
    required this.icon,
    required this.title,
    this.subtitle,
    this.severity = AlertSeverity.warning,
  });
}

enum AlertSeverity { warning, critical }

/// Displays a list of [VehicleAlert] items under an "Attention Required"
/// heading. Only rendered when [alerts] is non-empty.
///
/// When [alerts] is empty, renders a subtle "All good" state.
class AlertsCard extends StatelessWidget {
  final List<VehicleAlert> alerts;

  const AlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const _AllGoodCard();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // Slight tint for the alert card
      color: colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Text(
                  'Attention Required',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingMd),

            ...alerts.map((alert) => _AlertRow(alert: alert)),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final VehicleAlert alert;
  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert.severity == AlertSeverity.critical
        ? AppColors.error
        : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, size: AppSizes.iconSm, color: color),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (alert.subtitle != null) ...[
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    alert.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllGoodCard extends StatelessWidget {
  const _AllGoodCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: AppColors.success.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Text(
              'Everything looks good',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
