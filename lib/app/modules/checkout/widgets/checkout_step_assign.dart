import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../checkout_controller.dart';

class CheckoutStepAssign extends GetView<CheckoutController> {
  const CheckoutStepAssign({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign to Project', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.projects.map((project) {
                  final isSelected =
                      controller.selectedProject.value?.id == project.id;
                  return ChoiceChip(
                    label: Text(project.name),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.selectedProject.value = project,
                    selectedColor: AppColors.primary.withValues(alpha: 0.12),
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 32),
          Text('Checked Out By', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: controller.teamMembers.map((member) {
                  final isSelected =
                      controller.selectedMember.value?.id == member.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () =>
                          controller.selectedMember.value = member,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.glass
                              : AppColors.glass,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.glassBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.glass,
                              child: Text(
                                member.initials,
                                style: AppTextStyles.captionMedium
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(member.fullName,
                                  style: AppTextStyles.bodyMedium),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}
