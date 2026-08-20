import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';

final vehiclePreferencesLocalDataSourceProvider =
    Provider<VehiclePreferencesLocalDataSource>((ref) {
  return HiveVehiclePreferencesLocalDataSource();
});

final vehiclePreferencesRepositoryProvider =
    Provider<VehiclePreferencesRepository>((ref) {
  final localDataSource = ref.watch(vehiclePreferencesLocalDataSourceProvider);
  return VehiclePreferencesRepository(localDataSource: localDataSource);
});

class VehiclePreferencesNotifier
    extends StateNotifier<Map<String, VehiclePreferences>> {
  VehiclePreferencesNotifier(this._repository, this._ref)
      : super(_repository.getAllPreferences());

  final VehiclePreferencesRepository _repository;
  final Ref _ref;

  /// Toggles the pinned status of [vehicleId], persists it, and immediately refreshes vehicle ordering.
  Future<bool> togglePin(String vehicleId) async {
    final current = state[vehicleId]?.isPinned ?? false;
    final newPinned = !current;
    final updated = VehiclePreferences(
      vehicleId: vehicleId,
      isPinned: newPinned,
    );

    await _repository.savePreference(updated);

    final newMap = Map<String, VehiclePreferences>.from(state);
    newMap[vehicleId] = updated;
    state = newMap;

    // Refresh vehicle list ordering in VehicleNotifier
    _ref.read(vehicleProvider.notifier).refreshWithPreferences(newMap);

    return newPinned;
  }

  /// Checks if [vehicleId] is currently pinned.
  bool isPinned(String vehicleId) {
    return state[vehicleId]?.isPinned ?? false;
  }
}

final vehiclePreferencesProvider = StateNotifierProvider<
    VehiclePreferencesNotifier, Map<String, VehiclePreferences>>((ref) {
  final repository = ref.watch(vehiclePreferencesRepositoryProvider);
  return VehiclePreferencesNotifier(repository, ref);
});

/// Reactively provides whether a specific vehicle is pinned.
final isVehiclePinnedProvider =
    Provider.family<bool, String>((ref, vehicleId) {
  final prefs = ref.watch(vehiclePreferencesProvider);
  return prefs[vehicleId]?.isPinned ?? false;
});
