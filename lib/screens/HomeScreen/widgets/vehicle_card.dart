import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isPinned;
  final VoidCallback? onView;
  final VoidCallback? onAdd;
  final VoidCallback? onLongPress;
  final VoidCallback? onActions;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isPinned = false,
    this.onView,
    this.onAdd,
    this.onLongPress,
    this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actionsCallback = onActions ?? onLongPress;

    return Semantics(
      label:
          '${vehicle.brandDisplayName} ${vehicle.model}, ${vehicle.vehicleType.displayName}, ${vehicle.odometerReading.toStringAsFixed(0)} km. ${isPinned ? "Pinned. " : ""}Long press for vehicle actions.',
      button: true,
      child: Card(
        elevation: AppSizes.elevationSm,
        child: InkWell(
          onTap: onView,
          onLongPress: actionsCallback,
          borderRadius: BorderRadius.circular(
            AppSizes.radiusLg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isPinned) ...[
                            Icon(
                              Icons.push_pin_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: AppSizes.spacingXs),
                          ],
                          Flexible(
                            child: Hero(
                              tag: 'vehicle_${vehicle.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  vehicle.model,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: isPinned
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppSizes.spacingSm,
                      ),
                      Row(
                        children: [
                          Icon(
                            vehicle.vehicleType.icon,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${vehicle.vehicleType.displayName} · ${vehicle.odometerReading.toStringAsFixed(0)} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add record',
                ),
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'View vehicle',
                ),
                IconButton(
                  onPressed: actionsCallback,
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Vehicle actions',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
