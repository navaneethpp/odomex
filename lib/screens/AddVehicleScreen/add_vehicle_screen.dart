import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/puc_utils.dart';
import 'package:odomex/core/validation/vehicle_validators.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/calculated_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/date_picker_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/form_section_card.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Screen for adding a new vehicle to the in-memory vehicle repository.
///
/// The form is divided into six sections:
///   1. Vehicle Information (required)
///   2. Engine Information (required; electric vehicles skip engine capacity)
///   3. Usage Information (required)
///   4. Insurance (optional; all fields required if any are filled)
///   5. PUC — Pollution Under Control (optional; all fields required if any filled)
///   6. Oil Change (optional; all fields required if any filled)
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Scroll controller used to scroll toward the first invalid field.
  final _scrollController = ScrollController();

  // Whether save is in progress (prevents duplicate submissions).
  bool _isSaving = false;

  // ─────────────────────────────────────────────
  // 1. VEHICLE INFORMATION
  // ─────────────────────────────────────────────

  VehicleBrand? _brand;
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _colorController = TextEditingController();

  // ─────────────────────────────────────────────
  // 2. ENGINE INFORMATION
  // ─────────────────────────────────────────────

  String? _fuelType;
  final _customFuelController = TextEditingController();
  final _engineCapacityController = TextEditingController();

  static const String _otherFuel = 'Other';
  static const String _electricFuel = 'Electric';

  static const List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    _electricFuel,
    'CNG',
    _otherFuel,
  ];

  bool get _isElectric => _fuelType == _electricFuel;
  bool get _isOtherFuel => _fuelType == _otherFuel;

  // ─────────────────────────────────────────────
  // 3. USAGE INFORMATION
  // ─────────────────────────────────────────────

  DateTime? _purchaseDate;
  final _odometerController = TextEditingController();

  // ─────────────────────────────────────────────
  // 4. INSURANCE INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyNumberController = TextEditingController();
  DateTime? _insuranceStartDate;
  DateTime? _insuranceEndDate;

  // ─────────────────────────────────────────────
  // 5. PUC INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _pucCertificateController = TextEditingController();
  DateTime? _pucStartDate;
  DateTime? _pucEndDate;

  // ─────────────────────────────────────────────
  // 6. OIL CHANGE INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _oilIntervalController = TextEditingController();
  final _lastOilOdometerController = TextEditingController();
  DateTime? _lastOilChangeDate;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void dispose() {
    _scrollController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regNumberController.dispose();
    _colorController.dispose();
    _customFuelController.dispose();
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
  // OPTIONAL-SECTION GUARDS
  // ─────────────────────────────────────────────

  bool get _hasAnyInsuranceInput =>
      _insuranceProviderController.text.trim().isNotEmpty ||
      _insurancePolicyNumberController.text.trim().isNotEmpty ||
      _insuranceStartDate != null ||
      _insuranceEndDate != null;

  bool get _hasAnyPucInput =>
      _pucCertificateController.text.trim().isNotEmpty ||
      _pucStartDate != null ||
      _pucEndDate != null;

  bool get _hasAnyOilChangeInput =>
      _oilIntervalController.text.trim().isNotEmpty ||
      _lastOilOdometerController.text.trim().isNotEmpty ||
      _lastOilChangeDate != null;

  // ─────────────────────────────────────────────
  // DERIVED VALUES
  // ─────────────────────────────────────────────

  int get _parsedYear => int.tryParse(_yearController.text.trim()) ?? 0;

  double? get _parsedCurrentOdometer =>
      double.tryParse(_odometerController.text.trim());

  double? get _nextOilChangeOdometer {
    final interval = double.tryParse(_oilIntervalController.text.trim());
    final lastOdo =
        double.tryParse(_lastOilOdometerController.text.trim());
    if (interval == null || lastOdo == null) return null;
    return lastOdo + interval;
  }

  // ─────────────────────────────────────────────
  // DATE EVENT HANDLERS
  // ─────────────────────────────────────────────

  void _onInsuranceStartDateSelected(DateTime date) {
    setState(() {
      _insuranceStartDate = date;
      // Default end date to one year later if not yet set.
      _insuranceEndDate ??= DateTime(date.year + 1, date.month, date.day);
    });
  }

  void _onPucStartDateSelected(DateTime date) {
    setState(() {
      _pucStartDate = date;
      // Auto-calculate PUC expiry from manufacturing year (see puc_utils.dart).
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

  Future<void> _save() async {
    if (_isSaving) return;

    // Rebuild so optional-section validators see the latest
    // _hasAnyInsuranceInput / _hasAnyPucInput / _hasAnyOilChangeInput values.
    setState(() {});

    final valid = _formKey.currentState!.validate();

    if (!valid) {
      // Scroll back to the top so the user can see the first error.
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    setState(() => _isSaving = true);

    // Determine the fuel type to store.
    final resolvedFuelType = _isOtherFuel
        ? _customFuelController.text.trim()
        : _fuelType!;

    // Normalise the registration number to canonical spaced format.
    final normalisedReg =
        normaliseRegistrationNumber(_regNumberController.text.trim());

    final vehicle = Vehicle(
      brand: _brand!,
      model: _modelController.text.trim(),
      manufacturingYear: _parsedYear,
      odometerReading: double.parse(_odometerController.text.trim()),
      registrationNumber: normalisedReg,
      color: _colorController.text.trim(),
      fuelType: resolvedFuelType,
      // Electric vehicles have no engine displacement.
      engineCapacity: _isElectric
          ? null
          : int.tryParse(_engineCapacityController.text.trim()),
      purchaseDate: _purchaseDate!,

      // Insurance — only persisted when the user filled the section.
      insuranceProvider: _hasAnyInsuranceInput
          ? _insuranceProviderController.text.trim()
          : null,
      insurancePolicyNumber: _hasAnyInsuranceInput
          ? _insurancePolicyNumberController.text.trim()
          : null,
      insuranceStartDate:
          _hasAnyInsuranceInput ? _insuranceStartDate : null,
      insuranceEndDate: _hasAnyInsuranceInput ? _insuranceEndDate : null,

      // PUC — only persisted when the user filled the section.
      pucCertificateNumber: _hasAnyPucInput
          ? _pucCertificateController.text.trim()
          : null,
      pucStartDate: _hasAnyPucInput ? _pucStartDate : null,
      pucEndDate: _hasAnyPucInput ? _pucEndDate : null,

      // Oil change — only persisted when the user filled the section.
      oilChangeInterval: _hasAnyOilChangeInput
          ? double.tryParse(_oilIntervalController.text.trim())
          : null,
      lastOilChangeOdometer: _hasAnyOilChangeInput
          ? double.tryParse(_lastOilOdometerController.text.trim())
          : null,
      lastOilChangeDate:
          _hasAnyOilChangeInput ? _lastOilChangeDate : null,
    );

    try {
      // Add to Riverpod & Hive persistence — HomeScreen rebuilds automatically via vehicleProvider.
      await ref.read(vehicleProvider.notifier).addVehicle(vehicle);

      // Ensure onboarding is marked completed if it was first vehicle setup
      await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't save your vehicle. Please try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      child: ScreenContainer(
        title: 'Add Vehicle',
        showBackButton: true,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        child: Form(
          key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
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
    ),
  );
  }

  // ─────────────────────────────────────────────
  // SECTION: VEHICLE INFORMATION
  // ─────────────────────────────────────────────

  Widget _buildVehicleInfoSection() {
    final currentYear = DateTime.now().year;
    return FormSectionCard(
      title: 'Vehicle Information',
      children: [
        // Brand
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
          validator: (value) => validateBrand(value),
        ),

        // Model
        TextFormField(
          controller: _modelController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Model *',
            hintText: 'e.g. Activa 5G',
          ),
          validator: (v) => validateModel(v),
        ),

        // Manufacturing Year
        TextFormField(
          controller: _yearController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: const InputDecoration(
            labelText: 'Manufacturing Year *',
            hintText: 'e.g. 2022',
          ),
          onChanged: (_) => setState(() {}), // refreshes PUC hint suffix
          validator: (v) =>
              validateManufacturingYear(v, currentYear: currentYear),
        ),

        // Registration Number
        TextFormField(
          controller: _regNumberController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Allow letters, digits, spaces, and hyphens only.
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s\-]')),
            LengthLimitingTextInputFormatter(15),
            _UpperCaseTextFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Registration Number *',
            hintText: 'e.g. KL 10 AB 1234',
          ),
          validator: (v) => validateRegistrationNumber(v),
        ),

        // Color
        TextFormField(
          controller: _colorController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Color *',
            hintText: 'e.g. Pearl White',
          ),
          validator: (v) => validateColor(v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: ENGINE INFORMATION
  // ─────────────────────────────────────────────

  Widget _buildEngineInfoSection() {
    return FormSectionCard(
      title: 'Engine Information',
      children: [
        // Fuel Type
        DropdownButtonFormField<String>(
          initialValue: _fuelType,
          decoration: const InputDecoration(labelText: 'Fuel Type *'),
          items: _fuelTypes
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _fuelType = value;
              // Clear engine capacity when switching to Electric.
              if (value == _electricFuel) {
                _engineCapacityController.clear();
              }
            });
          },
          validator: (value) => validateFuelType(value),
        ),

        // Custom Fuel Type — only shown when "Other" is selected
        if (_isOtherFuel)
          TextFormField(
            controller: _customFuelController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Specify Fuel Type *',
              hintText: 'e.g. Hydrogen',
            ),
            validator: (v) => validateCustomFuelType(v),
          ),

        // Engine Capacity — hidden for electric vehicles
        if (!_isElectric)
          TextFormField(
            controller: _engineCapacityController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: const InputDecoration(
              labelText: 'Engine Capacity *',
              hintText: 'e.g. 109',
              suffixText: 'cc',
            ),
            validator: (v) =>
                validateEngineCapacity(v, isElectric: _isElectric),
          ),

        // Informational note for electric vehicles
        if (_isElectric)
          _ElectricNote(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: USAGE INFORMATION
  // ─────────────────────────────────────────────

  Widget _buildUsageInfoSection() {
    return FormSectionCard(
      title: 'Usage Information',
      children: [
        // Purchase Date
        DatePickerField(
          labelText: 'Purchase Date *',
          selectedDate: _purchaseDate,
          lastDate: DateTime.now(),
          onDateSelected: (date) => setState(() => _purchaseDate = date),
          validator: (date) => validatePurchaseDate(
            date,
            manufacturingYear: _parsedYear,
          ),
        ),

        // Current Odometer
        TextFormField(
          controller: _odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Current Odometer *',
            hintText: 'e.g. 25000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(() {}), // refreshes oil change cross-field
          validator: (v) => validateOdometer(v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: INSURANCE (optional)
  // ─────────────────────────────────────────────

  Widget _buildInsuranceSection() {
    final active = _hasAnyInsuranceInput;

    return FormSectionCard(
      title: 'Insurance (Optional)',
      children: [
        // Insurance Provider
        TextFormField(
          controller: _insuranceProviderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: active
                ? 'Insurance Provider *'
                : 'Insurance Provider',
            hintText: 'e.g. New India Assurance',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyInsuranceInput) return null;
            return validateInsuranceProvider(v);
          },
        ),

        // Policy Number
        TextFormField(
          controller: _insurancePolicyNumberController,
          decoration: InputDecoration(
            labelText: active ? 'Policy Number *' : 'Policy Number',
            hintText: 'e.g. POL-1234567890',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyInsuranceInput) return null;
            return validatePolicyNumber(v);
          },
        ),

        // Start Date
        DatePickerField(
          labelText: active ? 'Start Date *' : 'Start Date',
          selectedDate: _insuranceStartDate,
          onDateSelected: _onInsuranceStartDateSelected,
          validator: (date) {
            if (!_hasAnyInsuranceInput) return null;
            if (date == null) return 'Insurance start date is required.';
            return null;
          },
        ),

        // End Date — with cross-field validation
        DatePickerField(
          labelText: active ? 'End Date *' : 'End Date',
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
          onDateSelected: (date) =>
              setState(() => _insuranceEndDate = date),
          hintText: 'Auto-set to 1 year after start date',
          validator: (date) {
            if (!_hasAnyInsuranceInput) return null;
            if (date == null) return 'Insurance end date is required.';
            return validateInsuranceDates(_insuranceStartDate, date);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: PUC (optional)
  // ─────────────────────────────────────────────

  Widget _buildPucSection() {
    final active = _hasAnyPucInput;
    final year = _parsedYear;
    final hintSuffix =
        year > 0 ? ' (${pucValidityDescription(year)})' : '';

    return FormSectionCard(
      title: 'PUC — Pollution Under Control (Optional)',
      children: [
        // Certificate Number
        TextFormField(
          controller: _pucCertificateController,
          decoration: InputDecoration(
            labelText: active
                ? 'Certificate Number *'
                : 'Certificate Number',
            hintText: 'e.g. PUC-123456',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyPucInput) return null;
            return validatePucCertificate(v);
          },
        ),

        // Start Date
        DatePickerField(
          labelText: active ? 'Start Date *' : 'Start Date',
          selectedDate: _pucStartDate,
          onDateSelected: _onPucStartDateSelected,
          validator: (date) {
            if (!_hasAnyPucInput) return null;
            if (date == null) return 'PUC start date is required.';
            return null;
          },
        ),

        // End Date — auto-calculated, cross-field validated
        DatePickerField(
          labelText: active ? 'End Date *' : 'End Date',
          selectedDate: _pucEndDate,
          firstDate: _pucStartDate,
          onDateSelected: (date) => setState(() => _pucEndDate = date),
          hintText: 'Auto-calculated$hintSuffix',
          validator: (date) {
            if (!_hasAnyPucInput) return null;
            if (date == null) return 'PUC end date is required.';
            return validatePucDates(_pucStartDate, date);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: OIL CHANGE (optional)
  // ─────────────────────────────────────────────

  Widget _buildOilChangeSection() {
    final active = _hasAnyOilChangeInput;
    final next = _nextOilChangeOdometer;

    return FormSectionCard(
      title: 'Oil Change (Optional)',
      children: [
        // Interval
        TextFormField(
          controller: _oilIntervalController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText:
                active ? 'Oil Change Interval *' : 'Oil Change Interval',
            hintText: 'e.g. 5000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyOilChangeInput) return null;
            return validateOilChangeInterval(v);
          },
        ),

        // Last Oil Change Odometer — cross-field against current odometer
        TextFormField(
          controller: _lastOilOdometerController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          decoration: InputDecoration(
            labelText: active
                ? 'Last Oil Change Odometer *'
                : 'Last Oil Change Odometer',
            hintText: 'e.g. 20000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (!_hasAnyOilChangeInput) return null;
            return validateOilChangeOdometer(
              v,
              currentOdometer: _parsedCurrentOdometer,
            );
          },
        ),

        // Last Oil Change Date
        DatePickerField(
          labelText: active
              ? 'Last Oil Change Date *'
              : 'Last Oil Change Date',
          selectedDate: _lastOilChangeDate,
          lastDate: DateTime.now(),
          onDateSelected: (date) =>
              setState(() => _lastOilChangeDate = date),
          validator: (date) {
            if (!_hasAnyOilChangeInput) return null;
            return validateLastOilChangeDate(date);
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

  // ─────────────────────────────────────────────
  // SAVE BUTTON
  // ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────

/// Input formatter that automatically converts typed text to uppercase.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Informational card displayed instead of the engine capacity field
/// when the user selects "Electric" as the fuel type.
class _ElectricNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.electric_bolt_outlined,
            size: AppSizes.iconSm,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: Text(
              'Engine capacity is not applicable for electric vehicles.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
