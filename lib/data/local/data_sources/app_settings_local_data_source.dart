import 'package:hive_ce/hive.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';

/// Abstract data source for app-level settings and preferences.
abstract class AppSettingsLocalDataSource {
  /// Reads the saved theme preference, defaulting to [AppThemeMode.system].
  AppThemeMode getThemeMode();

  /// Persists [mode] into local storage.
  Future<void> saveThemeMode(AppThemeMode mode);

  /// Reads global vehicle maintenance defaults.
  GlobalVehicleSettings getGlobalVehicleSettings();

  /// Persists [settings] as the global vehicle defaults.
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings);

  /// Reads the saved vehicle list sorting preference.
  VehicleSortOption getVehicleSortOption();

  /// Persists [option] as the vehicle list sorting preference.
  Future<void> saveVehicleSortOption(VehicleSortOption option);

  /// Returns whether the first-time onboarding has been completed.
  bool isOnboardingCompleted();

  /// Persists onboarding completion status.
  Future<void> setOnboardingCompleted(bool completed);

  /// Returns whether local notifications are enabled by the user (default: false).
  bool getNotificationsEnabled();

  /// Persists notification preference into local storage.
  Future<void> saveNotificationsEnabled(bool enabled);

  /// Reads global notification preferences and category settings.
  NotificationSettings getNotificationSettings();

  /// Persists global notification preferences and category settings.
  Future<void> saveNotificationSettings(NotificationSettings settings);
}

/// Hive CE implementation of [AppSettingsLocalDataSource].
class HiveAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  HiveAppSettingsLocalDataSource({
    Box<dynamic>? settingsBox,
  }) : _customBox = settingsBox;

  final Box<dynamic>? _customBox;

  Box<dynamic>? get _settingsBox =>
      _customBox ??
      (Hive.isBoxOpen(HiveBoxes.appSettings)
          ? Hive.box<dynamic>(HiveBoxes.appSettings)
          : null);

  static const String _themeModeKey = 'theme_mode';
  static const String _globalVehicleSettingsKey = 'global_vehicle_settings';
  static const String _vehicleSortOptionKey = 'vehicle_sort_option';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationSettingsKey = 'notification_settings';

  @override
  AppThemeMode getThemeMode() {
    final box = _settingsBox;
    if (box == null) return AppThemeMode.system;

    final rawValue = box.get(_themeModeKey);
    if (rawValue is String) {
      return AppThemeModeExtension.fromStorageKey(rawValue);
    }
    return AppThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(_themeModeKey, mode.storageKey);
    }
  }

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() {
    final box = _settingsBox;
    if (box == null) return const GlobalVehicleSettings();

    final raw = box.get(_globalVehicleSettingsKey);
    if (raw is Map) {
      return GlobalVehicleSettings.fromMap(raw);
    }
    return const GlobalVehicleSettings();
  }

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(_globalVehicleSettingsKey, settings.toMap());
    }
  }

  @override
  VehicleSortOption getVehicleSortOption() {
    final box = _settingsBox;
    if (box == null) return VehicleSortOption.lastAccessed;

    final rawValue = box.get(_vehicleSortOptionKey);
    if (rawValue is String) {
      return VehicleSortOptionExtension.fromStorageKey(rawValue);
    }
    return VehicleSortOption.lastAccessed;
  }

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(_vehicleSortOptionKey, option.storageKey);
    }
  }

  @override
  bool isOnboardingCompleted() {
    final box = _settingsBox;
    if (box != null) {
      final val = box.get(_onboardingCompletedKey);
      if (val is bool) {
        return val;
      }
    }
    return false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(_onboardingCompletedKey, completed);
    }
  }

  @override
  bool getNotificationsEnabled() {
    return getNotificationSettings().enabled;
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final current = getNotificationSettings();
    await saveNotificationSettings(current.copyWith(enabled: enabled));
  }

  @override
  NotificationSettings getNotificationSettings() {
    final box = _settingsBox;
    if (box == null) return const NotificationSettings();

    final raw = box.get(_notificationSettingsKey);
    if (raw is Map) {
      return NotificationSettings.fromMap(raw);
    }

    final legacyEnabled = box.get(_notificationsEnabledKey);
    if (legacyEnabled is bool) {
      return NotificationSettings(enabled: legacyEnabled);
    }

    return const NotificationSettings();
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final box = _settingsBox;
    if (box != null) {
      await box.put(_notificationSettingsKey, settings.toMap());
      await box.put(_notificationsEnabledKey, settings.enabled);
    }
  }
}
