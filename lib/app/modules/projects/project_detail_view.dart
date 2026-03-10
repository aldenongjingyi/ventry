import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/shimmer_list.dart';
import 'projects_controller.dart';

class ProjectDetailView extends StatelessWidget {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;

    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadProjectDetail(id);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Project Detail')),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const ShimmerList(itemCount: 3);
        }

        final project = controller.selectedProject.value;
        if (project == null) {
          return const Center(child: Text('Project not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(project.name, style: AppTextStyles.h3)),
                        StatusBadge(status: project.status),
                      ],
                    ),
                    if (project.clientName != null) ...[
                      const SizedBox(height: 8),
                      Text(project.clientName!, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                    if (project.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(project.location!, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                    if (project.startDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat.MMMd().format(project.startDate!)}${project.endDate != null ? ' - ${DateFormat.MMMd().format(project.endDate!)}' : ''}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Assigned equipment
              Text('Assigned Equipment', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),
              if (controller.projectAssignments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    'No equipment currently assigned',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...controller.projectAssignments.map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.glass,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.equipmentName ?? 'Unknown', style: AppTextStyles.bodyMedium),
                                Text(
                                  'Since ${DateFormat.MMMd().format(a.checkedOutAt)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      }),
    );
  }
}
