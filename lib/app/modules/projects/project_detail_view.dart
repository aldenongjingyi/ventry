import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
import '../../data/services/supabase_service.dart';
import 'project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text("Couldn't load project",
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: controller.loadProject,
                      child: Text('Try again',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            );
          }
          final project = controller.project.value;
          if (project == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_outlined,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text('This project no longer exists',
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Go back',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  if (SupabaseService.to.isAdmin)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                      onPressed: () => _confirmDelete(context),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(project.name, style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.getStatusColor(project.status)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.getStatusColor(project.status)
                                    .withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              project.status[0].toUpperCase() +
                                  project.status.substring(1),
                              style: AppTextStyles.captionMedium.copyWith(
                                color:
                                    AppColors.getStatusColor(project.status),
                              ),
                            ),
                          ),
                          if (project.location != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.location_on_outlined,
                                color: AppColors.textTertiary, size: 16),
                            const SizedBox(width: 4),
                            Text(project.location!,
                                style: AppTextStyles.caption),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${controller.items.length}',
                                    style: AppTextStyles.statNumber,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Items',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat.MMMd()
                                        .format(project.createdAt),
                                    style: AppTextStyles.subtitle.copyWith(
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Created',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Items list
                      Text('Assigned Items',
                          style: AppTextStyles.captionMedium),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.items.isEmpty) {
                          return GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text('No items assigned',
                                  style: AppTextStyles.bodySmall),
                            ),
                          );
                        }
                        return Column(
                          children: controller.items
                              .map((item) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: GlassCard(
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 2),
                                        leading: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.getStatusColor(
                                                    item.status)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#${item.itemNumber}',
                                              style:
                                                  AppTextStyles.itemNumber
                                                      .copyWith(
                                                          fontSize: 10),
                                            ),
                                          ),
                                        ),
                                        title: Text(item.name,
                                            style:
                                                AppTextStyles.bodyMedium),
                                        subtitle: Text(
                                            item.displayStatus,
                                            style: AppTextStyles.caption),
                                        onTap: () => Get.toNamed('/items/${item.id}'),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Actions
                      if (project.isActive) ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColors.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: controller.completeProject,
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: AppColors.textOnPrimary,
                                        size: 20),
                                    SizedBox(width: 8),
                                    Text('Complete Project',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textOnPrimary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Material(
                              color: AppColors.glass,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: controller.archiveProject,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.archive_outlined,
                                          color: AppColors.textSecondary,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text('Archive',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Delete Project', style: AppTextStyles.h3),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteProject();
            },
            child: Text('Delete',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
