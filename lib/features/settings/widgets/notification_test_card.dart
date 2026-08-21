import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Card container providing a test notification trigger with descriptive helper text.
class NotificationTestCard extends ConsumerWidget {
  const NotificationTestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationSettingsProvider);
    final isMasterEnabled = settings.enabled;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: isMasterEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Text(
                    'Check whether Odomex notifications are working correctly on this device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMd),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .sendTestNotification(context);
              },
              icon: Icon(
                Icons.science_outlined,
                size: AppSizes.iconSm + 2,
                color: isMasterEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Test Notification',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isMasterEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(
                  color: isMasterEnabled
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: AppSizes.borderWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
