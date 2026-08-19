import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// A read-only display row used to show a calculated value inside a form,
/// for example the "Next Oil Change" odometer derived from user input.
///
/// Renders as a subtle info row with a label and a highlighted value, making
/// it visually distinct from editable fields.
class CalculatedField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const CalculatedField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizes.iconSm,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.spacingSm),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
