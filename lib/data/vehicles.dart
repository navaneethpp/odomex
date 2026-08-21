import 'package:odomex/models/vehicle.dart';

/// Seed data for the in-memory vehicle repository.
///
/// Each vehicle has a stable, hard-coded [Vehicle.id] so that any records
/// created against these vehicles remain consistent across hot-restarts during
/// development. Production vehicles receive auto-generated IDs from the
/// [Vehicle] constructor.
class Vehicles {
  Vehicles._();

  static final List<Vehicle> vehicles = [
    Vehicle(
      id: 'vehicle_001',
      brand: VehicleBrand.honda,
      model: 'Honda Activa 5G',
      manufacturingYear: 2019,
      odometerReading: 25000,
      registrationNumber: 'KL 10 AB 1234',
      color: 'Pearl White',
      fuelType: 'Petrol',
      engineCapacity: 109,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: DateTime(2019, 3, 15),
      lastServiceDate: DateTime(2026, 7, 10),
      nextServiceOdometer: 30000,
    ),

    Vehicle(
      id: 'vehicle_002',
      brand: VehicleBrand.hero,
      model: 'Hero Splendor Plus',
      manufacturingYear: 2018,
      odometerReading: 30000,
      registrationNumber: 'KL 11 CD 5678',
      color: 'Black',
      fuelType: 'Petrol',
      engineCapacity: 97,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: DateTime(2018, 8, 22),
      lastServiceDate: DateTime(2026, 6, 28),
      nextServiceOdometer: 35000,
    ),

    Vehicle(
      id: 'vehicle_003',
      brand: VehicleBrand.suzuki,
      model: 'Suzuki Access 125',
      manufacturingYear: 2020,
      odometerReading: 20000,
      registrationNumber: 'KL 07 EF 2468',
      color: 'Metallic Blue',
      fuelType: 'Petrol',
      engineCapacity: 124,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: DateTime(2020, 1, 12),
      lastServiceDate: DateTime(2026, 8, 5),
      nextServiceOdometer: 25000,
    ),

    Vehicle(
      id: 'vehicle_004',
      brand: VehicleBrand.ktm,
      model: 'KTM Duke 200',
      manufacturingYear: 2022,
      odometerReading: 15000,
      registrationNumber: 'KL 08 GH 1357',
      color: 'Orange',
      fuelType: 'Petrol',
      engineCapacity: 0.20,
      engineCapacityUnit: EngineCapacityUnit.litres,
      purchaseDate: DateTime(2022, 6, 18),
      lastServiceDate: DateTime(2026, 7, 20),
      nextServiceOdometer: 20000,
    ),

    Vehicle(
      id: 'vehicle_005',
      brand: VehicleBrand.royalEnfield,
      model: 'Royal Enfield Classic 350',
      manufacturingYear: 2021,
      odometerReading: 28000,
      registrationNumber: 'KL 13 IJ 9753',
      color: 'Chrome Red',
      fuelType: 'Petrol',
      engineCapacity: 349,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: DateTime(2021, 11, 5),
      lastServiceDate: DateTime(2026, 6, 15),
      nextServiceOdometer: 30000,
    ),

    Vehicle(
      id: 'vehicle_006',
      brand: VehicleBrand.triumph,
      model: 'Triumph Street Triple',
      manufacturingYear: 2023,
      odometerReading: 10000,
      registrationNumber: 'KL 14 KL 8642',
      color: 'Matt Silver',
      fuelType: 'Petrol',
      engineCapacity: 765,
      engineCapacityUnit: EngineCapacityUnit.cc,
      purchaseDate: DateTime(2023, 9, 10),
      lastServiceDate: DateTime(2026, 8, 1),
      nextServiceOdometer: 15000,
    ),
  ];
}
