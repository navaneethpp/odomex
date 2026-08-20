import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/widgets/vehicle_sort_selection_sheet.dart';
import 'package:odomex/providers/vehicle_sort_provider.dart';

/// Settings tile displaying the active vehicle sorting option and opening the selection sheet.
class VehicleSortSettingTile extends ConsumerWidget {
  const VehicleSortSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortOption = ref.watch(vehicleSortOptionProvider);

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () => showVehicleSortSelectionSheet(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Semantics(
          label:
              'Sort Vehicles. Current selection: ${sortOption.title}. Tap to change sorting order.',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color: colorScheme.primary,
                    size: AppSizes.iconMd,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingMd),

                // Title & Active Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort Vehicles',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sortOption.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSizes.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
