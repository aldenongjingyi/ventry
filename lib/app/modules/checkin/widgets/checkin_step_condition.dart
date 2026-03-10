import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../checkin_controller.dart';

class CheckinStepCondition extends GetView<CheckinController> {
  const CheckinStepCondition({super.key});

  static const _conditions = [
    ('excellent', 'Excellent', AppColors.conditionExcellent),
    ('good', 'Good', AppColors.conditionGood),
    ('fair', 'Fair', AppColors.conditionFair),
    ('poor', 'Poor', AppColors.conditionPoor),
    ('damaged', 'Damaged', AppColors.conditionDamaged),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.selectedAssignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final assignment = controller.selectedAssignments[index];
            final currentCondition = controller.getCondition(assignment.id);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.equipmentName ?? 'Unknown',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _conditions.map((c) {
                      final (value, label, color) = c;
                      final isSelected = currentCondition == value;
                      return GestureDetector(
                        onTap: () =>
                            controller.setCondition(assignment.id, value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? color : AppColors.glassBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: AppTextStyles.captionMedium.copyWith(
                              color: isSelected ? color : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
