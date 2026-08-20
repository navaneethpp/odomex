import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_settings_local_data_source.dart';
import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/utils/vehicle_settings_resolver.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';
import 'package:odomex/repositories/vehicle_settings_repository.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

final vehicleSettingsLocalDataSourceProvider =
    Provider<VehicleSettingsLocalDataSource>((ref) {
  return HiveVehicleSettingsLocalDataSource();
});

final vehicleSettingsRepositoryProvider =
    Provider<VehicleSettingsRepository>((ref) {
  final localDataSource = ref.watch(vehicleSettingsLocalDataSourceProvider);
  return VehicleSettingsRepository(localDataSource: localDataSource);
});

// ─────────────────────────────────────────────
// GLOBAL VEHICLE SETTINGS NOTIFIER & PROVIDER
// ─────────────────────────────────────────────

class GlobalVehicleSettingsNotifier
    extends StateNotifier<GlobalVehicleSettings> {
  GlobalVehicleSettingsNotifier(this._repository)
      : super(_repository.getGlobalVehicleSettings());

  final AppSettingsRepository _repository;

  /// Updates and persists the global vehicle maintenance defaults.
  Future<void> updateGlobalSettings(GlobalVehicleSettings updated) async {
    await _repository.saveGlobalVehicleSettings(updated);
    state = updated;
  }
}

final globalVehicleSettingsProvider = StateNotifierProvider<
    GlobalVehicleSettingsNotifier, GlobalVehicleSettings>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return GlobalVehicleSettingsNotifier(repository);
});

// ─────────────────────────────────────────────
// VEHICLE OVERRIDE SETTINGS NOTIFIER & PROVIDER
// ─────────────────────────────────────────────

class VehicleSettingsNotifier extends StateNotifier<VehicleSettings> {
  VehicleSettingsNotifier(this._repository, VehicleSettings initialSettings)
      : super(initialSettings);

  final VehicleSettingsRepository _repository;

  /// Updates and persists the vehicle-specific override configuration.
  Future<void> updateSettings(VehicleSettings updatedSettings) async {
    if (updatedSettings.isUsingAllDefaults) {
      await _repository.deleteSettings(updatedSettings.vehicleId);
    } else {
      await _repository.saveSettings(updatedSettings);
    }
    state = updatedSettings;
  }

  /// Clears all vehicle overrides so it cleanly uses global defaults.
  Future<void> resetToGlobalDefaults() async {
    await _repository.deleteSettings(state.vehicleId);
    state = VehicleSettings(vehicleId: state.vehicleId);
  }
}

/// Reactively provides the raw [VehicleSettings] overrides for [vehicleId].
final vehicleSettingsProvider = StateNotifierProvider.family<
    VehicleSettingsNotifier, VehicleSettings, String>((ref, vehicleId) {
  final repository = ref.watch(vehicleSettingsRepositoryProvider);
  final existing = repository.localDataSource.getSettings(vehicleId);

  final initialSettings = existing ?? VehicleSettings(vehicleId: vehicleId);
  return VehicleSettingsNotifier(repository, initialSettings);
});

// ─────────────────────────────────────────────
// EFFECTIVE VEHICLE SETTINGS RESOLVER PROVIDER
// ─────────────────────────────────────────────

/// Reactively resolves the final [EffectiveVehicleSettings] for [vehicleId],
/// dynamically inheriting from [globalVehicleSettingsProvider] and applying
/// any active overrides from [vehicleSettingsProvider].
final effectiveVehicleSettingsProvider =
    Provider.family<EffectiveVehicleSettings, String>((ref, vehicleId) {
  final globalSettings = ref.watch(globalVehicleSettingsProvider);
  final vehicleOverride = ref.watch(vehicleSettingsProvider(vehicleId));

  return VehicleSettingsResolver.resolve(
    global: globalSettings,
    vehicleOverride: vehicleOverride,
    vehicleId: vehicleId,
  );
});
