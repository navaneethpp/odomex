import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';

/// Segmented period selector (7D, 14D, 30D, 90D) with period description label.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selectedRange,
    required this.periodLabel,
    required this.onRangeSelected,
  });

  final UsageRange selectedRange;
  final String periodLabel;
  final ValueChanged<UsageRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            // Range Chips
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
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
                        horizontal: AppSizes.paddingSm + 2,
                        vertical: AppSizes.paddingXs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        range.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          periodLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
