import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging a fuel refill with comprehensive validation.
///
/// Fields:
///   - Fuel quantity (L, required, > 0)
///   - Total cost (₹, required, >= 0)
///   - Odometer reading (required, >= 0, >= current vehicle odometer)
///   - Date (required, no future dates)
///   - Fuel station (optional, max 100 chars)
///   - Notes (optional, max 500 chars)
class FuelRecordForm extends StatefulWidget {
  const FuelRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
  });

  final String vehicleId;
  final double? currentOdometer;

  @override
  VehicleRecordFormState<FuelRecordForm> createState() =>
      _FuelRecordFormState();
}

class _FuelRecordFormState extends VehicleRecordFormState<FuelRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  FuelRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;
    final odometerText = _odometerController.text.trim();
    return FuelRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      quantity: double.parse(_quantityController.text.trim()),
      cost: double.parse(_costController.text.trim()),
      odometerReading: odometerText.isNotEmpty
          ? double.tryParse(odometerText)
          : null,
      station: _stationController.text.trim().isEmpty
          ? null
          : _stationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final odoHint = widget.currentOdometer != null
        ? 'Current: ${widget.currentOdometer!.toStringAsFixed(0)} km'
        : 'e.g. 25100';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quantity + Cost (side by side) ──
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Fuel Quantity *',
                    suffixText: 'L',
                    hintText: 'e.g. 5.2',
                  ),
                  validator: validateFuelQuantity,
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
                    labelText: 'Fuel Cost *',
                    prefixText: '₹ ',
                    hintText: 'e.g. 550',
                  ),
                  validator: validateFuelCost,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Odometer (required) ──
          TextFormField(
            controller: _odometerController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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
            labelText: 'Fuel Date *',
            selectedDate: _date,
            disableFutureDates: true,
            onDateSelected: (d) => setState(() => _date = d),
            validator: (d) => validateRecordDate(d, fieldName: 'Fuel date'),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Station (optional) ──
          TextFormField(
            controller: _stationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Fuel Station',
              hintText: 'e.g. Shell, IndianOil (optional)',
              prefixIcon: Icon(Icons.local_gas_station_outlined),
            ),
            validator: (v) => validateMaxLength(v, 100, 'Fuel station'),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Notes (optional) ──
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional notes (max 500 characters)',
            ),
            validator: validateNotes,
          ),
        ],
      ),
    );
  }
}
