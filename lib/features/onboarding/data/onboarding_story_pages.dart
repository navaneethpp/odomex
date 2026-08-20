import 'package:odomex/features/onboarding/models/onboarding_page_data.dart';
import 'package:odomex/features/onboarding/widgets/illustrations/onboarding_illustrations.dart';

/// The 5 story-driven onboarding pages for Odomex.
final List<OnboardingPageData> onboardingPages = [
  // Page 1
  OnboardingPageData(
    title: 'Meet your vehicle.',
    description:
        'It takes you to work, home, places you love, and everywhere in between.',
    illustrationBuilder: (context) =>
        const OnboardingVehicleJourneyIllustration(),
  ),

  // Page 2
  OnboardingPageData(
    title: 'Every journey adds a story.',
    description:
        'Every kilometre. Every litre. Every refill.\n\nLittle details that quickly add up.',
    illustrationBuilder: (context) => const OnboardingMetricsIllustration(),
  ),

  // Page 3
  OnboardingPageData(
    title: "But it's easy to forget.",
    description:
        'When was the last oil change?\nHow much did you spend on fuel?\nWhen does the insurance expire?\n\nIt’s all important. And easy to lose track of.',
    illustrationBuilder: (context) => const OnboardingRemindersIllustration(),
  ),

  // Page 4
  OnboardingPageData(
    title: 'Odomex keeps it all together.',
    description:
        'Track your journeys. Record your expenses. Remember your maintenance.\n\nEverything about your vehicle, in one place.',
    illustrationBuilder: (context) => const OnboardingDashboardIllustration(),
  ),

  // Page 5
  OnboardingPageData(
    title: 'Your vehicle.\nYour journey.\nYour records.',
    description: "Let's keep everything in one place.",
    illustrationBuilder: (context) => const OnboardingControlIllustration(),
    primaryButtonText: 'Get Started',
  ),
];
