import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/smart_odometer_input_field.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging an odometer reading with comprehensive validation.
///
/// Fields:
///   - Current odometer (required, numeric, >= 0, >= currentVehicleOdometer)
///   - Date (required, no future dates)
///   - Notes (optional, max 500 chars)
class OdometerRecordForm extends StatefulWidget {
  const OdometerRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
  });

  /// The vehicle this record belongs to.
  final String vehicleId;

  /// The vehicle's current known odometer (used for cross-field consistency).
  final double? currentOdometer;

  @override
  VehicleRecordFormState<OdometerRecordForm> createState() =>
      _OdometerRecordFormState();
}

class _OdometerRecordFormState
    extends VehicleRecordFormState<OdometerRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  OdometerRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;
    return OdometerRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      odometer: double.parse(_odometerController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.currentOdometer != null
        ? 'Current: ${widget.currentOdometer!.toStringAsFixed(0)} km'
        : 'e.g. 25000';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Odometer (with Smart "Use Latest" shortcut) ──
          SmartOdometerInputField(
            controller: _odometerController,
            vehicleId: widget.vehicleId,
            currentOdometer: widget.currentOdometer,
            autofocus: true,
            hintText: hint,
            validator: (v) => validateRecordOdometer(
              v,
              currentVehicleOdometer: widget.currentOdometer,
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Date ──
          AppDateField(
            labelText: 'Record Date *',
            selectedDate: _date,
            disableFutureDates: true,
            onDateSelected: (d) => setState(() => _date = d),
            validator: (d) => validateRecordDate(d, fieldName: 'Record date'),
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
