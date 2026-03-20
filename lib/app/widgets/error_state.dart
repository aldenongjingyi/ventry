import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container — 44x44, surface3 bg, border2 border, 12px radius
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: AppColors.t5,
              ),
            ),
            const SizedBox(height: 16),
            // Heading
            Text(
              'Connection error',
              style: AppTextStyles.itemName.copyWith(color: AppColors.t1),
            ),
            const SizedBox(height: 8),
            // Subtext
            Text(
              message,
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.t4,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Retry — secondary button
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyles.button.copyWith(color: AppColors.t2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
