import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/features/privacy/providers/privacy_consent_provider.dart';
import 'package:odomex/features/privacy/widgets/privacy_policy_content.dart';
import 'package:odomex/routes/app_routes.dart';

/// One-time Privacy Policy and Data Usage Consent screen.
///
/// Clearly informs the user about Odomex's local-first privacy model, what data
/// is stored on-device, and what is NOT collected or transmitted.
class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({
    super.key,
    this.isFirstLaunch = false,
    this.isPolicyUpdate = false,
    this.isViewOnly = false,
    this.targetRoute,
  });

  /// True if shown during the initial first-launch onboarding progression.
  final bool isFirstLaunch;

  /// True if shown because the Privacy Policy version was updated.
  final bool isPolicyUpdate;

  /// True if opened in view-only / informational mode.
  final bool isViewOnly;

  /// The route to navigate to upon acceptance (e.g. AppRoutes.addVehicle or AppRoutes.home).
  final String? targetRoute;

  @override
  ConsumerState<PrivacyConsentScreen> createState() =>
      _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  bool _isAccepting = false;

  Future<void> _handleAccept() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    // 1. Persist acceptance of the active policy version
    await ref.read(privacyConsentProvider.notifier).acceptPrivacyPolicy();

    // 2. Ensure onboarding is marked completed if part of first launch
    if (widget.isFirstLaunch) {
      await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    }

    if (!mounted) return;

    // 3. Navigate to target destination or pop
    if (widget.isViewOnly) {
      Navigator.pop(context);
    } else {
      final destination = widget.targetRoute ??
          (widget.isFirstLaunch ? AppRoutes.addVehicle : AppRoutes.home);
      Navigator.pushReplacementNamed(context, destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRequiredFlow = !widget.isViewOnly;

    String titleText = 'Your Privacy Matters';
    if (widget.isPolicyUpdate) {
      titleText = 'Updated Privacy Policy';
    }

    return PopScope(
      canPop: !isRequiredFlow,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: widget.isViewOnly
            ? AppBar(
                title: const Text('Privacy & Data'),
                leading: const BackButton(),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXl,
                    vertical: AppSizes.paddingLg,
                  ),
                  child: PrivacyPolicyContent(
                    titleText: titleText,
                  ),
                ),
              ),

              // Bottom Action Button (only for consent flow or acknowledge)
              if (isRequiredFlow)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXl,
                    vertical: AppSizes.paddingLg,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: AppSizes.borderWidth,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _isAccepting ? null : _handleAccept,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      child: _isAccepting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'I Understand & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

