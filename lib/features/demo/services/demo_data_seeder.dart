
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
    // Use an old purchase date to allow realistic history
    final purchaseDate = now.subtract(const Duration(days: 365 * 3));

    final demoVehicle = Vehicle(
      isDemo: true,
      vehicleType: VehicleType.scooter,
      brand: VehicleBrand.honda,
      model: 'Activa 5G',
      manufacturingYear: purchaseDate.year,
      odometerReading: 25430,
      registrationNumber: 'DEMO 1234',
      color: 'Pearl White',
      fuelType: 'Petrol',
      powertrainType: PowertrainType.petrol,
      engineCapacity: 109,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: purchaseDate,
    );

    await vehicleRepo.add(demoVehicle);
    final vehicleId = demoVehicle.id;

    final records = <VehicleRecord>[
      // Odometer records
      OdometerRecord(
        id: '${vehicleId}_odo_1',
        vehicleId: vehicleId,
        date: purchaseDate.add(const Duration(days: 30)),
        odometer: 1000,
      ),
      OdometerRecord(
        id: '${vehicleId}_odo_2',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 90)),
        odometer: 20000,
      ),
      OdometerRecord(
        id: '${vehicleId}_odo_3',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 60)),
        odometer: 22100,
      ),
      OdometerRecord(
        id: '${vehicleId}_odo_4',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 15)),
        odometer: 25000,
      ),
      
      // Fuel records
      FuelRecord(
        id: '${vehicleId}_fuel_1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 60)),
        odometerReading: 22100,
        energySource: EnergySource.petrol,
        quantity: 5.0,
        cost: 512.50,
      ),
      FuelRecord(
        id: '${vehicleId}_fuel_2',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 15)),
        odometerReading: 25000,
        energySource: EnergySource.petrol,
        quantity: 5.2,
        cost: 530.40,
      ),

      // Service record
      ServiceRecord(
        id: '${vehicleId}_service_1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 45)),
        odometerReading: 24000,
        serviceType: ServiceType.generalService,
        description: 'General Service',
        cost: 1800.0,
        notes: 'Oil changed, brakes tightened.',
      ),

      // Oil Change record
      OilChangeRecord(
        id: '${vehicleId}_oil_1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 45)),
        odometerReading: 24000,
        cost: 450.0,
        notes: 'Standard mineral oil',
      ),
    ];

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
