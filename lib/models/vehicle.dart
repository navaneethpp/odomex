enum VehicleBarnd {
  honda,
  hero,
  suzuki,
  ktm,
  royalEnfield,
  trimph,
}

class Vehicle {
  const Vehicle({
    required this.barnd,
    required this.model,
    required this.manufacturingYear,
    required this.odometerReading,
  });

  final VehicleBarnd barnd;
  final String model;
  final int manufacturingYear;
  final double odometerReading;
}
