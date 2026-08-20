import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';

/// Donut chart displaying the valid part-to-whole monetary cost breakdown (Fuel, Service, Oil Change).
class CostBreakdownDonut extends StatelessWidget {
  const CostBreakdownDonut({
    super.key,
    required this.breakdown,
  });

  final CostBreakdown breakdown;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!breakdown.hasAnyCost) {
      return const SizedBox.shrink();
    }

    final fuelColor = Colors.amber.shade700;
    const serviceColor = Colors.teal;
    final oilColor = Colors.deepOrange.shade600;

    final sections = <PieChartSectionData>[];

    if (breakdown.fuelCost > 0) {
      sections.add(
        PieChartSectionData(
          color: fuelColor,
          value: breakdown.fuelCost,
          title: '${breakdown.fuelPercentage.toStringAsFixed(0)}%',
          radius: 20,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      );
    }

    if (breakdown.serviceCost > 0) {
      sections.add(
        PieChartSectionData(
          color: serviceColor,
          value: breakdown.serviceCost,
          title: '${breakdown.servicePercentage.toStringAsFixed(0)}%',
          radius: 20,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      );
    }

    if (breakdown.oilChangeCost > 0) {
      sections.add(
        PieChartSectionData(
          color: oilColor,
          value: breakdown.oilChangeCost,
          title: '${breakdown.oilPercentage.toStringAsFixed(0)}%',
          radius: 20,
          titleStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost Composition',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 90,
                height: 90,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 24,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingLg),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (breakdown.fuelCost > 0)
                      _LegendItem(
                        color: fuelColor,
                        label: 'Fuel',
                        amount: _currencyFormat.format(breakdown.fuelCost),
                        percentage:
                            '${breakdown.fuelPercentage.toStringAsFixed(0)}%',
                      ),
                    if (breakdown.serviceCost > 0) ...[
                      const SizedBox(height: 4),
                      _LegendItem(
                        color: serviceColor,
                        label: 'Service',
                        amount: _currencyFormat.format(breakdown.serviceCost),
                        percentage:
                            '${breakdown.servicePercentage.toStringAsFixed(0)}%',
                      ),
                    ],
                    if (breakdown.oilChangeCost > 0) ...[
                      const SizedBox(height: 4),
                      _LegendItem(
                        color: oilColor,
                        label: 'Oil Change',
                        amount:
                            _currencyFormat.format(breakdown.oilChangeCost),
                        percentage:
                            '${breakdown.oilPercentage.toStringAsFixed(0)}%',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String amount;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($percentage)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
