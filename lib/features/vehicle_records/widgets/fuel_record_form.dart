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
class FuelRecordForm extends StatefulWidget {
  const FuelRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
    this.initialRecord,
    this.defaultOdometer,
  });

  final String vehicleId;
  final double? currentOdometer;
  final FuelRecord? initialRecord;
  final String? defaultOdometer;

  @override
  VehicleRecordFormState<FuelRecordForm> createState() =>
      _FuelRecordFormState();
}

class _FuelRecordFormState extends VehicleRecordFormState<FuelRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  final _qtyFocus = FocusNode();
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
      _quantityController.text = rec.quantity.toString();
      _priceController.text = rec.costPerLitre.toStringAsFixed(2);
      _amountController.text = rec.cost.toStringAsFixed(2);
      if (rec.odometerReading != null) {
        _odometerController.text = rec.odometerReading.toString();
      }
      _date = rec.date;
      if (rec.station != null) _stationController.text = rec.station!;
      if (rec.notes != null) _notesController.text = rec.notes!;
    } else if (widget.defaultOdometer != null) {
      _odometerController.text = widget.defaultOdometer!;
    }
    
    _quantityController.addListener(_onInputChanged);
    _priceController.addListener(_onInputChanged);
    _amountController.addListener(_onInputChanged);

    _qtyFocus.addListener(() => _onFocusChange('qty', _qtyFocus.hasFocus));
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
    _quantityController.removeListener(_onInputChanged);
    _priceController.removeListener(_onInputChanged);
    _amountController.removeListener(_onInputChanged);
    _quantityController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _qtyFocus.dispose();
    _priceFocus.dispose();
    _amountFocus.dispose();
    _odometerController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_isCalculating) return;

    final qtyStr = _quantityController.text.trim();
    final priceStr = _priceController.text.trim();
    final amtStr = _amountController.text.trim();

    int filled = (qtyStr.isNotEmpty ? 1 : 0) +
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
    if (qtyStr.isEmpty) {
      target = 'qty';
    } else if (priceStr.isEmpty) {
      target = 'price';
    } else if (amtStr.isEmpty) {
      target = 'amount';
    } else {
      target = ['qty', 'price', 'amount'].firstWhere(
        (f) => !_focusHistory.reversed.take(2).contains(f), 
        orElse: () => 'amount');
    }

    final qty = double.tryParse(qtyStr);
    final price = double.tryParse(priceStr);
    final amt = double.tryParse(amtStr);

    if (target == 'amount' && qty != null && price != null) {
      final a = FuelCostCalculator.calculateTotalCost(quantity: qty, pricePerUnit: price);
      if (a != null) {
        _amountController.text = a.toStringAsFixed(2);
        newCalculatedField = 'amount';
      }
    } else if (target == 'qty' && amt != null && price != null) {
      final q = FuelCostCalculator.calculateQuantity(totalCost: amt, pricePerUnit: price);
      if (q != null) {
        String formattedQ = q.toStringAsFixed(3);
        if (formattedQ.contains('.')) {
          formattedQ = formattedQ.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        _quantityController.text = formattedQ;
        newCalculatedField = 'qty';
      }
    } else if (target == 'price' && amt != null && qty != null) {
      final p = FuelCostCalculator.calculatePricePerUnit(totalCost: amt, quantity: qty);
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

  void _clearFuelFields() {
    if (_quantityController.text.isEmpty &&
        _priceController.text.isEmpty &&
        _amountController.text.isEmpty) {
      return;
    }

    _isCalculating = true;
    _quantityController.clear();
    _priceController.clear();
    _amountController.clear();

    setState(() {
      _calculatedField = null;
      _focusHistory.clear();
      _clearCount++;
    });

    Future.microtask(() => _isCalculating = false);
  }

  String? _validateFuelField(String? value, String? Function(String?) defaultValidator) {
    final emptyCount = (_quantityController.text.trim().isEmpty ? 1 : 0) +
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
  FuelRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;

    final quantity = double.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final totalCost = double.tryParse(_amountController.text.trim());

    if (quantity == null || price == null || totalCost == null) return null;

    if (!FuelCostCalculator.areValuesConsistent(
        quantity: quantity, pricePerUnit: price, totalCost: totalCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fuel details don't match. Quantity × fuel price must equal the amount paid."),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    final odometerText = _odometerController.text.trim();
    final parsedOdo = odometerText.isNotEmpty ? double.tryParse(odometerText) : null;
    final parsedStation = _stationController.text.trim().isEmpty ? null : _stationController.text.trim();
    final parsedNotes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (widget.initialRecord != null) {
      return widget.initialRecord!.copyWith(
        date: _date!,
        quantity: quantity,
        cost: totalCost,
        odometerReading: parsedOdo,
        station: parsedStation,
        notes: parsedNotes,
      );
    }

    return FuelRecord.create(
      vehicleId: widget.vehicleId,
      date: _date!,
      quantity: quantity,
      cost: totalCost,
      odometerReading: parsedOdo,
      station: parsedStation,
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
          // ── Fuel Quantity & Price per Litre (side by side) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('qty_$_clearCount'),
                  controller: _quantityController,
                  focusNode: _qtyFocus,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Fuel Quantity *',
                    suffixText: 'L',
                    hintText: 'e.g. 5.5',
                    helperText: _calculatedField == 'qty' ? 'Calculated automatically' : null,
                    helperStyle: _calculatedField == 'qty' 
                        ? TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic) 
                        : null,
                  ),
                  validator: (v) => _validateFuelField(v, validateFuelQuantity),
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
                    labelText: 'Price per Litre *',
                    prefixText: '${AppConstants.currencySymbol} ',
                    suffixText: '/L',
                    hintText: 'e.g. 105.50',
                    helperText: _calculatedField == 'price' ? 'Calculated automatically' : null,
                    helperStyle: _calculatedField == 'price' 
                        ? TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic) 
                        : null,
                  ),
                  validator: (v) => _validateFuelField(v, validateFuelPrice),
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
            validator: (v) => _validateFuelField(v, validateFuelCost),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              label: 'Clear fuel calculation fields',
              child: TextButton.icon(
                onPressed: _clearFuelFields,
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
