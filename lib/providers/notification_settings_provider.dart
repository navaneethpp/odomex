import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages application notification preferences as reactive, persistent Riverpod state.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier({
    required AppSettingsRepository repository,
    NotificationService? notificationService,
  })  : _repository = repository,
        _notificationService =
            notificationService ?? NotificationService.instance,
        super(repository.getNotificationSettings()) {
    _syncSchedules(state);
  }

  final AppSettingsRepository _repository;
  final NotificationService _notificationService;

  /// Synchronizes active notification schedules with the current [settings].
  Future<void> _syncSchedules(NotificationSettings settings) async {
    try {
      await _notificationService.syncDailyActivitySchedule(
        masterEnabled: settings.enabled,
        dailyActivityEnabled: settings.dailyActivity,
        hour: settings.dailyActivityReminderHour,
        minute: settings.dailyActivityReminderMinute,
      );
    } catch (e) {
      debugPrint('NotificationSettingsNotifier: Schedule sync failed: $e');
    }
  }

  /// Toggles the master notification switch.
  ///
  /// When enabling, requests OS permission. If denied, resets master to `false`
  /// and shows an informative snackbar without crashing.
  /// When disabling, individual category preferences and custom times are preserved.
  Future<bool> setMasterEnabled(
    bool enable, {
    BuildContext? context,
  }) async {
    if (!enable) {
      final updated = state.copyWith(enabled: false);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);
      return true;
    }

    // Request OS permission when user enables
    final granted = await _notificationService.requestPermission();
    if (granted) {
      final updated = state.copyWith(enabled: true);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);
      return true;
    } else {
      final updated = state.copyWith(enabled: false);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are disabled for Odomex. Enable them in your device settings.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Convenience alias for [setMasterEnabled].
  Future<bool> setNotificationsEnabled(
    bool enable, {
    BuildContext? context,
  }) =>
      setMasterEnabled(enable, context: context);

  /// Toggles an individual notification category preference.
  Future<void> setCategoryEnabled(
    NotificationCategory category,
    bool isEnabled,
  ) async {
    final updated = state.copyWithCategory(category, isEnabled);
    await _repository.saveNotificationSettings(updated);
    state = updated;
    await _syncSchedules(updated);
  }

  /// Sets the daily activity reminder time and updates the schedule if active.
  Future<void> setDailyActivityTime(TimeOfDay time) async {
    if (state.dailyActivityReminderHour == time.hour &&
        state.dailyActivityReminderMinute == time.minute) {
      return;
    }

    final updated = state.copyWith(
      dailyActivityReminderHour: time.hour,
      dailyActivityReminderMinute: time.minute,
    );
    await _repository.saveNotificationSettings(updated);
    state = updated;
    await _syncSchedules(updated);
  }

  /// Triggers a test notification if master notifications are enabled.
  ///
  /// If notifications are disabled or permission is missing, shows user feedback.
  Future<void> sendTestNotification(BuildContext context) async {
    if (!state.enabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable notifications first.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final hasPermission = await _notificationService.areNotificationsEnabled();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are disabled for Odomex. Enable them in your device settings.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await _notificationService.showTestNotification();
  }
}

/// Exposes the [NotificationService] instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Exposes current [NotificationSettings] as reactive state.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(
    repository: repository,
    notificationService: notificationService,
  );
});
