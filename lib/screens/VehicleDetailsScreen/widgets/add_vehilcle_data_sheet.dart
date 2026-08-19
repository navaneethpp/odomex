import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle_data_type.dart';

class AddVehicleDataSheet extends StatefulWidget {
  const AddVehicleDataSheet({
    super.key,
    required this.onSave,
  });

  final void Function(
    VehicleDataType type,
    Map<String, dynamic> data,
  )
  onSave;

  @override
  State<AddVehicleDataSheet> createState() =>
      _AddVehicleDataSheetState();
}

class _AddVehicleDataSheetState
    extends State<AddVehicleDataSheet> {
  VehicleDataType _selectedType = VehicleDataType.odometer;

  final _formKey = GlobalKey<FormState>();

  final _odometerController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _serviceDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelAmountController.dispose();
    _fuelPriceController.dispose();
    _serviceDescriptionController.dispose();

    super.dispose();
  }

  String _getTypeName(VehicleDataType type) {
    switch (type) {
      case VehicleDataType.odometer:
        return 'Odometer Reading';

      case VehicleDataType.fuelRefill:
        return 'Petrol Refilling';

      case VehicleDataType.service:
        return 'Service Update';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Map<String, dynamic> data;

    switch (_selectedType) {
      case VehicleDataType.odometer:
        data = {
          'odometerReading': double.parse(
            _odometerController.text,
          ),
        };
        break;

      case VehicleDataType.fuelRefill:
        data = {
          'fuelAmount': double.parse(
            _fuelAmountController.text,
          ),
          'fuelPrice': double.parse(
            _fuelPriceController.text,
          ),
        };
        break;

      case VehicleDataType.service:
        data = {
          'description': _serviceDescriptionController.text
              .trim(),
        };
        break;
    }

    widget.onSave(_selectedType, data);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.spacingLg,
          right: AppSizes.spacingLg,
          top: AppSizes.spacingLg,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              AppSizes.spacingLg,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Vehicle Data',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),

                const SizedBox(height: AppSizes.spacingLg),

                Text(
                  'Data Type',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSizes.spacingSm),

                DropdownButtonFormField<VehicleDataType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: VehicleDataType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeName(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),

                const SizedBox(height: AppSizes.spacingLg),

                _buildForm(),

                const SizedBox(height: AppSizes.spacingXl),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (_selectedType) {
      case VehicleDataType.odometer:
        return _buildOdometerForm();

      case VehicleDataType.fuelRefill:
        return _buildFuelForm();

      case VehicleDataType.service:
        return _buildServiceForm();
    }
  }

  Widget _buildOdometerForm() {
    return TextFormField(
      controller: _odometerController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Current Odometer',
        suffixText: 'km',
        hintText: 'Enter current odometer reading',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter the odometer reading';
        }

        if (double.tryParse(value) == null) {
          return 'Enter a valid number';
        }

        return null;
      },
    );
  }

  Widget _buildFuelForm() {
    return Column(
      children: [
        TextFormField(
          controller: _fuelAmountController,
          keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
          decoration: const InputDecoration(
            labelText: 'Fuel Amount',
            suffixText: 'L',
            hintText: 'Enter fuel quantity',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter fuel amount';
            }

            if (double.tryParse(value) == null) {
              return 'Enter a valid amount';
            }

            return null;
          },
        ),

        const SizedBox(height: AppSizes.spacingMd),

        TextFormField(
          controller: _fuelPriceController,
          keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
          decoration: const InputDecoration(
            labelText: 'Fuel Cost',
            prefixText: '₹ ',
            hintText: 'Enter total fuel cost',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter fuel cost';
            }

            if (double.tryParse(value) == null) {
              return 'Enter a valid amount';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServiceForm() {
    return TextFormField(
      controller: _serviceDescriptionController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Service Details',
        hintText:
            'Describe the service or maintenance performed',
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter service details';
        }

        return null;
      },
    );
  }
}
