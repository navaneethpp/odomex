import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// A reusable card that wraps a form section with a titled header and
/// consistent padding/spacing. Used in the Add Vehicle form to visually
/// separate sections (Vehicle Info, Engine, Insurance, etc.).
class FormSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // Render children with consistent vertical spacing between them.
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const SizedBox(height: AppSizes.spacingMd),
            ],
          ],
        ),
      ),
    );
  }
}
