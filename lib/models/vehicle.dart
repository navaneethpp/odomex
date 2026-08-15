enum VehicleBrand {
  honda,
  hero,
  suzuki,
  ktm,
  royalEnfield,
  triumph,
}

class Vehicle {
  const Vehicle({
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.odometerReading,
    required this.registrationNumber,
    required this.color,
    required this.fuelType,
    required this.engineCapacity,
    required this.purchaseDate,
    required this.lastServiceDate,
    required this.nextServiceOdometer,
  });

  final VehicleBrand brand;
  final String model;
  final int manufacturingYear;

  // Distance
  final double odometerReading;

  // Vehicle identification
  final String registrationNumber;
  final String color;

  // Engine
  final String fuelType;
  final int engineCapacity;

  // Service information
  final String purchaseDate;
  final String lastServiceDate;
  final double nextServiceOdometer;
}
