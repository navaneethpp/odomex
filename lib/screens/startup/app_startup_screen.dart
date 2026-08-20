import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';

/// Decides whether to display the First-Time Onboarding flow or the Home Screen
/// based on persisted onboarding completion state.
class AppStartupScreen extends ConsumerWidget {
  const AppStartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnboardingCompleted = ref.watch(onboardingCompletedProvider);

    if (!isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    return const HomeScreen();
  }
}
