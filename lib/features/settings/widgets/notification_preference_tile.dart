import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Reusable preference tile for a specific notification category.
class NotificationPreferenceTile extends StatelessWidget {
  const NotificationPreferenceTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.isInteractive,
    required this.onChanged,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final bool isInteractive;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textColor = isInteractive
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);

    final subtitleColor = isInteractive
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    final iconColor = isInteractive
        ? (value ? colorScheme.primary : colorScheme.onSurfaceVariant)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Semantics(
      label: '$title. $description. Currently ${value ? "enabled" : "disabled"}. ${isInteractive ? "Interactive" : "Disabled because master notifications are off"}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category Icon Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isInteractive
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppSizes.iconMd - 2,
              ),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.spacingSm),

            // Category Switch
            Switch.adaptive(
              value: value,
              onChanged: isInteractive ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
