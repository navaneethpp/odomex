import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/notifications/vehicle_reminder_scheduler.dart';
import 'package:odomex/features/settings/models/notification_permission_state.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';

// ─────────────────────────────────────────────
// TEST DOUBLE: Fake NotificationService
// ─────────────────────────────────────────────

class _FakeNotificationService
    implements NotificationService {
  bool mockPermissionEnabled = true;
  bool mockExactAlarmGranted = true;

  final List<Map<String, dynamic>> scheduledNotifications =
      [];
  final List<int> cancelledIds = [];
  final List<Map<String, dynamic>> shownNotifications = [];

  @override
  bool get isInitialized => true;

  @override
  NotificationTapCallback? onNotificationTapped;

  @override
  String get localTimeZoneName => 'UTC';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async =>
      mockPermissionEnabled;

  @override
  Future<bool> areNotificationsEnabled() async =>
      mockPermissionEnabled;

  @override
  Future<NotificationPermissionState>
  checkPermissions() async {
    return NotificationPermissionState(
      notificationGranted: mockPermissionEnabled,
      exactAlarmGranted: mockExactAlarmGranted,
    );
  }

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
    shownNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  @override
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    dynamic channelId,
    dynamic channelName,
    dynamic channelDescription,
    dynamic importance,
    dynamic priority,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
    });
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
  }) async {}

  @override
  Future<void> syncDailyActivitySchedule({
    required bool masterEnabled,
    required bool dailyActivityEnabled,
    required int hour,
    required int minute,
  }) async {}

  @override
  Future<bool> scheduleDevTestReminder({
    int minutesFromNow = 2,
  }) async => true;

  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelledIds.add(-1); // sentinel
  }
}

// ─────────────────────────────────────────────
// TEST HELPERS
// ─────────────────────────────────────────────

/// Creates a minimal valid Vehicle for testing.
Vehicle _makeVehicle({
  String id = 'vehicle_test_1',
  double odometerReading = 10000,
  DateTime? pucEndDate,
  DateTime? insuranceEndDate,
  double? nextServiceOdometer,
  double? oilChangeInterval,
  double? lastOilChangeOdometer,
}) {
  return Vehicle(
    id: id,
    brand: VehicleBrand.honda,
    model: 'Activa',
    manufacturingYear: 2020,
    odometerReading: odometerReading,
    registrationNumber: 'KL01AA1234',
    color: 'Blue',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
    pucEndDate: pucEndDate,
    insuranceEndDate: insuranceEndDate,
    nextServiceOdometer: nextServiceOdometer,
    oilChangeInterval: oilChangeInterval,
    lastOilChangeOdometer: lastOilChangeOdometer,
  );
}

/// Returns a default EffectiveVehicleSettings with sensible test defaults.
EffectiveVehicleSettings _defaultEffective(
  String vehicleId,
) {
  return EffectiveVehicleSettings(
    vehicleId: vehicleId,
    serviceIntervalKm: 3000,
    oilChangeIntervalKm: 3000,
    serviceReminderEnabled: true,
    oilChangeReminderEnabled: true,
    maintenanceReminderThresholdKm: 500,
    pucReminderEnabled: true,
    pucReminderDays: 30,
    insuranceReminderEnabled: true,
    insuranceReminderDays: 30,
    isUsingGlobalServiceInterval: true,
    isUsingGlobalOilChangeInterval: true,
    isUsingGlobalServiceReminder: true,
    isUsingGlobalOilChangeReminder: true,
    isUsingGlobalMaintenanceThreshold: true,
    isUsingGlobalPucReminder: true,
    isUsingGlobalPucReminderDays: true,
    isUsingGlobalInsuranceReminder: true,
    isUsingGlobalInsuranceReminderDays: true,
  );
}

const _enabledSettings = NotificationSettings(
  enabled: true,
  dailyActivity: true,
  pucReminder: true,
  insuranceReminder: true,
  serviceReminder: true,
  oilChangeReminder: true,
);

// ─────────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────────

void main() {
  setUpAll(() {
    // Initialize timezone data so TZDateTime.from() works in tests.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });
  group('NotificationConstants – vehicle ID helper', () {
    test(
      'vehicleNotificationId returns value in correct ID range',
      () {
        const vehicleId = 'abc123';
        final pucId =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.pucReminderIdBase,
              vehicleId,
            );
        final insId =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.insuranceReminderIdBase,
              vehicleId,
            );
        final svcId =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.serviceReminderIdBase,
              vehicleId,
            );
        final oilId =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.oilChangeReminderIdBase,
              vehicleId,
            );

        expect(
          pucId,
          greaterThanOrEqualTo(
            NotificationConstants.pucReminderIdBase,
          ),
        );
        expect(
          pucId,
          lessThan(
            NotificationConstants.pucReminderIdBase + 1000,
          ),
        );

        expect(
          insId,
          greaterThanOrEqualTo(
            NotificationConstants.insuranceReminderIdBase,
          ),
        );
        expect(
          insId,
          lessThan(
            NotificationConstants.insuranceReminderIdBase +
                1000,
          ),
        );

        expect(
          svcId,
          greaterThanOrEqualTo(
            NotificationConstants.serviceReminderIdBase,
          ),
        );
        expect(
          svcId,
          lessThan(
            NotificationConstants.serviceReminderIdBase +
                1000,
          ),
        );

        expect(
          oilId,
          greaterThanOrEqualTo(
            NotificationConstants.oilChangeReminderIdBase,
          ),
        );
        expect(
          oilId,
          lessThan(
            NotificationConstants.oilChangeReminderIdBase +
                1000,
          ),
        );
      },
    );

    test(
      'vehicleNotificationId is deterministic for same vehicle ID',
      () {
        const vehicleId = 'stable_vehicle_id';
        final id1 =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.pucReminderIdBase,
              vehicleId,
            );
        final id2 =
            NotificationConstants.vehicleNotificationId(
              NotificationConstants.pucReminderIdBase,
              vehicleId,
            );
        expect(id1, equals(id2));
      },
    );

    test(
      'pucReminderBody includes vehicle name and days',
      () {
        expect(
          NotificationConstants.pucReminderBody(
            'Honda Activa',
            15,
          ),
          contains('Honda Activa'),
        );
        expect(
          NotificationConstants.pucReminderBody(
            'Honda Activa',
            15,
          ),
          contains('15'),
        );
      },
    );

    test(
      'insuranceReminderBody includes vehicle name and days',
      () {
        expect(
          NotificationConstants.insuranceReminderBody(
            'KTM Duke',
            7,
          ),
          contains('KTM Duke'),
        );
        expect(
          NotificationConstants.insuranceReminderBody(
            'KTM Duke',
            7,
          ),
          contains('7'),
        );
      },
    );

    test(
      'pucReminderBody uses singular "day" for 1 day left',
      () {
        expect(
          NotificationConstants.pucReminderBody(
            'Honda Activa',
            1,
          ),
          contains('1 day'),
        );
        expect(
          NotificationConstants.pucReminderBody(
            'Honda Activa',
            1,
          ),
          isNot(contains('days')),
        );
      },
    );

    test(
      'pucReminderBody handles expired PUC (0 or negative days)',
      () {
        expect(
          NotificationConstants.pucReminderBody(
            'Honda Activa',
            0,
          ),
          contains('expired'),
        );
      },
    );
  });

  group('VehicleReminderScheduler – master switch OFF', () {
    test(
      'no notifications scheduled when master notifications are disabled',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        final vehicle = _makeVehicle(
          pucEndDate: DateTime.now().add(
            const Duration(days: 20),
          ),
          insuranceEndDate: DateTime.now().add(
            const Duration(days: 15),
          ),
        );

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: const NotificationSettings(
            enabled: false,
          ),
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        // All notification types were cancelled (4 cancel calls per vehicle)
        expect(fakeService.scheduledNotifications, isEmpty);
        expect(fakeService.shownNotifications, isEmpty);
      },
    );
  });

  group(
    'VehicleReminderScheduler – OS permission denied',
    () {
      test(
        'no notifications scheduled when OS permission is denied',
        () async {
          final fakeService = _FakeNotificationService();
          fakeService.mockPermissionEnabled = false;
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          final vehicle = _makeVehicle(
            pucEndDate: DateTime.now().add(
              const Duration(days: 20),
            ),
          );

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          expect(
            fakeService.scheduledNotifications,
            isEmpty,
          );
          expect(fakeService.shownNotifications, isEmpty);
        },
      );
    },
  );

  group('VehicleReminderScheduler – PUC reminder', () {
    test(
      'schedules PUC reminder when end date is within threshold',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        // PUC expires in 45 days → reminder fires in 15 days (45 - 30 = +15 days from now)
        // Reminder date is in the future → should schedule.
        final pucExpiry = DateTime.now().add(
          const Duration(days: 45),
        );
        final vehicle = _makeVehicle(pucEndDate: pucExpiry);

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        expect(
          fakeService.scheduledNotifications,
          isNotEmpty,
        );
        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(pucNotif, isNotEmpty);
        expect(
          pucNotif['title'],
          NotificationConstants.pucReminderTitle,
        );
      },
    );

    test(
      'does NOT schedule PUC reminder when end date is far in the future',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        // PUC expires in 365 days → reminder date = 335 days from now (still in the future).
        // The reminder WILL be scheduled (it just fires far in the future).
        final pucExpiry = tz.TZDateTime.now(
          tz.UTC,
        ).add(const Duration(days: 365));
        final vehicle = _makeVehicle(pucEndDate: pucExpiry);

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        // A PUC notification SHOULD be scheduled (reminder date = 335 days from now, which is in the future)
        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(
          pucNotif,
          isNotEmpty,
        ); // still scheduled — reminder date is 335 days from now
      },
    );

    test(
      'does NOT schedule PUC reminder when end date has already passed',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        // PUC expired 5 days ago → reminder window already passed
        final pucExpiry = DateTime.now().subtract(
          const Duration(days: 5),
        );
        final vehicle = _makeVehicle(pucEndDate: pucExpiry);

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(
          pucNotif,
          isEmpty,
        ); // reminder date is in the past → not scheduled
      },
    );

    test(
      'skips PUC reminder when vehicle has no pucEndDate',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        final vehicle = _makeVehicle(); // no pucEndDate

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(pucNotif, isEmpty);
      },
    );

    test(
      'skips PUC reminder when pucReminder category is disabled',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        final pucExpiry = DateTime.now().add(
          const Duration(days: 10),
        );
        final vehicle = _makeVehicle(pucEndDate: pucExpiry);

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: const NotificationSettings(
            enabled: true,
            pucReminder: false, // disabled
          ),
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(pucNotif, isEmpty);
      },
    );
  });

  group('VehicleReminderScheduler – Insurance reminder', () {
    test(
      'schedules insurance reminder when end date is within threshold',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        // Insurance expires in 40 days → reminder fires in 10 days (40 - 30 = +10 days)
        // Reminder date is in the future → should schedule.
        final insuranceExpiry = DateTime.now().add(
          const Duration(days: 40),
        );
        final vehicle = _makeVehicle(
          insuranceEndDate: insuranceExpiry,
        );

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        final insNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypeInsuranceReminder,
              orElse: () => {},
            );
        expect(insNotif, isNotEmpty);
        expect(
          insNotif['title'],
          NotificationConstants.insuranceReminderTitle,
        );
      },
    );

    test(
      'skips insurance reminder when vehicle has no insuranceEndDate',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        final vehicle = _makeVehicle();

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle.id: _defaultEffective(vehicle.id),
          },
        );

        final insNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypeInsuranceReminder,
              orElse: () => {},
            );
        expect(insNotif, isEmpty);
      },
    );
  });

  group(
    'VehicleReminderScheduler – Service reminder (odometer-based)',
    () {
      test(
        'shows immediate notification when within service threshold',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          // Current odometer = 9,600 km. Next service at 10,000 km.
          // Threshold = 500 km. kmUntilDue = 400 km → within threshold.
          final vehicle = _makeVehicle(
            odometerReading: 9600,
            nextServiceOdometer: 10000,
          );

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final svcNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeServiceReminder,
                orElse: () => {},
              );
          expect(svcNotif, isNotEmpty);
          expect(
            svcNotif['title'],
            NotificationConstants.serviceReminderTitle,
          );
        },
      );

      test(
        'does NOT notify when still far from service threshold',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          // Current odometer = 5,000 km. Next service at 10,000 km.
          // kmUntilDue = 5,000 km → well outside 500 km threshold.
          final vehicle = _makeVehicle(
            odometerReading: 5000,
            nextServiceOdometer: 10000,
          );

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final svcNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeServiceReminder,
                orElse: () => {},
              );
          expect(svcNotif, isEmpty);
        },
      );

      test(
        'skips service reminder when vehicle has no nextServiceOdometer',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          final vehicle = _makeVehicle(
            odometerReading: 9800,
          ); // no nextServiceOdometer

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final svcNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeServiceReminder,
                orElse: () => {},
              );
          expect(svcNotif, isEmpty);
        },
      );
    },
  );

  group(
    'VehicleReminderScheduler – Oil change reminder (odometer-based)',
    () {
      test(
        'shows immediate notification when within oil change threshold',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          // Last oil change at 7,000 km. Interval = 3,000 km → next at 10,000 km.
          // Current = 9,700 km. kmUntilDue = 300 km → within 500 km threshold.
          final vehicle = _makeVehicle(
            odometerReading: 9700,
            oilChangeInterval: 3000,
            lastOilChangeOdometer: 7000,
          );

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final oilNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeOilChangeReminder,
                orElse: () => {},
              );
          expect(oilNotif, isNotEmpty);
          expect(
            oilNotif['title'],
            NotificationConstants.oilChangeReminderTitle,
          );
        },
      );

      test(
        'does NOT notify when still far from oil change threshold',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          // Last oil change at 5,000 km. Interval = 3,000 km → next at 8,000 km.
          // Current = 5,000 km. kmUntilDue = 3,000 km → outside 500 km threshold.
          final vehicle = _makeVehicle(
            odometerReading: 5000,
            oilChangeInterval: 3000,
            lastOilChangeOdometer: 5000,
          );

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final oilNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeOilChangeReminder,
                orElse: () => {},
              );
          expect(oilNotif, isEmpty);
        },
      );

      test(
        'skips oil change reminder when vehicle has no oil change info',
        () async {
          final fakeService = _FakeNotificationService();
          final scheduler = VehicleReminderScheduler(
            service: fakeService,
          );

          final vehicle =
              _makeVehicle(); // no oilChangeInterval or lastOilChangeOdometer

          await scheduler.syncAllVehicleReminders(
            vehicles: [vehicle],
            notificationSettings: _enabledSettings,
            effectiveSettings: {
              vehicle.id: _defaultEffective(vehicle.id),
            },
          );

          final oilNotif = fakeService.shownNotifications
              .firstWhere(
                (n) =>
                    n['payload'] ==
                    NotificationConstants
                        .payloadTypeOilChangeReminder,
                orElse: () => {},
              );
          expect(oilNotif, isEmpty);
        },
      );
    },
  );

  group('VehicleReminderScheduler – cancel all', () {
    test(
      'cancelAllVehicleReminders calls cancel for each notification type',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        final vehicle = _makeVehicle();
        await scheduler.cancelAllVehicleReminders([
          vehicle,
        ]);

        // 4 cancels per vehicle (puc, insurance, service, oil)
        expect(fakeService.cancelledIds.length, 4);
      },
    );

    test(
      'cancelRemindersForVehicle cancels 4 notification types',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        await scheduler.cancelRemindersForVehicle(
          'vehicle_test_1',
        );
        expect(fakeService.cancelledIds.length, 4);
      },
    );
  });

  group('VehicleReminderScheduler – multiple vehicles', () {
    test(
      'schedules independently for multiple vehicles',
      () async {
        final fakeService = _FakeNotificationService();
        final scheduler = VehicleReminderScheduler(
          service: fakeService,
        );

        // v1 has PUC expiry in 35 days → reminder fires in 5 days (+5 from now)
        final vehicle1 = _makeVehicle(
          id: 'v1',
          pucEndDate: DateTime.now().add(
            const Duration(days: 35),
          ),
        );
        // v2 has Insurance expiry in 40 days → reminder fires in 10 days (+10 from now)
        final vehicle2 = _makeVehicle(
          id: 'v2',
          insuranceEndDate: DateTime.now().add(
            const Duration(days: 40),
          ),
        );

        await scheduler.syncAllVehicleReminders(
          vehicles: [vehicle1, vehicle2],
          notificationSettings: _enabledSettings,
          effectiveSettings: {
            vehicle1.id: _defaultEffective(vehicle1.id),
            vehicle2.id: _defaultEffective(vehicle2.id),
          },
        );

        // v1 should have a PUC notification
        final pucNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypePucReminder,
              orElse: () => {},
            );
        expect(pucNotif, isNotEmpty);

        // v2 should have an Insurance notification
        final insNotif = fakeService.scheduledNotifications
            .firstWhere(
              (n) =>
                  n['payload'] ==
                  NotificationConstants
                      .payloadTypeInsuranceReminder,
              orElse: () => {},
            );
        expect(insNotif, isNotEmpty);
      },
    );
  });
}
