import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/recent_record_card.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record_type.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Screen displaying the complete history of vehicle records with type filters.
class VehicleRecordsScreen extends ConsumerStatefulWidget {
  const VehicleRecordsScreen({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  ConsumerState<VehicleRecordsScreen> createState() =>
      _VehicleRecordsScreenState();
}

class _VehicleRecordsScreenState extends ConsumerState<VehicleRecordsScreen> {
  VehicleRecordType? _selectedFilter; // null means 'All'

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehicleByIdProvider(widget.vehicleId));
    final allRecords = ref.watch(recordsByVehicleProvider(widget.vehicleId));

    // Filter records
    final filteredRecords = allRecords.where((r) {
      if (_selectedFilter == null) return true;
      switch (_selectedFilter!) {
        case VehicleRecordType.odometer:
          return r is OdometerRecord;
        case VehicleRecordType.fuelRefill:
          return r is FuelRecord;
        case VehicleRecordType.service:
          return r is ServiceRecord;
        case VehicleRecordType.oilChange:
          return r is OilChangeRecord;
      }
    }).toList();

    return ScreenContainer(
      title: vehicle != null ? '${vehicle.model} Records' : 'Vehicle Records',
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddVehicleRecordSheet(
            context: context,
            vehicleId: widget.vehicleId,
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter Chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${allRecords.length})',
                  isSelected: _selectedFilter == null,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: AppSizes.spacingSm),
                ...VehicleRecordType.values.map((type) {
                  final isSelected = _selectedFilter == type;
                  final count = allRecords.where((r) {
                    switch (type) {
                      case VehicleRecordType.odometer:
                        return r is OdometerRecord;
                      case VehicleRecordType.fuelRefill:
                        return r is FuelRecord;
                      case VehicleRecordType.service:
                        return r is ServiceRecord;
                      case VehicleRecordType.oilChange:
                        return r is OilChangeRecord;
                    }
                  }).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.spacingSm),
                    child: _buildFilterChip(
                      label: '${type.chipLabel} ($count)',
                      icon: type.icon,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedFilter = type),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Records List ──
          Expanded(
            child: filteredRecords.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return RecentRecordCard(record: record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(label),
      avatar: icon != null
          ? Icon(
              icon,
              size: AppSizes.iconSm,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            )
          : null,
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.5)
            : colorScheme.outlineVariant.withValues(alpha: 0.4),
        width: AppSizes.borderWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppSizes.iconXl * 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Text(
              _selectedFilter == null
                  ? 'No records found'
                  : 'No ${_selectedFilter!.title.toLowerCase()}s found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Tap + to add a record for this vehicle.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
