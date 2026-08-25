import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';

/// Repository managing application-level preferences and settings.
///
/// Backed by an [AppSettingsLocalDataSource] (e.g. Hive).
class AppSettingsRepository {
  AppSettingsRepository({
    required this.localDataSource,
  });

  final AppSettingsLocalDataSource localDataSource;

  /// Returns the current stored theme mode preference.
  AppThemeMode getThemeMode() => localDataSource.getThemeMode();

  /// Persists the selected [mode].
  Future<void> saveThemeMode(AppThemeMode mode) =>
      localDataSource.saveThemeMode(mode);

  /// Returns global vehicle maintenance defaults.
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      localDataSource.getGlobalVehicleSettings();

  /// Persists global vehicle maintenance defaults.
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) =>
      localDataSource.saveGlobalVehicleSettings(settings);

  /// Returns the stored vehicle list sorting preference.
  VehicleSortOption getVehicleSortOption() =>
      localDataSource.getVehicleSortOption();

  /// Persists the selected vehicle list sorting preference.
  Future<void> saveVehicleSortOption(VehicleSortOption option) =>
      localDataSource.saveVehicleSortOption(option);

  /// Returns whether the onboarding flow has been completed.
  bool isOnboardingCompleted() => localDataSource.isOnboardingCompleted();

  /// Sets and persists onboarding completion status.
  Future<void> setOnboardingCompleted(bool completed) =>
      localDataSource.setOnboardingCompleted(completed);

  /// Returns whether local notifications are enabled by the user (default: false).
  bool getNotificationsEnabled() => localDataSource.getNotificationsEnabled();

  /// Persists notification preference.
  Future<void> saveNotificationsEnabled(bool enabled) =>
      localDataSource.saveNotificationsEnabled(enabled);

  /// Returns global notification preferences and category settings.
  NotificationSettings getNotificationSettings() =>
      localDataSource.getNotificationSettings();

  /// Persists global notification preferences and category settings.
  Future<void> saveNotificationSettings(NotificationSettings settings) =>
      localDataSource.saveNotificationSettings(settings);

  /// Returns the accepted Privacy Policy version, or null if not yet accepted.
  String? getPrivacyPolicyAcceptedVersion() =>
      localDataSource.getPrivacyPolicyAcceptedVersion();

  /// Persists the accepted Privacy Policy version string.
  Future<void> savePrivacyPolicyAcceptedVersion(String version) =>
      localDataSource.savePrivacyPolicyAcceptedVersion(version);
}
