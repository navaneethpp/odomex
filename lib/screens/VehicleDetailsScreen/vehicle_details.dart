import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/models/vehicle_data_type.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/add_vehilcle_data_sheet.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/responsive_info_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/section_title.dart';
import 'package:odomex/widgets/screen_container.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  static final DateFormat _dateFormat = DateFormat('d MMMM yyyy');

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return _dateFormat.format(date);
  }

  void _handleVehicleData(
    BuildContext context,
    VehicleDataType type,
    Map<String, dynamic> data,
  ) {
    switch (type) {
      case VehicleDataType.odometer:
        final odometer = data['odometerReading'];
        debugPrint('New odometer: $odometer km');
        break;

      case VehicleDataType.fuelRefill:
        final amount = data['fuelAmount'];
        final price = data['fuelPrice'];
        debugPrint('Fuel: $amount L - ₹$price');
        break;

      case VehicleDataType.service:
        final description = data['description'];
        debugPrint('Service: $description');
        break;
    }
  }

  void _showAddDataSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return AddVehicleDataSheet(
          onSave: (type, data) {
            _handleVehicleData(context, type, data);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: vehicle.model,
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDataSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Current Odometer (highlighted) ──
            ResponsiveInfoCard(
              subtitleValue: 'Current Odometer',
              titleValue: '${vehicle.odometerReading} km',
              centerAlign: true,
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── Vehicle Information ──
            const SectionTitle(title: 'Vehicle Information'),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Brand',
                    titleValue: vehicle.brand.displayName,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Model',
                    titleValue: vehicle.model,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Year',
                    titleValue: vehicle.manufacturingYear.toString(),
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Registration',
                    titleValue: vehicle.registrationNumber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Color',
                    titleValue: vehicle.color,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Purchase Date',
                    titleValue: _formatDate(vehicle.purchaseDate),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── Engine Information ──
            const SectionTitle(title: 'Engine Information'),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Fuel Type',
                    titleValue: vehicle.fuelType,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Engine Capacity',
                    titleValue: '${vehicle.engineCapacity} cc',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── Service Information ──
            if (vehicle.lastServiceDate != null ||
                vehicle.nextServiceOdometer != null) ...[
              const SectionTitle(title: 'Service Information'),

              Row(
                children: [
                  if (vehicle.lastServiceDate != null)
                    Expanded(
                      child: ResponsiveInfoCard(
                        subtitleValue: 'Last Service Date',
                        titleValue: _formatDate(vehicle.lastServiceDate),
                      ),
                    ),

                  if (vehicle.lastServiceDate != null &&
                      vehicle.nextServiceOdometer != null)
                    const SizedBox(width: AppSizes.spacingLg),

                  if (vehicle.nextServiceOdometer != null)
                    Expanded(
                      child: ResponsiveInfoCard(
                        subtitleValue: 'Next Service',
                        titleValue: '${vehicle.nextServiceOdometer} km',
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),
            ],

            // ── Insurance ──
            if (vehicle.hasInsurance) ...[
              const SectionTitle(title: 'Insurance'),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Provider',
                      titleValue: vehicle.insuranceProvider ?? '—',
                    ),
                  ),

                  const SizedBox(width: AppSizes.spacingLg),

                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Policy Number',
                      titleValue: vehicle.insurancePolicyNumber ?? '—',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Start Date',
                      titleValue: _formatDate(vehicle.insuranceStartDate),
                    ),
                  ),

                  const SizedBox(width: AppSizes.spacingLg),

                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'End Date',
                      titleValue: _formatDate(vehicle.insuranceEndDate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),
            ],

            // ── PUC ──
            if (vehicle.hasPuc) ...[
              const SectionTitle(title: 'PUC — Pollution Under Control'),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Certificate Number',
                      titleValue: vehicle.pucCertificateNumber ?? '—',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Start Date',
                      titleValue: _formatDate(vehicle.pucStartDate),
                    ),
                  ),

                  const SizedBox(width: AppSizes.spacingLg),

                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'End Date',
                      titleValue: _formatDate(vehicle.pucEndDate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),
            ],

            // ── Oil Change ──
            if (vehicle.hasOilChange) ...[
              const SectionTitle(title: 'Oil Change'),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Last Oil Change',
                      titleValue: _formatDate(vehicle.lastOilChangeDate),
                    ),
                  ),

                  const SizedBox(width: AppSizes.spacingLg),

                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Interval',
                      titleValue: vehicle.oilChangeInterval != null
                          ? '${vehicle.oilChangeInterval!.toStringAsFixed(0)} km'
                          : '—',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),

              Row(
                children: [
                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Last Oil Change At',
                      titleValue: vehicle.lastOilChangeOdometer != null
                          ? '${vehicle.lastOilChangeOdometer!.toStringAsFixed(0)} km'
                          : '—',
                    ),
                  ),

                  const SizedBox(width: AppSizes.spacingLg),

                  Expanded(
                    child: ResponsiveInfoCard(
                      subtitleValue: 'Next Oil Change',
                      titleValue: vehicle.nextOilChangeOdometer != null
                          ? '${vehicle.nextOilChangeOdometer!.toStringAsFixed(0)} km'
                          : '—',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingLg),
            ],
          ],
        ),
      ),
    );
  }
}

/// TODO:
/// Currently the Add Data sheet has no logic — data is only printed to the
/// debug console. Implement persistence (e.g. update odometer, record fuel
/// refill, log service) once a storage layer is introduced.
