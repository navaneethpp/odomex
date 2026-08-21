import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/data/vehicle_catalog.dart';
import 'package:odomex/models/vehicle.dart';

/// Searchable brand picker widget that opens a modal bottom sheet
/// to search and select manufacturers for the given [vehicleType].
class SearchableBrandPicker extends StatelessWidget {
  const SearchableBrandPicker({
    super.key,
    required this.vehicleType,
    required this.selectedBrand,
    this.customBrandName,
    required this.onBrandSelected,
    this.validator,
  });

  final VehicleType vehicleType;
  final VehicleBrand? selectedBrand;
  final String? customBrandName;
  final void Function(VehicleBrand brand, String? customBrand) onBrandSelected;
  final FormFieldValidator<VehicleBrand>? validator;

  String get _displayValue {
    if (selectedBrand == null) return '';
    if (selectedBrand == VehicleBrand.other &&
        customBrandName != null &&
        customBrandName!.trim().isNotEmpty) {
      return '${selectedBrand!.displayName} (${customBrandName!.trim()})';
    }
    return selectedBrand!.displayName;
  }

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (sheetContext) {
        return _BrandSearchSheet(
          vehicleType: vehicleType,
          selectedBrand: selectedBrand,
          initialCustomBrand: customBrandName,
          onBrandSelected: (brand, custom) {
            Navigator.pop(sheetContext);
            onBrandSelected(brand, custom);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormField<VehicleBrand>(
      initialValue: selectedBrand,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _openSearchSheet(context),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Brand *',
                  hintText: 'Select or search brand...',
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
                ),
                isEmpty: selectedBrand == null,
                child: Text(
                  _displayValue,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selectedBrand == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrandSearchSheet extends StatefulWidget {
  const _BrandSearchSheet({
    required this.vehicleType,
    required this.selectedBrand,
    required this.initialCustomBrand,
    required this.onBrandSelected,
  });

  final VehicleType vehicleType;
  final VehicleBrand? selectedBrand;
  final String? initialCustomBrand;
  final void Function(VehicleBrand brand, String? customBrand) onBrandSelected;

  @override
  State<_BrandSearchSheet> createState() => _BrandSearchSheetState();
}

class _BrandSearchSheetState extends State<_BrandSearchSheet> {
  final _searchController = TextEditingController();
  final _customBrandController = TextEditingController();
  String _query = '';
  VehicleBrand? _chosenBrand;
  bool _showCustomField = false;

  @override
  void initState() {
    super.initState();
    _chosenBrand = widget.selectedBrand;
    _showCustomField = widget.selectedBrand == VehicleBrand.other;
    if (widget.initialCustomBrand != null) {
      _customBrandController.text = widget.initialCustomBrand!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customBrandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allBrands = VehicleCatalog.getBrandsForType(widget.vehicleType);

    final filteredBrands = allBrands.where((b) {
      if (_query.trim().isEmpty) return true;
      return b.displayName.toLowerCase().contains(_query.toLowerCase().trim());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            // Header
            Row(
              children: [
                Icon(
                  widget.vehicleType.icon,
                  color: colorScheme.primary,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: Text(
                    'Select ${widget.vehicleType.displayName} Brand',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSm),

            // Search bar
            TextField(
              key: const Key('brand_search_field'),
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search brand (e.g. Honda, Toyota)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.paddingSm,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            // Custom Brand input if "Other" is chosen
            if (_showCustomField) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specify Manufacturer Name:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    TextField(
                      controller: _customBrandController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Custom Manufacturer',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonal(
                        onPressed: () {
                          widget.onBrandSelected(
                            VehicleBrand.other,
                            _customBrandController.text.trim(),
                          );
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),
            ],

            // Brand list
            Flexible(
              child: filteredBrands.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingXl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSizes.spacingSm),
                            Text(
                              'No brands found matching "$_query"',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingMd),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _chosenBrand = VehicleBrand.other;
                                  _showCustomField = true;
                                  _customBrandController.text = _query.trim();
                                });
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: Text('Use "$_query" as custom brand'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        final isSelected = _chosenBrand == brand && !_showCustomField;

                        return ListTile(
                          title: Text(
                            brand.displayName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          onTap: () {
                            if (brand == VehicleBrand.other) {
                              setState(() {
                                _chosenBrand = VehicleBrand.other;
                                _showCustomField = true;
                              });
                            } else {
                              widget.onBrandSelected(brand, null);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
