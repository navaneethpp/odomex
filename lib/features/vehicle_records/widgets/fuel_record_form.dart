import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging a fuel refill.
///
/// Fields:
///   - Fuel quantity (L, required)
///   - Total cost (₹, required)
///   - Odometer reading (optional)
///   - Date (required, no future dates)
///   - Fuel station (optional)
///   - Notes (optional)
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
  DateTime? _date;
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
                    labelText: 'Quantity *',
                    suffixText: 'L',
                    hintText: 'e.g. 10.5',
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
                    labelText: 'Total Cost *',
                    prefixText: '₹ ',
                    hintText: 'e.g. 920',
                  ),
                  validator: validateCost,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Odometer (optional) ──
          TextFormField(
            controller: _odometerController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Odometer',
              suffixText: 'km',
              hintText: widget.currentOdometer != null
                  ? '${widget.currentOdometer!.toStringAsFixed(0)} km'
                  : 'Optional',
            ),
            // Odometer is optional for fuel records
            validator: (v) => v != null && v.trim().isNotEmpty
                ? validateOdometer(v)
                : null,
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

          // ── Station (optional) ──
          TextFormField(
            controller: _stationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Fuel Station',
              hintText: 'Optional',
              prefixIcon: Icon(Icons.local_gas_station_outlined),
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Notes (optional) ──
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional notes',
            ),
          ),
        ],
      ),
    );
  }
}
