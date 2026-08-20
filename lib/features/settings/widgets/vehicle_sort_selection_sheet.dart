import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/providers/vehicle_sort_provider.dart';

/// Modal bottom sheet allowing the user to select their vehicle list sorting preference.
class VehicleSortSelectionSheet extends ConsumerWidget {
  const VehicleSortSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) => const VehicleSortSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentOption = ref.watch(vehicleSortOptionProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingLg,
          horizontal: AppSizes.paddingMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: Text(
                'Sort Vehicles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // Options
            ...VehicleSortOption.values.map((option) {
              final isSelected = option == currentOption;
              final icon = option == VehicleSortOption.lastAccessed
                  ? Icons.history_rounded
                  : Icons.sort_by_alpha_rounded;

              return InkWell(
                onTap: () {
                  ref
                      .read(vehicleSortOptionProvider.notifier)
                      .updateSortOption(option);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacingXs,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMd,
                    vertical: AppSizes.paddingMd,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingSm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: AppSizes.iconMd,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        size: AppSizes.iconMd,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Displays the [VehicleSortSelectionSheet] bottom sheet.
Future<void> showVehicleSortSelectionSheet(BuildContext context) {
  return VehicleSortSelectionSheet.show(context);
}
