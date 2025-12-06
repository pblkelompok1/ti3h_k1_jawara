import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

enum StatusType {
  success,
  approved,
  active,
  completed,
  pending,
  warning,
  error,
  rejected,
  inactive,
  info,
  inProgress,
  neutral,
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool small;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
    this.small = false,
  });

  Color _getColor(BuildContext context) {
    switch (type) {
      case StatusType.success:
      case StatusType.approved:
      case StatusType.active:
      case StatusType.completed:
        return const Color(0xFF4CAF50);
      case StatusType.pending:
      case StatusType.warning:
        return const Color(0xFFFF9800);
      case StatusType.error:
      case StatusType.rejected:
      case StatusType.inactive:
        return AppColors.redAccent(context);
      case StatusType.info:
      case StatusType.inProgress:
        return const Color(0xFF2196F3);
      case StatusType.neutral:
        return AppColors.textSecondary(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Helper function to get status type from string
StatusType getStatusType(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'active':
      return StatusType.approved;
    case 'pending':
      return StatusType.pending;
    case 'rejected':
    case 'inactive':
      return StatusType.rejected;
    case 'completed':
    case 'ready':
      return StatusType.completed;
    case 'in_progress':
    case 'processing':
      return StatusType.inProgress;
    case 'new':
      return StatusType.info;
    default:
      return StatusType.neutral;
  }
}
