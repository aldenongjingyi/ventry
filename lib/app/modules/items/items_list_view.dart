import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/add_item_sheet.dart';
import '../../widgets/item_visual_avatar.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/relocate_sheet.dart';
import '../../data/models/item_model.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/qr_label_export.dart';
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
            // Header — always the same, selection state shown elsewhere
            _buildHeader(context),
            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border1, width: 0.5),
                ),
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: AppColors.t5, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.t5, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
              ),
            ),

            // Limit warning
            _buildLimitWarning(),
            const SizedBox(height: 10),

            // Filter bar
            _buildFilterBar(),
            const SizedBox(height: 8),

            // Items list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const ShimmerList();
                if (controller.hasError.value) {
                  return ErrorState(
                    message: "Couldn't load items",
                    onRetry: controller.loadItems,
                  );
                }
                if (controller.filteredItems.isEmpty) return _buildEmptyState(context);
                return _buildItemsList(context);
              }),
            ),

            // Bottom action bar (selection mode)
            Obx(() => controller.isSelecting.value
                ? _buildBottomBar(context)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Obx(() {
        final selecting = controller.isSelecting.value;
        final count = controller.selectedIds.length;
        return Row(
          children: [
            if (selecting) ...[
              GestureDetector(
                onTap: controller.toggleSelecting,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: AppColors.t2, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                count == 0 ? 'Select items' : '$count selected',
                style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
              ),
            ] else
              Text('Items', style: AppTextStyles.screenTitle),
            const Spacer(),
            if (!selecting) ...[
              Obx(() {
                if (!SupabaseService.to.isAdmin) return const SizedBox.shrink();
                final limitReached = SupabaseService.to.isLimitReached('items');
                return GestureDetector(
                  onTap: limitReached ? null : () => _showAddItemSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: limitReached ? AppColors.surface2 : AppColors.accBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: limitReached ? AppColors.border1 : AppColors.accBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(Icons.add,
                        color: limitReached ? AppColors.t4 : AppColors.acc, size: 20),
                  ),
                );
              }),
            ],
            if (selecting) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final allSelected = count == controller.filteredItems.length
                      && controller.filteredItems.isNotEmpty;
                  allSelected ? controller.deselectAll() : controller.selectAll();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border1, width: 0.5),
                  ),
                  child: Obx(() {
                    final allSelected = controller.selectedIds.length == controller.filteredItems.length
                        && controller.filteredItems.isNotEmpty;
                    return Text(
                      allSelected ? 'None' : 'All',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.t2,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // ─── Filter bar ──────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return SizedBox(
      height: 34,
      child: Obx(() {
        final hasGroups = controller.itemGroups.isNotEmpty;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _FilterChip(
              label: 'All',
              isActive: controller.filterStatus.value.isEmpty,
              onTap: () => controller.setFilterStatus(''),
            ),
            _FilterChip(
              label: 'Storage',
              isActive: controller.filterStatus.value == 'storage',
              onTap: () => controller.setFilterStatus('storage'),
            ),
            _FilterChip(
              label: 'In Project',
              isActive: controller.filterStatus.value == 'in_project',
              onTap: () => controller.setFilterStatus('in_project'),
            ),
            _FilterChip(
              label: 'Missing',
              isActive: controller.filterStatus.value == 'missing',
              onTap: () => controller.setFilterStatus('missing'),
            ),
            _FilterChip(
              label: 'Repair',
              isActive: controller.filterStatus.value == 'under_repair',
              onTap: () => controller.setFilterStatus('under_repair'),
            ),
            if (hasGroups) ...[
              // Subtle separator
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                color: AppColors.border2,
              ),
              ...controller.itemGroups.map((group) => _FilterChip(
                    label: group.name,
                    isActive: controller.filterGroupId.value == group.id,
                    onTap: () => controller.setFilterGroup(group.id),
                    isGroup: true,
                  )),
            ],
          ],
        );
      }),
    );
  }

  // ─── Item list ───────────────────────────────────────────────────────

  Widget _buildItemsList(BuildContext context) {
    return Obx(() {
      final selecting = controller.isSelecting.value;
      return RefreshIndicator(
        onRefresh: controller.loadItems,
        color: AppColors.acc,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: controller.filteredItems.length,
          itemBuilder: (context, index) {
            final item = controller.filteredItems[index];
            return Obx(() {
              final isSelected = controller.selectedIds.contains(item.id);
              return _ItemTile(
                item: item,
                visual: controller.getVisual(item.name),
                isSelecting: selecting,
                isSelected: isSelected,
                onTap: selecting
                    ? () {
                        HapticFeedback.selectionClick();
                        controller.toggleSelected(item.id);
                      }
                    : () => Get.toNamed('/items/${item.id}'),
                onLongPress: selecting
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        controller.isSelecting.value = true;
                        controller.toggleSelected(item.id);
                      },
                onSwipeRight: !selecting
                    ? () {
                        HapticFeedback.mediumImpact();
                        controller.isSelecting.value = true;
                        controller.toggleSelected(item.id);
                      }
                    : null,
              );
            });
          },
        ),
      );
    });
  }

  // ─── Bottom action bar ───────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final count = controller.selectedIds.length;
      if (count == 0) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface1,
            border: Border(top: BorderSide(color: AppColors.border1, width: 0.5)),
          ),
          child: Text(
            'Swipe right or tap items to select',
            style: AppTextStyles.caption.copyWith(color: AppColors.t4),
            textAlign: TextAlign.center,
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border1, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _AnimatedActionButton(
                icon: Icons.swap_horiz_rounded,
                label: 'Move $count',
                color: AppColors.acc,
                iconColor: Colors.white,
                labelColor: Colors.white,
                splashColor: Colors.white.withValues(alpha: 0.25),
                onTap: () => _showBulkRelocate(context),
              ),
            ),
            const SizedBox(width: 10),
            _AnimatedActionButton(
              icon: Icons.qr_code_2_rounded,
              color: AppColors.surface2,
              iconColor: AppColors.t2,
              splashColor: AppColors.acc.withValues(alpha: 0.2),
              onTap: () => _printSelectedLabels(context),
              isCompact: true,
            ),
          ],
        ),
      );
    });
  }

  // ─── Empty / warning states ──────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final hasFilter = controller.searchQuery.value.isNotEmpty ||
        controller.filterStatus.value.isNotEmpty ||
        controller.filterGroupId.value.isNotEmpty;
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

  Widget _buildLimitWarning() {
    return Obx(() {
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
                      ? 'Item limit reached ($current/$limitInt)'
                      : 'Approaching limit ($current/$limitInt)',
                  style: AppTextStyles.caption.copyWith(
                    color: atLimit ? AppColors.reText : AppColors.amText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Actions ─────────────────────────────────────────────────────────

  void _showAddItemSheet(BuildContext context) {
    showAddItemSheet(context, onCreated: () => controller.loadItems());
  }

  Future<void> _printSelectedLabels(BuildContext context) async {
    var selected = controller.selectedItems;
    if (selected.length > 20) {
      Get.snackbar('Limit', 'First 20 selected will be exported.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.amText,
      );
      selected = selected.take(20).toList();
    }
    await shareBulkQrLabels(selected);
    controller.toggleSelecting();
  }

  void _showBulkRelocate(BuildContext context) {
    final selected = controller.selectedItems;
    if (selected.isEmpty) return;
    showRelocateSheet(
      context,
      itemId: selected.first.id,
      itemName: '${selected.length} items',
      itemNumber: 0,
      onComplete: () {
        controller.toggleSelecting();
        controller.loadItems();
      },
      bulkItemIds: selected.map((i) => i.id).toList(),
    );
  }
}

// ─── Filter chip ────────────────────────────────────────────────────────

// ─── Animated action button ─────────────────────────────────────────────

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final Color iconColor;
  final Color? labelColor;
  final Color splashColor;
  final VoidCallback onTap;
  final bool isCompact;

  const _AnimatedActionButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.splashColor,
    required this.onTap,
    this.label,
    this.labelColor,
    this.isCompact = false,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.04), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _iconRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.05), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: widget.splashColor,
          highlightColor: widget.splashColor.withValues(alpha: 0.1),
          child: Padding(
            padding: widget.isCompact
                ? const EdgeInsets.all(13)
                : const EdgeInsets.symmetric(vertical: 13),
            child: widget.isCompact
                ? AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, child) => Transform.rotate(
                      angle: _iconRotation.value,
                      child: child,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 20),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, child) => Transform.rotate(
                          angle: _iconRotation.value,
                          child: child,
                        ),
                        child: Icon(widget.icon, color: widget.iconColor, size: 18),
                      ),
                      if (widget.label != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.label!,
                          style: TextStyle(
                            color: widget.labelColor ?? widget.iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Filter chip ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isGroup;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (isGroup ? AppColors.emBg : AppColors.accBg)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? (isGroup ? AppColors.emBorder : AppColors.accBorder)
                  : AppColors.border1,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isGroup) ...[
                Icon(Icons.folder_outlined, size: 12,
                    color: isActive ? AppColors.emText : AppColors.t5),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive
                      ? (isGroup ? AppColors.emText : AppColors.accText)
                      : AppColors.t4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Item tile with swipe-to-select ─────────────────────────────────────

class _ItemTile extends StatefulWidget {
  final ItemModel item;
  final dynamic visual;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSwipeRight;

  const _ItemTile({
    required this.item,
    required this.visual,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.onSwipeRight,
  });

  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _swiped = false;
  static const _swipeThreshold = 60.0;
  static const _maxDrag = 80.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHorizontalDragUpdate: widget.onSwipeRight != null ? _onDragUpdate : null,
        onHorizontalDragEnd: widget.onSwipeRight != null ? _onDragEnd : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_dragOffset, 0, 0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accBg
                : AppColors.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.acc.withValues(alpha: 0.5)
                  : AppColors.border1,
              width: widget.isSelected ? 1 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Always show visual
                ItemVisualAvatar(visual: widget.visual, size: 40, iconSize: 22),
                const SizedBox(width: 12),
                // Content
                Expanded(child: _buildContent()),
                // Status pill or selection checkbox
                if (widget.isSelecting) ...[
                  const SizedBox(width: 10),
                  _buildCheckbox(),
                ] else ...[
                  const SizedBox(width: 8),
                  _buildStatusPill(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_swiped) return;
    setState(() {
      _dragOffset = (_dragOffset + d.delta.dx).clamp(0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffset >= _swipeThreshold && !_swiped) {
      _swiped = true;
      widget.onSwipeRight?.call();
    }
    setState(() => _dragOffset = 0);
    _swiped = false;
  }

  Widget _buildCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.em : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: widget.isSelected ? AppColors.em : AppColors.border2,
          width: widget.isSelected ? 0 : 1.5,
        ),
      ),
      child: widget.isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _buildContent() {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(item.name, style: AppTextStyles.itemName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (item.sequentialId != null) ...[
              const SizedBox(width: 6),
              Text(item.displayId,
                  style: AppTextStyles.micro.copyWith(color: AppColors.t5)),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (item.labelColor != null) ...[
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getLabelColor(item.labelColor!),
                ),
              ),
            ],
            Flexible(
              child: Text(
                _subtitle(item),
                style: AppTextStyles.caption.copyWith(color: AppColors.t4),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    final badge = AppColors.statusBadge(widget.item.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badge.bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badge.border, width: 0.5),
      ),
      child: Text(
        widget.item.displayStatus,
        style: AppTextStyles.micro.copyWith(color: badge.text),
      ),
    );
  }

  String _subtitle(ItemModel item) {
    final parts = <String>[item.displayStatus];
    if (item.projectName != null) parts.add(item.projectName!);
    if (item.itemGroupName != null) parts.add(item.itemGroupName!);
    return parts.join(' \u2022 ');
  }

  static const _labelColorMap = <String, Color>{
    'red': Color(0xFFEF4444),
    'green': Color(0xFF22C55E),
    'blue': Color(0xFF3B82F6),
    'yellow': Color(0xFFEAB308),
    'pink': Color(0xFFEC4899),
    'cyan': Color(0xFF06B6D4),
    'white': Color(0xFFFFFFFF),
    'black': Color(0xFF000000),
  };

  Color _getLabelColor(String v) =>
      _labelColorMap[v] ?? (() {
        final c = v.replaceAll('#', '');
        return c.length == 6 ? Color(int.parse('FF$c', radix: 16)) : AppColors.t4;
      })();
}
