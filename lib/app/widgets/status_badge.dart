import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _label,
        style: (small ? AppTextStyles.overline : AppTextStyles.captionMedium)
            .copyWith(color: _color),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case 'in-storage':
        return AppColors.inStorage;
      case 'checked-out':
        return AppColors.checkedOut;
      case 'maintenance':
        return AppColors.maintenance;
      case 'retired':
        return AppColors.retired;
      case 'active':
        return AppColors.success;
      case 'planning':
        return AppColors.info;
      case 'completed':
        return AppColors.textTertiary;
      case 'archived':
        return AppColors.retired;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status) {
      case 'in-storage':
        return 'In Storage';
      case 'checked-out':
        return 'Checked Out';
      case 'maintenance':
        return 'Maintenance';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }
}
