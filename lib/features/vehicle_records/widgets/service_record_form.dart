import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging a service or maintenance event with comprehensive validation.
///
/// Fields:
///   - Service type (required)
///   - Service date (required, no future dates)
///   - Service odometer (required, numeric, >= 0, >= currentVehicleOdometer)
///   - Service cost (required, numeric, >= 0)
///   - Description (required, min 5 chars, max 1000 chars)
class ServiceRecordForm extends StatefulWidget {
  const ServiceRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
    this.initialRecord,
  });

  final String vehicleId;
  final double? currentOdometer;
  final ServiceRecord? initialRecord;

  @override
  VehicleRecordFormState<ServiceRecordForm> createState() =>
      _ServiceRecordFormState();
}

class _ServiceRecordFormState
    extends VehicleRecordFormState<ServiceRecordForm> {
  final _formKey = GlobalKey<FormState>();
  ServiceType _serviceType = ServiceType.generalService;
  DateTime? _date = DateTime.now();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final rec = widget.initialRecord!;
      _serviceType = rec.serviceType;
      _date = rec.date;
      if (rec.odometerReading != null) {
        _odometerController.text = rec.odometerReading.toString();
      }
      if (rec.cost != null) {
        _costController.text = rec.cost.toString();
      }
      _descriptionController.text = rec.description;
    }
  }

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

    final parsedOdo = odometerText.isNotEmpty ? double.tryParse(odometerText) : null;
    final parsedCost = costText.isNotEmpty ? double.tryParse(costText) : null;

    if (widget.initialRecord != null) {
      return widget.initialRecord!.copyWith(
        date: _date!,
        serviceType: _serviceType,
        description: _descriptionController.text.trim(),
        odometerReading: parsedOdo,
        cost: parsedCost,
      );
    }

    return ServiceRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      serviceType: _serviceType,
      description: _descriptionController.text.trim(),
      odometerReading: parsedOdo,
      cost: parsedCost,
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
            validator: (v) => v == null ? 'Please select a service type.' : null,
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
            validator: (d) => validateRecordDate(d, fieldName: 'Service date'),
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
                  decoration: InputDecoration(
                    labelText: 'Odometer *',
                    suffixText: 'km',
                    hintText: odoHint,
                  ),
                  validator: (v) => validateRecordOdometer(
                    v,
                    currentVehicleOdometer: widget.currentOdometer,
                    required: true,
                    fieldName: 'Service odometer',
                  ),
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
                    labelText: 'Service Cost *',
                    prefixText: '₹ ',
                    hintText: 'e.g. 1250',
                  ),
                  validator: (v) => validateServiceCost(v, required: true),
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
                  ? 'Custom Service Description *'
                  : 'Service Details / Description *',
              hintText: _serviceType == ServiceType.other
                  ? 'Describe the specific service performed (min 5 chars)'
                  : 'e.g. Engine oil change, air filter replacement (min 5 chars)',
              alignLabelWithHint: true,
            ),
            validator: (v) => validateServiceDescription(v, required: true),
          ),
        ],
      ),
    );
  }
}
