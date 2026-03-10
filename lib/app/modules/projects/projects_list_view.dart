import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/project_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_list.dart';
import 'projects_controller.dart';

class ProjectsListView extends GetView<ProjectsController> {
  const ProjectsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerList();
        }

        if (controller.projects.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_outlined,
            title: 'No projects yet',
            subtitle: 'Projects will appear here when created',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProjects,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.activeProjects.isNotEmpty) ...[
                _SectionHeader(title: 'Active', count: controller.activeProjects.length),
                const SizedBox(height: 8),
                ...controller.activeProjects.map((p) => _ProjectCard(project: p)),
                const SizedBox(height: 24),
              ],
              if (controller.planningProjects.isNotEmpty) ...[
                _SectionHeader(title: 'Planning', count: controller.planningProjects.length),
                const SizedBox(height: 8),
                ...controller.planningProjects.map((p) => _ProjectCard(project: p)),
                const SizedBox(height: 24),
              ],
              if (controller.completedProjects.isNotEmpty) ...[
                _SectionHeader(title: 'Completed', count: controller.completedProjects.length),
                const SizedBox(height: 8),
                ...controller.completedProjects.map((p) => _ProjectCard(project: p)),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.subtitle),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.captionMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.projectDetail,
          arguments: {'id': project.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(project.name, style: AppTextStyles.bodyMedium),
                  ),
                  StatusBadge(status: project.status, small: true),
                ],
              ),
              if (project.clientName != null) ...[
                const SizedBox(height: 4),
                Text(project.clientName!, style: AppTextStyles.caption),
              ],
              if (project.startDate != null || project.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (project.startDate != null) ...[
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.MMMd().format(project.startDate!),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (project.location != null) ...[
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.location!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
