import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/add_item_sheet.dart';
import '../../widgets/add_project_sheet.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pressable.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/error_state.dart';
import '../../data/services/supabase_service.dart';
import '../shell/shell_controller.dart';
import '../items/items_controller.dart';
import '../account/account_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ShimmerList();
          }
          if (controller.hasError.value) {
            return ErrorState(
              message: "Couldn't load dashboard",
              onRetry: controller.loadHome,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadHome,
            color: AppColors.acc,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 14),
                Text(
                  controller.greeting,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 16),
                _buildMissingAlert(),
                _buildOrgStats(context),
                _buildQuickActions(context),
                _buildRecentActivity(),
                if (!controller.hasContent)
                  _buildChecklist(),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChecklist() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to Ventry', style: AppTextStyles.cardTitle),
            const SizedBox(height: 6),
            Text(
              'Track your equipment across projects and storage with QR codes.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 18),
            _ExplainerStep(
              icon: Icons.create_new_folder_rounded,
              title: 'Create a project',
              subtitle: 'Group items by job site or location',
            ),
            _ExplainerStep(
              icon: Icons.inventory_2_rounded,
              title: 'Add your items',
              subtitle: 'Register equipment and print QR labels',
            ),
            _ExplainerStep(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan to move',
              subtitle: 'Check items in and out with a quick scan',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgStats(BuildContext context) {
    return Obx(() {
      final active = controller.activeProjects;
      final hasStats = controller.totalItems > 0 || controller.activeProjectCount > 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Org header — always shown
              const _OrgPill(),
              // Stats row — only when there's data
              if (hasStats) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Items',
                        count: controller.totalItems,
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'In Storage',
                        count: controller.inStorageCount,
                        icon: Icons.warehouse_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Deployed',
                        count: controller.inProjectCount,
                        icon: Icons.rocket_launch_outlined,
                      ),
                    ),
                  ],
                ),
              ],
              // Active projects section
              const SizedBox(height: 14),
              const Divider(color: AppColors.border1, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ACTIVE PROJECTS',
                      style: AppTextStyles.sectionLabel),
                  if (active.length > 2)
                    GestureDetector(
                      onTap: () => controller.projectsExpanded.toggle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.projectsExpanded.value
                                ? 'Show less'
                                : 'See all (${active.length})',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.accText),
                          ),
                          const SizedBox(width: 2),
                          AnimatedRotation(
                            turns: controller.projectsExpanded.value
                                ? 0.5
                                : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.accText,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (active.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Pressable(
                    onTap: () => _showAddProjectSheet(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border2,
                          width: 0.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.create_new_folder_rounded,
                              color: AppColors.acc,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No active projects',
                            style: AppTextStyles.itemName.copyWith(
                              color: AppColors.t2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to create your first project',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.t4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (active.isNotEmpty) ...[
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: (controller.projectsExpanded.value
                            ? active
                            : active.take(2).toList())
                        .map((project) {
                  final checkIn =
                      controller.projectCheckInPercent(project.id);
                  final pct = (checkIn * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Pressable(
                      onTap: () =>
                          Get.toNamed('/projects/${project.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface1,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border1,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + item count pill
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    project.name,
                                    style: AppTextStyles.itemName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accBg,
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${project.itemCount} ITEMS',
                                    style:
                                        AppTextStyles.micro.copyWith(
                                      color: AppColors.accText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Location
                            if (project.location != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.t4,
                                      size: 14),
                                  const SizedBox(width: 4),
                                  Text(project.location!,
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ],
                            // Check-in progress
                            if (project.itemCount > 0) ...[
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('CHECK-IN STATUS',
                                      style:
                                          AppTextStyles.sectionLabel),
                                  Text('$pct%',
                                      style: AppTextStyles.caption
                                          .copyWith(
                                        color: AppColors.t2,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: checkIn,
                                  minHeight: 6,
                                  backgroundColor:
                                      AppColors.surface3,
                                  valueColor:
                                      const AlwaysStoppedAnimation<
                                          Color>(AppColors.acc),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMissingAlert() {
    return Obx(() {
      if (controller.missingCount == 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Pressable(
          onTap: () {
            Get.find<ItemsController>().setFilterStatus('missing');
            Get.find<ShellController>().changePage(1);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.reBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.reBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D0F0F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.reText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.missingCount} item${controller.missingCount == 1 ? '' : 's'} reported missing',
                        style: AppTextStyles.itemName.copyWith(
                          color: AppColors.reText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to review missing items',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.reText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.reText,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add_box_rounded,
                label: 'Add Item',
                onTap: () => _showAddItemSheet(context),
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.create_new_folder_rounded,
                label: 'New Project',
                onTap: () => _showAddProjectSheet(context),
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.swap_horiz_rounded,
                label: 'Bulk Move',
                onTap: () {
                  final itemsCtrl = Get.find<ItemsController>();
                  if (!itemsCtrl.isSelecting.value) {
                    itemsCtrl.toggleSelecting();
                  }
                  Get.find<ShellController>().changePage(1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      if (controller.recentActivity.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT ACTIVITY', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          ...controller.recentActivity.map((entry) {
            final Color dotColor;
            switch (entry.action) {
              case 'mark_missing':
                dotColor = AppColors.re;
              case 'mark_repair':
                dotColor = AppColors.am;
              case 'move_to_project':
              case 'return_to_storage':
              case 'relocate':
                dotColor = AppColors.em;
              default:
                dotColor = AppColors.sl;
            }
            final itemName =
                entry.metadata['item_name'] as String? ?? entry.displayEntity;
            final description =
                '${entry.userName ?? 'Someone'} ${entry.displayAction} $itemName';
            final timeAgo = _formatTimeAgo(entry.createdAt);
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border1,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.t3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeAgo,
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.t5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat.MMMd().format(dateTime);
  }

  void _showAddItemSheet(BuildContext context) {
    showAddItemSheet(context, onCreated: () => controller.loadHome());
  }

  void _showAddProjectSheet(BuildContext context) {
    showAddProjectSheet(context, onCreated: () => controller.loadHome());
  }
}

// ─── Quick Action button ──────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.accBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.acc, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.t2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const fg = AppColors.t3;
    const bg = AppColors.surface3;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border1,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: fg, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: AppTextStyles.screenTitle.copyWith(
              color: AppColors.t1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.t3),
          ),
        ],
      ),
    );
  }
}

// ─── Org pill ─────────────────────────────────────────────────────────

class _OrgPill extends StatelessWidget {
  const _OrgPill();

  @override
  Widget build(BuildContext context) {
    final accountCtrl = Get.find<AccountController>();
    return Obx(() {
      final orgName = SupabaseService.to.activeOrgName.value;
      final tappable = accountCtrl.hasMultipleOrgs;
      return GestureDetector(
        onTap: tappable ? () => Get.find<ShellController>().changePage(3) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.accBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.accBorder, width: 0.5),
              ),
              child: Center(
                child: Text(
                  orgName.isNotEmpty ? orgName[0].toUpperCase() : '?',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.accText,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                orgName,
                style: AppTextStyles.itemName.copyWith(
                  color: AppColors.t1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: SupabaseService.to.isPro
                    ? AppColors.accBg
                    : AppColors.surface3,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: SupabaseService.to.isPro
                      ? AppColors.accBorder
                      : AppColors.border2,
                  width: 0.5,
                ),
              ),
              child: Text(
                SupabaseService.to.activePlan.value.toUpperCase(),
                style: AppTextStyles.micro.copyWith(
                  color: SupabaseService.to.isPro
                      ? AppColors.accText
                      : AppColors.t4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more_rounded,
                  color: AppColors.t4, size: 16),
            ],
          ],
        ),
      );
    });
  }
}

// ─── Checklist row ────────────────────────────────────────────────────

class _ExplainerStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _ExplainerStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.t3, size: 16),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 28,
                color: AppColors.border2,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.itemName.copyWith(color: AppColors.t2)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
