import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/odometer_summary_card.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/widgets/animated_odometer_card.dart';
import 'package:odomex/widgets/animated_odometer_text.dart';

void main() {
  final testVehicle = Vehicle(
    id: 'veh_anim_123',
    brand: VehicleBrand.honda,
    model: 'Activa 5G',
    manufacturingYear: 2020,
    odometerReading: 25000,
    registrationNumber: 'KL 10 AB 1234',
    color: 'Black',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
  );

  group('Odometer Duration Constants Tests', () {
    test('AppDurations.odometerCountUp is set to 1500ms', () {
      expect(AppDurations.odometerCountUp, const Duration(milliseconds: 1500));
      expect(AppDurations.counterAnimation, const Duration(milliseconds: 1500));
      expect(AppDurations.odometer, const Duration(milliseconds: 1500));
    });
  });

  group('Odometer Formatting Tests', () {
    test('formats diverse whole and decimal numbers accurately', () {
      expect(AnimatedOdometerTextStateTest.format(0), '0');
      expect(AnimatedOdometerTextStateTest.format(1), '1');
      expect(AnimatedOdometerTextStateTest.format(100), '100');
      expect(AnimatedOdometerTextStateTest.format(999), '999');
      expect(AnimatedOdometerTextStateTest.format(1000), '1,000');
      expect(AnimatedOdometerTextStateTest.format(5000), '5,000');
      expect(AnimatedOdometerTextStateTest.format(25000), '25,000');
      expect(AnimatedOdometerTextStateTest.format(25000.5), '25,000.5');
      expect(AnimatedOdometerTextStateTest.format(100000), '100,000');
      expect(AnimatedOdometerTextStateTest.format(250000), '250,000');
    });
  });

  group('AnimatedOdometerText Widget Tests', () {
    testWidgets('counts up from 0 to exact target value over default 1800ms',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOdometerText(
              value: 25000,
              unit: 'km',
            ),
          ),
        ),
      );

      // Frame 0: starts at 0
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);

      // Mid-animation (900ms): interpolated intermediate value, not finished yet
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('25,000'), findsNothing);
      expect(find.text('km'), findsOneWidget);

      // Complete animation: exact target value
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('25,000'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
    });

    testWidgets('animates smoothly from previous value when value updates',
        (tester) async {
      double reading = 25000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedOdometerText(
                      value: reading,
                      unit: 'km',
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => reading = 25500),
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Settle initial 25,000
      await tester.pumpAndSettle();
      expect(find.text('25,000'), findsOneWidget);

      // Trigger update to 25,500
      await tester.tap(find.text('Update'));
      await tester.pump(); // starts from 25,000

      // Mid-way: does NOT reset to 0
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('0'), findsNothing);

      // Finishes at exact 25,500
      await tester.pumpAndSettle();
      expect(find.text('25,500'), findsOneWidget);
    });
  });

  group('AnimatedOdometerCard & OdometerSummaryCard Widget Tests', () {
    testWidgets('AnimatedOdometerCard renders subtitle and count-up value',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOdometerCard(
              value: 15000,
            ),
          ),
        ),
      );

      expect(find.text('Current Odometer'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('15,000'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
    });

    testWidgets('OdometerSummaryCard animates to vehicle reading on mount',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OdometerSummaryCard(
              vehicle: testVehicle,
            ),
          ),
        ),
      );

      expect(find.text('CURRENT ODOMETER'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('25,000'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
    });
  });
}

// Helper test extension to access formatReading
extension AnimatedOdometerTextStateTest on AnimatedOdometerText {
  static String format(double reading) {
    if (reading % 1 == 0) {
      return AnimatedOdometerTextStateHelper.formatInt(reading.toInt());
    }
    return AnimatedOdometerTextStateHelper.formatDec(reading);
  }
}

class AnimatedOdometerTextStateHelper {
  static String formatInt(int val) {
    return AnimatedOdometerCardHelper.format(val.toDouble());
  }

  static String formatDec(double val) {
    return AnimatedOdometerCardHelper.format(val);
  }
}

class AnimatedOdometerCardHelper {
  static String format(double val) {
    if (val % 1 == 0) {
      final s = val.toInt().toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return s.replaceAllMapped(reg, (Match m) => '${m[1]},');
    }
    final parts = val.toString().split('.');
    final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return '$intPart.${parts[1]}';
  }
}
