import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/features/vehicle_dashboard/models/period_usage_summary.dart';
import 'package:odomex/features/vehicle_dashboard/utils/daily_travel_calculator.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/period_metric_card.dart';
import 'package:odomex/widgets/animated_number_text.dart';

void main() {
  group('AnimatedNumberText Formatting & Precision Tests', () {
    test('formats whole numbers with integer grouping', () {
      expect(AnimatedNumberText.formatNumber(0), '0');
      expect(AnimatedNumberText.formatNumber(1), '1');
      expect(AnimatedNumberText.formatNumber(100), '100');
      expect(AnimatedNumberText.formatNumber(999), '999');
      expect(AnimatedNumberText.formatNumber(1000), '1,000');
      expect(AnimatedNumberText.formatNumber(25430), '25,430');
      expect(AnimatedNumberText.formatNumber(100000), '100,000');
      expect(AnimatedNumberText.formatNumber(99999999), '99,999,999');
    });

    test('formats explicit decimal places (0, 1, 2)', () {
      expect(AnimatedNumberText.formatNumber(42.5, decimalDigits: 1), '42.5');
      expect(AnimatedNumberText.formatNumber(42.0, decimalDigits: 1), '42.0');
      expect(AnimatedNumberText.formatNumber(4850.5, decimalDigits: 2), '4,850.50');
      expect(AnimatedNumberText.formatNumber(4850, decimalDigits: 0), '4,850');
      expect(AnimatedNumberText.formatNumber(4850.75, decimalDigits: 0), '4,851');
    });

    test('handles extreme, zero, and invalid inputs gracefully', () {
      expect(AnimatedNumberText.formatNumber(0), '0');
      expect(AnimatedNumberText.formatNumber(double.nan), '0');
      expect(AnimatedNumberText.formatNumber(double.infinity), '0');
      expect(AnimatedNumberText.formatNumber(double.negativeInfinity), '0');
    });
  });

  group('AnimatedNumberText Standalone Widget Tests', () {
    testWidgets('animates standalone number from 0 to target value',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedNumberText(
              value: 25430,
              suffix: ' km',
            ),
          ),
        ),
      );

      // Frame 0: starts at 0
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);

      // Mid-way (750ms): intermediate reading
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('25,430'), findsNothing);

      // Complete animation: exact target
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('25,430'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
    });

    testWidgets('renders zero value immediately without animation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedNumberText(
              value: 0,
              prefix: '₹',
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
    });

    testWidgets('respects MediaQuery.disableAnimations (reduced motion)',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedNumberText(
                value: 4850,
                prefix: '₹',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      // Target value is shown immediately on frame 0
      expect(find.text('4,850'), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
    });
  });

  group('Synchronized Counter System Tests', () {
    testWidgets(
        'all counters in SynchronizedCounterScope start together and finish at the exact same moment',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _TestSynchronizedDashboard(),
          ),
        ),
      );

      // Frame 0 (0ms): All counters are at 0
      await tester.pump();
      expect(find.text('0'), findsNWidgets(3)); // Odometer, Distance, Cost
      expect(find.text('0.0'), findsOneWidget); // Fuel (1 decimal digit)

      // Mid-way (750ms / 50%): None have completed yet
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('100,000'), findsNothing);
      expect(find.text('327'), findsNothing);
      expect(find.text('42.5'), findsNothing);
      expect(find.text('4,850'), findsNothing);

      // End of duration (1500ms): All counters finish simultaneously
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();

      expect(find.text('100,000'), findsOneWidget);
      expect(find.text('327'), findsOneWidget);
      expect(find.text('42.5'), findsOneWidget);
      expect(find.text('4,850'), findsOneWidget);
      expect(find.text('km'), findsNWidgets(2)); // Odometer + Distance
      expect(find.text('L'), findsOneWidget); // Fuel
      expect(find.text('₹'), findsOneWidget); // Cost
    });

    testWidgets('PeriodMetricCard renders animated numbers inside scope',
        (tester) async {
      final now = DateTime.now();
      final summary = PeriodUsageSummary(
        range: UsageRange.thirtyDays,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
        periodLabel: 'Last 30 Days',
        totalDistanceKm: 327,
        totalFuelLitres: 42.5,
        totalCost: 4850,
        travelSummary: const DailyTravelSummary(
          points: [],
          totalDistanceKm: 327,
          averageDailyKm: 10.9,
          maxDailyKm: 25,
          recordedDaysCount: 15,
        ),
        dailyCosts: const [],
        costBreakdown: const CostBreakdown(
          fuelCost: 4850,
          serviceCost: 0,
          oilChangeCost: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPeriodMetricsContainer(summary: summary),
          ),
        ),
      );

      // Frame 0: starts at 0
      await tester.pump();
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('0.0'), findsOneWidget);

      // Settle
      await tester.pump(AppDurations.counterAnimation);
      await tester.pumpAndSettle();

      expect(find.text('327'), findsOneWidget);
      expect(find.text('42.5'), findsOneWidget);
      expect(find.text('4,850'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
    });

    testWidgets('safe disposal when popping screen during animation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: _TestSynchronizedDashboard(),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open dashboard
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Start animation partially (300ms)
      await tester.pump(const Duration(milliseconds: 300));

      // Pop immediately while animating
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      // No crash, ticker leak, or error
      expect(find.text('Open'), findsOneWidget);
    });
  });
}

class _TestSynchronizedDashboard extends StatefulWidget {
  const _TestSynchronizedDashboard();

  @override
  State<_TestSynchronizedDashboard> createState() =>
      _TestSynchronizedDashboardState();
}

class _TestSynchronizedDashboardState extends State<_TestSynchronizedDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.counterAnimation,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppDurations.counterCurve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SynchronizedCounterScope(
      animation: _animation,
      child: const Column(
        children: [
          AnimatedNumberText(
            value: 100000,
            suffix: ' km',
          ),
          AnimatedNumberText(
            value: 327,
            suffix: ' km',
          ),
          AnimatedNumberText(
            value: 42.5,
            suffix: ' L',
            decimalDigits: 1,
          ),
          AnimatedNumberText(
            value: 4850,
            prefix: '₹',
            decimalDigits: 0,
          ),
        ],
      ),
    );
  }
}

class _TestPeriodMetricsContainer extends StatefulWidget {
  const _TestPeriodMetricsContainer({required this.summary});

  final PeriodUsageSummary summary;

  @override
  State<_TestPeriodMetricsContainer> createState() =>
      _TestPeriodMetricsContainerState();
}

class _TestPeriodMetricsContainerState extends State<_TestPeriodMetricsContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.counterAnimation,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppDurations.counterCurve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SynchronizedCounterScope(
      animation: _animation,
      child: Row(
        children: [
          Expanded(
            child: PeriodMetricCard(
              title: 'Distance',
              numericValue: widget.summary.totalDistanceKm,
              decimalDigits: 0,
              unit: 'km',
              icon: Icons.route_rounded,
            ),
          ),
          Expanded(
            child: PeriodMetricCard(
              title: 'Fuel',
              numericValue: widget.summary.totalFuelLitres,
              decimalDigits: 1,
              unit: 'L',
              icon: Icons.local_gas_station_rounded,
            ),
          ),
          Expanded(
            child: PeriodMetricCard(
              title: 'Cost',
              numericValue: widget.summary.totalCost,
              prefix: '₹',
              decimalDigits: 0,
              icon: Icons.payments_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
