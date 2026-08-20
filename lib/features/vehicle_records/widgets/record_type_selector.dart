import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record_type.dart';

/// Segmented chip selector for picking a [VehicleRecordType].
///
/// Features all 4 record types (Odometer, Fuel Refill, Service, Oil Change).
/// Uses metadata directly from [VehicleRecordTypeExtension] for consistency.
class RecordTypeSelector extends StatelessWidget {
  const RecordTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final VehicleRecordType selected;
  final ValueChanged<VehicleRecordType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: VehicleRecordType.values
          .map(
            (type) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type == VehicleRecordType.values.last
                      ? 0
                      : AppSizes.spacingSm,
                ),
                child: _RecordTypeChip(
                  type: type,
                  isSelected: type == selected,
                  onTap: () => onSelected(type),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RecordTypeChip extends StatelessWidget {
  const _RecordTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final VehicleRecordType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final fgColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingMd,
          horizontal: AppSizes.paddingXs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: AppSizes.borderWidth,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: AppSizes.iconMd, color: fgColor),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              type.chipLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
