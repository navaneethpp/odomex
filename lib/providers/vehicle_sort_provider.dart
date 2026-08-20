import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages and persists the user's vehicle list sorting preference.
class VehicleSortNotifier extends StateNotifier<VehicleSortOption> {
  VehicleSortNotifier(this._repository, this._ref)
      : super(_repository.getVehicleSortOption());

  final AppSettingsRepository _repository;
  final Ref _ref;

  /// Updates and persists the [option], and immediately triggers vehicle list re-sorting.
  Future<void> updateSortOption(VehicleSortOption option) async {
    await _repository.saveVehicleSortOption(option);
    state = option;

    _ref.read(vehicleProvider.notifier).refreshWithSortOption(option);
  }
}

final vehicleSortOptionProvider =
    StateNotifierProvider<VehicleSortNotifier, VehicleSortOption>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return VehicleSortNotifier(repository, ref);
});
