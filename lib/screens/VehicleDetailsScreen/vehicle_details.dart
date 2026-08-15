import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/responsive_info_card.dart';
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
            Row(
              children: [
                const Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Odometer Reading',
                    titleValue: 'titleValue',
                  ),
                ),
                const SizedBox(width: AppSizes.spacingLg),
                const Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Hi',
                    titleValue: 'titleValue',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Row(
              children: [
                const Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Hi',
                    titleValue: 'titleValue',
                  ),
                ),
                const SizedBox(width: AppSizes.spacingLg),
                const Expanded(
                  child: ResponsiveInfoCard(
                    subtitleValue: 'Hi',
                    titleValue: 'titleValue',
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
/// 1. Completing the UI.
