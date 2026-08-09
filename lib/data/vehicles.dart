import 'package:odomex/models/vehicle.dart';

class Vehicles {
  Vehicles._();

  static const List<Vehicle> vehicles = [
    Vehicle(
      barnd: VehicleBarnd.honda,
      model: 'Honda Activa 5G',
      manufacturingYear: 2019,
      odometerReading: 25000,
    ),
    Vehicle(
      barnd: VehicleBarnd.hero,
      model: 'Hero Splendor Plus',
      manufacturingYear: 2018,
      odometerReading: 30000,
    ),
    Vehicle(
      barnd: VehicleBarnd.suzuki,
      model: 'Suzuki Access 125',
      manufacturingYear: 2020,
      odometerReading: 20000,
    ),
    Vehicle(
      barnd: VehicleBarnd.ktm,
      model: 'KTM Duke 200',
      manufacturingYear: 2022,
      odometerReading: 15000,
    ),
    Vehicle(
      barnd: VehicleBarnd.royalEnfield,
      model: 'Royal Enfield Classic 350',
      manufacturingYear: 2021,
      odometerReading: 28000,
    ),
    Vehicle(
      barnd: VehicleBarnd.trimph,
      model: 'Triumph Street Triple',
      manufacturingYear: 2023,
      odometerReading: 10000,
    ),
  ];
}
