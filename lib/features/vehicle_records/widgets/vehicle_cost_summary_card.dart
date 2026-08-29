import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/cost_summary.dart';
import 'package:odomex/features/vehicle_records/providers/cost_summary_provider.dart';
import 'package:odomex/features/vehicle_records/services/cost_summary_calculator.dart';
import 'package:odomex/widgets/animated_number_text.dart';

/// Interactive summary card displaying vehicle financial spending across Daily, Monthly, and Yearly timeframes.
class VehicleCostSummaryCard extends ConsumerWidget {
  const VehicleCostSummaryCard({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedPeriod = ref.watch(costPeriodProvider(vehicleId));
    final selectedDate = ref.watch(costSelectedDateProvider(vehicleId));
    final summary = ref.watch(costSummaryProvider(vehicleId));

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.25),
              colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Top Section: Title & Status Badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: AppSizes.iconSm,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSizes.spacingXs),
                    Text(
                      'COST SUMMARY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm,
                    vertical: AppSizes.paddingXs,
                  ),
                  decoration: BoxDecoration(
                    color: summary.hasCost
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    summary.hasCost
                        ? '${summary.costBearingRecordCount} records'
                        : 'No expenses',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: summary.hasCost
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // ── 2. Full-Width Period Segmented Control ──
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<CostPeriod>(
                segments: const [
                  ButtonSegment(
                    value: CostPeriod.daily,
                    label: Text('Daily'),
                  ),
                  ButtonSegment(
                    value: CostPeriod.monthly,
                    label: Text('Monthly'),
                  ),
                  ButtonSegment(
                    value: CostPeriod.yearly,
                    label: Text('Yearly'),
                  ),
                ],
                selected: {selectedPeriod},
                onSelectionChanged: (newSelection) {
                  ref.read(costPeriodProvider(vehicleId).notifier).state =
                      newSelection.first;
                },
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // ── 2. Period Navigation (‹ Label ›) ──
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: 'Previous ${selectedPeriod.label}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final prev = CostSummaryCalculator.previousPeriod(
                        selectedDate,
                        selectedPeriod,
                      );
                      ref.read(costSelectedDateProvider(vehicleId).notifier).state =
                          prev;
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSizes.spacingXs),
                      Text(
                        summary.periodLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: 'Next ${selectedPeriod.label}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final next = CostSummaryCalculator.nextPeriod(
                        selectedDate,
                        selectedPeriod,
                      );
                      ref.read(costSelectedDateProvider(vehicleId).notifier).state =
                          next;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // ── 3. Prominent Total Spending Display ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL EXPENSES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedNumberText(
                  value: summary.totalCost,
                  prefix: '₹',
                  decimalDigits: 2,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // ── 4. Category Breakdown ──
            if (summary.hasCost)
              Row(
                children: [
                  Expanded(
                    child: _CategoryPill(
                      label: 'Fuel',
                      cost: summary.fuelCost,
                      percentage: summary.fuelPercentage,
                      icon: Icons.local_gas_station_rounded,
                      accentColor: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(
                    child: _CategoryPill(
                      label: 'Service',
                      cost: summary.serviceCost,
                      percentage: summary.servicePercentage,
                      icon: Icons.build_rounded,
                      accentColor: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(
                    child: _CategoryPill(
                      label: 'Oil',
                      cost: summary.oilChangeCost,
                      percentage: summary.oilChangePercentage,
                      icon: Icons.oil_barrel_rounded,
                      accentColor: Colors.deepOrange.shade700,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingSm,
                  horizontal: AppSizes.paddingMd,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: AppSizes.iconSm,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: Text(
                        'No monetary expenses logged for this ${selectedPeriod.label.toLowerCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.cost,
    required this.percentage,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final double cost;
  final double percentage;
  final IconData icon;
  final Color accentColor;

  static final _formatter = NumberFormat('#,##0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: accentColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${_formatter.format(cost)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (percentage > 0)
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: accentColor,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}
