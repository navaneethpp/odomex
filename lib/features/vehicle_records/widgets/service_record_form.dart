import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging a service or maintenance event.
///
/// Fields:
///   - Service type (dropdown, required)
///   - Custom description when "Other" is selected (required in that case)
///   - Date (required, no future dates)
///   - Odometer reading (optional)
///   - Cost (optional)
///   - Description / notes (always shown, required for all types)
class ServiceRecordForm extends StatefulWidget {
  const ServiceRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
  });

  final String vehicleId;
  final double? currentOdometer;

  @override
  VehicleRecordFormState<ServiceRecordForm> createState() =>
      _ServiceRecordFormState();
}

class _ServiceRecordFormState
    extends VehicleRecordFormState<ServiceRecordForm> {
  final _formKey = GlobalKey<FormState>();
  ServiceType _serviceType = ServiceType.generalService;
  DateTime? _date;
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  ServiceRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;
    final odometerText = _odometerController.text.trim();
    final costText = _costController.text.trim();
    return ServiceRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      serviceType: _serviceType,
      description: _descriptionController.text.trim(),
      odometerReading: odometerText.isNotEmpty
          ? double.tryParse(odometerText)
          : null,
      cost: costText.isNotEmpty ? double.tryParse(costText) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Service type dropdown ──
          DropdownButtonFormField<ServiceType>(
            initialValue: _serviceType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Service Type *',
              prefixIcon: Icon(Icons.build_outlined),
            ),
            items: ServiceType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.displayName),
                    ))
                .toList(),
            onChanged: (t) {
              if (t != null) setState(() => _serviceType = t);
            },
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Date ──
          AppDateField(
            labelText: 'Service Date *',
            selectedDate: _date,
            disableFutureDates: true,
            onDateSelected: (d) => setState(() => _date = d),
            validator: validateRecordDate,
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Odometer + Cost (side by side) ──
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _odometerController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Odometer',
                    suffixText: 'km',
                    hintText: 'Optional',
                  ),
                  validator: (v) => v != null && v.trim().isNotEmpty
                      ? validateOdometer(v)
                      : null,
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
                    hintText: 'Optional',
                  ),
                  validator: (v) =>
                      validateCost(v, required: false),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Description ──
          TextFormField(
            controller: _descriptionController,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: _serviceType == ServiceType.other
                  ? 'Description *'
                  : 'Description / Notes',
              hintText: _serviceType == ServiceType.other
                  ? 'Describe the service performed'
                  : 'Additional details (optional)',
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (_serviceType == ServiceType.other) {
                return validateRequired(v, 'a description');
              }
              return null; // optional for other types
            },
          ),
        ],
      ),
    );
  }
}
