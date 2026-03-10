import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_list.dart';
import 'checkout_controller.dart';
import 'widgets/checkout_step_items.dart';
import 'widgets/checkout_step_assign.dart';
import 'widgets/checkout_step_review.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out'),
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
            _StepIndicator(currentStep: controller.currentStep.value),
            // Step content
            Expanded(
              child: IndexedStack(
                index: controller.currentStep.value,
                children: const [
                  CheckoutStepItems(),
                  CheckoutStepAssign(),
                  CheckoutStepReview(),
                ],
              ),
            ),
            // Bottom bar
            _BottomBar(controller: controller),
          ],
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Select Items', 'Assign', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.glass,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= currentStep;
          final isComplete = i < currentStep;
          return Expanded(
            child: Row(
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
                            '${i + 1}',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: isActive ? Colors.white : AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    steps[i],
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isComplete ? AppColors.primary : AppColors.glassBorder,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final CheckoutController controller;

  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.glass,
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              if (controller.currentStep.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.prevStep,
                    child: const Text('Back'),
                  ),
                ),
              if (controller.currentStep.value > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: controller.currentStep.value == 2
                    ? ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.canProceedToStep3
                                ? controller.confirmCheckout
                                : null,
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
                                'Check Out (${controller.selectedItems.length})',
                              ),
                      )
                    : ElevatedButton(
                        onPressed: controller.currentStep.value == 0
                            ? (controller.canProceedToStep2
                                ? controller.nextStep
                                : null)
                            : (controller.canProceedToStep3
                                ? controller.nextStep
                                : null),
                        child: const Text('Continue'),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
