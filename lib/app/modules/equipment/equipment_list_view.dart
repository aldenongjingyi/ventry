import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/equipment_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_list.dart';
import 'equipment_controller.dart';

class EquipmentListView extends GetView<EquipmentController> {
  const EquipmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Get.toNamed(AppRoutes.scan, arguments: {'mode': 'lookup'}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.onSearch('');
                        },
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),
          // Status filter chips
          SizedBox(
            height: 40,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'All',
                      count: controller.totalCount,
                      isSelected: controller.selectedStatus.value == 'all',
                      onTap: () => controller.onStatusFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'In Storage',
                      count: controller.inStorageCount,
                      isSelected: controller.selectedStatus.value == 'in-storage',
                      onTap: () => controller.onStatusFilter('in-storage'),
                      color: AppColors.inStorage,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Checked Out',
                      count: controller.checkedOutCount,
                      isSelected: controller.selectedStatus.value == 'checked-out',
                      onTap: () => controller.onStatusFilter('checked-out'),
                      color: AppColors.checkedOut,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Maintenance',
                      count: controller.maintenanceCount,
                      isSelected: controller.selectedStatus.value == 'maintenance',
                      onTap: () => controller.onStatusFilter('maintenance'),
                      color: AppColors.maintenance,
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 8),
          // Equipment list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ShimmerList();
              }

              if (controller.filteredEquipment.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'No results found'
                      : 'No equipment yet',
                  subtitle: controller.searchQuery.value.isNotEmpty
                      ? 'Try a different search term'
                      : 'Add equipment to get started',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadEquipment,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredEquipment.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = controller.filteredEquipment[index];
                    return EquipmentTile(
                      equipment: item,
                      onTap: () => Get.toNamed(
                        AppRoutes.equipmentDetail,
                        arguments: {'id': item.id},
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.glass : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(
                color: isSelected ? chipColor : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTextStyles.captionMedium.copyWith(
                color: isSelected ? chipColor : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
