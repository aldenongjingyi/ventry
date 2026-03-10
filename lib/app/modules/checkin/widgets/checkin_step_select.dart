import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../data/models/equipment_model.dart';
import '../../../widgets/empty_state.dart';
import '../checkin_controller.dart';

class CheckinStepSelect extends GetView<CheckinController> {
  const CheckinStepSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Get.toNamed(
                AppRoutes.scan,
                arguments: {'mode': 'checkin-add'},
              );
              if (result is EquipmentModel) {
                final assignment = controller.activeAssignments
                    .firstWhereOrNull((a) => a.equipmentId == result.id);
                if (assignment != null) {
                  controller.toggleAssignment(assignment);
                }
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan to Return'),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.activeAssignments.isEmpty) {
              return const EmptyState(
                icon: Icons.input_rounded,
                title: 'No items to check in',
                subtitle: 'All equipment is in storage',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.activeAssignments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final assignment = controller.activeAssignments[index];
                final isSelected =
                    controller.isAssignmentSelected(assignment.id);
                return InkWell(
                  onTap: () => controller.toggleAssignment(assignment),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.glass
                          : AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.glassBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.checkedOut, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.equipmentName ?? 'Unknown',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                '${assignment.projectName ?? 'No project'} - Since ${DateFormat.MMMd().format(assignment.checkedOutAt)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              controller.toggleAssignment(assignment),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
