import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(
        condition[0].toUpperCase() + condition.substring(1),
        style: AppTextStyles.captionMedium.copyWith(color: _color),
      ),
    );
  }

  Color get _color {
    switch (condition) {
      case 'excellent':
        return AppColors.conditionExcellent;
      case 'good':
        return AppColors.conditionGood;
      case 'fair':
        return AppColors.conditionFair;
      case 'poor':
        return AppColors.conditionPoor;
      case 'damaged':
        return AppColors.conditionDamaged;
      default:
        return AppColors.textSecondary;
    }
  }
}
