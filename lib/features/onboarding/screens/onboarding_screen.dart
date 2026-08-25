import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/onboarding/data/onboarding_story_pages.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/features/onboarding/widgets/onboarding_page.dart';
import 'package:odomex/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:odomex/features/privacy/providers/privacy_consent_provider.dart';
import 'package:odomex/routes/app_routes.dart';

/// The 5-step story-driven first-time onboarding screen for Odomex.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleSkip() async {
    final isConsentAccepted = ref.read(isPrivacyConsentAcceptedProvider);
    if (!isConsentAccepted) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.privacyConsent,
          arguments: {
            'isFirstLaunch': true,
            'targetRoute': AppRoutes.home,
          },
        );
      }
    } else {
      await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  Future<void> _handleNext() async {
    if (_currentPage < onboardingPages.length - 1) {
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      if (reduceMotion) {
        _pageController.jumpToPage(_currentPage + 1);
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: AppDurations.defaultCurve,
        );
      }
    } else {
      // Final CTA: "Get Started"
      final isConsentAccepted = ref.read(isPrivacyConsentAcceptedProvider);
      if (!isConsentAccepted) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.privacyConsent,
            arguments: {
              'isFirstLaunch': true,
              'targetRoute': AppRoutes.addVehicle,
            },
          );
        }
      } else {
        await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.addVehicle);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          final reduceMotion = MediaQuery.of(context).disableAnimations;
          if (reduceMotion) {
            _pageController.jumpToPage(_currentPage - 1);
          } else {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: AppDurations.defaultCurve,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Top action bar (Skip button)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLg,
                ),
                alignment: Alignment.centerRight,
                child: isLastPage
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),

              // PageView content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: onboardingPages[index]);
                  },
                ),
              ),

              // Bottom Navigation & Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXl,
                  vertical: AppSizes.paddingLg,
                ),
                child: isLastPage
                    ? SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: _handleNext,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLg),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page Indicator
                          OnboardingPageIndicator(
                            itemCount: onboardingPages.length,
                            currentIndex: _currentPage,
                          ),

                          // Next Button
                          FilledButton(
                            onPressed: _handleNext,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingXl,
                                vertical: AppSizes.paddingMd,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusRound),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
