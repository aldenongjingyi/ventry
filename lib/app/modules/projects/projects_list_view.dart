import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
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
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.standard,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Projects', style: AppTextStyles.h1),
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
                                ? 'Project limit reached ($current/$limitInt). Upgrade to add more.'
                                : 'Approaching project limit ($current/$limitInt)',
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
              const SizedBox(height: 16),
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
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  'Total', controller.totalItems, AppColors.textPrimary)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildStatCard(
                                  'In Project', controller.inProjectCount, AppColors.textPrimary)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildStatCard(
                                  'Missing', controller.missingCount, AppColors.statusMissing)),
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
                                Text('Recent activity',
                                    style: AppTextStyles.captionMedium),
                                const SizedBox(height: 10),
                                ...controller.recentActivity.map((entry) {
                                  final Color dotColor;
                                  switch (entry.action) {
                                    case 'mark_missing':
                                      dotColor = AppColors.statusMissing;
                                    case 'mark_repair':
                                      dotColor = AppColors.warning;
                                    default:
                                      dotColor = AppColors.statusStorage;
                                  }
                                  final itemName =
                                      entry.metadata['item_name'] as String? ??
                                          entry.displayEntity;
                                  final description =
                                      '${entry.userName ?? 'Someone'} ${entry.displayAction} $itemName';
                                  final timeAgo = _formatTimeAgo(entry.createdAt);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            description,
                                            style: AppTextStyles.caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeAgo,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textTertiary,
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
                        else ...[
                          if (controller.activeProjects.isNotEmpty) ...[
                            _buildSectionLabel('Active', AppColors.primary),
                            const SizedBox(height: 8),
                            ...controller.activeProjects.map((p) => _buildProjectCard(p)),
                            const SizedBox(height: 16),
                          ],
                          if (controller.completedProjects.isNotEmpty) ...[
                            _buildSectionLabel('Completed', AppColors.info),
                            const SizedBox(height: 8),
                            ...controller.completedProjects.map((p) => _buildProjectCard(p)),
                            const SizedBox(height: 16),
                          ],
                          if (controller.archivedProjects.isNotEmpty) ...[
                            _buildSectionLabel('Archived', AppColors.textTertiary),
                            const SizedBox(height: 8),
                            ...controller.archivedProjects.map((p) => _buildProjectCard(p)),
                          ],
                        ],
                      ],
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

  Widget _buildStatCard(String label, int count, Color numberColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        children: [
          Text('$count',
              style: AppTextStyles.h2.copyWith(color: numberColor)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.captionMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.getStatusColor(project.status).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.getStatusColor(project.status).withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Icon(Icons.folder_rounded, color: AppColors.getStatusColor(project.status), size: 22),
          ),
          title: Text(project.name, style: AppTextStyles.bodyMedium),
          subtitle: Text(
            project.location ?? 'No location',
            style: AppTextStyles.caption,
          ),
          trailing: Text(
            '${project.itemCount} items',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          onTap: () => Get.toNamed('/projects/${project.id}'),
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
                Text('Add Project', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text('Create a new project to organize items',
                    style: AppTextStyles.bodySmall),
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
                  controller: locationController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g. 123 Main St',
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
                              await controller.createProject(
                                name,
                                locationController.text.trim().isEmpty
                                    ? null
                                    : locationController.text.trim(),
                              );
                              isSubmitting.value = false;
                              if (context.mounted) Navigator.of(context).pop();
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
                              : Text('Create Project',
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
