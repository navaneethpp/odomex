import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/vehicle_status.dart';

/// A compact 2×2 grid of status mini-cards covering the four key vehicle
/// health dimensions: Oil Change, Service, Insurance, and PUC.
///
/// Each card uses a colour dot + short label to convey status at a glance.
class StatusOverviewGrid extends StatelessWidget {
  final MaintenanceStatus oilChangeStatus;
  final String oilChangeSubtitle;

  final MaintenanceStatus serviceStatus;
  final String serviceSubtitle;

  final DocumentStatus insuranceStatus;
  final String insuranceSubtitle;

  final DocumentStatus pucStatus;
  final String pucSubtitle;

  const StatusOverviewGrid({
    super.key,
    required this.oilChangeStatus,
    required this.oilChangeSubtitle,
    required this.serviceStatus,
    required this.serviceSubtitle,
    required this.insuranceStatus,
    required this.insuranceSubtitle,
    required this.pucStatus,
    required this.pucSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusMiniCard(
                icon: Icons.oil_barrel_outlined,
                label: 'Oil Change',
                subtitle: oilChangeSubtitle,
                color: maintenanceStatusColor(
                    oilChangeStatus, Theme.of(context).colorScheme),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Expanded(
              child: _StatusMiniCard(
                icon: Icons.build_circle_outlined,
                label: 'Service',
                subtitle: serviceSubtitle,
                color: maintenanceStatusColor(
                    serviceStatus, Theme.of(context).colorScheme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingMd),
        Row(
          children: [
            Expanded(
              child: _StatusMiniCard(
                icon: Icons.shield_outlined,
                label: 'Insurance',
                subtitle: insuranceSubtitle,
                color: documentStatusColor(
                    insuranceStatus, Theme.of(context).colorScheme),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Expanded(
              child: _StatusMiniCard(
                icon: Icons.verified_outlined,
                label: 'PUC',
                subtitle: pucSubtitle,
                color: documentStatusColor(
                    pucStatus, Theme.of(context).colorScheme),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _StatusMiniCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSizes.iconSm, color: colorScheme.onSurfaceVariant),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
