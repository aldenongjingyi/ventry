import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
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
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.standard,
        child: SafeArea(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 12,
                  child: TextField(
                    onChanged: controller.setSearchQuery,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (atLimit ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (atLimit ? AppColors.error : AppColors.warning).withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          atLimit ? Icons.block : Icons.warning_amber_rounded,
                          size: 16,
                          color: atLimit ? AppColors.error : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            atLimit
                                ? 'Item limit reached ($current/$limitInt). Upgrade to add more.'
                                : 'Approaching item limit ($current/$limitInt)',
                            style: AppTextStyles.caption.copyWith(
                              color: atLimit ? AppColors.error : AppColors.warning,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        final isSelected = controller.selectedIds.contains(item.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            borderColor: isSelected
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : null,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: selecting
                                  ? _buildSelectionCheckbox(isSelected)
                                  : _buildItemLeading(item),
                              title: Text(item.name, style: AppTextStyles.bodyMedium),
                              subtitle: Text(
                                item.displayStatus + (item.projectName != null ? ' \u2022 ${item.projectName}' : ''),
                                style: AppTextStyles.caption,
                              ),
                              trailing: selecting
                                  ? null
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.getStatusColor(item.status).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.getStatusColor(item.status).withValues(alpha: 0.25),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        item.displayStatus,
                                        style: AppTextStyles.overline.copyWith(
                                          color: AppColors.getStatusColor(item.status),
                                        ),
                                      ),
                                    ),
                              onTap: selecting
                                  ? () => controller.toggleSelected(item.id)
                                  : () => Get.toNamed('/items/${item.id}'),
                              onLongPress: selecting
                                  ? null
                                  : () {
                                      controller.isSelecting.value = true;
                                      controller.toggleSelected(item.id);
                                    },
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
      ),
    );
  }

  Widget _buildNormalHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Items', style: AppTextStyles.h1),
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
                        ? AppColors.glass
                        : AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: limitReached
                          ? AppColors.glassBorder
                          : AppColors.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(Icons.add,
                    color: limitReached ? AppColors.textTertiary : AppColors.primary,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.toggleSelecting,
            child: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Obx(() => Text(
                '${controller.selectedIds.length} selected',
                style: AppTextStyles.h3,
              )),
          const Spacer(),
          Obx(() {
            if (controller.selectedIds.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _printSelectedLabels(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text('Print labels',
                        style: AppTextStyles.captionMedium
                            .copyWith(color: AppColors.primary)),
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(item.status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.getStatusColor(item.status).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '#${item.itemNumber}',
          style: AppTextStyles.itemNumber,
        ),
      ),
    );
  }

  Widget _buildSelectionCheckbox(bool isSelected) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryMuted : AppColors.glass,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.glassBorder,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Center(
        child: isSelected
            ? const Icon(Icons.check, color: AppColors.primary, size: 20)
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
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.warning,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.glass,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.glassBorder,
                width: 0.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(
                color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
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
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                left: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                right: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              ),
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
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Add Item', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text('Create a new item to track',
                    style: AppTextStyles.bodySmall),
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
                        color: AppColors.textTertiary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.glassBorder, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1),
                    ),
                    filled: true,
                    fillColor: AppColors.glass,
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.glassBorder, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1),
                    ),
                    filled: true,
                    fillColor: AppColors.glass,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : Text('Create Item',
                                  style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
