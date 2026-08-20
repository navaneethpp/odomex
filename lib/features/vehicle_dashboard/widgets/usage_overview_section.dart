import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/cost_breakdown_donut.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/daily_cost_chart.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/daily_distance_chart.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/period_metric_card.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/period_selector.dart';

enum _ChartTab { distance, cost }

/// Main Period-based Usage and Cost Overview section.
///
/// Contains:
///   1. Period Selector (7D, 14D, 30D, 90D)
///   2. 3 Period Metric Cards (Total Distance, Fuel Used, Total Cost)
///   3. Discrete Bar Charts for Daily Distance and Daily Cost
///   4. Donut Chart for monetary Cost Breakdown (Fuel vs Service vs Oil)
class UsageOverviewSection extends StatefulWidget {
  const UsageOverviewSection({
    super.key,
    required this.periodSummary,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final PeriodUsageSummary periodSummary;
  final UsageRange selectedRange;
  final ValueChanged<UsageRange> onRangeSelected;

  @override
  State<UsageOverviewSection> createState() => _UsageOverviewSectionState();
}

class _UsageOverviewSectionState extends State<UsageOverviewSection> {
  _ChartTab _activeTab = _ChartTab.distance;

  static final _numberFormat = NumberFormat('#,##0.#');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = widget.periodSummary;

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
            // ── 1. Top Period Selector & Date Range Label ────────────
            PeriodSelector(
              selectedRange: widget.selectedRange,
              periodLabel: summary.periodLabel,
              onRangeSelected: widget.onRangeSelected,
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // ── 2. Metric Summary Cards (Distance, Fuel, Cost) ───────
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: PeriodMetricCard(
                        title: 'Distance',
                        value: _numberFormat.format(summary.totalDistanceKm),
                        unit: 'km',
                        icon: Icons.route_rounded,
                        accentColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: PeriodMetricCard(
                        title: 'Fuel',
                        value: summary.totalFuelLitres.toStringAsFixed(1),
                        unit: 'L',
                        icon: Icons.local_gas_station_rounded,
                        accentColor: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: PeriodMetricCard(
                        title: 'Cost',
                        value: _currencyFormat.format(summary.totalCost),
                        icon: Icons.payments_rounded,
                        accentColor: Colors.teal.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 3. Chart Tab Selector (Daily Distance vs Daily Cost) ─
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Daily Distance (km)',
                      icon: Icons.bar_chart_rounded,
                      isSelected: _activeTab == _ChartTab.distance,
                      onTap: () => setState(() => _activeTab = _ChartTab.distance),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      label: 'Daily Cost (₹)',
                      icon: Icons.payments_outlined,
                      isSelected: _activeTab == _ChartTab.cost,
                      onTap: () => setState(() => _activeTab = _ChartTab.cost),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // ── 4. Active Bar Chart ──────────────────────────────────
            if (_activeTab == _ChartTab.distance)
              DailyDistanceChart(travelSummary: summary.travelSummary)
            else
              DailyCostChart(dailyCosts: summary.dailyCosts),

            // ── 5. Monetary Cost Breakdown Donut ─────────────────────
            if (summary.costBreakdown.hasAnyCost) ...[
              const SizedBox(height: AppSizes.spacingMd),
              CostBreakdownDonut(breakdown: summary.costBreakdown),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingSm,
          horizontal: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconSm,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
