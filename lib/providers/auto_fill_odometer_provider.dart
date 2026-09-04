import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages the auto-fill current odometer setting as reactive, persistent Riverpod state.
class AutoFillOdometerNotifier extends StateNotifier<bool> {
  AutoFillOdometerNotifier(this._repository)
      : super(_repository.getAutoFillCurrentOdometer());

  final AppSettingsRepository _repository;

  /// Updates and persists the auto-fill setting.
  Future<void> setAutoFillOdometer(bool enabled) async {
    if (state == enabled) return;
    await _repository.saveAutoFillCurrentOdometer(enabled);
    state = enabled;
  }
}

/// Exposes the current Auto-Fill Odometer setting as reactive state.
final autoFillOdometerProvider =
    StateNotifierProvider<AutoFillOdometerNotifier, bool>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return AutoFillOdometerNotifier(repository);
});
