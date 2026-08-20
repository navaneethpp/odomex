import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';

/// Bar chart rendering daily distance travelled over the selected period.
class DailyDistanceChart extends StatelessWidget {
  const DailyDistanceChart({
    super.key,
    required this.travelSummary,
  });

  final DailyTravelSummary travelSummary;

  static final _numberFormat = NumberFormat('#,##0.#');
  static final _dayOfWeekFormat = DateFormat('E');
  static final _dayMonthFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final points = travelSummary.points;

    if (!travelSummary.hasSufficientData) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXl),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.route_rounded,
              size: AppSizes.iconXl,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'No travel recorded in this period',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final maxDistance = travelSummary.maxDailyKm;
    final maxY = maxDistance > 0 ? (maxDistance * 1.25) : 10.0;

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
                final point = points[groupIndex];
                final dateStr = _dayMonthFormat.format(point.date);
                final text = point.isRecorded
                    ? '$dateStr\n${_numberFormat.format(point.distanceKm)} km'
                    : '$dateStr\nNo data recorded';

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
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }

                  final total = points.length;
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

                  final date = points[index].date;
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
          barGroups: List.generate(points.length, (index) {
            final point = points[index];
            final hasValue = point.isRecorded && point.distanceKm > 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hasValue ? point.distanceKm : 0.0,
                  color: hasValue
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  width: points.length <= 7
                      ? 18
                      : (points.length <= 14
                          ? 10
                          : (points.length <= 30 ? 6 : 3)),
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
