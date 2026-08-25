import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/onboarding/providers/onboarding_provider.dart';
import 'package:odomex/features/privacy/providers/privacy_consent_provider.dart';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: AppSizes.iconXl,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacingLg),

                      // Title
                      Center(
                        child: Text(
                          titleText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacingSm),

                      // Intro subtitle
                      Center(
                        child: Text(
                          'Odomex is designed with your privacy in mind. Here is a clear summary of how your information is handled.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacingXl),

                      // ── Section 1: Local Storage ──
                      _buildInfoCard(
                        context,
                        icon: Icons.phone_android_rounded,
                        iconColor: colorScheme.primary,
                        title: 'Stored Locally on Your Device',
                        description:
                            'Your vehicle information and activity records are stored locally on your device and are not transmitted to remote servers.',
                        items: const [
                          'Vehicle information (brand, model, year, registration)',
                          'Odometer readings & date logs',
                          'Fuel refueling records & costs',
                          'Service, maintenance & repair details',
                          'Insurance & PUC document dates',
                          'Oil change history & reminder intervals',
                          'Notification schedules & app preferences',
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacingLg),

                      // ── Section 2: What is NOT collected ──
                      _buildInfoCard(
                        context,
                        icon: Icons.verified_user_outlined,
                        iconColor: Colors.teal,
                        title: 'What We Don’t Collect',
                        description:
                            'Odomex does not sell your personal data or use your vehicle information for advertising or tracking.',
                        items: const [
                          'No advertising SDKs or third-party ad profiling',
                          'No background tracking or remote telemetry',
                          'No remote account or cloud database requirements',
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacingLg),

                      // ── Section 3: Data Safety & Uninstall Notice ──
                      _buildInfoCard(
                        context,
                        icon: Icons.info_outline_rounded,
                        iconColor: Colors.amber.shade800,
                        title: 'Device Data Notice',
                        description:
                            'Because your data is stored locally on your device, uninstalling Odomex or clearing application data may remove locally stored information unless your device’s backup system preserves it.',
                      ),

                      const SizedBox(height: AppSizes.spacingLg),
                    ],
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

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    List<String>? items,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: iconColor),
              const SizedBox(width: AppSizes.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (items != null && items.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingSm),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSizes.spacingXs,
                  left: AppSizes.spacingXs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
