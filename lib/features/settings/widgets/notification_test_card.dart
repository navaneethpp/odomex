import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Card container providing notification test triggers with descriptive helper text.
///
/// Provides three diagnostic capabilities:
/// 1. **Immediate test**: Fires an instant notification via `show()`.
/// 2. **Scheduled test**: Schedules a notification 1 minute in the future via `zonedSchedule()`.
/// 3. **Pending inspector**: Queries and displays the count of OS-registered pending notifications.
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

            // ── 1. Immediate test notification ─────────────
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
              style: _buttonStyle(colorScheme, isMasterEnabled),
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // ── 2. Scheduled test notification (1 min) ─────
            OutlinedButton.icon(
              onPressed: isMasterEnabled
                  ? () => _scheduleDevTest(context, ref)
                  : null,
              icon: Icon(
                Icons.schedule_rounded,
                size: AppSizes.iconSm + 2,
                color: isMasterEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Schedule Test (1 min)',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isMasterEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              style: _buttonStyle(colorScheme, isMasterEnabled),
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // ── 3. Pending notification inspector ──────────
            OutlinedButton.icon(
              onPressed: () => _showPendingCount(context, ref),
              icon: Icon(
                Icons.pending_actions_outlined,
                size: AppSizes.iconSm + 2,
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Show Pending',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              style: _buttonStyle(colorScheme, true),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(ColorScheme colorScheme, bool isEnabled) {
    return OutlinedButton.styleFrom(
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
    );
  }

  /// Schedules a dev test reminder for 1 minute in the future using the real
  /// `zonedSchedule()` pipeline — the same path production reminders use.
  Future<void> _scheduleDevTest(BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    final success = await service.scheduleDevTestReminder(minutesFromNow: 1);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Scheduled test notification for ~1 minute from now.'
              : 'Failed: notifications may be disabled in device settings.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Queries the OS for pending scheduled notifications and shows the count.
  Future<void> _showPendingCount(BuildContext context, WidgetRef ref) async {
    final service = ref.read(notificationServiceProvider);
    final count = await service.debugPrintPendingNotifications();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count pending notification(s) registered with OS. See debug console for details.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
