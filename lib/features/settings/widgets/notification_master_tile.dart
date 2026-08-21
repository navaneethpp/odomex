import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Card tile for the master notification toggle.
class NotificationMasterTile extends ConsumerWidget {
  const NotificationMasterTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationSettingsProvider);

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
                settings.enabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                color: settings.enabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
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
                    'Manage your vehicle reminders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Master Switch
            Semantics(
              label:
                  'Master notifications toggle. Currently ${settings.enabled ? "enabled" : "disabled"}.',
              child: Switch.adaptive(
                value: settings.enabled,
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
