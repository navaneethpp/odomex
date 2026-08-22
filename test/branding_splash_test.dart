import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/constants/app_assets.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/features/settings/widgets/about_app_card.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Branding & Splash Screen Tests', () {
    test('AppAssets constants are valid and centralized', () {
      expect(AppAssets.logo, equals('assets/images/odomex_logo.png'));
    });

    testWidgets('SplashScreen renders official logo and Odomex brand title',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      );

      // Verify the image asset and brand title are rendered
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, equals(AppAssets.logo));
      expect(find.text('Odomex'), findsOneWidget);

      // Advance animation
      await tester.pumpAndSettle();
      expect(find.text('Odomex'), findsOneWidget);
    });

    testWidgets('SplashScreen renders properly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Odomex'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('AboutAppCard renders official Odomex logo image',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AboutAppCard(),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, equals(AppAssets.logo));
      expect(find.text('Odomex'), findsOneWidget);
      expect(find.text('Your vehicle, your journey.'), findsOneWidget);
    });

    test('AppRoutes.onGenerateRoute correctly handles /splash route', () {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: AppRoutes.splash),
      );
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });
  });
}
