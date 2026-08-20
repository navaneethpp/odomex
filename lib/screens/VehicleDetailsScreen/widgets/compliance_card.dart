import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/vehicle_status.dart';
import 'package:odomex/models/vehicle.dart';

/// Documents & Compliance card — shows Insurance and PUC status in a single
/// grouped card, including validity, provider, and expiry info.
class ComplianceCard extends StatelessWidget {
  final Vehicle vehicle;

  const ComplianceCard({super.key, required this.vehicle});

  static final _fmt = DateFormat('d MMMM yyyy');
  String _fmtDate(DateTime? d) => d != null ? _fmt.format(d) : '—';

  @override
  Widget build(BuildContext context) {
    final insuranceStatus = vehicle.hasInsurance
        ? calculateDocumentStatus(vehicle.insuranceEndDate)
        : DocumentStatus.notAvailable;

    final pucStatus = vehicle.hasPuc
        ? calculateDocumentStatus(vehicle.pucEndDate)
        : DocumentStatus.notAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insurance
            _DocumentBlock(
              icon: Icons.shield_outlined,
              title: 'Insurance',
              status: insuranceStatus,
              provider: vehicle.insuranceProvider,
              policyNumber: vehicle.insurancePolicyNumber,
              startDate: _fmtDate(vehicle.insuranceStartDate),
              endDate: _fmtDate(vehicle.insuranceEndDate),
              expiryDate: vehicle.insuranceEndDate,
            ),

            Divider(height: AppSizes.spacingXl),

            // PUC
            _DocumentBlock(
              icon: Icons.verified_outlined,
              title: 'PUC',
              status: pucStatus,
              provider: null,
              policyNumber: vehicle.pucCertificateNumber,
              policyNumberLabel: 'Certificate',
              startDate: _fmtDate(vehicle.pucStartDate),
              endDate: _fmtDate(vehicle.pucEndDate),
              expiryDate: vehicle.pucEndDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final DocumentStatus status;
  final String? provider;
  final String? policyNumber;
  final String? policyNumberLabel;
  final String startDate;
  final String endDate;
  final DateTime? expiryDate;

  const _DocumentBlock({
    required this.icon,
    required this.title,
    required this.status,
    required this.provider,
    required this.policyNumber,
    this.policyNumberLabel,
    required this.startDate,
    required this.endDate,
    this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = documentStatusColor(status, colorScheme);
    final isNotAvailable = status == DocumentStatus.notAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + status badge
        Row(
          children: [
            Icon(icon, size: AppSizes.iconSm, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSizes.spacingSm),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingXs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingXs),
                  Text(
                    documentStatusLabel(status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingMd),

        if (isNotAvailable)
          Text(
            'Not added',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          if (provider != null && provider!.isNotEmpty) ...[
            Text(
              provider!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXs),
          ],

          if (policyNumber != null && policyNumber!.isNotEmpty) ...[
            Text(
              '${policyNumberLabel ?? 'Policy'}: $policyNumber',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
          ],

          // Validity row
          Row(
            children: [
              Expanded(
                child: _DateChip(label: 'From', date: startDate),
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: _DateChip(
                  label: 'Until',
                  date: endDate,
                  highlight: expiryDate,
                  status: status,
                ),
              ),
            ],
          ),

          // Expiry countdown
          if (expiryDate != null &&
              status != DocumentStatus.active &&
              status != DocumentStatus.notAvailable) ...[
            const SizedBox(height: AppSizes.spacingSm),
            _ExpiryCountdown(expiryDate: expiryDate!, status: status),
          ],
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  final DateTime? highlight;
  final DocumentStatus? status;

  const _DateChip({
    required this.label,
    required this.date,
    this.highlight,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryCountdown extends StatelessWidget {
  final DateTime expiryDate;
  final DocumentStatus status;

  const _ExpiryCountdown({
    required this.expiryDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final days = daysUntilExpiry(expiryDate);
    final color = documentStatusColor(status, colorScheme);

    final String text;
    if (days < 0) {
      text = 'Expired ${-days} ${-days == 1 ? 'day' : 'days'} ago';
    } else if (days == 0) {
      text = 'Expires today';
    } else {
      text = 'Expires in $days ${days == 1 ? 'day' : 'days'}';
    }

    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: AppSizes.iconXs, color: color),
        const SizedBox(width: AppSizes.spacingXs),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
