import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages first-time onboarding completion state.
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._repository)
      : super(_repository.isOnboardingCompleted());

  final AppSettingsRepository _repository;

  /// Marks onboarding as completed and persists to local storage.
  Future<void> completeOnboarding() async {
    await _repository.setOnboardingCompleted(true);
    state = true;
  }
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return OnboardingNotifier(repository);
});
