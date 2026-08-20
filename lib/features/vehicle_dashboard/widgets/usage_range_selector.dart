import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';

/// Range selector chips for 7D, 14D, 30D, 90D analytics windows.
class UsageRangeSelector extends StatelessWidget {
  const UsageRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final UsageRange selectedRange;
  final ValueChanged<UsageRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: UsageRange.values.map((range) {
          final isSelected = range == selectedRange;
          return InkWell(
            onTap: () => onRangeSelected(range),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingXs + 2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                range.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
