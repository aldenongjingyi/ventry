import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/equipment_tile.dart';
import '../../../data/models/equipment_model.dart';
import '../checkout_controller.dart';

class CheckoutStepItems extends GetView<CheckoutController> {
  const CheckoutStepItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scan button
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Get.toNamed(
                AppRoutes.scan,
                arguments: {'mode': 'checkout-add'},
              );
              if (result is EquipmentModel) {
                controller.addScannedItem(result);
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan to Add'),
          ),
        ),
        // Selected items header
        Obx(() => controller.selectedItems.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Selected (${controller.selectedItems.length})',
                      style: AppTextStyles.subtitle,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => controller.selectedItems.clear(),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),
        // Equipment list
        Expanded(
          child: Obx(() => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableEquipment.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = controller.availableEquipment[index];
                  final isSelected = controller.isItemSelected(item.id);
                  return EquipmentTile(
                    equipment: item,
                    onTap: () => controller.toggleItem(item),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => controller.toggleItem(item),
                      activeColor: AppColors.primary,
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }
}
