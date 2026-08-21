import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Settings tile card allowing users to toggle notifications and test local notification delivery.
class NotificationSettingTile extends ConsumerWidget {
  const NotificationSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = ref.watch(notificationSettingsProvider);

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Notification Toggle Row ───────────────────────
          Padding(
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
                    isEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: isEnabled
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
                        'Receive reminders and updates',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Material 3 Switch
                Semantics(
                  label: 'Toggle notifications. Currently ${isEnabled ? "enabled" : "disabled"}.',
                  child: Switch.adaptive(
                    value: isEnabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setNotificationsEnabled(value, context: context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────
          Divider(
            height: 1,
            thickness: AppSizes.borderWidth,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          // ── 2. Test Notification Action Button ────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .sendTestNotification(context);
              },
              icon: Icon(
                Icons.notifications_none_rounded,
                size: AppSizes.iconSm + 2,
                color: isEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Test Notification',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(
                  color: isEnabled
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: AppSizes.borderWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
