import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../checkout_controller.dart';

class CheckoutStepReview extends GetView<CheckoutController> {
  const CheckoutStepReview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Checkout Summary', style: AppTextStyles.subtitle),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      label: 'Items',
                      value: '${controller.selectedItems.length} equipment',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Project',
                      value: controller.selectedProject.value?.name ?? '-',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Assigned to',
                      value: controller.selectedMember.value?.fullName ?? '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Items list
              Text('Items', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),
              ...controller.selectedItems.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppTextStyles.bodyMedium),
                              if (item.barcode != null)
                                Text(item.barcode!, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.error, size: 20),
                          onPressed: () => controller.toggleItem(item),
                        ),
                      ],
                    ),
                  )),

              // Notes
              const SizedBox(height: 24),
              Text('Notes (optional)', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => controller.notes.value = v,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any notes about this checkout...',
                ),
              ),
            ],
          )),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
