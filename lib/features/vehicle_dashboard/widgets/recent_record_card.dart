import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';

/// Renders a single vehicle record card with type-specific details.
class RecentRecordCard extends ConsumerWidget {
  const RecentRecordCard({
    super.key,
    required this.record,
  });

  final VehicleRecord record;

  static final _numberFormat = NumberFormat('#,##0');
  static final _dateFormat = DateFormat('d MMM yyyy');

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(recordDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _dateFormat.format(date);
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(vehicleRecordProvider.notifier).deleteRecord(
            record.vehicleId,
            record.id,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final IconData icon;
    final String typeTitle;
    final String mainValue;
    final String? secondaryValue;
    final Color badgeBg;
    final Color badgeFg;

    switch (record) {
      case OdometerRecord odo:
        icon = Icons.speed_rounded;
        typeTitle = 'Odometer Reading';
        mainValue = '${_numberFormat.format(odo.odometer)} km';
        secondaryValue = odo.notes;
        badgeBg = colorScheme.primaryContainer;
        badgeFg = colorScheme.onPrimaryContainer;

      case FuelRecord fuel:
        icon = Icons.local_gas_station_rounded;
        typeTitle = 'Fuel Refill';
        mainValue = '${fuel.quantity.toStringAsFixed(1)} L  •  ₹${_numberFormat.format(fuel.cost)}';
        final odoPart = fuel.odometerReading != null
            ? '${_numberFormat.format(fuel.odometerReading!)} km'
            : null;
        final stationPart = fuel.station;
        secondaryValue = [odoPart, stationPart].whereType<String>().join(' • ');
        badgeBg = Colors.amber.withValues(alpha: 0.2);
        badgeFg = Colors.amber.shade900;

      case ServiceRecord svc:
        icon = Icons.build_rounded;
        typeTitle = svc.serviceType.displayName;
        mainValue = svc.cost != null
            ? '₹${_numberFormat.format(svc.cost!)}'
            : svc.description;
        secondaryValue = svc.cost != null ? svc.description : null;
        badgeBg = Colors.teal.withValues(alpha: 0.2);
        badgeFg = Colors.teal.shade900;

      case OilChangeRecord oil:
        icon = Icons.oil_barrel_rounded;
        typeTitle = 'Oil Change';
        mainValue = oil.oilType != null ? oil.oilType! : 'Oil Replaced';
        final odoPart = '${_numberFormat.format(oil.odometerReading)} km';
        final costPart = oil.cost != null ? '₹${_numberFormat.format(oil.cost!)}' : null;
        secondaryValue = [odoPart, costPart].whereType<String>().join(' • ');
        badgeBg = Colors.deepOrange.withValues(alpha: 0.2);
        badgeFg = Colors.deepOrange.shade900;
        
      case ChargingRecord charge:
        icon = Icons.electrical_services_rounded;
        typeTitle = 'Charging';
        mainValue = '${charge.energyCharged.toStringAsFixed(1)} kWh  •  ₹${_numberFormat.format(charge.cost)}';
        final odoPart = charge.odometerReading != null
            ? '${_numberFormat.format(charge.odometerReading!)} km'
            : null;
        final stationPart = charge.location;
        secondaryValue = [odoPart, stationPart].whereType<String>().join(' • ');
        badgeBg = Colors.blue.withValues(alpha: 0.2);
        badgeFg = Colors.blue.shade900;
    }

    return Card(
      elevation: AppSizes.elevationSm,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingSm),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, size: AppSizes.iconMd, color: badgeFg),
            ),

            const SizedBox(width: AppSizes.spacingMd),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          typeTitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(record.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingXs),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              showAddVehicleRecordSheet(
                                context: context,
                                vehicleId: record.vehicleId,
                                initialRecord: record,
                              );
                            } else if (val == 'delete') {
                              _showDeleteConfirmation(context, ref);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Record'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Record', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mainValue,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (secondaryValue != null && secondaryValue.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondaryValue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
