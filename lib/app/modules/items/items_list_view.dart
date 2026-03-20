import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../data/models/item_model.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/qr_label_export.dart';
import 'item_added_view.dart';
import 'items_controller.dart';

class ItemsListView extends GetView<ItemsController> {
  const ItemsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — switches between normal and selection mode
            Obx(() {
              if (controller.isSelecting.value) {
                return _buildSelectionHeader(context);
              }
              return _buildNormalHeader(context);
            }),
            const SizedBox(height: 12),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.t5),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            // Limit warning
            Obx(() {
              final svc = SupabaseService.to;
              final usage = svc.getResourceUsage('items');
              if (usage == null) return const SizedBox.shrink();
              final limit = usage['limit'];
              if (limit == null) return const SizedBox.shrink();
              final current = usage['current'] as int? ?? 0;
              final limitInt = limit as int;
              if (current < (limitInt * 0.8).ceil()) return const SizedBox.shrink();
              final atLimit = current >= limitInt;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: atLimit ? AppColors.reBg : AppColors.amBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: atLimit ? AppColors.reBorder : AppColors.amBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        atLimit ? Icons.block : Icons.warning_amber_rounded,
                        size: 16,
                        color: atLimit ? AppColors.reText : AppColors.amText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          atLimit
                              ? 'Item limit reached ($current/$limitInt). Upgrade to add more.'
                              : 'Approaching item limit ($current/$limitInt)',
                          style: AppTextStyles.caption.copyWith(
                            color: atLimit ? AppColors.reText : AppColors.amText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Status filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All', ''),
                  _buildFilterChip('Storage', 'storage'),
                  _buildFilterChip('In Project', 'in_project'),
                  _buildFilterChip('Missing', 'missing'),
                  _buildFilterChip('Repair', 'under_repair'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Items list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerList();
                }
                if (controller.hasError.value) {
                  return ErrorState(
                    message: "Couldn't load items",
                    onRetry: controller.loadItems,
                  );
                }
                if (controller.filteredItems.isEmpty) {
                  final hasFilter = controller.searchQuery.value.isNotEmpty ||
                      controller.filterStatus.value.isNotEmpty;
                  if (hasFilter) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No matches',
                      subtitle: 'Try a different search or filter',
                    );
                  }
                  if (SupabaseService.to.isAdmin) {
                    return EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No items yet',
                      subtitle: 'Add your first item to get started',
                      actionLabel: 'Add Item',
                      onAction: () => _showAddItemSheet(context),
                    );
                  }
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No items yet',
                    subtitle: 'Ask an admin to add items',
                  );
                }
                final selecting = controller.isSelecting.value;
                return RefreshIndicator(
                  onRefresh: controller.loadItems,
                  color: AppColors.acc,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredItems[index];
                      final isSelected = controller.selectedIds.contains(item.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: selecting
                              ? () => controller.toggleSelected(item.id)
                              : () => Get.toNamed('/items/${item.id}'),
                          onLongPress: selecting
                              ? null
                              : () {
                                  controller.isSelecting.value = true;
                                  controller.toggleSelected(item.id);
                                },
                          child: GlassCard(
                            borderColor: isSelected ? AppColors.accBorder : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Leading: checkbox or number badge
                                  selecting
                                      ? _buildSelectionCheckbox(isSelected)
                                      : _buildItemLeading(item),
                                  const SizedBox(width: 12),
                                  // Name + subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: AppTextStyles.itemName),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.displayStatus + (item.projectName != null ? ' \u2022 ${item.projectName}' : ''),
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status pill (hidden in selection mode)
                                  if (!selecting) ...[
                                    const SizedBox(width: 8),
                                    _buildStatusPill(item),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Items', style: AppTextStyles.screenTitle),
          Obx(() {
            if (!SupabaseService.to.isAdmin) return const SizedBox.shrink();
            final limitReached = SupabaseService.to.isLimitReached('items');
            return Tooltip(
              message: limitReached ? 'Item limit reached. Upgrade your plan.' : '',
              child: GestureDetector(
                onTap: limitReached ? null : () => _showAddItemSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: limitReached
                        ? AppColors.surface2
                        : AppColors.accBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: limitReached
                          ? AppColors.border1
                          : AppColors.accBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(Icons.add,
                    color: limitReached ? AppColors.t4 : AppColors.acc,
                    size: 20,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.toggleSelecting,
            child: const Icon(Icons.close, color: AppColors.t1, size: 24),
          ),
          const SizedBox(width: 12),
          Obx(() => Text(
                '${controller.selectedIds.length} selected',
                style: AppTextStyles.cardTitle,
              )),
          const Spacer(),
          Obx(() {
            if (controller.selectedIds.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _printSelectedLabels(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code, color: AppColors.acc, size: 16),
                    const SizedBox(width: 6),
                    Text('Print labels',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.acc)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemLeading(ItemModel item) {
    final badge = AppColors.statusBadge(item.status);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badge.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badge.border,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '#${item.itemNumber}',
          style: AppTextStyles.micro.copyWith(color: AppColors.accText),
        ),
      ),
    );
  }

  Widget _buildStatusPill(ItemModel item) {
    final badge = AppColors.statusBadge(item.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: badge.bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: badge.border,
          width: 0.5,
        ),
      ),
      child: Text(
        item.displayStatus,
        style: AppTextStyles.micro.copyWith(color: badge.text),
      ),
    );
  }

  Widget _buildSelectionCheckbox(bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accBg : AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.accBorder : AppColors.border1,
          width: 0.5,
        ),
      ),
      child: Center(
        child: isSelected
            ? const Icon(Icons.check, color: AppColors.acc, size: 20)
            : null,
      ),
    );
  }

  Future<void> _printSelectedLabels(BuildContext context) async {
    var selected = controller.selectedItems;
    if (selected.length > 20) {
      Get.snackbar(
        'Limit',
        'Maximum 20 labels per export. First 20 selected will be used.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.amText,
      );
      selected = selected.take(20).toList();
    }
    await shareBulkQrLabels(selected);
    controller.toggleSelecting();
  }

  Widget _buildFilterChip(String label, String status) {
    return Obx(() {
      final isActive = controller.filterStatus.value == status;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => controller.setFilterStatus(status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accBg : AppColors.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? AppColors.acc : AppColors.border1,
                width: 0.5,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.micro.copyWith(
                color: isActive ? AppColors.accText : AppColors.t4,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showAddItemSheet(BuildContext context) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    final isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Item', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Create a new item to track',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: AppTextStyles.body,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g. Drill, Safety Harness',
                labelStyle: AppTextStyles.caption,
                hintStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.t4),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.acc, width: 1),
                ),
                filled: true,
                fillColor: AppColors.surface2,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: AppTextStyles.body,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                labelStyle: AppTextStyles.caption,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.acc, width: 1),
                ),
                filled: true,
                fillColor: AppColors.surface2,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => Material(
              color: AppColors.acc,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: isSubmitting.value
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        isSubmitting.value = true;
                        final item = await controller.createItem(
                          name,
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );
                        isSubmitting.value = false;
                        if (context.mounted) Navigator.of(context).pop();
                        if (item != null) {
                          Get.to(() => ItemAddedView(item: item));
                        }
                      },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Create Item',
                            style: AppTextStyles.button),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
