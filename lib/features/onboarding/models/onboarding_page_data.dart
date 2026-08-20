import 'package:flutter/material.dart';

/// Data model representing a single story screen in the onboarding flow.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.illustrationBuilder,
    this.primaryButtonText = 'Next',
  });

  final String title;
  final String description;
  final Widget Function(BuildContext context) illustrationBuilder;
  final String primaryButtonText;
}
