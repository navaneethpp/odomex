import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
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
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: vehicle.model,
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
