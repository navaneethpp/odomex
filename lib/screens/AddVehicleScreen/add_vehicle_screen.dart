import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/puc_utils.dart';
import 'package:odomex/core/validation/vehicle_validators.dart';
import 'package:odomex/data/vehicle_catalog.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/calculated_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/date_picker_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/form_section_card.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/insurance_provider_selector_sheet.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/searchable_brand_picker.dart';
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
  ConsumerState<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Scroll controller used to scroll toward the first invalid field.
  final _scrollController = ScrollController();

  // Whether save is in progress (prevents duplicate submissions).
  bool _isSaving = false;

  // ─────────────────────────────────────────────
  // 1. VEHICLE INFORMATION
  // ─────────────────────────────────────────────

  VehicleType _vehicleType = VehicleType.motorcycle;
  VehicleBrand? _brand;
  String? _customBrandName;
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _colorController = TextEditingController();

  // ─────────────────────────────────────────────
  // 2. ENGINE INFORMATION
  // ─────────────────────────────────────────────

  PowertrainType? _powertrainType;
  final _engineCapacityController = TextEditingController();
  EngineCapacityUnit _engineCapacityUnit =
      EngineCapacityUnit.cc;

  bool get _isElectric =>
      _powertrainType ==
      PowertrainType
          .plugInHybrid; // Temporarily using plugInHybrid as electric proxy if needed, though pure electric isn't supported yet. We'll hide engine capacity for plugInHybrid maybe? No, plugInHybrid has a petrol engine. So no powertrain is pure electric.
  bool get _hasNoEngine =>
      _powertrainType == PowertrainType.ev;

  // ─────────────────────────────────────────────
  // 3. USAGE INFORMATION
  // ─────────────────────────────────────────────

  DateTime? _purchaseDate;
  final _odometerController = TextEditingController();

  // ─────────────────────────────────────────────
  // 4. INSURANCE INFORMATION (optional)
  // ─────────────────────────────────────────────

  final _insuranceProviderController =
      TextEditingController();
  final _insurancePolicyNumberController =
      TextEditingController();
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
  final _lastOilOdometerController =
      TextEditingController();
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
      _insurancePolicyNumberController.text
          .trim()
          .isNotEmpty ||
      _insuranceStartDate != null ||
      _insuranceEndDate != null;

  bool get _hasAnyPucInput {
    if (!(_powertrainType?.isPucApplicable ?? true)) {
      return false;
    }
    return _pucCertificateController.text
            .trim()
            .isNotEmpty ||
        _pucStartDate != null ||
        _pucEndDate != null;
  }

  bool get _hasAnyOilChangeInput {
    if (!(_powertrainType?.isOilChangeApplicable ?? true)) return false;
    return _oilIntervalController.text.trim().isNotEmpty ||
        _lastOilOdometerController.text.trim().isNotEmpty ||
        _lastOilChangeDate != null;
  }

  // ─────────────────────────────────────────────
  // DERIVED VALUES
  // ─────────────────────────────────────────────

  int get _parsedYear =>
      int.tryParse(_yearController.text.trim()) ?? 0;

  double? get _parsedCurrentOdometer =>
      double.tryParse(_odometerController.text.trim());

  double? get _nextOilChangeOdometer {
    final interval = double.tryParse(
      _oilIntervalController.text.trim(),
    );
    final lastOdo = double.tryParse(
      _lastOilOdometerController.text.trim(),
    );
    if (interval == null || lastOdo == null) return null;
    return lastOdo + interval;
  }

  // ─────────────────────────────────────────────
  // DATE EVENT HANDLERS

  void _onPurchaseDateSelected(DateTime date) {
    setState(() {
      _purchaseDate = date;
      final pDate = DateTime(
        date.year,
        date.month,
        date.day,
      );

      if (_insuranceStartDate != null) {
        final iDate = DateTime(
          _insuranceStartDate!.year,
          _insuranceStartDate!.month,
          _insuranceStartDate!.day,
        );
        if (iDate.isBefore(pDate)) {
          _insuranceStartDate = null;
        }
      }

      if (_pucStartDate != null) {
        final puDate = DateTime(
          _pucStartDate!.year,
          _pucStartDate!.month,
          _pucStartDate!.day,
        );
        if (puDate.isBefore(pDate)) {
          _pucStartDate = null;
        }
      }

      if (_lastOilChangeDate != null) {
        final oilDate = DateTime(
          _lastOilChangeDate!.year,
          _lastOilChangeDate!.month,
          _lastOilChangeDate!.day,
        );
        if (oilDate.isBefore(pDate)) {
          _lastOilChangeDate = null;
        }
      }
    });
  }

  // ─────────────────────────────────────────────

  void _onInsuranceStartDateSelected(DateTime date) {
    setState(() {
      _insuranceStartDate = date;
      // Default end date to one year later if not yet set.
      _insuranceEndDate ??= DateTime(
        date.year + 1,
        date.month,
        date.day,
      );
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

    // Removed custom fuel logic as per new architecture
    // We pass the string value for backwards compatibility, or better, we set the powertrain.
    final resolvedFuelType =
        _powertrainType?.displayName ?? 'Petrol';

    // Normalise the registration number to canonical spaced format.
    final normalisedReg = normaliseRegistrationNumber(
      _regNumberController.text.trim(),
    );

    final vehicle = Vehicle(
      vehicleType: _vehicleType,
      brand: _brand!,
      customBrand: _customBrandName,
      model: _modelController.text.trim(),
      manufacturingYear: _parsedYear,
      odometerReading: double.parse(
        _odometerController.text.trim(),
      ),
      registrationNumber: normalisedReg,
      color: _colorController.text.trim(),
      fuelType: resolvedFuelType,
      powertrainType: _powertrainType,
      // Electric vehicles have no engine displacement.
      engineCapacity: _hasNoEngine
          ? null
          : double.tryParse(
              _engineCapacityController.text.trim(),
            ),
      engineCapacityUnit: _hasNoEngine
          ? null
          : _engineCapacityUnit,
      purchaseDate: _purchaseDate!,

      // Insurance — only persisted when the user filled the section.
      insuranceProvider: _hasAnyInsuranceInput
          ? _insuranceProviderController.text.trim()
          : null,
      insurancePolicyNumber: _hasAnyInsuranceInput
          ? _insurancePolicyNumberController.text.trim()
          : null,
      insuranceStartDate: _hasAnyInsuranceInput
          ? _insuranceStartDate
          : null,
      insuranceEndDate: _hasAnyInsuranceInput
          ? _insuranceEndDate
          : null,

      // PUC — only persisted when the user filled the section.
      pucCertificateNumber: _hasAnyPucInput
          ? _pucCertificateController.text.trim()
          : null,
      pucStartDate: _hasAnyPucInput ? _pucStartDate : null,
      pucEndDate: _hasAnyPucInput ? _pucEndDate : null,

      // Oil change — only persisted when the user filled the section.
      oilChangeInterval: _hasAnyOilChangeInput
          ? double.tryParse(
              _oilIntervalController.text.trim(),
            )
          : null,
      lastOilChangeOdometer: _hasAnyOilChangeInput
          ? double.tryParse(
              _lastOilOdometerController.text.trim(),
            )
          : null,
      lastOilChangeDate: _hasAnyOilChangeInput
          ? _lastOilChangeDate
          : null,
    );

    try {
      // Add to Riverpod & Hive persistence — HomeScreen rebuilds automatically via vehicleProvider.
      await ref
          .read(vehicleProvider.notifier)
          .addVehicle(vehicle);

      // Ensure onboarding is marked completed if it was first vehicle setup
      await ref
          .read(onboardingCompletedProvider.notifier)
          .completeOnboarding();

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't save your vehicle. Please try again.",
            ),
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
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
          );
        }
      },
      child: ScreenContainer(
        title: 'Add Vehicle',
        showBackButton: true,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildVehicleInfoSection(),
                const SizedBox(height: AppSizes.spacingLg),

                _buildEngineInfoSection(),
                const SizedBox(height: AppSizes.spacingLg),

                _buildUsageInfoSection(),
                const SizedBox(height: AppSizes.spacingLg),

                _buildInsuranceSection(),
                const SizedBox(height: AppSizes.spacingLg),

                if (_powertrainType?.isPucApplicable ??
                    true) ...[
                  _buildPucSection(),
                  const SizedBox(
                    height: AppSizes.spacingLg,
                  ),
                ],

                if (_powertrainType?.isOilChangeApplicable ?? true) ...[
                  _buildOilChangeSection(),
                  const SizedBox(height: AppSizes.spacingXl),
                ],

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
        // Vehicle Type
        DropdownButtonFormField<VehicleType>(
          initialValue: _vehicleType,
          decoration: const InputDecoration(
            labelText: 'Vehicle Type *',
          ),
          items: VehicleType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(
                        width: AppSizes.spacingSm,
                      ),
                      Text(type.displayName),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null && value != _vehicleType) {
              setState(() {
                _vehicleType = value;
                if (_brand != null &&
                    !VehicleCatalog.isBrandSupported(
                      value,
                      _brand!,
                    )) {
                  _brand = null;
                  _customBrandName = null;
                }
              });
            }
          },
        ),

        // Brand (Searchable selection modal)
        SearchableBrandPicker(
          vehicleType: _vehicleType,
          selectedBrand: _brand,
          customBrandName: _customBrandName,
          onBrandSelected: (brand, custom) {
            setState(() {
              _brand = brand;
              _customBrandName = custom;
            });
          },
          validator: (value) => validateBrand(value),
        ),

        // Model
        TextFormField(
          controller: _modelController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Model *',
            hintText: 'e.g. Activa 5G or Swift',
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
          onChanged: (_) =>
              setState(() {}), // refreshes PUC hint suffix
          validator: (v) => validateManufacturingYear(
            v,
            currentYear: currentYear,
          ),
        ),

        // Registration Number
        TextFormField(
          controller: _regNumberController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Allow letters, digits, spaces, and hyphens only.
            FilteringTextInputFormatter.allow(
              RegExp(r'[A-Za-z0-9\s\-]'),
            ),
            LengthLimitingTextInputFormatter(15),
            _UpperCaseTextFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Registration Number *',
            hintText: 'e.g. KL 56 6556',
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
      title: 'Powertrain Information',
      children: [
        // Powertrain Type & Description
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<PowertrainType>(
              initialValue: _powertrainType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Powertrain *',
              ),
              items: PowertrainType.values
                  .map(
                    (pt) => DropdownMenuItem(
                      value: pt,
                      child: Text(pt.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _powertrainType = value;
                });
              },
              validator: (value) => value == null
                  ? 'Please select a powertrain'
                  : null,
            ),
            if (_powertrainType != null &&
                _powertrainType!.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.spacingSm,
                  left: AppSizes.paddingSm,
                  right: AppSizes.paddingSm,
                ),
                child: Text(
                  _powertrainType!.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),

        // Engine Capacity — hidden for pure electric vehicles
        if (!_hasNoEngine)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engine Capacity Unit',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<EngineCapacityUnit>(
                  segments: const [
                    ButtonSegment<EngineCapacityUnit>(
                      value: EngineCapacityUnit.cc,
                      label: Text('CC'),
                      tooltip: 'Engine capacity in CC',
                    ),
                    ButtonSegment<EngineCapacityUnit>(
                      value: EngineCapacityUnit.litres,
                      label: Text('Litres'),
                      tooltip: 'Engine capacity in Litres',
                    ),
                  ],
                  selected: {_engineCapacityUnit},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _engineCapacityUnit =
                          newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              TextFormField(
                controller: _engineCapacityController,
                keyboardType:
                    _engineCapacityUnit == EngineCapacityUnit.cc
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                inputFormatters:
                    _engineCapacityUnit == EngineCapacityUnit.cc
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ]
                    : [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                      ],
                decoration: InputDecoration(
                  labelText: 'Engine Capacity *',
                  hintText:
                      _engineCapacityUnit ==
                          EngineCapacityUnit.cc
                      ? 'e.g. 109'
                      : 'e.g. 1.09',
                  suffixText: _engineCapacityUnit.shortName,
                ),
                validator: (v) => validateEngineCapacity(
                  v,
                  isElectric: _isElectric,
                  unit: _engineCapacityUnit,
                ),
              ),
            ],
          ),

        // Informational note for electric vehicles
        if (_isElectric) _ElectricNote(),
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
          disableFutureDates: true,
          onDateSelected: _onPurchaseDateSelected,
          validator: (date) => validatePurchaseDate(
            date,
            manufacturingYear: _parsedYear,
          ),
        ),

        // Current Odometer
        TextFormField(
          controller: _odometerController,
          keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d*'),
            ),
          ],
          decoration: const InputDecoration(
            labelText: 'Current Odometer *',
            hintText: 'e.g. 25000',
            suffixText: 'km',
          ),
          onChanged: (_) => setState(
            () {},
          ), // refreshes oil change cross-field
          validator: (v) => validateOdometer(v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: INSURANCE (optional)
  // ─────────────────────────────────────────────

  Widget _buildInsuranceSection() {
    return FormSectionCard(
      title: 'Insurance (Optional)',
      children: [
        // Insurance Provider
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            final selected =
                await InsuranceProviderSelectorSheet.show(
                  context,
                  _insuranceProviderController.text
                          .trim()
                          .isEmpty
                      ? null
                      : _insuranceProviderController.text
                            .trim(),
                );
            if (selected != null) {
              setState(() {
                _insuranceProviderController.text =
                    selected;
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _insuranceProviderController,
              decoration: InputDecoration(
                labelText: 'Insurance Provider',
                hintText: 'Select insurance provider',
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                ),
              ),
              validator: (v) {
                if (!_hasAnyInsuranceInput) return null;
                return validateInsuranceProvider(v);
              },
            ),
          ),
        ),

        // Policy Number
        TextFormField(
          controller: _insurancePolicyNumberController,
          decoration: const InputDecoration(
            labelText: 'Policy Number',
            hintText: 'e.g. POL-1234567890',
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (v) {
            if (!_hasAnyInsuranceInput) return null;
            return validatePolicyNumber(v);
          },
        ),

        // Start Date
        DatePickerField(
          labelText: 'Start Date',
          selectedDate: _insuranceStartDate,
          onDateSelected: _onInsuranceStartDateSelected,
          disableFutureDates: true,
          firstDate: _purchaseDate,
          initialDate: _insuranceStartDate ?? _purchaseDate,
          enabled: _purchaseDate != null,
          onDisabledTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Select the vehicle purchase date first.',
                ),
              ),
            );
          },
          validator: (date) {
            if (!_hasAnyInsuranceInput) return null;
            if (_purchaseDate == null) {
              return 'Select the vehicle purchase date first.';
            }
            return validateDependentDate(
              date,
              _purchaseDate,
              'Insurance start date',
            );
          },
        ),

        // End Date — with cross-field validation
        DatePickerField(
          labelText: 'End Date',
          selectedDate: _insuranceEndDate,
          firstDate: _insuranceStartDate,
          initialDate:
              _insuranceEndDate ??
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
            return validateInsuranceDates(
              _insuranceStartDate,
              date,
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: PUC (optional)
  // ─────────────────────────────────────────────

  Widget _buildPucSection() {
    final year = _parsedYear;
    final hintSuffix = year > 0
        ? ' (${pucValidityDescription(year)})'
        : '';

    return FormSectionCard(
      title: 'PUC — Pollution Under Control (Optional)',
      children: [
        // Certificate Number
        TextFormField(
          controller: _pucCertificateController,
          decoration: const InputDecoration(
            labelText: 'Certificate Number',
            hintText: 'e.g. PUC-123456',
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (v) {
            if (!_hasAnyPucInput) return null;
            return validatePucCertificate(v);
          },
        ),

        DatePickerField(
          labelText: 'Start Date',
          selectedDate: _pucStartDate,
          onDateSelected: _onPucStartDateSelected,
          disableFutureDates: true,
          firstDate: _purchaseDate,
          initialDate: _pucStartDate ?? _purchaseDate,
          enabled: _purchaseDate != null,
          onDisabledTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Select the vehicle purchase date first.',
                ),
              ),
            );
          },
          validator: (date) {
            if (!_hasAnyPucInput) return null;
            if (_purchaseDate == null) {
              return 'Select the vehicle purchase date first.';
            }
            return validateDependentDate(
              date,
              _purchaseDate,
              'PUC start date',
            );
          },
        ),

        // End Date — auto-calculated, cross-field validated
        DatePickerField(
          labelText: 'End Date',
          selectedDate: _pucEndDate,
          firstDate: _pucStartDate,
          onDateSelected: (date) =>
              setState(() => _pucEndDate = date),
          hintText: 'Auto-calculated$hintSuffix',
          validator: (date) {
            if (!_hasAnyPucInput) return null;
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
            labelText: active
                ? 'Oil Change Interval *'
                : 'Oil Change Interval',
            hintText: 'e.g. 5000',
            suffixText: 'km',
          ),
          onChanged: (_) {
            setState(() {});
          },
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
          onChanged: (_) {
            setState(() {});
          },
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
          disableFutureDates: true,
          firstDate: _purchaseDate,
          initialDate: _lastOilChangeDate ?? _purchaseDate,
          enabled: _purchaseDate != null,
          onDisabledTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Select the vehicle purchase date first.',
                ),
              ),
            );
          },
          onDateSelected: (date) =>
              setState(() => _lastOilChangeDate = date),
          validator: (date) {
            if (!_hasAnyOilChangeInput) return null;
            if (_purchaseDate == null) {
              return 'Select the vehicle purchase date first.';
            }
            if (date == null) {
              return 'Last oil change date is required.';
            }
            return validateDependentDate(
              date,
              _purchaseDate,
              'Last oil change date',
            );
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
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
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
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
        color: colorScheme.secondaryContainer.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(
          color: colorScheme.secondary.withValues(
            alpha: 0.4,
          ),
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
