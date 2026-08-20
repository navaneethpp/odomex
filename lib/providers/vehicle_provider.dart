import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_preferences/utils/vehicle_list_sorter.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';
import 'package:odomex/repositories/vehicle_preferences_repository.dart';
import 'package:odomex/repositories/vehicles_repository.dart';

// ─────────────────────────────────────────────
// DATA SOURCE & REPOSITORY PROVIDERS
// ─────────────────────────────────────────────

/// Provides the [VehicleLocalDataSource] backed by Hive.
final vehicleLocalDataSourceProvider = Provider<VehicleLocalDataSource>((ref) {
  return HiveVehicleLocalDataSource();
});

/// Provides the [VehiclesRepository] instance.
final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  final localDataSource = ref.watch(vehicleLocalDataSourceProvider);
  return VehiclesRepository(localDataSource: localDataSource);
});

// ─────────────────────────────────────────────
// VEHICLE STATE NOTIFIER
// ─────────────────────────────────────────────

/// Manages the application's vehicle list as immutable Riverpod state,
/// keeping vehicles sorted by:
///   1. Pinned status (pinned vehicles first)
///   2. Selected [VehicleSortOption] (Last Accessed or Alphabetical)
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  VehicleNotifier(
    this._repository,
    this._preferencesRepository,
    this._appSettingsRepository,
  ) : super([]) {
    _refresh();
  }

  final VehiclesRepository _repository;
  final VehiclePreferencesRepository _preferencesRepository;
  final AppSettingsRepository _appSettingsRepository;

  void _refresh() {
    final vehicles = _repository.getAll();
    final prefs = _preferencesRepository.getAllPreferences();
    final sortOption = _appSettingsRepository.getVehicleSortOption();
    state = VehicleListSorter.sort(
      vehicles: vehicles,
      sortOption: sortOption,
      preferences: prefs,
    );
  }

  /// Refreshes state with an explicitly updated preferences map.
  void refreshWithPreferences(Map<String, VehiclePreferences> prefs) {
    final vehicles = _repository.getAll();
    final sortOption = _appSettingsRepository.getVehicleSortOption();
    state = VehicleListSorter.sort(
      vehicles: vehicles,
      sortOption: sortOption,
      preferences: prefs,
    );
  }

  /// Refreshes state with an explicitly updated sort option.
  void refreshWithSortOption(VehicleSortOption sortOption) {
    final vehicles = _repository.getAll();
    final prefs = _preferencesRepository.getAllPreferences();
    state = VehicleListSorter.sort(
      vehicles: vehicles,
      sortOption: sortOption,
      preferences: prefs,
    );
  }

  /// Delegates to [VehicleListSorter.sort].
  static List<Vehicle> sort(
    List<Vehicle> vehicles,
    Map<String, VehiclePreferences> prefs, [
    VehicleSortOption sortOption = VehicleSortOption.lastAccessed,
  ]) {
    return VehicleListSorter.sort(
      vehicles: vehicles,
      sortOption: sortOption,
      preferences: prefs,
    );
  }

  // ─────────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────────

  /// Adds [vehicle] to the collection and returns its assigned [Vehicle.id].
  Future<String> addVehicle(Vehicle vehicle) async {
    await _repository.add(vehicle);
    _refresh();
    return vehicle.id;
  }

  /// Replaces the existing vehicle whose id matches [vehicle.id].
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repository.update(vehicle);
    _refresh();
  }

  /// Updates the vehicle's odometer reading if [newOdometer] is greater than current.
  Future<void> updateOdometerIfHigher(
      String vehicleId, double newOdometer) async {
    final index = state.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;
    final vehicle = state[index];
    if (newOdometer > vehicle.odometerReading) {
      final updated = vehicle.copyWith(odometerReading: newOdometer);
      await _repository.update(updated);
      _refresh();
    }
  }

  /// Removes the vehicle with [vehicleId] from the collection.
  Future<void> removeVehicle(String vehicleId) async {
    await _repository.delete(vehicleId);
    await _preferencesRepository.deletePreference(vehicleId);
    _refresh();
  }

  /// Records that the user opened the vehicle (e.g. via tap).
  void markVehicleAsAccessed(String vehicleId) {
    final index = state.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    final updated = state[index].copyWith(
      lastAccessedAt: DateTime.now(),
    );

    _repository.update(updated);
    _refresh();
  }
}

// ─────────────────────────────────────────────
// VEHICLE PROVIDERS
// ─────────────────────────────────────────────

final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, List<Vehicle>>((ref) {
  final repository = ref.watch(vehiclesRepositoryProvider);
  final preferencesRepository =
      ref.watch(vehiclePreferencesRepositoryProvider);
  final appSettingsRepository = ref.watch(appSettingsRepositoryProvider);
  return VehicleNotifier(
    repository,
    preferencesRepository,
    appSettingsRepository,
  );
});

final vehicleByIdProvider =
    Provider.family<Vehicle?, String>((ref, vehicleId) {
  final vehicles = ref.watch(vehicleProvider);
  for (final v in vehicles) {
    if (v.id == vehicleId) return v;
  }
  return null;
});
