import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/data/insurance_provider_catalog.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Notifier that manages the custom insurance providers.
class CustomInsuranceProviderNotifier extends Notifier<List<String>> {
  late final AppSettingsRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(appSettingsRepositoryProvider);
    return _repository.getCustomInsuranceProviders();
  }

  /// Adds a custom insurance provider and updates state.
  Future<void> addCustomProvider(String provider) async {
    await _repository.addCustomInsuranceProvider(provider);
    state = _repository.getCustomInsuranceProviders();
  }
}

/// Provider for the [CustomInsuranceProviderNotifier].
final customInsuranceProviderProvider =
    NotifierProvider<CustomInsuranceProviderNotifier, List<String>>(
        CustomInsuranceProviderNotifier.new);

/// Provider that returns the combined list of built-in and custom providers,
/// sorted alphabetically and avoiding duplicates.
final allInsuranceProvidersProvider = Provider<List<String>>((ref) {
  final customProviders = ref.watch(customInsuranceProviderProvider);
  final builtInProviders = InsuranceProviderCatalog.builtInProviders;

  final allProvidersSet = <String>{...builtInProviders, ...customProviders};
  final allProviders = allProvidersSet.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return allProviders;
});
