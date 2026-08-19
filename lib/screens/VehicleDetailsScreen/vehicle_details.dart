import 'package:flutter/material.dart';
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

  @override
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
            ResponsiveInfoCard(
              subtitleValue: 'Current Odometer',
              titleValue: '${vehicle.odometerReading} km',
              centerAlign: true,
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // Vehicle Information
            const SectionTitle(
              title: 'Vehicle Information',
            ),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Brand',
                    titleValue: vehicle.brand.name
                        .toUpperCase(),
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
                    titleValue: vehicle.manufacturingYear
                        .toString(),
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Registration Number',
                    titleValue: vehicle.registrationNumber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // Engine Information
            const SectionTitle(
              title: 'Enginer Informaiton',
            ),

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
                    titleValue:
                        '${vehicle.engineCapacity} cc',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // Service Information
            const SectionTitle(
              title: 'Service Information',
            ),

            Row(
              children: [
                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Last Service Date',
                    titleValue: vehicle.lastServiceDate,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingLg),

                Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Next Service Odometer',
                    titleValue:
                        '${vehicle.nextServiceOdometer} km',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// TODO:
/// Currently it is have the option to add data. there is no logic
/// We need to add the logic.
