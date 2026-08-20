import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';

/// Bar chart rendering daily vehicle expenses (Fuel + Service + Oil Change).
class DailyCostChart extends StatelessWidget {
  const DailyCostChart({
    super.key,
    required this.dailyCosts,
  });

  final List<DailyCostPoint> dailyCosts;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final _dayOfWeekFormat = DateFormat('E');
  static final _dayMonthFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasAnyCost = dailyCosts.any((c) => c.hasExpense);

    if (!hasAnyCost) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXl),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.payments_outlined,
              size: AppSizes.iconXl,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'No expenses recorded in this period',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    double maxCost = 0.0;
    for (final c in dailyCosts) {
      if (c.totalCost > maxCost) maxCost = c.totalCost;
    }
    final maxY = maxCost > 0 ? (maxCost * 1.25) : 100.0;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.inverseSurface,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingXs,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = dailyCosts[groupIndex];
                final dateStr = _dayMonthFormat.format(point.date);

                if (!point.hasExpense) {
                  return BarTooltipItem(
                    '$dateStr\nNo expense',
                    theme.textTheme.labelSmall!.copyWith(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                final details = <String>[];
                if (point.fuelCost > 0) {
                  details.add('Fuel: ${_currencyFormat.format(point.fuelCost)}');
                }
                if (point.serviceCost > 0) {
                  details.add('Service: ${_currencyFormat.format(point.serviceCost)}');
                }
                if (point.oilChangeCost > 0) {
                  details.add('Oil: ${_currencyFormat.format(point.oilChangeCost)}');
                }

                final text =
                    '$dateStr\nTotal: ${_currencyFormat.format(point.totalCost)}\n${details.join('\n')}';

                return BarTooltipItem(
                  text,
                  theme.textTheme.labelSmall!.copyWith(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dailyCosts.length) {
                    return const SizedBox.shrink();
                  }

                  final total = dailyCosts.length;
                  bool shouldShow = false;

                  if (total <= 7) {
                    shouldShow = true;
                  } else if (total <= 14) {
                    shouldShow = index % 2 == 0 || index == total - 1;
                  } else if (total <= 30) {
                    shouldShow = index % 5 == 0 || index == total - 1;
                  } else {
                    shouldShow = index % 15 == 0 || index == total - 1;
                  }

                  if (!shouldShow) return const SizedBox.shrink();

                  final date = dailyCosts[index].date;
                  final text = total <= 7
                      ? _dayOfWeekFormat.format(date)
                      : DateFormat('d/M').format(date);

                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      text,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: math.max(maxY / 3, 1.0),
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(dailyCosts.length, (index) {
            final point = dailyCosts[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: point.hasExpense ? point.totalCost : 0.0,
                  color: point.hasExpense
                      ? Colors.amber.shade700
                      : colorScheme.surfaceContainerHighest,
                  width: dailyCosts.length <= 7
                      ? 18
                      : (dailyCosts.length <= 14
                          ? 10
                          : (dailyCosts.length <= 30 ? 6 : 3)),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.2),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
