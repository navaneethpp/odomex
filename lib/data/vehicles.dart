import 'package:odomex/models/vehicle.dart';

class Vehicles {
  Vehicles._();

  static const List<Vehicle> vehicles = [
    Vehicle(
      brand: VehicleBrand.honda,
      model: 'Honda Activa 5G',
      manufacturingYear: 2019,
      odometerReading: 25000,

      registrationNumber: 'KL 10 AB 1234',
      color: 'Pearl White',

      fuelType: 'Petrol',
      engineCapacity: 109,

      purchaseDate: '15 March 2019',
      lastServiceDate: '10 July 2026',
      nextServiceOdometer: 30000,
    ),

    Vehicle(
      brand: VehicleBrand.hero,
      model: 'Hero Splendor Plus',
      manufacturingYear: 2018,
      odometerReading: 30000,

      registrationNumber: 'KL 11 CD 5678',
      color: 'Black',

      fuelType: 'Petrol',
      engineCapacity: 97,

      purchaseDate: '22 August 2018',
      lastServiceDate: '28 June 2026',
      nextServiceOdometer: 35000,
    ),

    Vehicle(
      brand: VehicleBrand.suzuki,
      model: 'Suzuki Access 125',
      manufacturingYear: 2020,
      odometerReading: 20000,

      registrationNumber: 'KL 07 EF 2468',
      color: 'Metallic Blue',

      fuelType: 'Petrol',
      engineCapacity: 124,

      purchaseDate: '12 January 2020',
      lastServiceDate: '05 August 2026',
      nextServiceOdometer: 25000,
    ),

    Vehicle(
      brand: VehicleBrand.ktm,
      model: 'KTM Duke 200',
      manufacturingYear: 2022,
      odometerReading: 15000,

      registrationNumber: 'KL 08 GH 1357',
      color: 'Orange',

      fuelType: 'Petrol',
      engineCapacity: 199,

      purchaseDate: '18 June 2022',
      lastServiceDate: '20 July 2026',
      nextServiceOdometer: 20000,
    ),

    Vehicle(
      brand: VehicleBrand.royalEnfield,
      model: 'Royal Enfield Classic 350',
      manufacturingYear: 2021,
      odometerReading: 28000,

      registrationNumber: 'KL 13 IJ 9753',
      color: 'Chrome Red',

      fuelType: 'Petrol',
      engineCapacity: 349,

      purchaseDate: '05 November 2021',
      lastServiceDate: '15 June 2026',
      nextServiceOdometer: 30000,
    ),

    Vehicle(
      brand: VehicleBrand.triumph,
      model: 'Triumph Street Triple',
      manufacturingYear: 2023,
      odometerReading: 10000,

      registrationNumber: 'KL 14 KL 8642',
      color: 'Matt Silver',

      fuelType: 'Petrol',
      engineCapacity: 765,

      purchaseDate: '10 September 2023',
      lastServiceDate: '01 August 2026',
      nextServiceOdometer: 15000,
    ),
  ];
}
