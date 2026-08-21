import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Card tile for the master notification toggle reflecting real operational state and permissions.
class NotificationMasterTile extends ConsumerWidget {
  const NotificationMasterTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationSettingsProvider);
    final permission = ref.watch(notificationPermissionProvider);
    final isOperational = settings.enabled && permission.notificationGranted;
    final isPermissionMissing = settings.enabled && !permission.notificationGranted;

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: isPermissionMissing
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPermissionMissing
                    ? colorScheme.errorContainer.withValues(alpha: 0.5)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                isOperational
                    ? Icons.notifications_active_rounded
                    : (isPermissionMissing
                        ? Icons.notification_important_rounded
                        : Icons.notifications_off_outlined),
                color: isOperational
                    ? colorScheme.primary
                    : (isPermissionMissing
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant),
                size: AppSizes.iconMd,
              ),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPermissionMissing
                        ? 'Permission required in device settings'
                        : 'Manage your vehicle reminders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPermissionMissing
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isPermissionMissing
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Master Switch
            Semantics(
              label:
                  'Master notifications toggle. Currently ${isOperational ? "enabled" : "disabled"}.',
              child: Switch.adaptive(
                value: isOperational,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .setMasterEnabled(value, context: context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
