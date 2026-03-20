import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_list.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../data/services/supabase_service.dart';
import 'members_controller.dart';

class MembersView extends GetView<MembersController> {
  const MembersView({super.key});

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Members', style: AppTextStyles.screenTitle),
                  Obx(() {
                    if (!SupabaseService.to.isAdmin) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => _showInviteSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accBorder,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: AppColors.acc, size: 20),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerList();
                }
                if (controller.hasError.value) {
                  return ErrorState(
                    message: "Couldn't load members",
                    onRetry: controller.loadMembers,
                  );
                }
                if (controller.members.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outlined,
                    title: 'No members found',
                    subtitle: 'Invite team members to your organisation',
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadMembers,
                  color: AppColors.acc,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.members.length,
                    itemBuilder: (context, index) {
                      final member = controller.members[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: member.isAdmin
                                      ? AppColors.accBg
                                      : AppColors.surface3,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: member.isAdmin
                                        ? AppColors.accBorder
                                        : AppColors.border2,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    member.fullName.isNotEmpty
                                        ? member.fullName[0].toUpperCase()
                                        : '?',
                                    style: AppTextStyles.itemName.copyWith(
                                      color: member.isAdmin
                                          ? AppColors.acc
                                          : AppColors.t3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(member.fullName,
                                              style: AppTextStyles.itemName),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: member.isAdmin
                                                ? AppColors.accBg
                                                : AppColors.surface3,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            member.isAdmin ? 'Admin' : 'Member',
                                            style: AppTextStyles.micro.copyWith(
                                              color: member.isAdmin
                                                  ? AppColors.accText
                                                  : AppColors.t4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Joined ${DateFormat.yMMMd().format(member.createdAt)}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              // Admin actions
                              if (SupabaseService.to.isAdmin &&
                                  member.userId != SupabaseService.to.userId)
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: AppColors.t4, size: 20),
                                  color: AppColors.surface3,
                                  onSelected: (value) {
                                    if (value == 'toggle_role') {
                                      controller.toggleRole(member);
                                    } else if (value == 'remove') {
                                      _confirmRemove(context, member);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'toggle_role',
                                      child: Text(
                                        member.isAdmin ? 'Make Member' : 'Make Admin',
                                        style: AppTextStyles.body,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text(
                                        'Remove',
                                        style: AppTextStyles.body
                                            .copyWith(color: AppColors.reText),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, dynamic member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface3,
        title: Text('Remove Member', style: AppTextStyles.cardTitle),
        content: Text('Remove ${member.fullName} from the organisation?',
            style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.t3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.removeMember(member);
            },
            child: Text('Remove',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.reText)),
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    final isGenerating = false.obs;
    final generatedCode = ''.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
            Text('Invite Members', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Generate a code or link that others can use to join',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            Obx(() {
              if (generatedCode.value.isNotEmpty) {
                final link =
                    'https://ventry.app/invite/${generatedCode.value}';
                return Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderColor: AppColors.accBorder,
                      child: Column(
                        children: [
                          Text('INVITE CODE',
                              style: AppTextStyles.sectionLabel),
                          const SizedBox(height: 8),
                          Text(
                            generatedCode.value,
                            style: AppTextStyles.screenTitle.copyWith(
                              color: AppColors.accText,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: generatedCode.value));
                              Get.snackbar('Copied',
                                  'Invite code copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor:
                                      AppColors.surface3,
                                  colorText: AppColors.t1);
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Code'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: link));
                              Get.snackbar('Copied',
                                  'Invite link copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor:
                                      AppColors.surface3,
                                  colorText: AppColors.t1);
                            },
                            icon: const Icon(Icons.link, size: 16),
                            label: const Text('Copy Link'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Material(
                color: isGenerating.value
                    ? AppColors.surface3
                    : AppColors.acc,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isGenerating.value
                      ? null
                      : () async {
                          isGenerating.value = true;
                          try {
                            final orgId =
                                SupabaseService.to.activeOrgId.value;
                            if (orgId == null) return;
                            final code = await SupabaseService
                                .to.client
                                .rpc('create_invite', params: {
                              'p_org_id': orgId,
                            });
                            generatedCode.value = code as String;
                          } catch (e) {
                            Get.snackbar(
                                'Error', 'Failed to generate invite',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    AppColors.surface3,
                                colorText: AppColors.reText);
                          } finally {
                            isGenerating.value = false;
                          }
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: isGenerating.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Generate Invite Code',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
