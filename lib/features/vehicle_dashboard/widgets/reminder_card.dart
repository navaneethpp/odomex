import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';

/// Card rendering a single vehicle maintenance or compliance reminder.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
  });

  final VehicleReminder reminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = reminder.urgency.color(colorScheme);

    return Card(
      elevation: AppSizes.elevationSm,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: reminder.urgency == ReminderUrgency.overdue ||
                  reminder.urgency == ReminderUrgency.dueToday
              ? statusColor.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Row(
          children: [
            // Icon container with urgency tint
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingSm),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                reminder.icon,
                color: statusColor,
                size: AppSizes.iconMd,
              ),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Reminder content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Text(
                          reminder.urgency.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reminder.dueText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        reminder.remainingText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
