import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/utils/period_usage_calculator.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';

void main() {
  group('PeriodUsageCalculator Tests', () {
    final now = DateTime(2026, 8, 20);

    final testVehicle = Vehicle(
      id: 'v1',
      brand: VehicleBrand.honda,
      model: 'Activa',
      manufacturingYear: 2021,
      odometerReading: 25000,
      registrationNumber: 'KL 01 BB 3333',
      color: 'Grey',
      fuelType: 'Petrol',
      purchaseDate: DateTime(2021, 1, 1),
    );

    final records = [
      // 40 days ago (outside 7D and 30D)
      FuelRecord(
        id: '1',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 40)),
        quantity: 5.0,
        cost: 500.0,
        odometerReading: 24000,
      ),
      // 20 days ago (inside 30D, outside 7D)
      FuelRecord(
        id: '2',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 20)),
        quantity: 5.0,
        cost: 550.0,
        odometerReading: 24200,
      ),
      // 15 days ago (inside 30D, outside 7D)
      OilChangeRecord(
        id: '3',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 15)),
        odometerReading: 24350,
        cost: 650.0,
      ),
      // 4 days ago (inside 7D)
      OdometerRecord(
        id: '4',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 4)),
        odometer: 24500,
      ),
      // 2 days ago (inside 7D)
      FuelRecord(
        id: '5',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 2)),
        quantity: 4.5,
        cost: 500.0,
        odometerReading: 24560, // +60 km
      ),
      // Yesterday (inside 7D)
      ServiceRecord(
        id: '6',
        vehicleId: 'v1',
        date: now.subtract(const Duration(days: 1)),
        serviceType: ServiceType.generalService,
        description: 'Brake adjustments',
        odometerReading: 24590, // +30 km
        cost: 750.0,
      ),
    ];

    test('calculates 7-day period usage metrics correctly', () {
      final summary7 = PeriodUsageCalculator.calculate(
        vehicle: testVehicle,
        records: records,
        range: UsageRange.sevenDays,
        referenceDate: now,
      );

      expect(summary7.range, UsageRange.sevenDays);
      expect(summary7.dailyCosts.length, 7);
      expect(summary7.travelSummary.points.length, 7);

      // In 7D: only records 4, 5, 6 fall within the window
      // Fuel: 4.5 L, Cost: 500
      expect(summary7.totalFuelLitres, 4.5);

      // Cost: Fuel (500) + Service (750) = 1,250
      expect(summary7.totalCost, 1250.0);
      expect(summary7.costBreakdown.fuelCost, 500.0);
      expect(summary7.costBreakdown.serviceCost, 750.0);
      expect(summary7.costBreakdown.oilChangeCost, 0.0);

      // Distance: 24590 - 24350 (previous reading before 7D window) = 240 km
      expect(summary7.totalDistanceKm, 240.0);
    });

    test('calculates 30-day period usage metrics correctly', () {
      final summary30 = PeriodUsageCalculator.calculate(
        vehicle: testVehicle,
        records: records,
        range: UsageRange.thirtyDays,
        referenceDate: now,
      );

      expect(summary30.range, UsageRange.thirtyDays);
      expect(summary30.dailyCosts.length, 30);

      // In 30D: records 2, 3, 4, 5, 6
      // Fuel: 5.0 (rec 2) + 4.5 (rec 5) = 9.5 L
      expect(summary30.totalFuelLitres, 9.5);

      // Costs: Fuel (550 + 500 = 1050) + Oil (650) + Service (750) = 2,450
      expect(summary30.totalCost, 2450.0);
      expect(summary30.costBreakdown.fuelCost, 1050.0);
      expect(summary30.costBreakdown.oilChangeCost, 650.0);
      expect(summary30.costBreakdown.serviceCost, 750.0);

      // Distance: 24590 - 24000 = 590 km
      expect(summary30.totalDistanceKm, 590.0);
    });
  });
}
