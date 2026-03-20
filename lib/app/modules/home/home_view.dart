import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/error_state.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../shell/shell_controller.dart';
import '../items/items_controller.dart';
import '../projects/projects_controller.dart';
import '../account/account_controller.dart';
import '../scan/scan_view.dart';
import '../scan/scan_binding.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Obx(() => Text(
                    controller.greeting,
                    style: AppTextStyles.screenTitle,
                  )),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
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
                      // Show checklist if no content and not all done
                      if (!controller.hasContent && !controller.allChecklistDone)
                        _buildChecklist()
                      else ...[
                        _buildMissingAlert(),
                        _buildOrgStats(),
                        _buildQuickActions(context),
                        _buildActiveProjects(),
                        _buildRecentActivity(),
                        const SizedBox(height: 100),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Get started with Ventry', style: AppTextStyles.cardTitle),
        const SizedBox(height: 16),
        Obx(() => _ChecklistRow(
              title: 'Create your first project',
              isDone: controller.checklistProject.value,
              onTap: () {
                Get.find<ShellController>().changePage(1);
              },
            )),
        const SizedBox(height: 8),
        Obx(() => _ChecklistRow(
              title: 'Add your first item',
              isDone: controller.checklistItem.value,
              onTap: () {
                Get.find<ShellController>().changePage(2);
              },
            )),
        const SizedBox(height: 8),
        Obx(() => _ChecklistRow(
              title: 'Invite your team',
              isDone: controller.checklistInvite.value,
              onTap: () {
                Get.toNamed(AppRoutes.members);
              },
            )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOrgStats() {
    return Obx(() {
      if (controller.totalItems == 0 && controller.activeProjectCount == 0) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Org header
              const _OrgPill(),
              const SizedBox(height: 14),
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Items',
                      count: controller.totalItems,
                      icon: Icons.inventory_2_outlined,
                      onTap: () => Get.find<ShellController>().changePage(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'In Storage',
                      count: controller.inStorageCount,
                      icon: Icons.warehouse_outlined,
                      onTap: () {
                        Get.find<ItemsController>().setFilterStatus('in_storage');
                        Get.find<ShellController>().changePage(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Deployed',
                      count: controller.inProjectCount,
                      icon: Icons.rocket_launch_outlined,
                      onTap: () {
                        Get.find<ItemsController>().setFilterStatus('in_project');
                        Get.find<ShellController>().changePage(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Active Projects',
                      count: controller.activeProjectCount,
                      icon: Icons.folder_outlined,
                      onTap: () => Get.find<ShellController>().changePage(1),
                    ),
                  ),
                ],
              ),
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
        child: GestureDetector(
          onTap: () {
            Get.find<ItemsController>().setFilterStatus('missing');
            Get.find<ShellController>().changePage(2);
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
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR',
                onTap: () => Get.to(
                  () => const ScanView(),
                  fullscreenDialog: true,
                  binding: ScanBinding(),
                ),
              ),
            ),
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
                  Get.find<ShellController>().changePage(2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjects() {
    return Obx(() {
      final active = controller.activeProjects;
      if (active.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE PROJECTS',
                  style: AppTextStyles.sectionLabel,
                ),
                GestureDetector(
                  onTap: () => Get.find<ShellController>().changePage(1),
                  child: Text(
                    'See all',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...active.map((project) {
              final checkIn = controller.projectCheckInPercent(project.id);
              final pct = (checkIn * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => Get.toNamed('/projects/${project.id}'),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with item count pill
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
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${project.itemCount} ITEMS',
                                style: AppTextStyles.micro.copyWith(
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
                              const Icon(Icons.location_on_outlined,
                                  color: AppColors.t4, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                project.location!,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                        // Check-in progress
                        if (project.itemCount > 0) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CHECK-IN STATUS',
                                style: AppTextStyles.sectionLabel,
                              ),
                              Text(
                                '$pct%',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.t2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: checkIn,
                              minHeight: 6,
                              backgroundColor: AppColors.surface3,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(AppColors.acc),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
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
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            _buildTextField(nameCtrl, 'Item Name', 'e.g. Drill, Safety Harness',
                autofocus: true),
            const SizedBox(height: 16),
            _buildTextField(notesCtrl, 'Notes (optional)', null, maxLines: 2),
            const SizedBox(height: 24),
            Obx(() => _buildSubmitButton(
                  label: 'Create Item',
                  isSubmitting: isSubmitting.value,
                  onTap: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    isSubmitting.value = true;
                    await Get.find<ItemsController>().createItem(
                      name,
                      notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    );
                    isSubmitting.value = false;
                    controller.loadHome();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAddProjectSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            Text('New Project', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Create a project to organize items',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            _buildTextField(
                nameCtrl, 'Project Name', 'e.g. Building A Renovation',
                autofocus: true),
            const SizedBox(height: 16),
            _buildTextField(
                locationCtrl, 'Location (optional)', 'e.g. 123 Main St'),
            const SizedBox(height: 24),
            Obx(() => _buildSubmitButton(
                  label: 'Create Project',
                  isSubmitting: isSubmitting.value,
                  onTap: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    isSubmitting.value = true;
                    await Get.find<ProjectsController>().createProject(
                      name,
                      locationCtrl.text.trim().isEmpty
                          ? null
                          : locationCtrl.text.trim(),
                    );
                    isSubmitting.value = false;
                    controller.loadHome();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label,
    String? hint, {
    bool autofocus = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: textController,
      style: AppTextStyles.body,
      autofocus: autofocus,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.caption,
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.t5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.acc, width: 1),
        ),
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isSubmitting,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.acc,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isSubmitting ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label, style: AppTextStyles.button),
          ),
        ),
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
  final VoidCallback? onTap;
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const fg = AppColors.t3;
    const bg = AppColors.surface3;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    ));
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
            Text(
              orgName,
              style: AppTextStyles.itemName.copyWith(
                color: AppColors.t1,
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 6),
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

class _ChecklistRow extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;

  const _ChecklistRow({
    required this.title,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: GestureDetector(
        onTap: isDone ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isDone ? AppColors.em : AppColors.t4,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: isDone ? AppColors.t4 : AppColors.t1,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (!isDone)
              const Icon(Icons.chevron_right, color: AppColors.t4, size: 20),
          ],
        ),
      ),
    );
  }
}
