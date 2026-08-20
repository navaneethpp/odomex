import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

/// Provides the [AppSettingsLocalDataSource] backed by Hive.
final appSettingsLocalDataSourceProvider =
    Provider<AppSettingsLocalDataSource>((ref) {
  return HiveAppSettingsLocalDataSource();
});

/// Provides the [AppSettingsRepository] instance.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  final localDataSource = ref.watch(appSettingsLocalDataSourceProvider);
  return AppSettingsRepository(localDataSource: localDataSource);
});

// ─────────────────────────────────────────────
// THEME STATE NOTIFIER
// ─────────────────────────────────────────────

/// Manages the application theme mode as reactive, persistent Riverpod state.
class AppThemeNotifier extends StateNotifier<AppThemeMode> {
  AppThemeNotifier(this._repository)
      : super(_repository.getThemeMode());

  final AppSettingsRepository _repository;

  /// Updates and persists the selected [mode], immediately triggering an app-wide theme rebuild.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state == mode) return;
    await _repository.saveThemeMode(mode);
    state = mode;
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

/// Exposes the current [AppThemeMode] as reactive state.
final appThemeModeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeMode>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return AppThemeNotifier(repository);
});
