import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// A reusable setting row for displaying and selecting a notification reminder time.
class NotificationTimeTile extends StatelessWidget {
  const NotificationTimeTile({
    super.key,
    required this.title,
    required this.time,
    required this.isInteractive,
    required this.onTimeChanged,
  });

  final String title;
  final TimeOfDay time;
  final bool isInteractive;
  final ValueChanged<TimeOfDay> onTimeChanged;

  Future<void> _pickTime(BuildContext context) async {
    if (!isInteractive) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: time,
      helpText: 'SELECT REMINDER TIME',
    );

    if (picked != null && (picked.hour != time.hour || picked.minute != time.minute)) {
      onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final formattedTime = localizations.formatTimeOfDay(time);

    final textColor = isInteractive
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    final iconColor = isInteractive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    final chipBgColor = isInteractive
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final chipBorderColor = isInteractive
        ? colorScheme.primary.withValues(alpha: 0.25)
        : colorScheme.outlineVariant.withValues(alpha: 0.2);

    final chipTextColor = isInteractive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Semantics(
      label:
          '$title. Currently $formattedTime. ${isInteractive ? "Tap to change reminder time." : "Disabled because notifications are off."}',
      button: isInteractive,
      child: InkWell(
        onTap: isInteractive ? () => _pickTime(context) : null,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingLg + AppSizes.spacingSm,
            right: AppSizes.paddingLg,
            top: AppSizes.paddingSm,
            bottom: AppSizes.paddingMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: AppSizes.iconSm + 2,
                color: iconColor,
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.paddingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  border: Border.all(
                    color: chipBorderColor,
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: chipTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isInteractive) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: chipTextColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
