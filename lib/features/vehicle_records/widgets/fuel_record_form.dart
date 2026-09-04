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
///
/// Fields:
///   - Fuel quantity (L, required, > 0)
///   - Price per litre (₹/L, required, > 0)
///   - Total cost (₹, automatically calculated as quantity × price per litre)
///   - Odometer reading (required, with "Use Latest" shortcut)
///   - Date (required, no future dates)
///   - Fuel station (optional, max 100 chars)
///   - Notes (optional, max 500 chars)
class FuelRecordForm extends StatefulWidget {
  const FuelRecordForm({
    super.key,
    required this.vehicleId,
    this.currentOdometer,
    this.initialRecord,
  });

  final String vehicleId;
  final double? currentOdometer;
  final FuelRecord? initialRecord;

  @override
  VehicleRecordFormState<FuelRecordForm> createState() =>
      _FuelRecordFormState();
}

class _FuelRecordFormState extends VehicleRecordFormState<FuelRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _odometerController = TextEditingController();
  DateTime? _date = DateTime.now();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  double? _calculatedTotalCost;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final rec = widget.initialRecord!;
      _quantityController.text = rec.quantity.toString();
      _priceController.text = rec.costPerLitre.toStringAsFixed(2);
      if (rec.odometerReading != null) {
        _odometerController.text = rec.odometerReading.toString();
      }
      _date = rec.date;
      if (rec.station != null) _stationController.text = rec.station!;
      if (rec.notes != null) _notesController.text = rec.notes!;
      _calculatedTotalCost = rec.cost;
    }
    
    _quantityController.addListener(_onCostInputsChanged);
    _priceController.addListener(_onCostInputsChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onCostInputsChanged);
    _priceController.removeListener(_onCostInputsChanged);
    _quantityController.dispose();
    _priceController.dispose();
    _odometerController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCostInputsChanged() {
    final qty = double.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim());

    final total = FuelCostCalculator.calculateTotalCost(
      quantity: qty,
      pricePerUnit: price,
    );

    if (total != _calculatedTotalCost) {
      setState(() {
        _calculatedTotalCost = total;
      });
    }
  }

  @override
  FuelRecord? buildRecord() {
    if (!_formKey.currentState!.validate()) return null;

    final quantity = double.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());
    final totalCost = FuelCostCalculator.calculateTotalCost(
      quantity: quantity,
      pricePerUnit: price,
    );

    if (totalCost == null) return null;

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

    final hasCalculatedCost = _calculatedTotalCost != null;

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
                    hintText: 'e.g. 5.5',
                  ),
                  validator: validateFuelQuantity,
                ),
              ),

              const SizedBox(width: AppSizes.spacingMd),

              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price per Litre *',
                    prefixText: '${AppConstants.currencySymbol} ',
                    suffixText: '/L',
                    hintText: 'e.g. 105.50',
                  ),
                  validator: validateFuelPrice,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingMd),

          // ── Live Total Cost Display Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              color: hasCalculatedCost
                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: hasCalculatedCost
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasCalculatedCost
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    size: AppSizes.iconMd,
                    color: hasCalculatedCost
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Fuel Cost',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        FuelCostCalculator.formatCost(_calculatedTotalCost),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: hasCalculatedCost
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (hasCalculatedCost) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_quantityController.text.trim()} L × ${AppConstants.currencySymbol}${_priceController.text.trim()}/L',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
