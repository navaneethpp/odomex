import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/constants/app_constants.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/repositories/app_settings_repository.dart';

/// Manages Privacy Policy & Data Usage consent state and versioning.
class PrivacyConsentNotifier extends StateNotifier<String?> {
  PrivacyConsentNotifier(this._repository)
      : super(_repository.getPrivacyPolicyAcceptedVersion());

  final AppSettingsRepository _repository;

  /// Records and persists the user's acknowledgement of the Privacy Policy.
  ///
  /// Defaults to [AppConstants.currentPrivacyPolicyVersion] unless a specific
  /// version is explicitly provided.
  Future<void> acceptPrivacyPolicy({String? version}) async {
    final acceptedVersion = version ?? AppConstants.currentPrivacyPolicyVersion;
    await _repository.savePrivacyPolicyAcceptedVersion(acceptedVersion);
    state = acceptedVersion;
  }

  /// Whether the currently accepted version matches the active [AppConstants.currentPrivacyPolicyVersion].
  bool isAcceptedForCurrentVersion() {
    return state == AppConstants.currentPrivacyPolicyVersion;
  }
}

/// Provider exposing the currently accepted Privacy Policy version string, or null if unacknowledged.
final privacyConsentProvider =
    StateNotifierProvider<PrivacyConsentNotifier, String?>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return PrivacyConsentNotifier(repository);
});

/// Provider returning true if the user has accepted the CURRENT version of the Privacy Policy.
final isPrivacyConsentAcceptedProvider = Provider<bool>((ref) {
  final acceptedVersion = ref.watch(privacyConsentProvider);
  return acceptedVersion == AppConstants.currentPrivacyPolicyVersion;
});
