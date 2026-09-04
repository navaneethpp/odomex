import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/notifications/vehicle_reminder_scheduler.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_permission_state.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/settings/widgets/notification_preference_tile.dart';
import 'package:odomex/features/settings/widgets/notification_reminders_card.dart';
import 'package:odomex/features/settings/widgets/notification_time_tile.dart';
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
  bool getAutoFillCurrentOdometer() => true;

  @override
  Future<void> saveAutoFillCurrentOdometer(bool enabled) async {}


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

  @override
  String? getPrivacyPolicyAcceptedVersion() => '1.0';

  @override
  Future<void> savePrivacyPolicyAcceptedVersion(String version) async {}
}

class FakeNotificationService implements NotificationService {
  bool mockPermissionGranted = true;
  bool mockPlatformEnabled = true;
  bool mockExactAlarmGranted = true;
  int showCallCount = 0;
  int showTestCallCount = 0;
  int cancelCallCount = 0;
  int cancelAllCallCount = 0;
  int scheduleDailyCallCount = 0;
  int lastScheduledHour = -1;
  int lastScheduledMinute = -1;

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
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {
    scheduleDailyCallCount++;
    lastScheduledHour = hour;
    lastScheduledMinute = minute;
  }

  @override
  Future<void> syncDailyActivitySchedule({
    required bool masterEnabled,
    required bool dailyActivityEnabled,
    required int hour,
    required int minute,
  }) async {
    if (masterEnabled && dailyActivityEnabled) {
      final hasPermission = await areNotificationsEnabled();
      if (hasPermission) {
        await cancel(NotificationConstants.dailyActivityNotificationId);
        await scheduleDailyNotification(
          id: NotificationConstants.dailyActivityNotificationId,
          title: NotificationConstants.dailyActivityTitle,
          body: NotificationConstants.dailyActivityBody,
          hour: hour,
          minute: minute,
          payload: NotificationConstants.payloadTypeDailyActivity,
        );
        return;
      }
    }
    await cancel(NotificationConstants.dailyActivityNotificationId);
  }

  @override
  Future<NotificationPermissionState> checkPermissions() async {
    return NotificationPermissionState(
      notificationGranted: mockPlatformEnabled,
      exactAlarmGranted: mockExactAlarmGranted,
    );
  }

  @override
  String get localTimeZoneName => 'UTC';

  @override
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required dynamic scheduledDate,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {}

  @override
  Future<bool> scheduleDevTestReminder({int minutesFromNow = 2}) async => true;

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

/// A no-op fake for [VehicleReminderScheduler] used in notifier unit tests.
/// Prevents the real scheduler from accessing the uninitialized NotificationService.instance.
class FakeVehicleReminderScheduler extends VehicleReminderScheduler {
  FakeVehicleReminderScheduler() : super();

  @override
  Future<void> syncAllVehicleReminders({
    required dynamic vehicles,
    required dynamic notificationSettings,
    required dynamic effectiveSettings,
  }) async {}

  @override
  Future<void> cancelAllVehicleReminders(dynamic vehicles) async {}

  @override
  Future<void> cancelRemindersForVehicle(String vehicleId) async {}
}

void main() {
  group('NotificationConstants Tests', () {
    test('verifies constant IDs, channel definitions, and daily activity constants', () {
      expect(NotificationConstants.remindersChannelId, 'odomex_reminders');
      expect(NotificationConstants.remindersChannelName, 'Odomex Notifications');
      expect(NotificationConstants.testNotificationId, 1000);
      expect(NotificationConstants.dailyActivityNotificationId, 1100);
      expect(NotificationConstants.defaultDailyActivityHour, 20);
      expect(NotificationConstants.defaultDailyActivityMinute, 0);
      expect(
        NotificationConstants.defaultDailyActivityTime,
        const TimeOfDay(hour: 20, minute: 0),
      );
      expect(NotificationConstants.dailyActivityTitle, 'Odomex');
      expect(
        NotificationConstants.dailyActivityBody,
        "Don't forget to record today's vehicle activity.",
      );
      expect(NotificationConstants.androidNotificationIcon, '@drawable/ic_notification');
      expect(NotificationConstants.payloadTypeTest, 'test_notification');
      expect(NotificationConstants.payloadTypeDailyActivity, 'daily_activity');
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

    test('initializes with default values (master=false, all categories=true, time=20:00)', () {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      expect(notifier.state.enabled, false);
      expect(notifier.state.dailyActivity, true);
      expect(notifier.state.dailyActivityReminderHour, 20);
      expect(notifier.state.dailyActivityReminderMinute, 0);
      expect(notifier.state.pucReminder, true);
      expect(notifier.state.insuranceReminder, true);
      expect(notifier.state.serviceReminder, true);
      expect(notifier.state.oilChangeReminder, true);
      expect(repository.getNotificationSettings().enabled, false);
    });

    test('enabling master notifications schedules daily activity reminder when daily activity is true', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      fakeService.mockPermissionGranted = true;
      final result = await notifier.setMasterEnabled(true);

      expect(result, true);
      expect(notifier.state.enabled, true);
      expect(repository.getNotificationSettings().enabled, true);
      expect(fakeService.scheduleDailyCallCount, 1);
      expect(fakeService.lastScheduledHour, 20);
      expect(fakeService.lastScheduledMinute, 0);
    });

    test('disabling master cancels scheduled daily activity notification', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      fakeService.mockPermissionGranted = true;
      await notifier.setMasterEnabled(true);
      expect(fakeService.scheduleDailyCallCount, 1);

      // Disable master
      final cancelCountBefore = fakeService.cancelCallCount;
      await notifier.setMasterEnabled(false);

      expect(notifier.state.enabled, false);
      expect(fakeService.cancelCallCount, greaterThan(cancelCountBefore));
    });

    test('changing daily activity reminder time updates state and re-schedules', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      fakeService.mockPermissionGranted = true;
      await notifier.setMasterEnabled(true);

      await notifier.setDailyActivityTime(const TimeOfDay(hour: 21, minute: 30));
      expect(notifier.state.dailyActivityReminderHour, 21);
      expect(notifier.state.dailyActivityReminderMinute, 30);
      expect(repository.getNotificationSettings().dailyActivityReminderHour, 21);
      expect(repository.getNotificationSettings().dailyActivityReminderMinute, 30);

      expect(fakeService.lastScheduledHour, 21);
      expect(fakeService.lastScheduledMinute, 30);
    });

    test('disabling daily activity category cancels schedule and re-enabling re-schedules', () async {
      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      fakeService.mockPermissionGranted = true;
      await notifier.setMasterEnabled(true);
      await notifier.setDailyActivityTime(const TimeOfDay(hour: 22, minute: 15));

      // Disable Daily Activity
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, false);
      expect(notifier.state.dailyActivity, false);

      // Re-enable Daily Activity
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, true);
      expect(notifier.state.dailyActivity, true);
      expect(fakeService.lastScheduledHour, 22);
      expect(fakeService.lastScheduledMinute, 15);
    });
  });

  group('Notification Widgets Tests', () {
    late FakeAppSettingsLocalDataSource fakeDataSource;
    late AppSettingsRepository repository;

    setUp(() {
      fakeDataSource = FakeAppSettingsLocalDataSource();
      repository = AppSettingsRepository(localDataSource: fakeDataSource);
    });

    testWidgets('NotificationRemindersCard displays categories and Reminder Time tile', (tester) async {
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
      expect(find.text('Reminder Time'), findsOneWidget);
      expect(find.text('PUC Reminder'), findsOneWidget);
      expect(find.text('Insurance Reminder'), findsOneWidget);
      expect(find.text('Service Reminder'), findsOneWidget);
      expect(find.text('Oil Change Reminder'), findsOneWidget);

      expect(find.byType(NotificationPreferenceTile), findsNWidgets(5));
      expect(find.byType(NotificationTimeTile), findsOneWidget);
    });

    testWidgets('NotificationTimeTile shows formatted time and opens TimePicker when interactive', (tester) async {
      TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NotificationTimeTile(
                  title: 'Reminder Time',
                  time: selectedTime,
                  isInteractive: true,
                  onTimeChanged: (newTime) {
                    setState(() {
                      selectedTime = newTime;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reminder Time'), findsOneWidget);
      expect(find.text('8:00 PM'), findsOneWidget);

      // Tap on time tile to open time picker
      await tester.tap(find.text('Reminder Time'));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Tap Cancel -> TimePicker closes without changing time
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsNothing);
      expect(find.text('8:00 PM'), findsOneWidget);
    });

    test('rescheduling cancels old notification and creates new one with updated time', () async {
      final fakeDataSource = FakeAppSettingsLocalDataSource();
      final repository = AppSettingsRepository(localDataSource: fakeDataSource);
      final fakeService = FakeNotificationService();

      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      // Enable master and daily activity
      await notifier.setMasterEnabled(true);
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, true);

      expect(fakeService.scheduleDailyCallCount, 2);
      expect(fakeService.lastScheduledHour, 20);
      expect(fakeService.lastScheduledMinute, 0);

      // Change time to 9:30 PM (21:30)
      await notifier.setDailyActivityTime(const TimeOfDay(hour: 21, minute: 30));

      expect(fakeService.lastScheduledHour, 21);
      expect(fakeService.lastScheduledMinute, 30);
      expect(fakeService.cancelCallCount >= 3, true);

      // Disabling daily activity cancels schedule
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, false);
      expect(notifier.state.dailyActivity, false);
      expect(fakeService.cancelCallCount >= 4, true);

      // Re-enabling restores with previously saved time (21:30)
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, true);
      expect(notifier.state.dailyActivity, true);
      expect(fakeService.lastScheduledHour, 21);
      expect(fakeService.lastScheduledMinute, 30);
    });

    test('permission denied prevents false activation and does not schedule notifications', () async {
      final fakeDataSource = FakeAppSettingsLocalDataSource();
      final repository = AppSettingsRepository(localDataSource: fakeDataSource);
      final fakeService = FakeNotificationService();

      fakeService.mockPermissionGranted = false;
      fakeService.mockPlatformEnabled = false;

      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      final result = await notifier.setMasterEnabled(true);
      expect(result, false);
      expect(notifier.state.enabled, false);
      expect(fakeService.scheduleDailyCallCount, 0);
    });

    test('revoking OS permission cancels active schedules during refresh', () async {
      final fakeDataSource = FakeAppSettingsLocalDataSource();
      final repository = AppSettingsRepository(localDataSource: fakeDataSource);
      final fakeService = FakeNotificationService();

      fakeService.mockPermissionGranted = true;
      fakeService.mockPlatformEnabled = true;

      final notifier = NotificationSettingsNotifier(
        repository: repository,
        notificationService: fakeService,
        vehicleReminderScheduler: FakeVehicleReminderScheduler(),
      );

      await notifier.setMasterEnabled(true);
      await notifier.setCategoryEnabled(NotificationCategory.dailyActivity, true);
      expect(notifier.state.enabled, true);
      expect(fakeService.scheduleDailyCallCount, 2);

      // Simulate user revoking permission in Android system settings
      fakeService.mockPermissionGranted = false;
      fakeService.mockPlatformEnabled = false;

      final prevCancels = fakeService.cancelCallCount;
      await notifier.refreshPermissionAndSchedules();

      expect(fakeService.cancelCallCount > prevCancels, true);
    });
  });
}
