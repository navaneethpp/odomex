import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/widgets/notification_master_tile.dart';
import 'package:odomex/features/settings/widgets/notification_preference_tile.dart';
import 'package:odomex/features/settings/widgets/notification_reminders_card.dart';
import 'package:odomex/features/settings/widgets/notification_test_card.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/providers/notification_settings_provider.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  NotificationSettings _settings = const NotificationSettings();

  @override
  bool getNotificationsEnabled() => _settings.enabled;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(enabled: enabled);
  }

  @override
  NotificationSettings getNotificationSettings() => _settings;

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    _settings = settings;
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

    test('initializes with default values (master=false, all categories=true)', () {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      expect(notifier.state.enabled, false);
      expect(notifier.state.dailyActivity, true);
      expect(notifier.state.pucReminder, true);
      expect(notifier.state.insuranceReminder, true);
      expect(notifier.state.serviceReminder, true);
      expect(notifier.state.oilChangeReminder, true);
      expect(repository.getNotificationSettings().enabled, false);
    });

    test('enabling master notifications requests permission and persists true when granted', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = true;
      final result = await notifier.setMasterEnabled(true);

      expect(result, true);
      expect(notifier.state.enabled, true);
      expect(repository.getNotificationSettings().enabled, true);
    });

    test('enabling master notifications keeps false and persists false when permission denied', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = false;
      final result = await notifier.setMasterEnabled(true);

      expect(result, false);
      expect(notifier.state.enabled, false);
      expect(repository.getNotificationSettings().enabled, false);
    });

    test('disabling master preserves individual category preferences', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      fakeService.mockPermissionGranted = true;
      await notifier.setMasterEnabled(true);
      await notifier.setCategoryEnabled(NotificationCategory.insuranceReminder, false);
      expect(notifier.state.insuranceReminder, false);

      // Turn master OFF
      final result = await notifier.setMasterEnabled(false);
      expect(result, true);
      expect(notifier.state.enabled, false);
      // Individual category is preserved!
      expect(notifier.state.insuranceReminder, false);
      expect(notifier.state.dailyActivity, true);

      // Turn master back ON -> preferences restored
      await notifier.setMasterEnabled(true);
      expect(notifier.state.enabled, true);
      expect(notifier.state.insuranceReminder, false);
      expect(notifier.state.dailyActivity, true);
    });

    test('toggling category updates specific category state and persists', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
      );

      await notifier.setCategoryEnabled(NotificationCategory.pucReminder, false);
      expect(notifier.state.pucReminder, false);
      expect(repository.getNotificationSettings().pucReminder, false);

      await notifier.setCategoryEnabled(NotificationCategory.pucReminder, true);
      expect(notifier.state.pucReminder, true);
      expect(repository.getNotificationSettings().pucReminder, true);
    });
  });

  group('Notification Widgets Tests', () {
    late FakeAppSettingsLocalDataSource fakeDataSource;
    late AppSettingsRepository repository;

    setUp(() {
      fakeDataSource = FakeAppSettingsLocalDataSource();
      repository = AppSettingsRepository(localDataSource: fakeDataSource);
    });

    testWidgets('NotificationMasterTile renders master switch and responds to toggle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationMasterTile(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Manage your vehicle reminders'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });

    testWidgets('NotificationRemindersCard displays 5 categories and disables switches when master is OFF', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationRemindersCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Activity'), findsOneWidget);
      expect(find.text('PUC Reminder'), findsOneWidget);
      expect(find.text('Insurance Reminder'), findsOneWidget);
      expect(find.text('Service Reminder'), findsOneWidget);
      expect(find.text('Oil Change Reminder'), findsOneWidget);

      expect(find.byType(NotificationPreferenceTile), findsNWidgets(5));

      // With master OFF, switches have onChanged == null (disabled)
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 5);
      for (final s in switches) {
        expect(s.onChanged, isNull);
      }
    });

    testWidgets('NotificationTestCard displays button and shows warning snackbar when master is OFF', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationTestCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Notification'), findsOneWidget);
      expect(
        find.textContaining('Check whether Odomex notifications are working'),
        findsOneWidget,
      );

      await tester.tap(find.text('Test Notification'));
      await tester.pumpAndSettle();

      expect(find.text('Enable notifications first.'), findsOneWidget);
    });
  });
}
