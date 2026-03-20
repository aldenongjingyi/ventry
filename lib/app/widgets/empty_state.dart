import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gold_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container — 44x44, surface3, border2, 12px radius
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
              child: Icon(icon, size: 20, color: AppColors.t5),
            ),
            const SizedBox(height: 16),
            // Heading — 15px/w600
            Text(
              title,
              style: AppTextStyles.itemName.copyWith(color: AppColors.t1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtext — 13px/w400, line height 1.5
            Text(
              subtitle,
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.t4,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: GoldButton(
                  onPressed: onAction,
                  label: actionLabel!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
