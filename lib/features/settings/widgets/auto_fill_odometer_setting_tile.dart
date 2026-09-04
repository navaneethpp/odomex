import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/auto_fill_odometer_provider.dart';

/// Settings tile row displaying a switch for toggling Auto-fill Current Odometer.
class AutoFillOdometerSettingTile extends ConsumerWidget {
  const AutoFillOdometerSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = ref.watch(autoFillOdometerProvider);

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
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
                Icons.speed_rounded,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-fill Current Odometer',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Automatically fill the latest odometer reading when adding a new record.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: AppSizes.spacingMd),

            // Toggle Switch
            Switch(
              value: isEnabled,
              onChanged: (val) {
                ref.read(autoFillOdometerProvider.notifier).setAutoFillOdometer(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
