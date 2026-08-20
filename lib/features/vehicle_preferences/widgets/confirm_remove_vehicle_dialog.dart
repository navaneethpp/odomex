import 'package:flutter/material.dart';
import 'package:odomex/models/vehicle.dart';

/// Confirmation dialog shown before removing a vehicle and its records.
class ConfirmRemoveVehicleDialog extends StatelessWidget {
  const ConfirmRemoveVehicleDialog({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final regText = vehicle.registrationNumber.isNotEmpty
        ? ' (${vehicle.registrationNumber})'
        : '';
    final vehicleTitle = '${vehicle.brand.displayName} ${vehicle.model}$regText';

    return AlertDialog(
      title: const Text('Remove Vehicle?'),
      content: Text.rich(
        TextSpan(
          text: 'Are you sure you want to remove ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(
              text: vehicleTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const TextSpan(
              text: '?\n\nThis will remove the vehicle and its associated records from this device.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}

/// Displays the [ConfirmRemoveVehicleDialog] and returns whether the user confirmed deletion.
Future<bool?> showConfirmRemoveVehicleDialog(
  BuildContext context,
  Vehicle vehicle,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmRemoveVehicleDialog(vehicle: vehicle),
  );
}
