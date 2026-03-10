import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_list.dart';
import 'checkin_controller.dart';
import 'widgets/checkin_step_select.dart';
import 'widgets/checkin_step_condition.dart';

class CheckinView extends GetView<CheckinController> {
  const CheckinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerList();
        }

        return Column(
          children: [
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.glass,
                border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                children: [
                  _StepDot(
                    step: 1,
                    label: 'Select Items',
                    isActive: true,
                    isComplete: controller.currentStep.value > 0,
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: controller.currentStep.value > 0
                          ? AppColors.primary
                          : AppColors.glassBorder,
                    ),
                  ),
                  _StepDot(
                    step: 2,
                    label: 'Condition',
                    isActive: controller.currentStep.value >= 1,
                    isComplete: false,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: IndexedStack(
                index: controller.currentStep.value,
                children: const [
                  CheckinStepSelect(),
                  CheckinStepCondition(),
                ],
              ),
            ),
            // Bottom bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.glass,
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (controller.currentStep.value > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.prevStep,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: controller.currentStep.value == 1
                          ? ElevatedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : controller.canProceed
                                      ? controller.confirmCheckin
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                              ),
                              child: controller.isSubmitting.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Check In (${controller.selectedAssignments.length})',
                                    ),
                            )
                          : ElevatedButton(
                              onPressed:
                                  controller.canProceed ? controller.nextStep : null,
                              child: const Text('Continue'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isComplete;

  const _StepDot({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.glassBorder,
            ),
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isActive ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.captionMedium.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
