import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/condition_badge.dart';
import '../../widgets/shimmer_list.dart';
import 'equipment_controller.dart';

class EquipmentDetailView extends GetView<EquipmentController> {
  const EquipmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;

    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadEquipmentDetail(id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const ShimmerList(itemCount: 3);
        }

        final eq = controller.selectedEquipment.value;
        if (eq == null) {
          return const Center(child: Text('Equipment not found'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadEquipmentDetail(id!),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
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
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.glass,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eq.name, style: AppTextStyles.h3),
                                if (eq.categoryName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(eq.categoryName!, style: AppTextStyles.caption),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          StatusBadge(status: eq.status),
                          const SizedBox(width: 8),
                          ConditionBadge(condition: eq.condition),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info section
                _buildInfoCard([
                  if (eq.barcode != null)
                    _InfoRow(label: 'Barcode', value: eq.barcode!),
                  if (eq.serialNumber != null)
                    _InfoRow(label: 'Serial Number', value: eq.serialNumber!),
                  if (eq.purchaseDate != null)
                    _InfoRow(
                      label: 'Purchase Date',
                      value: DateFormat.yMMMd().format(eq.purchaseDate!),
                    ),
                  if (eq.purchasePrice != null)
                    _InfoRow(
                      label: 'Purchase Price',
                      value: NumberFormat.currency(symbol: '\$').format(eq.purchasePrice),
                    ),
                ]),

                if (eq.notes != null && eq.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard([_InfoRow(label: 'Notes', value: eq.notes!)]),
                ],

                // Action buttons
                if (eq.isAvailable) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.checkout),
                    icon: const Icon(Icons.output_rounded),
                    label: const Text('Check Out'),
                  ),
                ],
                if (eq.isCheckedOut) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.checkin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    icon: const Icon(Icons.input_rounded),
                    label: const Text('Check In'),
                  ),
                ],

                // Assignment history
                const SizedBox(height: 24),
                Text('History', style: AppTextStyles.subtitle),
                const SizedBox(height: 12),
                ...controller.equipmentHistory.map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            a.isActive ? Icons.output_rounded : Icons.input_rounded,
                            color: a.isActive ? AppColors.checkedOut : AppColors.inStorage,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.isActive ? 'Checked out' : 'Returned',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  '${a.checkedOutByName ?? 'Unknown'} ${a.projectName != null ? '- ${a.projectName}' : ''}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat.MMMd().format(a.checkedOutAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: rows.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(r.label, style: AppTextStyles.caption),
              ),
              Expanded(
                child: Text(r.value, style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}
