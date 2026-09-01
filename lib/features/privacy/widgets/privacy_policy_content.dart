import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Reusable, presentation-only widget containing the authoritative Odomex
/// Privacy Policy and Data Usage summary.
///
/// Decoupled from state management, onboarding logic, and navigation so it can
/// be embedded both in the first-launch consent flow and in-app settings dialogs.
class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({
    super.key,
    this.showHeader = true,
    this.titleText = 'Your Privacy Matters',
    this.subtitleText =
        'Odomex is designed with your privacy in mind. Here is a clear summary of how your information is handled.',
  });

  /// Whether to display the top shield badge and title/subtitle.
  final bool showHeader;

  /// Header title text (e.g. 'Your Privacy Matters' or 'Updated Privacy Policy').
  final String titleText;

  /// Header subtitle text.
  final String subtitleText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
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
              subtitleText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingXl),
        ],

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
      ],
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
