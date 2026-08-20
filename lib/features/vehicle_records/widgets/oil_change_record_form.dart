import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Standard preset oil types.
const _presetOilTypes = [
  '10W-30',
  '10W-40',
  '5W-30',
  '5W-40',
  '15W-40',
  '20W-50',
  'Other',
];

/// Form for logging an oil change with comprehensive validation.
///
/// Fields:
///   - Odometer reading (required, >= 0, >= current vehicle odometer)
///   - Date (required, no future dates)
///   - Oil type (required: preset dropdown or custom if "Other")
///   - Quantity (required, in litres, > 0)
///   - Cost (required, in INR, >= 0)
///   - Notes (optional, max 500 chars)
class OilChangeRecordForm extends StatefulWidget {
  const OilChangeRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
  });

  final String vehicleId;
  final double? currentOdometer;

  @override
  VehicleRecordFormState<OilChangeRecordForm> createState() =>
      _OilChangeRecordFormState();
}

class _OilChangeRecordFormState
    extends VehicleRecordFormState<OilChangeRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  String _selectedOilType = '10W-40';
  final _customOilTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isCustomOilType => _selectedOilType == 'Other';

  @override
  void dispose() {
    _odometerController.dispose();
    _customOilTypeController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  OilChangeRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;

    final resolvedOilType = _isCustomOilType
        ? _customOilTypeController.text.trim()
        : _selectedOilType;

    return OilChangeRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      odometerReading: double.parse(_odometerController.text.trim()),
      oilType: resolvedOilType,
      quantity: double.parse(_quantityController.text.trim()),
      cost: double.parse(_costController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final odoHint = widget.currentOdometer != null
        ? 'Current: ${widget.currentOdometer!.toStringAsFixed(0)} km'
        : 'e.g. 25000';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Odometer ──
          TextFormField(
            controller: _odometerController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Odometer Reading *',
              suffixText: 'km',
              hintText: odoHint,
            ),
            validator: (v) => validateRecordOdometer(
              v,
              currentVehicleOdometer: widget.currentOdometer,
              required: true,
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Date ──
          AppDateField(
            labelText: 'Oil Change Date *',
            selectedDate: _date,
            disableFutureDates: true,
            onDateSelected: (d) => setState(() => _date = d),
            validator: (d) =>
                validateRecordDate(d, fieldName: 'Oil change date'),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Oil Type Dropdown ──
          DropdownButtonFormField<String>(
            initialValue: _selectedOilType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Oil Type / Grade *',
              prefixIcon: Icon(Icons.oil_barrel_outlined),
            ),
            items: _presetOilTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            validator: (v) =>
                v == null || v.isEmpty ? 'Please select an oil type.' : null,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedOilType = val);
              }
            },
          ),

          // ── Custom Oil Type (when "Other" selected) ──
          if (_isCustomOilType) ...[
            const SizedBox(height: AppSizes.spacingMd),
            TextFormField(
              controller: _customOilTypeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Specify Oil Type *',
                hintText: 'e.g. 0W-20, Full Synthetic',
              ),
              validator: (v) => validateRequired(v, 'Custom oil type'),
            ),
          ],

          const SizedBox(height: AppSizes.spacingMd),

          // ── Quantity + Cost (side by side) ──
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    suffixText: 'L',
                    hintText: 'e.g. 1.0',
                  ),
                  validator: (v) => validateOilQuantity(v, required: true),
                ),
              ),

              const SizedBox(width: AppSizes.spacingMd),

              Expanded(
                child: TextFormField(
                  controller: _costController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Total Cost *',
                    prefixText: '₹ ',
                    hintText: 'e.g. 650',
                  ),
                  validator: (v) => validateOilCost(v, required: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Notes (optional) ──
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional notes or brand used (max 500 chars)',
            ),
            validator: validateNotes,
          ),
        ],
      ),
    );
  }
}
