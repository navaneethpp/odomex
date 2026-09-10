import 'dart:math';

import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/repositories/vehicle_records_repository.dart';

import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

class DemoDataSeeder {
  static Future<void> seedDemoData(
      VehiclesRepository vehicleRepo, VehicleRecordsRepository recordsRepo) async {
    // Idempotency check: Ensure no demo vehicle already exists.
    final existingVehicles = vehicleRepo.getAll();
    if (existingVehicles.any((v) => v.isDemo)) {
      return;
    }

    final now = DateTime.now();
    // Use an old purchase date to allow realistic history (3 years ago)
    final purchaseDate = now.subtract(const Duration(days: 365 * 3));

    // Simulation configuration
    final random = Random(42); // Fixed seed for deterministic demo data
    const int simulationDays = 90;
    const double startingOdometer = 24800.0;
    const double fuelEconomyKmPerL = 45.0; // ~45 km/L
    const double petrolPricePerL = 102.50; // ₹102.50 per Litre
    const double refuelThresholdKm = 150.0; // Refuel after ~150km of driving

    double currentOdometer = startingOdometer;
    double accumulatedDistanceSinceFuel = 0.0;

    final records = <VehicleRecord>[];
    
    // Generate vehicle ID early
    final String vehicleId = 'demo_${now.millisecondsSinceEpoch}';

    // Base Odometer Record at start of 90 days
    final simulationStartDate = now.subtract(const Duration(days: simulationDays));
    records.add(OdometerRecord.create(
      vehicleId: vehicleId,
      date: simulationStartDate,
      odometer: startingOdometer,
      createdAt: simulationStartDate,
    ));

    for (int day = 0; day <= simulationDays; day++) {
      final currentDate = simulationStartDate.add(Duration(days: day));
      
      // ~70% chance to ride on any given day
      if (random.nextDouble() < 0.70) {
        // Daily distance between 5.0 and 40.0 km
        final dailyDistance = 5.0 + random.nextDouble() * 35.0;
        currentOdometer += dailyDistance;
        accumulatedDistanceSinceFuel += dailyDistance;

        records.add(OdometerRecord.create(
          vehicleId: vehicleId,
          date: currentDate,
          odometer: double.parse(currentOdometer.toStringAsFixed(1)),
          createdAt: currentDate,
        ));
      }

      // Check if it's time to refuel
      if (accumulatedDistanceSinceFuel >= refuelThresholdKm) {
        // Add a bit of variance to the quantity
        final quantity = accumulatedDistanceSinceFuel / fuelEconomyKmPerL;
        final roundedQuantity = double.parse(quantity.toStringAsFixed(2));
        final cost = roundedQuantity * petrolPricePerL;

        records.add(FuelRecord.create(
          vehicleId: vehicleId,
          date: currentDate,
          quantity: roundedQuantity,
          cost: double.parse(cost.toStringAsFixed(2)),
          energySource: EnergySource.petrol,
          odometerReading: double.parse(currentOdometer.toStringAsFixed(1)),
          createdAt: currentDate,
        ));

        accumulatedDistanceSinceFuel = 0.0; // Reset
      }

      // Insert an Oil Change roughly at day 45
      if (day == 45) {
        records.add(OilChangeRecord.create(
          vehicleId: vehicleId,
          date: currentDate,
          odometerReading: double.parse(currentOdometer.toStringAsFixed(1)),
          cost: 450.0,
          notes: 'Standard mineral oil change',
          createdAt: currentDate,
        ));
      }

      // Insert a Service roughly at day 60
      if (day == 60) {
        records.add(ServiceRecord.create(
          vehicleId: vehicleId,
          date: currentDate,
          odometerReading: double.parse(currentOdometer.toStringAsFixed(1)),
          serviceType: ServiceType.generalService,
          description: 'General Maintenance',
          cost: 1800.0,
          notes: 'Regular checkup, brakes tightened, chain lubed.',
          createdAt: currentDate,
        ));
      }
    }

    final demoVehicle = Vehicle(
      id: vehicleId,
      isDemo: true,
      vehicleType: VehicleType.scooter,
      brand: VehicleBrand.honda,
      model: 'Activa 5G',
      manufacturingYear: purchaseDate.year,
      odometerReading: double.parse(currentOdometer.toStringAsFixed(1)),
      registrationNumber: 'DEMO 1234',
      color: 'Pearl White',
      fuelType: 'Petrol',
      powertrainType: PowertrainType.petrol,
      engineCapacity: 109,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: purchaseDate,
    );

    await vehicleRepo.add(demoVehicle);

    for (final record in records) {
      await recordsRepo.addRecord(record);
    }
  }

  static Future<void> removeDemoData(
      VehiclesRepository vehicleRepo, VehicleRecordsRepository recordsRepo) async {
    final existingVehicles = vehicleRepo.getAll();
    final demoVehicles = existingVehicles.where((v) => v.isDemo).toList();

    for (final vehicle in demoVehicles) {
      await vehicleRepo.delete(vehicle.id);
      final records = recordsRepo.getAllRecords(vehicle.id).toList();
      for (final record in records) {
        await recordsRepo.deleteRecord(vehicle.id, record.id);
      }
    }
  }
}
