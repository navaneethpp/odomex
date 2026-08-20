import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/settings/widgets/appearance_setting_tile.dart';
import 'package:odomex/features/settings/widgets/theme_mode_selection_sheet.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

void main() {
  group('AppThemeMode Enum & Parsing Tests', () {
    test('maps correctly to Flutter ThemeMode', () {
      expect(AppThemeMode.system.flutterThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.flutterThemeMode, ThemeMode.dark);
    });

    test('parses storage keys accurately with safe fallback', () {
      expect(AppThemeModeExtension.fromStorageKey('system'), AppThemeMode.system);
      expect(AppThemeModeExtension.fromStorageKey('light'), AppThemeMode.light);
      expect(AppThemeModeExtension.fromStorageKey('dark'), AppThemeMode.dark);
      expect(AppThemeModeExtension.fromStorageKey(null), AppThemeMode.system);
      expect(AppThemeModeExtension.fromStorageKey('corrupted_value'), AppThemeMode.system);
    });
  });

  group('HiveAppSettingsLocalDataSource & Repository Tests', () {
    late Directory tempDir;
    late Box<dynamic> settingsBox;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_settings_test_');
      Hive.init(tempDir.path);
      settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('defaults to system theme when no value exists', () {
      final dataSource = HiveAppSettingsLocalDataSource(settingsBox: settingsBox);
      final repository = AppSettingsRepository(localDataSource: dataSource);

      expect(repository.getThemeMode(), AppThemeMode.system);
    });

    test('persists and retrieves chosen theme mode', () async {
      final dataSource = HiveAppSettingsLocalDataSource(settingsBox: settingsBox);
      final repository = AppSettingsRepository(localDataSource: dataSource);

      await repository.saveThemeMode(AppThemeMode.dark);
      expect(repository.getThemeMode(), AppThemeMode.dark);

      await repository.saveThemeMode(AppThemeMode.light);
      expect(repository.getThemeMode(), AppThemeMode.light);
    });
  });

  group('Theme Widgets Tests', () {
    testWidgets('AppearanceSettingTile displays active mode and opens sheet',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AppearanceSettingTile(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Tap tile
      await tester.tap(find.byType(AppearanceSettingTile));
      await tester.pumpAndSettle();

      // Bottom sheet is displayed with options
      expect(find.byType(ThemeModeSelectionSheet), findsOneWidget);
      expect(find.text('Follow device settings'), findsOneWidget);
      expect(find.text('Always use light theme'), findsOneWidget);
      expect(find.text('Always use dark theme'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Tile now shows Dark
      expect(find.text('Dark'), findsOneWidget);
    });
  });
}
