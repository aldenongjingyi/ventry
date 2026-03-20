import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../data/models/project_model.dart';
import '../../data/services/supabase_service.dart';
import 'projects_controller.dart';

class ProjectsListView extends GetView<ProjectsController> {
  const ProjectsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Projects', style: AppTextStyles.screenTitle),
                  // Hide + button when zero projects (empty state has CTA)
                  Obx(() {
                    if (!SupabaseService.to.isAdmin) return const SizedBox.shrink();
                    if (controller.projects.isEmpty && !controller.isLoading.value) {
                      return const SizedBox.shrink();
                    }
                    final limitReached = SupabaseService.to.isLimitReached('projects');
                    return Tooltip(
                      message: limitReached ? 'Project limit reached. Upgrade your plan.' : '',
                      child: GestureDetector(
                        onTap: limitReached ? null : () => _showAddProjectSheet(context),
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
            ),
            // Limit warning
            Obx(() {
              final svc = SupabaseService.to;
              final usage = svc.getResourceUsage('projects');
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
                              ? 'Project limit reached ($current/$limitInt). Upgrade to add more.'
                              : 'Approaching project limit ($current/$limitInt)',
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
            // Filter chips
            Obx(() {
              if (controller.projects.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All', ''),
                      _buildFilterChip('Active', 'active'),
                      _buildFilterChip('Completed', 'completed'),
                      _buildFilterChip('Archived', 'archived'),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerList();
                }
                if (controller.hasError.value) {
                  return ErrorState(
                    message: "Couldn't load projects",
                    onRetry: controller.loadProjects,
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadProjects,
                  color: AppColors.acc,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Stat strip — hidden when all values are zero
                      Obx(() {
                        if (controller.totalItems == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard(
                                'TOTAL', controller.totalItems, AppColors.t1, false)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatCard(
                                'IN PROJECT', controller.inProjectCount, AppColors.t1, false)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatCard(
                                'MISSING', controller.missingCount, AppColors.reText, true)),
                            ],
                          ),
                        );
                      }),

                      // Recent activity — only when projects exist and entries exist
                      Obx(() {
                        if (controller.projects.isEmpty ||
                            controller.recentActivity.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RECENT ACTIVITY',
                                  style: AppTextStyles.sectionLabel),
                              const SizedBox(height: 10),
                              ...controller.recentActivity.asMap().entries.map((mapEntry) {
                                final index = mapEntry.key;
                                final entry = mapEntry.value;
                                final Color dotColor;
                                switch (entry.action) {
                                  case 'mark_missing':
                                    dotColor = AppColors.re;
                                  case 'mark_repair':
                                    dotColor = AppColors.am;
                                  default:
                                    dotColor = AppColors.sl;
                                }
                                final itemName =
                                    entry.metadata['item_name'] as String? ??
                                        entry.displayEntity;
                                final description =
                                    '${entry.userName ?? 'Someone'} ${entry.displayAction} $itemName';
                                final timeAgo = _formatTimeAgo(entry.createdAt);
                                final isLast = index == controller.recentActivity.length - 1;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : Border(
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
                                      const SizedBox(width: 10),
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
                          ),
                        );
                      }),

                      // Projects list / empty state
                      if (controller.projects.isEmpty)
                        EmptyState(
                          icon: Icons.folder_outlined,
                          title: 'No projects yet',
                          subtitle:
                              'Create a project to start tracking equipment across your team',
                          actionLabel: SupabaseService.to.isAdmin
                              ? 'Create first project'
                              : null,
                          onAction: SupabaseService.to.isAdmin
                              ? () => _showAddProjectSheet(context)
                              : null,
                        )
                      else if (controller.filteredProjects.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Center(
                            child: Text(
                              'No ${controller.filterStatus.value} projects',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ),
                      ] else ...[
                        ...controller.filteredProjects.map((p) => _buildProjectCard(p)),
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

  Widget _buildStatCard(String label, int count, Color numberColor, bool isMissing) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: isMissing ? AppColors.reBg : AppColors.surface1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMissing ? AppColors.reBorder : AppColors.border1,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text('$count',
              style: AppTextStyles.displayNumber.copyWith(
                color: isMissing ? AppColors.reText : numberColor,
              )),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.sectionLabel),
        ],
      ),
    );
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

  Widget _buildProjectCard(ProjectModel project) {
    // Determine semantic colors based on project status
    final Color iconBg;
    final Color iconBorder;
    final Color iconColor;
    switch (project.status) {
      case 'active':
        iconBg = AppColors.emBg;
        iconBorder = AppColors.emBorder;
        iconColor = AppColors.em;
      case 'completed':
        iconBg = AppColors.accBg;
        iconBorder = AppColors.accBorder;
        iconColor = AppColors.acc;
      case 'archived':
        iconBg = AppColors.slBg;
        iconBorder = AppColors.slBorder;
        iconColor = AppColors.sl;
      default:
        iconBg = AppColors.emBg;
        iconBorder = AppColors.emBorder;
        iconColor = AppColors.em;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: InkWell(
          onTap: () => Get.toNamed('/projects/${project.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(Icons.folder_rounded, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: AppTextStyles.itemName),
                      const SizedBox(height: 2),
                      Text(
                        project.location ?? 'No location',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${project.itemCount} items',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void _showAddProjectSheet(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: const Border(
            top: BorderSide(color: AppColors.border1, width: 0.5),
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
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Project', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Create a new project to organize items',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: AppTextStyles.body,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g. Building A Renovation',
                labelStyle: AppTextStyles.caption,
                hintStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.t5),
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
              controller: locationController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g. 123 Main St',
                labelStyle: AppTextStyles.caption,
                hintStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.t5),
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
                        await controller.createProject(
                          name,
                          locationController.text.trim().isEmpty
                              ? null
                              : locationController.text.trim(),
                        );
                        isSubmitting.value = false;
                        if (context.mounted) Navigator.of(context).pop();
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
                        : Text('Create Project',
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
