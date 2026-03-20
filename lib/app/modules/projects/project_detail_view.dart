import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../data/services/supabase_service.dart';
import 'project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

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
                      border: Border.all(
                        color: AppColors.border2,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(Icons.cloud_off_rounded,
                        size: 20, color: AppColors.t4),
                  ),
                  const SizedBox(height: 16),
                  Text("Couldn't load project",
                      style: AppTextStyles.itemName.copyWith(color: AppColors.t1)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.loadProject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border2,
                          width: 0.5,
                        ),
                      ),
                      child: Text('Try again',
                          style: AppTextStyles.bodySecondary),
                    ),
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border2,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(Icons.folder_outlined,
                        size: 20, color: AppColors.t4),
                  ),
                  const SizedBox(height: 16),
                  Text('This project no longer exists',
                      style: AppTextStyles.itemName.copyWith(color: AppColors.t1)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border2,
                          width: 0.5,
                        ),
                      ),
                      child: Text('Go back',
                          style: AppTextStyles.bodySecondary),
                    ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(project.name, style: AppTextStyles.screenTitle),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusPillBg(project.status),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _statusPillBorder(project.status),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            project.status[0].toUpperCase() +
                                project.status.substring(1),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _statusPillText(project.status),
                            ),
                          ),
                        ),
                        if (project.location != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.t4, size: 16),
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
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface1,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.border1,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.items.length}',
                                  style: AppTextStyles.displayNumber,
                                ),
                                const SizedBox(height: 4),
                                Text('ITEMS',
                                    style: AppTextStyles.sectionLabel),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface1,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.border1,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat.MMMd()
                                      .format(project.createdAt),
                                  style: AppTextStyles.itemName
                                      .copyWith(color: AppColors.accText),
                                ),
                                const SizedBox(height: 4),
                                Text('CREATED',
                                    style: AppTextStyles.sectionLabel),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Items list
                    Text('ASSIGNED ITEMS',
                        style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.items.isEmpty) {
                        return GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text('No items assigned',
                                style: AppTextStyles.bodySecondary),
                          ),
                        );
                      }
                      return Column(
                        children: controller.items
                            .map((item) {
                              final badge =
                                  AppColors.statusBadge(item.status);
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  child: InkWell(
                                    onTap: () =>
                                        Get.toNamed('/items/${item.id}'),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: badge.bg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                              border: Border.all(
                                                color: badge.border,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '#${item.itemNumber}',
                                                style: AppTextStyles
                                                    .micro
                                                    .copyWith(
                                                        color: AppColors
                                                            .accText),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(item.name,
                                                    style: AppTextStyles
                                                        .itemName),
                                                const SizedBox(
                                                    height: 2),
                                                Text(
                                                    item.displayStatus,
                                                    style: AppTextStyles
                                                        .caption),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Actions
                    if (project.isActive) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: AppColors.acc,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: controller.completeProject,
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Complete Project',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
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
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.border2,
                              width: 0.5,
                            ),
                          ),
                          child: Material(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: controller.archiveProject,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.archive_outlined,
                                        color: AppColors.t2, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Archive',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.t2,
                                        )),
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
    );
  }

  // ── Status pill helpers for project statuses ──

  Color _statusPillBg(String status) {
    return switch (status) {
      'active' => AppColors.emBg,
      'completed' => AppColors.accBg,
      'archived' => AppColors.surface3,
      _ => AppColors.surface3,
    };
  }

  Color _statusPillBorder(String status) {
    return switch (status) {
      'active' => AppColors.emBorder,
      'completed' => AppColors.accBorder,
      'archived' => AppColors.border2,
      _ => AppColors.border2,
    };
  }

  Color _statusPillText(String status) {
    return switch (status) {
      'active' => AppColors.emText,
      'completed' => AppColors.accText,
      'archived' => AppColors.t4,
      _ => AppColors.t4,
    };
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface3,
        title: Text('Delete Project', style: AppTextStyles.cardTitle),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodySecondary
                    .copyWith(color: AppColors.t3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteProject();
            },
            child: Text('Delete',
                style:
                    AppTextStyles.bodySecondary.copyWith(color: AppColors.reText)),
          ),
        ],
      ),
    );
  }
}
