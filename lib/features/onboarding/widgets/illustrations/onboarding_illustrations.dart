import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

// ─────────────────────────────────────────────
// PAGE 1: MEET YOUR VEHICLE
// ─────────────────────────────────────────────
class OnboardingVehicleJourneyIllustration extends StatelessWidget {
  const OnboardingVehicleJourneyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 240,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.15),
              colorScheme.primaryContainer.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Road line
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      colorScheme.primary.withValues(alpha: 0.4),
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating destination pill
            Positioned(
              top: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Every journey',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Vehicle Emblem Card
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: AppSizes.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.two_wheeler_rounded,
                  size: 52,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE 2: EVERY JOURNEY ADDS A STORY
// ─────────────────────────────────────────────
class OnboardingMetricsIllustration extends StatelessWidget {
  const OnboardingMetricsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 260,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center icon badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.route_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),

            // Metric Chip 1: Distance
            Positioned(
              top: 20,
              left: 10,
              child: _MetricBadge(
                icon: Icons.speed_rounded,
                label: '24 km',
                colorScheme: colorScheme,
              ),
            ),

            // Metric Chip 2: Fuel
            Positioned(
              top: 40,
              right: 15,
              child: _MetricBadge(
                icon: Icons.local_gas_station_rounded,
                label: '2.4 L',
                colorScheme: colorScheme,
              ),
            ),

            // Metric Chip 3: Expense
            Positioned(
              bottom: 30,
              left: 40,
              child: _MetricBadge(
                icon: Icons.currency_rupee_rounded,
                label: '₹252',
                colorScheme: colorScheme,
              ),
            ),

            // Metric Chip 4: Trips
            Positioned(
              bottom: 40,
              right: 25,
              child: _MetricBadge(
                icon: Icons.history_rounded,
                label: 'Refill #12',
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE 3: BUT IT'S EASY TO FORGET
// ─────────────────────────────────────────────
class OnboardingRemindersIllustration extends StatelessWidget {
  const OnboardingRemindersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 260,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center question badge
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 38,
                color: colorScheme.primary,
              ),
            ),

            // Floating query pills
            Positioned(
              top: 15,
              left: 15,
              child: _QueryPill(
                icon: Icons.oil_barrel_outlined,
                label: 'Oil change date?',
                colorScheme: colorScheme,
              ),
            ),

            Positioned(
              top: 55,
              right: 10,
              child: _QueryPill(
                icon: Icons.shield_outlined,
                label: 'Insurance expiry?',
                colorScheme: colorScheme,
              ),
            ),

            Positioned(
              bottom: 45,
              left: 20,
              child: _QueryPill(
                icon: Icons.verified_outlined,
                label: 'PUC renewal?',
                colorScheme: colorScheme,
              ),
            ),

            Positioned(
              bottom: 15,
              right: 20,
              child: _QueryPill(
                icon: Icons.receipt_long_outlined,
                label: 'Monthly fuel cost?',
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE 4: ODOMEX KEEPS IT ALL TOGETHER
// ─────────────────────────────────────────────
class OnboardingDashboardIllustration extends StatelessWidget {
  const OnboardingDashboardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 270,
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.speed_rounded,
                    title: '25,430 km',
                    subtitle: 'Current Odometer',
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.local_gas_station_rounded,
                    title: '₹2,450',
                    subtitle: 'Fuel This Month',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.build_circle_outlined,
                    title: 'Due in 420 km',
                    subtitle: 'Service',
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.shield_outlined,
                    title: '18 days left',
                    subtitle: 'Insurance',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE 5: YOUR VEHICLE IN CONTROL
// ─────────────────────────────────────────────
class OnboardingControlIllustration extends StatelessWidget {
  const OnboardingControlIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.18),
              colorScheme.primaryContainer.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 58,
                color: colorScheme.onPrimary,
              ),
            ),
            Positioned(
              bottom: 25,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Odomex Ready',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER PILLS & MINI CARDS
// ─────────────────────────────────────────────

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueryPill extends StatelessWidget {
  const _QueryPill({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMiniCard extends StatelessWidget {
  const _DashboardMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: AppSizes.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
