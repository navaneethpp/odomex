import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/demo/services/demo_data_seeder.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';

class EmptyVehicleState extends ConsumerStatefulWidget {
  const EmptyVehicleState({super.key});

  @override
  ConsumerState<EmptyVehicleState> createState() => _EmptyVehicleStateState();
}

class _EmptyVehicleStateState extends ConsumerState<EmptyVehicleState> {
  bool _isProcessing = false;

  Future<void> _handleTryDemo() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final vehicleRepo = ref.read(vehiclesRepositoryProvider);
      final recordsRepo = ref.read(vehicleRecordRepositoryProvider);
      await DemoDataSeeder.seedDemoData(vehicleRepo, recordsRepo);
      ref.invalidate(vehicleProvider);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleAddMyVehicle() {
    if (_isProcessing) return;
    Navigator.pushNamed(context, AppRoutes.addVehicle);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXxl),

            // Title
            Text(
              'No vehicles yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingLg),

            // Description
            Text(
              'Add your vehicle to start tracking your daily usage, fuel, costs and maintenance.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            
            const Spacer(flex: 3),

            // Primary Action
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _handleAddMyVehicle,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            // Secondary Action (Demo)
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _handleTryDemo,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Try Demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Explore Odomex with a sample vehicle.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
