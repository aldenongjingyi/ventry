import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_list.dart';
import 'team_controller.dart';

class TeamListView extends GetView<TeamController> {
  const TeamListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerList();
        }

        if (controller.members.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No team members',
            subtitle: 'Invite people to join your company',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadMembers,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = controller.members[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.glass,
                      child: Text(
                        member.initials,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.fullName, style: AppTextStyles.bodyMedium),
                          Text(
                            member.role[0].toUpperCase() + member.role.substring(1),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
