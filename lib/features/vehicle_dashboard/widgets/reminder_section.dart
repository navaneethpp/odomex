import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/reminder_card.dart';

/// Section displaying prioritized upcoming maintenance and compliance items.
class ReminderSection extends StatelessWidget {
  const ReminderSection({
    super.key,
    required this.reminders,
  });

  final List<VehicleReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming & Reminders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (reminders.isNotEmpty)
              Text(
                '${reminders.length} items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingMd),

        if (reminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: AppSizes.borderWidth,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: colorScheme.primary,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: Text(
                    'No pending reminders or scheduled maintenance.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          for (final reminder in reminders) ReminderCard(reminder: reminder),
      ],
    );
  }
}
