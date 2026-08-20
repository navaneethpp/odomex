import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/recent_record_card.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/routes/app_routes.dart';

/// Section rendering the last 10 records and a "View All Records" navigation action.
class RecentRecordsSection extends StatelessWidget {
  const RecentRecordsSection({
    super.key,
    required this.vehicleId,
    required this.records,
    required this.totalRecordsCount,
  });

  final String vehicleId;
  final List<VehicleRecord> records;
  final int totalRecordsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (records.isNotEmpty)
              Text(
                'Last ${records.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // List or Empty state
        if (records.isEmpty)
          _buildEmptyState(context)
        else ...[
          for (final record in records) RecentRecordCard(record: record),
          const SizedBox(height: AppSizes.spacingSm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.vehicleRecords,
                  arguments: vehicleId,
                );
              },
              icon: const Icon(Icons.history_rounded, size: AppSizes.iconSm),
              label: Text('View All Records ($totalRecordsCount)'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: AppSizes.iconXl,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            'No activity recorded yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            'Start tracking your vehicle usage by adding your first record.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          FilledButton.tonalIcon(
            onPressed: () {
              showAddVehicleRecordSheet(
                context: context,
                vehicleId: vehicleId,
              );
            },
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
            label: const Text('Add Record'),
          ),
        ],
      ),
    );
  }
}
