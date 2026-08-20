import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_colors.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// The hero odometer card — the single most important piece of information
/// on the Vehicle Details screen. Displayed prominently with a primary-color
/// gradient background.
class OdometerHeroCard extends StatelessWidget {
  final double odometerReading;

  const OdometerHeroCard({
    super.key,
    required this.odometerReading,
  });

  static final _numberFormat = NumberFormat.decimalPattern(
    'en_IN',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusXl,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.35,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXl,
        vertical: AppSizes.paddingXl,
      ),
      child: Column(
        children: [
          Text(
            'CURRENT ODOMETER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.white.withValues(
                alpha: 0.75,
              ),
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.spacingMd),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _numberFormat.format(odometerReading),
                style: theme.textTheme.displayMedium
                    ?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
              ),
              const SizedBox(width: AppSizes.spacingXs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'km',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                        color: AppColors.white.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
