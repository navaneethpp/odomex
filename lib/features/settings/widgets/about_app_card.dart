import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Card displaying application identity, dynamic version, and core description.
class AboutAppCard extends StatefulWidget {
  const AboutAppCard({super.key});

  @override
  State<AboutAppCard> createState() => _AboutAppCardState();
}

class _AboutAppCardState extends State<AboutAppCard> {
  String _versionDisplay = 'Version 1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          final build = info.buildNumber.isNotEmpty ? ' (${info.buildNumber})' : '';
          _versionDisplay = 'Version ${info.version}$build';
        });
      }
    } catch (_) {
      // Fallback already assigned
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          children: [
            // App Logo Badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: AppSizes.borderWidth,
                ),
              ),
              child: Icon(
                Icons.speed_rounded,
                size: AppSizes.iconXl,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: AppSizes.spacingMd),

            // App Name
            Text(
              'Odomex',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 2),

            // Tagline
            Text(
              'Your vehicle, your journey.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppSizes.spacingSm),

            // Version Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingXs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: AppSizes.borderWidth,
                ),
              ),
              child: Text(
                _versionDisplay,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // Description
            Text(
              'Odomex helps you monitor your vehicle usage, track daily travel, manage fuel and maintenance records, and keep important vehicle reminders in one place.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
