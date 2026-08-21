import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages the application notification enabled state as reactive, persistent Riverpod state.
class NotificationSettingsNotifier extends StateNotifier<bool> {
  NotificationSettingsNotifier({
    required AppSettingsRepository repository,
    NotificationService? notificationService,
  })  : _repository = repository,
        _notificationService = notificationService ?? NotificationService.instance,
        super(repository.getNotificationsEnabled());

  final AppSettingsRepository _repository;
  final NotificationService _notificationService;

  /// Toggles notifications on or off.
  ///
  /// When enabling, requests platform permission. If denied, resets state to `false`
  /// and shows an informative snackbar without crashing.
  Future<bool> setNotificationsEnabled(
    bool enable, {
    BuildContext? context,
  }) async {
    if (!enable) {
      await _repository.saveNotificationsEnabled(false);
      state = false;
      return true;
    }

    // Request OS permission when user enables
    final granted = await _notificationService.requestPermission();
    if (granted) {
      await _repository.saveNotificationsEnabled(true);
      state = true;
      return true;
    } else {
      await _repository.saveNotificationsEnabled(false);
      state = false;
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

  /// Triggers a test notification if notifications are enabled.
  ///
  /// If notifications are disabled or permission is missing, shows an explanation.
  Future<void> sendTestNotification(BuildContext context) async {
    if (!state) {
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

/// Exposes whether notifications are enabled as reactive state.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return NotificationSettingsNotifier(repository: repository);
});
