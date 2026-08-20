import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';

/// Contextual bottom sheet displayed on long-pressing a vehicle card.
class VehicleActionSheet extends StatelessWidget {
  const VehicleActionSheet({
    super.key,
    required this.vehicle,
    required this.isPinned,
    required this.onTogglePin,
  });

  final Vehicle vehicle;
  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Vehicle Header
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingSm,
                horizontal: AppSizes.paddingSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand.displayName} ${vehicle.model}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle.registrationNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spacingSm),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.spacingSm),

            // Pin / Unpin Action
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: AppSizes.iconMd,
                ),
              ),
              title: Text(
                isPinned ? 'Unpin Vehicle' : 'Pin Vehicle',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isPinned
                    ? 'Remove from the top of your vehicle list'
                    : 'Keep this vehicle at the top of your list',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onTogglePin();
              },
            ),

            // Cancel Action
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSizes.iconMd,
                ),
              ),
              title: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the [VehicleActionSheet] modal bottom sheet.
Future<void> showVehicleActionSheet({
  required BuildContext context,
  required Vehicle vehicle,
  required bool isPinned,
  required VoidCallback onTogglePin,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (context) => VehicleActionSheet(
      vehicle: vehicle,
      isPinned: isPinned,
      onTogglePin: onTogglePin,
    ),
  );
}
