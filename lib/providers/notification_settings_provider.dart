import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/features/settings/models/notification_permission_state.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages active OS notification permissions as reactive Riverpod state.
class NotificationPermissionNotifier
    extends StateNotifier<NotificationPermissionState> {
  NotificationPermissionNotifier({
    NotificationService? notificationService,
  })  : _notificationService =
            notificationService ?? NotificationService.instance,
        super(const NotificationPermissionState()) {
    refresh();
  }

  final NotificationService _notificationService;

  /// Re-queries the actual OS-level notification permission and alarm capability.
  Future<NotificationPermissionState> refresh() async {
    final permissions = await _notificationService.checkPermissions();
    state = permissions;
    debugPrint(
        '[Notifications] Permission refreshed: notificationGranted=${permissions.notificationGranted}');
    return permissions;
  }
}

/// Exposes the [NotificationService] instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Exposes the reactive OS-level notification permission state.
final notificationPermissionProvider = StateNotifierProvider<
    NotificationPermissionNotifier, NotificationPermissionState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationPermissionNotifier(notificationService: service);
});

/// Computes whether notifications are fully operational (User preference ON and OS permission GRANTED).
final isNotificationOperationalProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  final permission = ref.watch(notificationPermissionProvider);
  return settings.enabled && permission.notificationGranted;
});

/// Manages application notification preferences as reactive, persistent Riverpod state.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier({
    required AppSettingsRepository repository,
    NotificationService? notificationService,
    this._permissionNotifier,
  })  : _repository = repository,
        _notificationService =
            notificationService ?? NotificationService.instance,
        super(repository.getNotificationSettings()) {
    refreshPermissionAndSchedules();
  }

  final AppSettingsRepository _repository;
  final NotificationService _notificationService;
  final NotificationPermissionNotifier? _permissionNotifier;

  /// Synchronizes active notification schedules with the current [settings] and real OS permission.
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

  /// Re-evaluates actual OS permissions and re-synchronizes active schedules.
  ///
  /// Typically invoked on app startup and when returning from background (`AppLifecycleState.resumed`).
  Future<void> refreshPermissionAndSchedules() async {
    final permission = await _notificationService.checkPermissions();
    _permissionNotifier?.state = permission;

    if (state.enabled && permission.notificationGranted) {
      await _syncSchedules(state);
    } else {
      await _notificationService.cancel(1100); // Daily activity ID
    }
  }

  /// Toggles the master notification switch.
  ///
  /// When enabling, checks/requests OS permission. If denied, leaves setting disabled
  /// and shows informative feedback without assuming permission was granted.
  Future<bool> setMasterEnabled(
    bool enable, {
    BuildContext? context,
  }) async {
    if (!enable) {
      final updated = state.copyWith(enabled: false);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);
      await _permissionNotifier?.refresh();
      return true;
    }

    // 1. Check current OS permission
    bool isGranted = await _notificationService.areNotificationsEnabled();

    // 2. Request permission if not currently granted
    if (!isGranted) {
      isGranted = await _notificationService.requestPermission();
      // Re-query actual OS state
      isGranted = await _notificationService.areNotificationsEnabled();
    }

    await _permissionNotifier?.refresh();

    if (isGranted) {
      final updated = state.copyWith(enabled: true);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);
      return true;
    } else {
      // Permission was NOT granted - do NOT mark as enabled
      final updated = state.copyWith(enabled: false);
      await _repository.saveNotificationSettings(updated);
      state = updated;
      await _syncSchedules(updated);

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission is required to enable reminders. Please enable it in device settings.',
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

  /// Triggers a test notification if notifications are enabled and permission is granted.
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
              'Notifications are disabled for Odomex in device settings.',
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

/// Exposes current [NotificationSettings] as reactive state.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final permissionNotifier = ref.watch(notificationPermissionProvider.notifier);
  return NotificationSettingsNotifier(
    repository: repository,
    notificationService: notificationService,
    permissionNotifier: permissionNotifier,
  );
});
