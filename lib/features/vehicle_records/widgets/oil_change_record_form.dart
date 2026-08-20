import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging an oil change.
///
/// Fields:
///   - Odometer reading (required)
///   - Date (required, no future dates)
///   - Oil type (optional, e.g. 10W-40)
///   - Quantity (optional, in litres)
///   - Cost (optional, in INR)
///   - Notes (optional)
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
  DateTime? _date;
  final _oilTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _oilTypeController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  OilChangeRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;
    final quantityText = _quantityController.text.trim();
    final costText = _costController.text.trim();

    return OilChangeRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      odometerReading: double.parse(_odometerController.text.trim()),
      oilType: _oilTypeController.text.trim().isEmpty
          ? null
          : _oilTypeController.text.trim(),
      quantity: quantityText.isNotEmpty ? double.tryParse(quantityText) : null,
      cost: costText.isNotEmpty ? double.tryParse(costText) : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              hintText: widget.currentOdometer != null
                  ? 'Current: ${widget.currentOdometer!.toStringAsFixed(0)} km'
                  : 'e.g. 25000',
            ),
            validator: (v) => validateOdometer(
              v,
              currentOdometer: widget.currentOdometer,
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Date ──
          AppDateField(
            labelText: 'Date *',
            selectedDate: _date,
            disableFutureDates: true,
            onDateSelected: (d) => setState(() => _date = d),
            validator: validateRecordDate,
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Oil Type ──
          TextFormField(
            controller: _oilTypeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Oil Type / Grade',
              hintText: 'e.g. 10W-40, 20W-50',
              prefixIcon: Icon(Icons.oil_barrel_outlined),
            ),
          ),

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
                    labelText: 'Quantity',
                    suffixText: 'L',
                    hintText: 'e.g. 1.0',
                  ),
                  validator: (v) =>
                      validateOilQuantity(v, required: false),
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
                    labelText: 'Cost',
                    prefixText: '₹ ',
                    hintText: 'e.g. 650',
                  ),
                  validator: (v) =>
                      validateCost(v, required: false),
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
              hintText: 'Optional notes or brand used',
            ),
          ),
        ],
      ),
    );
  }
}
