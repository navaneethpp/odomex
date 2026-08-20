import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/usage_range_selector.dart';

/// Interactive daily travel analytics section with range selector and fl_chart bar chart.
class UsageChartSection extends StatelessWidget {
  const UsageChartSection({
    super.key,
    required this.travelSummary,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final DailyTravelSummary travelSummary;
  final UsageRange selectedRange;
  final ValueChanged<UsageRange> onRangeSelected;

  static final _numberFormat = NumberFormat('#,##0.#');
  static final _dayOfWeekFormat = DateFormat('E');
  static final _dayMonthFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top title and range selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Travel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                UsageRangeSelector(
                  selectedRange: selectedRange,
                  onRangeSelected: onRangeSelected,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingMd),

            if (!travelSummary.hasSufficientData)
              _buildEmptyState(context)
            else ...[
              // Summary Metrics Row
              _buildMetricsRow(context),

              const SizedBox(height: AppSizes.spacingLg),

              // Bar Chart
              SizedBox(
                height: 180,
                child: _buildBarChart(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricItem(
            label: 'Total Travel',
            value: '${_numberFormat.format(travelSummary.totalDistanceKm)} km',
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _MetricItem(
            label: 'Daily Avg',
            value: '${_numberFormat.format(travelSummary.averageDailyKm)} km/d',
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _MetricItem(
            label: 'Peak Day',
            value: '${_numberFormat.format(travelSummary.maxDailyKm)} km',
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final points = travelSummary.points;

    // Calculate dynamic Y-axis maximum
    final maxDistance = travelSummary.maxDailyKm;
    final maxY = maxDistance > 0 ? (maxDistance * 1.25) : 10.0;

    return BarChart(
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }

                // Determine label frequency based on range
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
                  padding: const EdgeInsets.only(top: 6),
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
                    : (points.length <= 14 ? 10 : (points.length <= 30 ? 6 : 3)),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingXl,
        horizontal: AppSizes.paddingMd,
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: AppSizes.iconXl,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            'Not enough travel data yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            'Add odometer readings regularly to see your daily travel analytics.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
