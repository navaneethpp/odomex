import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';

void main() {
  group('DailyTravelCalculator Tests', () {
    final testVehicle = Vehicle(
      id: 'v1',
      brand: VehicleBrand.honda,
      model: 'Activa',
      manufacturingYear: 2020,
      odometerReading: 25000,
      registrationNumber: 'KL 01 A 1234',
      color: 'White',
      fuelType: 'Petrol',
      purchaseDate: DateTime(2020, 1, 1),
    );

    test('correctly calculates cumulative distance differences per day', () {
      final now = DateTime(2026, 8, 20, 12, 0);

      final records = [
        OdometerRecord.create(
          vehicleId: 'v1',
          date: DateTime(2026, 8, 17, 10, 0), // Day 1
          odometer: 25000,
        ),
        OdometerRecord.create(
          vehicleId: 'v1',
          date: DateTime(2026, 8, 18, 18, 0), // Day 2: +35 km
          odometer: 25035,
        ),
        OdometerRecord.create(
          vehicleId: 'v1',
          date: DateTime(2026, 8, 19, 9, 0), // Day 3 (multiple readings): 25060
          odometer: 25060,
        ),
        OdometerRecord.create(
          vehicleId: 'v1',
          date: DateTime(2026, 8, 19, 20, 0), // Day 3 latest: 25080 (+45 km)
          odometer: 25080,
        ),
        // Day 4 (2026, 8, 20): no records
      ];

      final summary = DailyTravelCalculator.calculate(
        vehicle: testVehicle,
        records: records,
        range: UsageRange.sevenDays,
        referenceDate: now,
      );

      expect(summary.points.length, 7);

      // Find the points for Aug 18 and Aug 19
      final day18 = summary.points.firstWhere((p) => p.date.day == 18);
      expect(day18.isRecorded, isTrue);
      expect(day18.distanceKm, 35.0);

      final day19 = summary.points.firstWhere((p) => p.date.day == 19);
      expect(day19.isRecorded, isTrue);
      expect(day19.distanceKm, 45.0);

      final day20 = summary.points.firstWhere((p) => p.date.day == 20);
      expect(day20.isRecorded, isFalse);
      expect(day20.distanceKm, 0.0);

      expect(summary.totalDistanceKm, 80.0);
      expect(summary.maxDailyKm, 45.0);
      expect(summary.recordedDaysCount, 3);
    });

    test('handles 14D, 30D, 90D range count correctly', () {
      final summary14 = DailyTravelCalculator.calculate(
        vehicle: testVehicle,
        records: const [],
        range: UsageRange.fourteenDays,
      );
      expect(summary14.points.length, 14);

      final summary30 = DailyTravelCalculator.calculate(
        vehicle: testVehicle,
        records: const [],
        range: UsageRange.thirtyDays,
      );
      expect(summary30.points.length, 30);

      final summary90 = DailyTravelCalculator.calculate(
        vehicle: testVehicle,
        records: const [],
        range: UsageRange.ninetyDays,
      );
      expect(summary90.points.length, 90);
    });
  });

  group('VehicleReminderCalculator Tests', () {
    test('prioritizes reminders strictly by urgency (overdue first)', () {
      final now = DateTime.now();

      final vehicle = Vehicle(
        id: 'v2',
        brand: VehicleBrand.ktm,
        model: 'Duke',
        manufacturingYear: 2022,
        odometerReading: 20000,
        registrationNumber: 'KL 07 B 5678',
        color: 'Orange',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2022, 1, 1),
        // Insurance is upcoming (in 60 days)
        insuranceProvider: 'HDFC',
        insurancePolicyNumber: '12345',
        insuranceStartDate: now.subtract(const Duration(days: 300)),
        insuranceEndDate: now.add(const Duration(days: 60)),
        // PUC is expiring in 5 days (Due Soon)
        pucCertificateNumber: 'PUC-99',
        pucStartDate: now.subtract(const Duration(days: 175)),
        pucEndDate: now.add(const Duration(days: 5)),
        // Oil change is overdue (due at 19,000 km, current 20,000 km)
        lastOilChangeOdometer: 16000,
        oilChangeInterval: 3000,
        // Service is due at 25,000 km (upcoming, 5,000 km left)
        nextServiceOdometer: 25000,
      );

      final reminders = VehicleReminderCalculator.calculateReminders(vehicle);

      expect(reminders.length, 4);

      // 1st should be Overdue (Oil Change)
      expect(reminders[0].type, ReminderType.oilChange);
      expect(reminders[0].urgency, ReminderUrgency.overdue);

      // 2nd should be Due Soon (PUC in 5 days)
      expect(reminders[1].type, ReminderType.puc);
      expect(reminders[1].urgency, ReminderUrgency.dueSoon);

      // 3rd and 4th should be Upcoming
      expect(reminders[2].urgency, ReminderUrgency.upcoming);
      expect(reminders[3].urgency, ReminderUrgency.upcoming);
    });
  });
}
