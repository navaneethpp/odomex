import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle_data_type.dart';

/// Bottom sheet for adding a vehicle data record (odometer update, fuel
/// refill, or service log).
///
/// The [vehicleId] identifies which vehicle the record belongs to.
/// After validation, [onSave] is called with the record type and a
/// data map — the caller (VehicleDetailsScreen) routes this to the
/// appropriate Riverpod provider call.
class AddVehicleDataSheet extends ConsumerStatefulWidget {
  const AddVehicleDataSheet({
    super.key,
    required this.vehicleId,
    required this.onSave,
  });

  final String vehicleId;

  final void Function(
    VehicleDataType type,
    Map<String, dynamic> data,
  ) onSave;

  @override
  ConsumerState<AddVehicleDataSheet> createState() =>
      _AddVehicleDataSheetState();
}

class _AddVehicleDataSheetState extends ConsumerState<AddVehicleDataSheet> {
  VehicleDataType _selectedType = VehicleDataType.odometer;

  final _formKey = GlobalKey<FormState>();

  final _odometerController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelAmountController.dispose();
    _fuelPriceController.dispose();
    _serviceDescriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data;

    switch (_selectedType) {
      case VehicleDataType.odometer:
        data = {
          'odometerReading': double.parse(_odometerController.text.trim()),
        };
        break;

      case VehicleDataType.fuelRefill:
        data = {
          'fuelAmount': double.parse(_fuelAmountController.text.trim()),
          'fuelPrice': double.parse(_fuelPriceController.text.trim()),
        };
        break;

      case VehicleDataType.service:
        data = {
          'description': _serviceDescriptionController.text.trim(),
        };
        break;
    }

    widget.onSave(_selectedType, data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.paddingLg,
          right: AppSizes.paddingLg,
          top: AppSizes.paddingMd,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXl,
        ),
        child: Form(
          key: _formKey,
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

                const SizedBox(height: AppSizes.spacingXs),

                Text(
                  'Select what you want to record for this vehicle.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSizes.spacingLg),

                // ── Record type chips ──
                _RecordTypeSelector(
                  selected: _selectedType,
                  onSelected: (type) => setState(() => _selectedType = type),
                ),

                const SizedBox(height: AppSizes.spacingXl),

                // ── Contextual form ──
                _buildForm(),

                const SizedBox(height: AppSizes.spacingXl),

                // ── Save button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Record'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (_selectedType) {
      case VehicleDataType.odometer:
        return _buildOdometerForm();
      case VehicleDataType.fuelRefill:
        return _buildFuelForm();
      case VehicleDataType.service:
        return _buildServiceForm();
    }
  }

  Widget _buildOdometerForm() {
    return TextFormField(
      controller: _odometerController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Current Odometer *',
        suffixText: 'km',
        hintText: 'e.g. 25000',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter the odometer reading.';
        if (double.tryParse(v.trim()) == null) return 'Enter a valid number.';
        return null;
      },
    );
  }

  Widget _buildFuelForm() {
    return Column(
      children: [
        TextFormField(
          controller: _fuelAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Fuel Amount *',
            suffixText: 'L',
            hintText: 'e.g. 10.5',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter the fuel amount.';
            if (double.tryParse(v.trim()) == null) return 'Enter a valid amount.';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.spacingMd),

        TextFormField(
          controller: _fuelPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Total Cost *',
            prefixText: '₹ ',
            hintText: 'e.g. 920',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter the total cost.';
            if (double.tryParse(v.trim()) == null) return 'Enter a valid amount.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServiceForm() {
    return TextFormField(
      controller: _serviceDescriptionController,
      maxLines: 4,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Service Details *',
        hintText: 'Describe the service or maintenance performed',
        alignLabelWithHint: true,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter service details.';
        return null;
      },
    );
  }
}

// ─────────────────────────────────────────────
// RECORD TYPE SELECTOR
// ─────────────────────────────────────────────

class _RecordTypeItem {
  final VehicleDataType type;
  final IconData icon;
  final String label;

  const _RecordTypeItem(this.type, this.icon, this.label);
}

const _recordTypes = [
  _RecordTypeItem(VehicleDataType.odometer, Icons.speed_rounded, 'Odometer'),
  _RecordTypeItem(VehicleDataType.fuelRefill, Icons.local_gas_station_rounded, 'Fuel Refill'),
  _RecordTypeItem(VehicleDataType.service, Icons.build_rounded, 'Service'),
];

class _RecordTypeSelector extends StatelessWidget {
  final VehicleDataType selected;
  final ValueChanged<VehicleDataType> onSelected;

  const _RecordTypeSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _recordTypes
          .map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: item == _recordTypes.last ? 0 : AppSizes.spacingSm,
                  ),
                  child: _RecordTypeChip(
                    item: item,
                    isSelected: item.type == selected,
                    onTap: () => onSelected(item.type),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _RecordTypeChip extends StatelessWidget {
  final _RecordTypeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecordTypeChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

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
          children: [
            Icon(item.icon, size: AppSizes.iconMd, color: fgColor),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
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
