import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record_type.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/widgets/fuel_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/odometer_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/oil_change_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/record_form_actions.dart';
import 'package:odomex/features/vehicle_records/widgets/record_type_selector.dart';
import 'package:odomex/features/vehicle_records/widgets/service_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/providers/vehicle_provider.dart';

/// Opens the standard [AddVehicleRecordSheet] modal bottom sheet.
///
/// Reusable from HomeScreen, VehicleCard, VehicleDetailsScreen, and any
/// future screen with zero duplicated UI or business logic.
Future<void> showAddVehicleRecordSheet({
  required BuildContext context,
  required String vehicleId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => AddVehicleRecordSheet(
      vehicleId: vehicleId,
    ),
  );
}

/// Orchestrator bottom sheet for adding a new vehicle record.
///
/// Responsibilities:
///   - Displays the vehicle context (model, reg number).
///   - Hosts the [RecordTypeSelector] (Odometer, Fuel, Service, Oil Change).
///   - Renders the corresponding modular form widget.
///   - Handles save validation, state updates, and success messaging.
class AddVehicleRecordSheet extends ConsumerStatefulWidget {
  const AddVehicleRecordSheet({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  ConsumerState<AddVehicleRecordSheet> createState() =>
      _AddVehicleRecordSheetState();
}

class _AddVehicleRecordSheetState extends ConsumerState<AddVehicleRecordSheet> {
  VehicleRecordType _selectedType = VehicleRecordType.odometer;
  bool _isSaving = false;

  // Separate GlobalKey per form type to ensure clean form lifecycle and state
  final _odometerKey = GlobalKey<VehicleRecordFormState>();
  final _fuelKey = GlobalKey<VehicleRecordFormState>();
  final _serviceKey = GlobalKey<VehicleRecordFormState>();
  final _oilKey = GlobalKey<VehicleRecordFormState>();

  GlobalKey<VehicleRecordFormState> get _activeFormKey {
    switch (_selectedType) {
      case VehicleRecordType.odometer:
        return _odometerKey;
      case VehicleRecordType.fuelRefill:
        return _fuelKey;
      case VehicleRecordType.service:
        return _serviceKey;
      case VehicleRecordType.oilChange:
        return _oilKey;
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final record = _activeFormKey.currentState?.buildRecord();
    if (record == null) return; // Form validation failed

    setState(() => _isSaving = true);

    try {
      // 1. Add record to repository and synchronize all derived vehicle state
      await ref.read(vehicleRecordProvider.notifier).addRecord(record);

      if (!mounted) return;

      // 2. Close sheet
      Navigator.pop(context);

      // 3. Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedType.title} added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save record: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vehicle = ref.watch(vehicleByIdProvider(widget.vehicleId));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.paddingLg,
          right: AppSizes.paddingLg,
          top: AppSizes.paddingSm,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Text(
                'Add Record',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSizes.spacingSm),

              // ── Compact Vehicle Context Card ──
              if (vehicle != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMd,
                    vertical: AppSizes.paddingSm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        vehicle.vehicleType.icon,
                        size: AppSizes.iconMd,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSizes.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.model,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${vehicle.registrationNumber} • ${vehicle.odometerReading.toStringAsFixed(0)} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSizes.spacingLg),

              // ── Record Type Selector ──
              RecordTypeSelector(
                selected: _selectedType,
                onSelected: (type) {
                  setState(() => _selectedType = type);
                },
              ),

              const SizedBox(height: AppSizes.spacingXl),

              // ── Contextual Form ──
              _buildActiveForm(vehicle?.odometerReading),

              const SizedBox(height: AppSizes.spacingXl),

              // ── Actions ──
              RecordFormActions(
                onSave: _save,
                isSaving: _isSaving,
                saveLabel: 'Save ${_selectedType.chipLabel} Record',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveForm(double? currentOdometer) {
    switch (_selectedType) {
      case VehicleRecordType.odometer:
        return OdometerRecordForm(
          key: _odometerKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
        );
      case VehicleRecordType.fuelRefill:
        return FuelRecordForm(
          key: _fuelKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
        );
      case VehicleRecordType.service:
        return ServiceRecordForm(
          key: _serviceKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
        );
      case VehicleRecordType.oilChange:
        return OilChangeRecordForm(
          key: _oilKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
        );
    }
  }
}
