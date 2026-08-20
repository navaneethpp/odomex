import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/vehicle_status.dart';
import 'package:odomex/models/vehicle.dart';

/// Maintenance section card — groups oil change and service information
/// in a single grouped card. Shows both status-focused and raw date values.
class MaintenanceCard extends StatelessWidget {
  final Vehicle vehicle;

  const MaintenanceCard({super.key, required this.vehicle});

  static final _fmt = DateFormat('d MMMM yyyy');
  static final _numFmt = NumberFormat.decimalPattern('en_IN');

  String _fmtDate(DateTime? d) => d != null ? _fmt.format(d) : '—';

  String _relativeDate(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 0) return '$diff days ago';
    return 'In ${-diff} days';
  }

  @override
  Widget build(BuildContext context) {
    final hasOil = vehicle.hasOilChange;
    final hasService = vehicle.lastServiceDate != null ||
        vehicle.nextServiceOdometer != null;

    if (!hasOil && !hasService) {
      return _EmptyMaintenance();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Oil Change ──
            if (hasOil) ...[
              _buildOilChangeBlock(context),
            ],

            if (hasOil && hasService)
              Divider(height: AppSizes.spacingXl),

            // ── Service ──
            if (hasService) ...[
              _buildServiceBlock(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOilChangeBlock(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final next = vehicle.nextOilChangeOdometer;
    final remaining = next != null ? next - vehicle.odometerReading : null;
    final oilStatus = calculateOilChangeStatus(vehicle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(
          icon: Icons.oil_barrel_outlined,
          title: 'Oil Change',
        ),

        const SizedBox(height: AppSizes.spacingMd),

        // Next oil change
        if (next != null) ...[
          _DetailRow(
            label: 'Next at',
            value: '${_numFmt.format(next)} km',
          ),

          if (remaining != null) ...[
            const SizedBox(height: AppSizes.spacingSm),
            _DetailRow(
              label: remaining <= 0 ? 'Status' : 'Remaining',
              value: remaining <= 0
                  ? 'Due now'
                  : '${_numFmt.format(remaining)} km',
              valueColor: maintenanceStatusColor(oilStatus, colorScheme),
            ),
          ],

          const SizedBox(height: AppSizes.spacingSm),
        ],

        // Last oil change
        if (vehicle.lastOilChangeOdometer != null || vehicle.lastOilChangeDate != null)
          _DetailRow(
            label: 'Last at',
            value: [
              if (vehicle.lastOilChangeOdometer != null)
                '${_numFmt.format(vehicle.lastOilChangeOdometer!)} km',
              if (vehicle.lastOilChangeDate != null)
                _fmtDate(vehicle.lastOilChangeDate),
            ].join(' · '),
            secondary: _relativeDate(vehicle.lastOilChangeDate),
          ),

        if (vehicle.oilChangeInterval != null) ...[
          const SizedBox(height: AppSizes.spacingSm),
          _DetailRow(
            label: 'Interval',
            value: '${_numFmt.format(vehicle.oilChangeInterval!)} km',
          ),
        ],
      ],
    );
  }

  Widget _buildServiceBlock(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final next = vehicle.nextServiceOdometer;
    final remaining =
        next != null ? next - vehicle.odometerReading : null;
    final serviceStatus = calculateServiceStatus(vehicle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockTitle(
          icon: Icons.build_circle_outlined,
          title: 'Service',
        ),

        const SizedBox(height: AppSizes.spacingMd),

        if (next != null) ...[
          _DetailRow(
            label: 'Next at',
            value: '${_numFmt.format(next)} km',
          ),

          if (remaining != null) ...[
            const SizedBox(height: AppSizes.spacingSm),
            _DetailRow(
              label: remaining <= 0 ? 'Status' : 'Remaining',
              value: remaining <= 0
                  ? 'Due now'
                  : '${_numFmt.format(remaining)} km',
              valueColor: maintenanceStatusColor(serviceStatus, colorScheme),
            ),
          ],

          const SizedBox(height: AppSizes.spacingSm),
        ],

        if (vehicle.lastServiceDate != null)
          _DetailRow(
            label: 'Last service',
            value: _fmtDate(vehicle.lastServiceDate),
            secondary: _relativeDate(vehicle.lastServiceDate),
          ),
      ],
    );
  }
}

class _EmptyMaintenance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Row(
          children: [
            Icon(
              Icons.build_outlined,
              size: AppSizes.iconMd,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.spacingMd),
            Text(
              'No maintenance records added',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED INTERNAL WIDGETS
// ─────────────────────────────────────────────

class _BlockTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BlockTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.spacingSm),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? secondary;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.secondary,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
              if (secondary != null && secondary!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingXs),
                Text(
                  secondary!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
