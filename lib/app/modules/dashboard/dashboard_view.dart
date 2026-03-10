import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/shimmer_list.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Column(
            children: [
              GradientHeader(title: 'Dashboard', subtitle: 'Loading...'),
              const Expanded(child: ShimmerList()),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: GradientHeader(
                  title: 'Dashboard',
                  subtitle: '${controller.totalCount} total equipment',
                ),
              ),

              // Stats cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'In Storage',
                        count: controller.inStorageCount,
                        color: AppColors.inStorage,
                        icon: Icons.warehouse_outlined,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Checked Out',
                        count: controller.checkedOutCount,
                        color: AppColors.checkedOut,
                        icon: Icons.output_rounded,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Maintenance',
                        count: controller.maintenanceCount,
                        color: AppColors.maintenance,
                        icon: Icons.build_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: AppTextStyles.subtitle),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.qr_code_scanner,
                            label: 'Scan',
                            color: AppColors.primary,
                            onTap: () => Get.toNamed(AppRoutes.scan, arguments: {'mode': 'lookup'}),
                          ),
                          const SizedBox(width: 8),
                          _QuickAction(
                            icon: Icons.output_rounded,
                            label: 'Check Out',
                            color: AppColors.checkedOut,
                            onTap: () => Get.toNamed(AppRoutes.checkout),
                          ),
                          const SizedBox(width: 8),
                          _QuickAction(
                            icon: Icons.input_rounded,
                            label: 'Check In',
                            color: AppColors.success,
                            onTap: () => Get.toNamed(AppRoutes.checkin),
                          ),
                          const SizedBox(width: 8),
                          _QuickAction(
                            icon: Icons.folder_outlined,
                            label: 'Projects',
                            color: AppColors.info,
                            onTap: () => Get.toNamed(AppRoutes.projectDetail),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Active projects
              if (controller.activeProjects.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        Text('Active Projects', style: AppTextStyles.subtitle),
                        const Spacer(),
                        Text(
                          '${controller.activeProjects.length}',
                          style: AppTextStyles.captionMedium.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = controller.activeProjects[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          onTap: () => Get.toNamed(AppRoutes.projectDetail, arguments: {'id': project.id}),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
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
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.folder, color: AppColors.success, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(project.name, style: AppTextStyles.bodyMedium),
                                      if (project.clientName != null)
                                        Text(project.clientName!, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: controller.activeProjects.length,
                  ),
                ),
              ],

              // Recent activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text('Recent Activity', style: AppTextStyles.subtitle),
                ),
              ),
              if (controller.recentActivity.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        'No recent activity',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = controller.recentActivity[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                activity.action == 'checkout'
                                    ? Icons.output_rounded
                                    : activity.action == 'checkin'
                                        ? Icons.input_rounded
                                        : Icons.edit,
                                color: activity.action == 'checkout'
                                    ? AppColors.checkedOut
                                    : activity.action == 'checkin'
                                        ? AppColors.inStorage
                                        : AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${activity.userName ?? 'Someone'} ${activity.displayAction} ${activity.displayEntity}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    Text(
                                      DateFormat.MMMd().add_jm().format(activity.createdAt),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: controller.recentActivity.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: AppTextStyles.h2.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.captionMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
