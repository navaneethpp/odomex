import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/constants/app_constants.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/utils/fuel_cost_calculator.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';
import 'package:odomex/features/vehicle_records/widgets/smart_odometer_input_field.dart';
import 'package:odomex/features/vehicle_records/widgets/vehicle_record_form_base.dart';
import 'package:odomex/widgets/app_date_field.dart';

/// Form for logging a fuel refill with smart automatic total cost calculation
/// and smart odometer autofill.
class ChargingRecordForm extends StatefulWidget {
  const ChargingRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
    this.initialRecord,
    this.defaultOdometer,
  });

  final String vehicleId;
  final double? currentOdometer;
  final ChargingRecord? initialRecord;
  final String? defaultOdometer;

  @override
  VehicleRecordFormState<ChargingRecordForm> createState() =>
      _ChargingRecordFormState();
}

class _ChargingRecordFormState extends VehicleRecordFormState<ChargingRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _energyChargedController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();


  final _energyFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _amountFocus = FocusNode();

  bool _isCalculating = false;
  String? _calculatedField;
  final List<String> _focusHistory = [];
  int _clearCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final rec = widget.initialRecord!;
      _energyChargedController.text = rec.energyCharged.toString();
      _priceController.text = (rec.cost / rec.energyCharged).toStringAsFixed(2);
      _amountController.text = rec.cost.toStringAsFixed(2);
      if (rec.odometerReading != null) {
        _odometerController.text = rec.odometerReading.toString();
      }
      _date = rec.date;
      if (rec.location != null) _locationController.text = rec.location!;
      if (rec.notes != null) _notesController.text = rec.notes!;
    } else {
      if (widget.defaultOdometer != null) {
        _odometerController.text = widget.defaultOdometer!;
      }
    }
    
    _energyChargedController.addListener(_onInputChanged);
    _priceController.addListener(_onInputChanged);
    _amountController.addListener(_onInputChanged);

    _energyFocus.addListener(() => _onFocusChange('energy', _energyFocus.hasFocus));
    _priceFocus.addListener(() => _onFocusChange('price', _priceFocus.hasFocus));
    _amountFocus.addListener(() => _onFocusChange('amount', _amountFocus.hasFocus));
  }

  void _onFocusChange(String field, bool hasFocus) {
    if (hasFocus) {
      _focusHistory.remove(field);
      _focusHistory.add(field);
    }
  }

  @override
  void dispose() {
    _energyChargedController.removeListener(_onInputChanged);
    _priceController.removeListener(_onInputChanged);
    _amountController.removeListener(_onInputChanged);
    _energyChargedController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _energyFocus.dispose();
    _priceFocus.dispose();
    _amountFocus.dispose();
    _odometerController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_isCalculating) return;

    final energyStr = _energyChargedController.text.trim();
    final priceStr = _priceController.text.trim();
    final amtStr = _amountController.text.trim();

    int filled = (energyStr.isNotEmpty ? 1 : 0) +
        (priceStr.isNotEmpty ? 1 : 0) +
        (amtStr.isNotEmpty ? 1 : 0);

    if (filled < 2) {
      if (_calculatedField != null) {
        setState(() => _calculatedField = null);
      }
      return;
    }

    _isCalculating = true;
    String? newCalculatedField;

    String target;
    if (energyStr.isEmpty) {
      target = 'energy';
    } else if (priceStr.isEmpty) {
      target = 'price';
    } else if (amtStr.isEmpty) {
      target = 'amount';
    } else {
      target = ['energy', 'price', 'amount'].firstWhere(
        (f) => !_focusHistory.reversed.take(2).contains(f), 
        orElse: () => 'amount');
    }

    final energy = double.tryParse(energyStr);
    final price = double.tryParse(priceStr);
    final amt = double.tryParse(amtStr);

    if (target == 'amount' && energy != null && price != null) {
      final a = FuelCostCalculator.calculateTotalCost(quantity: energy, pricePerUnit: price);
      if (a != null) {
        _amountController.text = a.toStringAsFixed(2);
        newCalculatedField = 'amount';
      }
    } else if (target == 'energy' && amt != null && price != null) {
      final q = FuelCostCalculator.calculateQuantity(totalCost: amt, pricePerUnit: price);
      if (q != null) {
        String formattedQ = q.toStringAsFixed(3);
        if (formattedQ.contains('.')) {
          formattedQ = formattedQ.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        _energyChargedController.text = formattedQ;
        newCalculatedField = 'energy';
      }
    } else if (target == 'price' && amt != null && energy != null) {
      final p = FuelCostCalculator.calculatePricePerUnit(totalCost: amt, quantity: energy);
      if (p != null) {
        _priceController.text = p.toStringAsFixed(2);
        newCalculatedField = 'price';
      }
    }

    if (_calculatedField != newCalculatedField) {
      setState(() {
        _calculatedField = newCalculatedField;
      });
    }
    
    _isCalculating = false;
  }

  void _clearChargingFields() {
    if (_energyChargedController.text.isEmpty &&
        _priceController.text.isEmpty &&
        _amountController.text.isEmpty) {
      return;
    }

    _isCalculating = true;
    _energyChargedController.clear();
    _priceController.clear();
    _amountController.clear();

    setState(() {
      _calculatedField = null;
      _focusHistory.clear();
      _clearCount++;
    });

    Future.microtask(() => _isCalculating = false);
  }

  String? _validateChargingField(String? value, String? Function(String?) defaultValidator) {
    final emptyCount = (_energyChargedController.text.trim().isEmpty ? 1 : 0) +
                       (_priceController.text.trim().isEmpty ? 1 : 0) +
                       (_amountController.text.trim().isEmpty ? 1 : 0);
    if (emptyCount >= 2 && value?.trim().isEmpty == true) {
      return emptyCount == 3 
          ? 'Enter at least two fuel details.' 
          : 'Enter at least two fuel details to calculate the missing value.';
    }
    return defaultValidator(value);
  }

  @override
  ChargingRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;

    final energyCharged = double.tryParse(_energyChargedController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final totalCost = double.tryParse(_amountController.text.trim());

    if (energyCharged == null || price == null || totalCost == null) return null;

    if (!FuelCostCalculator.areValuesConsistent(
        quantity: energyCharged, pricePerUnit: price, totalCost: totalCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Charging details don't match. Quantity × price per kWh must equal the amount paid."),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    final odometerText = _odometerController.text.trim();
    final parsedOdo = odometerText.isNotEmpty ? double.tryParse(odometerText) : null;
    final parsedLocation = _locationController.text.trim().isEmpty ? null : _locationController.text.trim();
    final parsedNotes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (widget.initialRecord != null) {
      return widget.initialRecord!.copyWith(
        date: _date!,
        energyCharged: energyCharged,
        cost: totalCost,
        odometerReading: parsedOdo,
        location: parsedLocation,
        notes: parsedNotes,
      );
    }

    return ChargingRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      energyCharged: energyCharged,
      cost: totalCost,
      odometerReading: parsedOdo,
      location: parsedLocation,
      notes: parsedNotes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    final odoHint = widget.currentOdometer != null
        ? 'Current: ${widget.currentOdometer!.toStringAsFixed(0)} km'
        : 'e.g. 25100';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Energy Added & Price per kWh (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('energy_$_clearCount'),
                  controller: _energyChargedController,
                  focusNode: _energyFocus,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Energy Added *',
                    suffixText: 'kWh',
                    hintText: 'e.g. 5.5',
                    helperText: _calculatedField == 'energy' ? 'Calculated automatically' : null,
                    helperStyle: _calculatedField == 'energy' 
                        ? TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic) 
                        : null,
                  ),
                  validator: (v) => _validateChargingField(v, validateFuelQuantity),
                ),
              ),

              const SizedBox(width: AppSizes.spacingMd),

              Expanded(
                child: TextFormField(
                  key: ValueKey('price_$_clearCount'),
                  controller: _priceController,
                  focusNode: _priceFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Price per kWh *',
                    prefixText: '${AppConstants.currencySymbol} ',
                    suffixText: '/kWh',
                    hintText: 'e.g. 105.50',
                    helperText: _calculatedField == 'price' ? 'Calculated automatically' : null,
                    helperStyle: _calculatedField == 'price' 
                        ? TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic) 
                        : null,
                  ),
                  validator: (v) => _validateChargingField(v, validateFuelPrice),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Amount Paid ──
          TextFormField(
            key: ValueKey('amount_$_clearCount'),
            controller: _amountController,
            focusNode: _amountFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Amount Paid *',
              prefixText: '${AppConstants.currencySymbol} ',
              hintText: 'e.g. 2110.00',
              helperText: _calculatedField == 'amount' ? 'Calculated automatically' : null,
              helperStyle: _calculatedField == 'amount' 
                  ? TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic) 
                  : null,
            ),
            validator: (v) => _validateChargingField(v, validateFuelCost),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              label: 'Clear fuel calculation fields',
              child: TextButton.icon(
                onPressed: _clearChargingFields,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Odometer (with Smart "Use Latest" shortcut) ──
          SmartOdometerInputField(
            controller: _odometerController,
            vehicleId: widget.vehicleId,
            currentOdometer: widget.currentOdometer,
            hintText: odoHint,
            required: true,
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

          // ── Location (optional) ──
          TextFormField(
            controller: _locationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Fuel Location',
              hintText: 'e.g. Shell, IndianOil (optional)',
              prefixIcon: Icon(Icons.ev_station_outlined),
            ),
            validator: (v) => validateMaxLength(v, 100, 'Fuel location'),
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
