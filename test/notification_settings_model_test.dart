import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';

void main() {
  group('NotificationCategory Enum Tests', () {
    test('verifies title, description, icon, and storageKey for all categories', () {
      expect(NotificationCategory.dailyActivity.title, 'Daily Activity');
      expect(
        NotificationCategory.dailyActivity.description,
        "Remind me to record my vehicle's daily activity.",
      );
      expect(NotificationCategory.dailyActivity.icon, Icons.today_rounded);
      expect(NotificationCategory.dailyActivity.storageKey, 'daily_activity');

      expect(NotificationCategory.pucReminder.title, 'PUC Reminder');
      expect(
        NotificationCategory.pucReminder.description,
        'Remind me before my PUC expires.',
      );
      expect(NotificationCategory.pucReminder.icon, Icons.verified_outlined);
      expect(NotificationCategory.pucReminder.storageKey, 'puc_reminder');

      expect(NotificationCategory.insuranceReminder.title, 'Insurance Reminder');
      expect(
        NotificationCategory.insuranceReminder.description,
        'Remind me before my vehicle insurance expires.',
      );
      expect(NotificationCategory.insuranceReminder.icon, Icons.shield_outlined);
      expect(NotificationCategory.insuranceReminder.storageKey, 'insurance_reminder');

      expect(NotificationCategory.serviceReminder.title, 'Service Reminder');
      expect(
        NotificationCategory.serviceReminder.description,
        'Remind me when vehicle service is due.',
      );
      expect(NotificationCategory.serviceReminder.icon, Icons.build_outlined);
      expect(NotificationCategory.serviceReminder.storageKey, 'service_reminder');

      expect(NotificationCategory.oilChangeReminder.title, 'Oil Change Reminder');
      expect(
        NotificationCategory.oilChangeReminder.description,
        'Remind me when the next oil change is due.',
      );
      expect(NotificationCategory.oilChangeReminder.icon, Icons.oil_barrel_outlined);
      expect(NotificationCategory.oilChangeReminder.storageKey, 'oil_change_reminder');
    });
  });

  group('NotificationSettings Model Tests', () {
    test('verifies default values (master=false, categories=true)', () {
      const settings = NotificationSettings();
      expect(settings.enabled, false);
      expect(settings.dailyActivity, true);
      expect(settings.pucReminder, true);
      expect(settings.insuranceReminder, true);
      expect(settings.serviceReminder, true);
      expect(settings.oilChangeReminder, true);
    });

    test('isCategoryEnabled returns correct boolean for each category', () {
      const settings = NotificationSettings(
        dailyActivity: true,
        pucReminder: false,
        insuranceReminder: true,
        serviceReminder: false,
        oilChangeReminder: true,
      );

      expect(settings.isCategoryEnabled(NotificationCategory.dailyActivity), true);
      expect(settings.isCategoryEnabled(NotificationCategory.pucReminder), false);
      expect(settings.isCategoryEnabled(NotificationCategory.insuranceReminder), true);
      expect(settings.isCategoryEnabled(NotificationCategory.serviceReminder), false);
      expect(settings.isCategoryEnabled(NotificationCategory.oilChangeReminder), true);
    });

    test('copyWithCategory updates only the targeted category', () {
      const settings = NotificationSettings();
      final updated = settings.copyWithCategory(
        NotificationCategory.insuranceReminder,
        false,
      );

      expect(updated.insuranceReminder, false);
      expect(updated.dailyActivity, true);
      expect(updated.pucReminder, true);
      expect(updated.serviceReminder, true);
      expect(updated.oilChangeReminder, true);
      expect(updated.enabled, false);
    });

    test('toMap and fromMap serialize and deserialize correctly', () {
      const settings = NotificationSettings(
        enabled: true,
        dailyActivity: false,
        pucReminder: true,
        insuranceReminder: false,
        serviceReminder: true,
        oilChangeReminder: false,
      );

      final map = settings.toMap();
      final deserialized = NotificationSettings.fromMap(map);

      expect(deserialized, settings);
      expect(deserialized.enabled, true);
      expect(deserialized.dailyActivity, false);
      expect(deserialized.pucReminder, true);
      expect(deserialized.insuranceReminder, false);
      expect(deserialized.serviceReminder, true);
      expect(deserialized.oilChangeReminder, false);
    });

    test('fromMap with null/empty map uses safe defaults', () {
      final fromNull = NotificationSettings.fromMap(null);
      expect(fromNull, const NotificationSettings());

      final fromEmpty = NotificationSettings.fromMap({});
      expect(fromEmpty, const NotificationSettings());
    });
  });
}
