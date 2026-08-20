import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/features/settings/widgets/theme_mode_selection_sheet.dart';
import 'package:odomex/providers/theme_provider.dart';

/// Settings tile row displaying the active theme mode and opening the selection sheet.
class AppearanceSettingTile extends ConsumerWidget {
  const AppearanceSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentMode = ref.watch(appThemeModeProvider);

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () => ThemeModeSelectionSheet.show(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Semantics(
          label: 'Appearance. Current selection: ${currentMode.displayName}. Tap to change.',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Row(
              children: [
                // Theme icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    currentMode.icon,
                    color: colorScheme.primary,
                    size: AppSizes.iconMd,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingMd),

                // Title & current mode
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentMode.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSizes.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
