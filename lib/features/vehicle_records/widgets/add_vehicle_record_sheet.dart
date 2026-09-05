import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/providers/auto_fill_odometer_provider.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record_type.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/widgets/fuel_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/odometer_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/oil_change_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/record_form_actions.dart';
import 'package:odomex/features/vehicle_records/widgets/record_type_selector.dart';
import 'package:odomex/features/vehicle_records/widgets/service_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/charging_record_form.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';

/// Opens the standard [AddVehicleRecordSheet] modal bottom sheet.
///
/// Reusable from HomeScreen, VehicleCard, VehicleDetailsScreen, and any
/// future screen with zero duplicated UI or business logic.
Future<void> showAddVehicleRecordSheet({
  required BuildContext context,
  required String vehicleId,
  VehicleRecord? initialRecord,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => AddVehicleRecordSheet(
      vehicleId: vehicleId,
      initialRecord: initialRecord,
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
    this.initialRecord,
  });

  final String vehicleId;
  final VehicleRecord? initialRecord;

  @override
  ConsumerState<AddVehicleRecordSheet> createState() =>
      _AddVehicleRecordSheetState();
}

class _AddVehicleRecordSheetState extends ConsumerState<AddVehicleRecordSheet> {
  late VehicleRecordType _selectedType;
  bool _isSaving = false;
  String? _defaultOdometerText;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final rec = widget.initialRecord!;
      if (rec is OdometerRecord) {
        _selectedType = VehicleRecordType.odometer;
      } else if (rec is FuelRecord) {
        _selectedType = VehicleRecordType.fuelRefill;
      } else if (rec is ChargingRecord) {
        _selectedType = VehicleRecordType.charging;
      } else if (rec is ServiceRecord) {
        _selectedType = VehicleRecordType.service;
      } else if (rec is OilChangeRecord) {
        _selectedType = VehicleRecordType.oilChange;
      }
    } else {
      _selectedType = VehicleRecordType.odometer;

      // Auto-fill Current Odometer Feature
      final autoFillEnabled = ref.read(autoFillOdometerProvider);
      if (autoFillEnabled) {
        final latest = ref.read(latestOdometerReadingProvider(widget.vehicleId));
        if (latest != null && latest > 0) {
          _defaultOdometerText = latest % 1 == 0
              ? latest.toInt().toString()
              : latest.toString();
        }
      }
    }
  }

  // Separate GlobalKey per form type to ensure clean form lifecycle and state
  final _odometerKey = GlobalKey<VehicleRecordFormState>();
  final _fuelKey = GlobalKey<VehicleRecordFormState>();
  final _chargingKey = GlobalKey<VehicleRecordFormState>();
  final _serviceKey = GlobalKey<VehicleRecordFormState>();
  final _oilKey = GlobalKey<VehicleRecordFormState>();

  GlobalKey<VehicleRecordFormState> get _activeFormKey {
    switch (_selectedType) {
      case VehicleRecordType.odometer:
        return _odometerKey;
      case VehicleRecordType.fuelRefill:
        return _fuelKey;
      case VehicleRecordType.charging:
        return _chargingKey;
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
      // 1. Add/Update record in repository and synchronize all derived vehicle state
      if (widget.initialRecord != null) {
        await ref.read(vehicleRecordProvider.notifier).updateRecord(record);
      } else {
        await ref.read(vehicleRecordProvider.notifier).addRecord(record);
      }

      if (!mounted) return;

      // 2. Close sheet
      Navigator.pop(context);

      // 3. Feedback
      final actionStr = widget.initialRecord != null ? 'updated' : 'added';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedType.title} $actionStr successfully'),
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
                widget.initialRecord != null ? 'Edit Record' : 'Add Record',
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

              // ── Top Type Selector ──
              if (widget.initialRecord == null) ...[
                Builder(
                  builder: (context) {
                    final allowedTypes = [
                      VehicleRecordType.odometer,
                      VehicleRecordType.fuelRefill,
                      if (vehicle?.powertrainType == PowertrainType.plugInHybrid)
                        VehicleRecordType.charging,
                      VehicleRecordType.service,
                      if (vehicle?.isOilChangeApplicable ?? true)
                        VehicleRecordType.oilChange,
                    ];
                    return RecordTypeSelector(
                      selected: _selectedType,
                      allowedTypes: allowedTypes,
                      onSelected: (type) {
                        setState(() => _selectedType = type);
                      },
                    );
                  }
                ),
                const SizedBox(height: AppSizes.spacingXl),
              ] else ...[
              ],

              // ── Contextual Form ──
              _buildActiveForm(vehicle?.odometerReading, vehicle),

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

  Widget _buildActiveForm(double? currentOdometer, Vehicle? vehicle) {
    switch (_selectedType) {
      case VehicleRecordType.odometer:
        return OdometerRecordForm(
          key: _odometerKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
          initialRecord: widget.initialRecord as OdometerRecord?,
          defaultOdometer: _defaultOdometerText,
        );
      case VehicleRecordType.fuelRefill:
        return FuelRecordForm(
          key: _fuelKey,
          vehicleId: widget.vehicleId,
          vehicle: vehicle,
          currentOdometer: currentOdometer,
          initialRecord: widget.initialRecord as FuelRecord?,
          defaultOdometer: _defaultOdometerText,
        );
      case VehicleRecordType.charging:
        return ChargingRecordForm(
          key: _chargingKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
          initialRecord: widget.initialRecord as ChargingRecord?,
          defaultOdometer: _defaultOdometerText,
        );
      case VehicleRecordType.service:
        return ServiceRecordForm(
          key: _serviceKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
          initialRecord: widget.initialRecord as ServiceRecord?,
          defaultOdometer: _defaultOdometerText,
        );
      case VehicleRecordType.oilChange:
        return OilChangeRecordForm(
          key: _oilKey,
          vehicleId: widget.vehicleId,
          currentOdometer: currentOdometer,
          initialRecord: widget.initialRecord as OilChangeRecord?,
          defaultOdometer: _defaultOdometerText,
        );
    }
  }
}
