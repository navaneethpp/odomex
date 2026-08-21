import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/widgets/notification_setting_tile.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/providers/notification_settings_provider.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  bool _notificationsEnabled = false;

  @override
  bool getNotificationsEnabled() => _notificationsEnabled;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
  }

  @override
  AppThemeMode getThemeMode() => AppThemeMode.system;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {}

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      const GlobalVehicleSettings();

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {}

  @override
  VehicleSortOption getVehicleSortOption() => VehicleSortOption.lastAccessed;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async {}

  @override
  bool isOnboardingCompleted() => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}
}

class FakeNotificationService implements NotificationService {
  bool mockPermissionGranted = true;
  bool mockPlatformEnabled = true;
  int showCallCount = 0;
  int showTestCallCount = 0;
  int cancelCallCount = 0;
  int cancelAllCallCount = 0;

  @override
  bool get isInitialized => true;

  @override
  NotificationTapCallback? onNotificationTapped;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => mockPermissionGranted;

  @override
  Future<bool> areNotificationsEnabled() async => mockPlatformEnabled;

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {
    showCallCount++;
  }

  @override
  Future<void> showTestNotification() async {
    showTestCallCount++;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCallCount++;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
  }
}

void main() {
  group('NotificationConstants Tests', () {
    test('verifies constant IDs and channel definitions', () {
      expect(NotificationConstants.remindersChannelId, 'odomex_reminders');
      expect(NotificationConstants.remindersChannelName, 'Odomex Notifications');
      expect(NotificationConstants.testNotificationId, 1000);
      expect(NotificationConstants.androidNotificationIcon, '@drawable/ic_notification');
      expect(NotificationConstants.payloadTypeTest, 'test_notification');
    });
  });

  group('NotificationSettingsNotifier Tests', () {
    late FakeAppSettingsLocalDataSource fakeDataSource;
    late AppSettingsRepository repository;
    late FakeNotificationService fakeService;

    setUp(() {
      fakeDataSource = FakeAppSettingsLocalDataSource();
      repository = AppSettingsRepository(localDataSource: fakeDataSource);
      fakeService = FakeNotificationService();
    });

    test('initializes with default value (false)', () {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      expect(notifier.state, false);
      expect(repository.getNotificationsEnabled(), false);
    });

    test('enabling notifications requests permission and persists true when granted', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = true;
      final result = await notifier.setNotificationsEnabled(true);

      expect(result, true);
      expect(notifier.state, true);
      expect(repository.getNotificationsEnabled(), true);
    });

    test('enabling notifications keeps false and persists false when permission denied', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = false;
      final result = await notifier.setNotificationsEnabled(true);

      expect(result, false);
      expect(notifier.state, false);
      expect(repository.getNotificationsEnabled(), false);
    });

    test('disabling notifications updates state and persists false without requesting permission', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = true;
      await notifier.setNotificationsEnabled(true);
      expect(notifier.state, true);

      final result = await notifier.setNotificationsEnabled(false);
      expect(result, true);
      expect(notifier.state, false);
      expect(repository.getNotificationsEnabled(), false);
    });
  });

  group('NotificationSettingTile Widget Tests', () {
    late FakeAppSettingsLocalDataSource fakeDataSource;
    late AppSettingsRepository repository;

    setUp(() {
      fakeDataSource = FakeAppSettingsLocalDataSource();
      repository = AppSettingsRepository(localDataSource: fakeDataSource);
    });

    testWidgets('renders tile elements, switch state, and test button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationSettingTile(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Receive reminders and updates'), findsOneWidget);
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });

    testWidgets('tapping Test Notification when disabled shows warning snackbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationSettingTile(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Notification'));
      await tester.pumpAndSettle();

      expect(find.text('Enable notifications first.'), findsOneWidget);
    });
  });
}
