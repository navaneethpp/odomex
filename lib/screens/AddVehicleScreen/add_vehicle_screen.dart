import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/puc_utils.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/calculated_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/date_picker_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/form_section_card.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Screen for adding a new vehicle to the in-memory vehicle repository.
///
/// The form is divided into sections:
///   1. Vehicle Information (required)
///   2. Engine Information (required)
///   3. Usage Information (required)
///   4. Insurance (optional; validated if partially filled)
///   5. PUC (optional; validated if partially filled)
///   6. Oil Change (optional; validated if partially filled)
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Whether save is in progress (prevents duplicate submissions).
  bool _isSaving = false;

  // ─────────────────────────────────────────────
  // VEHICLE INFORMATION
  // ─────────────────────────────────────────────

  VehicleBrand? _brand;
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _colorController = TextEditingController();

  // ─────────────────────────────────────────────
  // ENGINE INFORMATION
  // ─────────────────────────────────────────────

  String? _fuelType;
  final _engineCapacityController = TextEditingController();

  static const List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'CNG',
    'Other',
  ];

  // ─────────────────────────────────────────────
  // USAGE INFORMATION
  // ─────────────────────────────────────────────

  DateTime? _purchaseDate;
  final _odometerController = TextEditingController();

  // ─────────────────────────────────────────────
  // INSURANCE INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyNumberController = TextEditingController();
  DateTime? _insuranceStartDate;
  DateTime? _insuranceEndDate;

  // ─────────────────────────────────────────────
  // PUC INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _pucCertificateController = TextEditingController();
  DateTime? _pucStartDate;
  DateTime? _pucEndDate;

  // ─────────────────────────────────────────────
  // OIL CHANGE INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _oilIntervalController = TextEditingController();
  final _lastOilOdometerController = TextEditingController();
  DateTime? _lastOilChangeDate;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _regNumberController.dispose();
    _colorController.dispose();
    _engineCapacityController.dispose();
    _odometerController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyNumberController.dispose();
    _pucCertificateController.dispose();
    _oilIntervalController.dispose();
    _lastOilOdometerController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  /// True if the user has entered any insurance information.
  bool get _hasAnyInsuranceInput =>
      _insuranceProviderController.text.trim().isNotEmpty ||
      _insurancePolicyNumberController.text.trim().isNotEmpty ||
      _insuranceStartDate != null ||
      _insuranceEndDate != null;

  /// True if the user has entered any PUC information.
  bool get _hasAnyPucInput =>
      _pucCertificateController.text.trim().isNotEmpty ||
      _pucStartDate != null ||
      _pucEndDate != null;

  /// True if the user has entered any oil change information.
  bool get _hasAnyOilChangeInput =>
      _oilIntervalController.text.trim().isNotEmpty ||
      _lastOilOdometerController.text.trim().isNotEmpty ||
      _lastOilChangeDate != null;

  int get _parsedYear => int.tryParse(_yearController.text.trim()) ?? 0;

  double? get _nextOilChangeOdometer {
    final interval = double.tryParse(_oilIntervalController.text.trim());
    final lastOdo = double.tryParse(_lastOilOdometerController.text.trim());
    if (interval == null || lastOdo == null) return null;
    return lastOdo + interval;
  }

  // ─────────────────────────────────────────────
  // INSURANCE DATE HELPERS
  // ─────────────────────────────────────────────

  void _onInsuranceStartDateSelected(DateTime date) {
    setState(() {
      _insuranceStartDate = date;
      // Auto-set end date to one year after start, but only if end date
      // has not been manually changed already.
      _insuranceEndDate ??= DateTime(date.year + 1, date.month, date.day);
    });
  }

  // ─────────────────────────────────────────────
  // PUC DATE HELPERS
  // ─────────────────────────────────────────────

  void _onPucStartDateSelected(DateTime date) {
    setState(() {
      _pucStartDate = date;
      // Auto-calculate PUC expiry based on manufacturing year (business rule).
      final year = _parsedYear;
      if (year > 0) {
        _pucEndDate = calculatePucExpiry(
          startDate: date,
          manufacturingYear: year,
        );
      }
    });
  }

  // ─────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────

  void _save() {
    if (_isSaving) return;

    // Trigger setState so that the optional-section validators
    // (which check _hasAnyInsuranceInput etc.) run with current values.
    setState(() {});

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final vehicle = Vehicle(
      brand: _brand!,
      model: _modelController.text.trim(),
      manufacturingYear: _parsedYear,
      odometerReading: double.parse(_odometerController.text.trim()),
      registrationNumber: _regNumberController.text.trim(),
      color: _colorController.text.trim(),
      fuelType: _fuelType!,
      engineCapacity: int.parse(_engineCapacityController.text.trim()),
      purchaseDate: _purchaseDate!,

      // Insurance (only if the user provided details)
      insuranceProvider: _hasAnyInsuranceInput
          ? _insuranceProviderController.text.trim()
          : null,
      insurancePolicyNumber: _hasAnyInsuranceInput
          ? _insurancePolicyNumberController.text.trim()
          : null,
      insuranceStartDate:
          _hasAnyInsuranceInput ? _insuranceStartDate : null,
      insuranceEndDate: _hasAnyInsuranceInput ? _insuranceEndDate : null,

      // PUC (only if the user provided details)
      pucCertificateNumber:
          _hasAnyPucInput ? _pucCertificateController.text.trim() : null,
      pucStartDate: _hasAnyPucInput ? _pucStartDate : null,
      pucEndDate: _hasAnyPucInput ? _pucEndDate : null,

      // Oil change (only if the user provided details)
      oilChangeInterval: _hasAnyOilChangeInput
          ? double.tryParse(_oilIntervalController.text.trim())
          : null,
      lastOilChangeOdometer: _hasAnyOilChangeInput
          ? double.tryParse(_lastOilOdometerController.text.trim())
          : null,
      lastOilChangeDate: _hasAnyOilChangeInput ? _lastOilChangeDate : null,
    );

    VehiclesRepository.instance.addVehicle(vehicle);

    // Pop back to HomeScreen. The caller will refresh its vehicle list.
    if (mounted) Navigator.pop(context, true);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: 'Add Vehicle',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVehicleInfoSection(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildEngineInfoSection(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildUsageInfoSection(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildInsuranceSection(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildPucSection(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildOilChangeSection(),
              const SizedBox(height: AppSizes.spacingXl),

              _buildSaveButton(),
              const SizedBox(height: AppSizes.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION BUILDERS
  // ─────────────────────────────────────────────

  Widget _buildVehicleInfoSection() {
    return FormSectionCard(
      title: 'Vehicle Information',
      children: [
        // Brand dropdown
        DropdownButtonFormField<VehicleBrand>(
          initialValue: _brand,
          decoration: const InputDecoration(labelText: 'Brand *'),
          items: VehicleBrand.values
              .map(
                (b) => DropdownMenuItem(
                  value: b,
                  child: Text(b.displayName),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _brand = value),
          validator: (value) =>
              value == null ? 'Please select a brand' : null,
        ),

        // Model
        TextFormField(
          controller: _modelController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Model *',
            hintText: 'e.g. Activa 5G',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter the model name' : null,
        ),

        // Manufacturing Year
        TextFormField(
          controller: _yearController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Manufacturing Year *',
            hintText: 'e.g. 2022',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Enter the manufacturing year';
            }
            final year = int.tryParse(v.trim());
            if (year == null || year < 1980 || year > DateTime.now().year) {
              return 'Enter a valid year (1980–${DateTime.now().year})';
            }
            return null;
          },
        ),

        // Registration Number
        TextFormField(
          controller: _regNumberController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Registration Number *',
            hintText: 'e.g. KL 10 AB 1234',
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Enter the registration number'
              : null,
        ),

        // Color
        TextFormField(
          controller: _colorController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Color *',
            hintText: 'e.g. Pearl White',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter the vehicle color' : null,
        ),
      ],
    );
  }

  Widget _buildEngineInfoSection() {
    return FormSectionCard(
      title: 'Engine Information',
      children: [
        // Fuel Type dropdown
        DropdownButtonFormField<String>(
          initialValue: _fuelType,
          decoration: const InputDecoration(labelText: 'Fuel Type *'),
          items: _fuelTypes
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (value) => setState(() => _fuelType = value),
          validator: (value) =>
              value == null ? 'Please select a fuel type' : null,
        ),

        // Engine Capacity
        TextFormField(
          controller: _engineCapacityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Engine Capacity *',
            hintText: 'e.g. 109',
            suffixText: 'cc',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Enter the engine capacity';
            }
            final cc = int.tryParse(v.trim());
            if (cc == null || cc <= 0) return 'Enter a valid capacity in cc';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUsageInfoSection() {
    return FormSectionCard(
      title: 'Usage Information',
      children: [
        // Purchase Date picker
        DatePickerField(
          labelText: 'Purchase Date *',
          selectedDate: _purchaseDate,
          lastDate: DateTime.now(),
          onDateSelected: (date) => setState(() => _purchaseDate = date),
          validator: (date) =>
              date == null ? 'Please select the purchase date' : null,
        ),

        // Current Odometer
        TextFormField(
          controller: _odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Current Odometer *',
            hintText: 'e.g. 25000',
            suffixText: 'km',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Enter the current odometer reading';
            }
            if (double.tryParse(v.trim()) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInsuranceSection() {
    final required = _hasAnyInsuranceInput;

    return FormSectionCard(
      title: 'Insurance (Optional)',
      children: [
        TextFormField(
          controller: _insuranceProviderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: required ? 'Insurance Provider *' : 'Insurance Provider',
            hintText: 'e.g. New India Assurance',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyInsuranceInput) return null;
            return (v == null || v.trim().isEmpty)
                ? 'Enter the insurance provider'
                : null;
          },
        ),

        TextFormField(
          controller: _insurancePolicyNumberController,
          decoration: InputDecoration(
            labelText: required ? 'Policy Number *' : 'Policy Number',
            hintText: 'e.g. POL-1234567890',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyInsuranceInput) return null;
            return (v == null || v.trim().isEmpty)
                ? 'Enter the policy number'
                : null;
          },
        ),

        DatePickerField(
          labelText: required ? 'Start Date *' : 'Start Date',
          selectedDate: _insuranceStartDate,
          onDateSelected: _onInsuranceStartDateSelected,
          validator: (date) {
            if (!_hasAnyInsuranceInput) return null;
            return date == null ? 'Select the insurance start date' : null;
          },
        ),

        DatePickerField(
          labelText: required ? 'End Date *' : 'End Date',
          selectedDate: _insuranceEndDate,
          firstDate: _insuranceStartDate,
          initialDate: _insuranceEndDate ??
              (_insuranceStartDate != null
                  ? DateTime(
                      _insuranceStartDate!.year + 1,
                      _insuranceStartDate!.month,
                      _insuranceStartDate!.day,
                    )
                  : null),
          onDateSelected: (date) => setState(() => _insuranceEndDate = date),
          hintText: 'Auto-set to 1 year after start date',
          validator: (date) {
            if (!_hasAnyInsuranceInput) return null;
            return date == null ? 'Select the insurance end date' : null;
          },
        ),
      ],
    );
  }

  Widget _buildPucSection() {
    final required = _hasAnyPucInput;
    final year = _parsedYear;
    final hintSuffix =
        year > 0 ? ' (${pucValidityDescription(year)})' : '';

    return FormSectionCard(
      title: 'PUC — Pollution Under Control (Optional)',
      children: [
        TextFormField(
          controller: _pucCertificateController,
          decoration: InputDecoration(
            labelText:
                required ? 'Certificate Number *' : 'Certificate Number',
            hintText: 'e.g. PUC-123456',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyPucInput) return null;
            return (v == null || v.trim().isEmpty)
                ? 'Enter the PUC certificate number'
                : null;
          },
        ),

        DatePickerField(
          labelText: required ? 'Start Date *' : 'Start Date',
          selectedDate: _pucStartDate,
          onDateSelected: _onPucStartDateSelected,
          validator: (date) {
            if (!_hasAnyPucInput) return null;
            return date == null ? 'Select the PUC start date' : null;
          },
        ),

        DatePickerField(
          labelText: required ? 'End Date *' : 'End Date',
          selectedDate: _pucEndDate,
          firstDate: _pucStartDate,
          onDateSelected: (date) => setState(() => _pucEndDate = date),
          hintText:
              'Auto-calculated$hintSuffix',
          validator: (date) {
            if (!_hasAnyPucInput) return null;
            return date == null ? 'Select the PUC end date' : null;
          },
        ),
      ],
    );
  }

  Widget _buildOilChangeSection() {
    final required = _hasAnyOilChangeInput;
    final next = _nextOilChangeOdometer;

    return FormSectionCard(
      title: 'Oil Change (Optional)',
      children: [
        TextFormField(
          controller: _oilIntervalController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: required ? 'Oil Change Interval *' : 'Oil Change Interval',
            hintText: 'e.g. 5000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyOilChangeInput) return null;
            if (v == null || v.trim().isEmpty) {
              return 'Enter the oil change interval';
            }
            final val = double.tryParse(v.trim());
            if (val == null || val <= 0) return 'Enter a valid interval in km';
            return null;
          },
        ),

        TextFormField(
          controller: _lastOilOdometerController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: required
                ? 'Last Oil Change Odometer *'
                : 'Last Oil Change Odometer',
            hintText: 'e.g. 20000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyOilChangeInput) return null;
            if (v == null || v.trim().isEmpty) {
              return 'Enter the last oil change odometer';
            }
            if (double.tryParse(v.trim()) == null) {
              return 'Enter a valid odometer reading';
            }
            return null;
          },
        ),

        DatePickerField(
          labelText:
              required ? 'Last Oil Change Date *' : 'Last Oil Change Date',
          selectedDate: _lastOilChangeDate,
          lastDate: DateTime.now(),
          onDateSelected: (date) => setState(() => _lastOilChangeDate = date),
          validator: (date) {
            if (!_hasAnyOilChangeInput) return null;
            return date == null ? 'Select the last oil change date' : null;
          },
        ),

        // Calculated: Next oil change odometer
        if (next != null)
          CalculatedField(
            icon: Icons.build_outlined,
            label: 'Next Oil Change',
            value: '${next.toStringAsFixed(0)} km',
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _save,
      child: _isSaving
          ? const SizedBox(
              height: AppSizes.iconMd,
              width: AppSizes.iconMd,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save Vehicle'),
    );
  }
}
