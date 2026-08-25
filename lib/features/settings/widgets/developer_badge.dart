import 'package:flutter/material.dart';
import 'package:odomex/core/constants/app_constants.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact attribution badge crediting HexaKode with an optional website launcher.
class DeveloperBadge extends StatelessWidget {
  const DeveloperBadge({super.key});

  Future<void> _launchWebsite(BuildContext context) async {
    final uri = Uri.parse(AppConstants.developerWebsiteUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open ${AppConstants.developerWebsiteUrl}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open ${AppConstants.developerWebsiteUrl}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Developed by HexaKode. Open HexaKode website.',
      button: true,
      child: InkWell(
        onTap: () => _launchWebsite(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSm,
            vertical: AppSizes.paddingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Developed by',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm + 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HexaKode',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 12,
                      color: colorScheme.primary,
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
