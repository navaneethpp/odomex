import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/features/privacy/providers/privacy_consent_provider.dart';
import 'package:odomex/features/privacy/screens/privacy_consent_screen.dart';

import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';

/// Decides whether to display the First-Time Onboarding flow, Privacy Policy update
/// consent, or the Home Screen based on persisted state.
class AppStartupScreen extends ConsumerWidget {
  const AppStartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnboardingCompleted = ref.watch(onboardingCompletedProvider);
    final isPrivacyConsentAccepted =
        ref.watch(isPrivacyConsentAcceptedProvider);

    if (!isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    if (!isPrivacyConsentAccepted) {
      return const PrivacyConsentScreen(
        isPolicyUpdate: true,
        targetRoute: AppRoutes.home,
      );
    }


    return const HomeScreen();
  }
}

