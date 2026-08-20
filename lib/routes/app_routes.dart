import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/vehicle_dashboard/screens/vehicle_dashboard_screen.dart';
import 'package:odomex/features/vehicle_records/screens/vehicle_records_screen.dart';
import 'package:odomex/features/vehicle_settings/screens/global_vehicle_settings_screen.dart';
import 'package:odomex/features/vehicle_settings/screens/vehicle_settings_screen.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';
import 'package:odomex/screens/startup/app_startup_screen.dart';

class AppRoutes {
  static const root = '/';
  static const home = '/home';
  static const onboarding = '/onboarding';
  static const vehicleDashboard = '/vehicle-dashboard';
  static const vehicleDetails = '/vehicle-details';
  static const vehicleRecords = '/vehicle-records';
  static const vehicleSettings = '/vehicle-settings';
  static const globalVehicleSettings = '/global-vehicle-settings';
  static const addVehicle = '/add-vehicle';
  static const settings = '/settings';

  /// Generates routes with custom, subtle transition animations.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(
          builder: (_) => const AppStartupScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case vehicleDashboard:
        final vehicleId = settings.arguments as String;
        return buildVehicleTransitionRoute(
          builder: (_) => VehicleDashboardScreen(vehicleId: vehicleId),
          settings: settings,
        );

      case vehicleSettings:
        final vehicleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VehicleSettingsScreen(vehicleId: vehicleId),
          settings: settings,
        );

      case globalVehicleSettings:
        return MaterialPageRoute(
          builder: (_) => const GlobalVehicleSettingsScreen(),
          settings: settings,
        );

      case vehicleDetails:
        final vehicleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VehicleDetailsScreen(vehicleId: vehicleId),
          settings: settings,
        );

      case vehicleRecords:
        final vehicleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VehicleRecordsScreen(vehicleId: vehicleId),
          settings: settings,
        );

      case addVehicle:
        return MaterialPageRoute(
          builder: (_) => const AddVehicleScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Builds a smooth, subtle fade + upward slide page route transition (250–350ms)
  /// matching Material 3 and respecting user reduce-motion settings.
  static PageRoute<T> buildVehicleTransitionRoute<T>({
    required WidgetBuilder builder,
    required RouteSettings settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: AppDurations.normal,
      reverseTransitionDuration: AppDurations.normal,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Respect reduce-motion accessibility preference
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppDurations.defaultCurve,
          reverseCurve: AppDurations.reverseCurve,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curvedAnimation);

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
