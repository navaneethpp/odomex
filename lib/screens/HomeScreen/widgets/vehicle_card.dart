import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onView;
  final VoidCallback? onAdd;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onView,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppSizes.elevationSm,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.model,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(
                      height: AppSizes.spacingSm,
                    ),

                    Text(
                      '${vehicle.odometerReading} km',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Add',
              ),

              IconButton(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
