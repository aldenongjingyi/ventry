import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/item_detail_content.dart';
import '../../data/services/supabase_service.dart';
import 'item_detail_controller.dart';

class ItemDetailView extends GetView<ItemDetailController> {
  const ItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.acc),
          );
        }
        if (controller.hasError.value) {
          return _buildErrorState(
            message: "Couldn't load item",
            action: 'Retry',
            onTap: controller.loadItem,
          );
        }
        final item = controller.item.value;
        if (item == null) {
          return _buildErrorState(
            message: 'This item no longer exists',
            action: 'Go back',
            onTap: () => Get.back(),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.t1),
                onPressed: () => Get.back(),
              ),
              actions: [
                if (SupabaseService.to.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.reText, size: 22),
                    onPressed: () => _confirmDelete(context),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Obx(() => ItemDetailContent(
                item: controller.item.value!,
                activities: controller.activities.toList(),
                onRelocated: controller.loadItem,
                onDelete: SupabaseService.to.isAdmin ? controller.deleteItem : null,
              )),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState({
    required String message,
    required String action,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.t5),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: AppTextStyles.itemName.copyWith(color: AppColors.t1)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: Text(action,
                    style: AppTextStyles.button.copyWith(color: AppColors.t2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface3,
        title: Text('Delete Item', style: AppTextStyles.cardTitle),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodySecondary.copyWith(color: AppColors.t3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteItem();
            },
            child: Text('Delete',
                style: AppTextStyles.bodySecondary.copyWith(color: AppColors.reText)),
          ),
        ],
      ),
    );
  }
}
