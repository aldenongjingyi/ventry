import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/shimmer_list.dart';
import 'account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Account', style: AppTextStyles.h1),
                const SizedBox(height: 24),

                // Profile Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            controller.userName.isNotEmpty
                                ? controller.userName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.textOnPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.userName,
                                style: AppTextStyles.subtitle),
                            const SizedBox(height: 2),
                            Text(controller.userEmail,
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Organisation + Plan Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text('Organisation',
                              style: AppTextStyles.captionMedium),
                          const Spacer(),
                          Obx(() => _PlanBadge(
                              plan: SupabaseService.to.activePlan.value)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Text(controller.orgName,
                          style: AppTextStyles.subtitle)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMuted,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  SupabaseService.to.isAdmin ? 'Admin' : 'Member',
                                  style: AppTextStyles.overline
                                      .copyWith(color: AppColors.primary),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Usage Card
                Obx(() {
                  final usage = SupabaseService.to.orgUsage.value;
                  if (usage == null) {
                    return Column(
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.textTertiary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Usage data unavailable',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textTertiary)),
                              ),
                              TextButton(
                                onPressed: () =>
                                    SupabaseService.to.loadOrgUsage(),
                                child: Text('Retry',
                                    style: AppTextStyles.captionMedium
                                        .copyWith(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Usage', style: AppTextStyles.captionMedium),
                            const SizedBox(height: 16),
                            _UsageRow(
                              label: 'Members',
                              icon: Icons.people_outline,
                              usage: usage['members'] as Map<String, dynamic>?,
                            ),
                            const SizedBox(height: 12),
                            _UsageRow(
                              label: 'Items',
                              icon: Icons.inventory_2_outlined,
                              usage: usage['items'] as Map<String, dynamic>?,
                            ),
                            const SizedBox(height: 12),
                            _UsageRow(
                              label: 'Projects',
                              icon: Icons.folder_outlined,
                              usage: usage['projects'] as Map<String, dynamic>?,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Invite members (admin only)
                Obx(() => SupabaseService.to.isAdmin
                    ? Column(
                        children: [
                          GlassCard(
                            child: ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMuted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(Icons.person_add_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                              title: Text('Invite Members',
                                  style: AppTextStyles.bodyMedium),
                              subtitle: Text('Generate an invite code or link',
                                  style: AppTextStyles.caption),
                              trailing: const Icon(Icons.chevron_right,
                                  color: AppColors.textTertiary, size: 20),
                              onTap: () =>
                                  _showInviteSheet(Get.context!),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink()),

                // Org actions (switch / join)
                Obx(() {
                  if (controller.isLoadingMemberships.value) {
                    return const ShimmerList(itemCount: 2, padding: EdgeInsets.zero);
                  }
                  if (controller.hasMembershipError.value) {
                    return GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              color: AppColors.textTertiary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("Couldn't load organisations",
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: controller.loadMemberships,
                            child: Text('Try again',
                                style: AppTextStyles.captionMedium
                                    .copyWith(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  }
                  return GlassCard(
                    child: Column(
                      children: [
                        if (controller.canSwitchOrgs) ...[
                          _buildSettingTile(
                            icon: Icons.swap_horiz_rounded,
                            title: 'Switch Organisation',
                            onTap: () => _showOrgSwitcher(context),
                          ),
                          Divider(height: 1, color: AppColors.glassBorder),
                        ],
                        _buildSettingTile(
                          icon: Icons.group_add_rounded,
                          title: 'Join Organisation',
                          onTap: () => _showJoinOrgSheet(context),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Settings
                GlassCard(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.qr_code_scanner,
                        title: 'Scanner Settings',
                        onTap: () => Get.toNamed(AppRoutes.scannerSettings),
                      ),
                      Divider(height: 1, color: AppColors.glassBorder),
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About Ventry',
                        onTap: () => Get.toNamed(AppRoutes.about),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Material(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: controller.logout,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, size: 18, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }

  // ── Org Switcher Sheet ──
  void _showOrgSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
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
            child: Obx(() {
              final currentOrgId = SupabaseService.to.activeOrgId.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Switch Organisation', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  if (controller.isSwitching.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else
                    ...controller.memberships.map((m) {
                      final orgData = m['organisations'] as Map<String, dynamic>;
                      final orgId = m['organisation_id'] as String;
                      final orgName = orgData['name'] as String;
                      final plan = orgData['plan'] as String? ?? 'free';
                      final role = m['role'] as String;
                      final isCurrent = orgId == currentOrgId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          borderColor: isCurrent ? AppColors.goldGlassBorder : null,
                          showGlow: isCurrent,
                          child: ListTile(
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: isCurrent ? AppColors.goldGradient : null,
                                color: isCurrent ? null : AppColors.glass,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  orgName.isNotEmpty ? orgName[0].toUpperCase() : '?',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: isCurrent ? AppColors.textOnPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(orgName, style: AppTextStyles.bodyMedium),
                            subtitle: Text(
                              '${role[0].toUpperCase()}${role.substring(1)} \u2022 ${plan[0].toUpperCase()}${plan.substring(1)}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: isCurrent
                                ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                                : null,
                            onTap: isCurrent
                                ? null
                                : () {
                                    Navigator.of(ctx).pop();
                                    controller.switchToOrg(m);
                                  },
                          ),
                        ),
                      );
                    }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Join Org Sheet ──
  void _showJoinOrgSheet(BuildContext context) {
    // Multi-org gate
    final supabase = SupabaseService.to;
    if (controller.hasMultipleOrgs || supabase.activeOrgId.value != null) {
      // Already in an org — check if multi-org allowed
      if (!supabase.canJoinMultipleOrgs && controller.memberships.isNotEmpty) {
        Get.snackbar(
          'Upgrade Required',
          'Multi-org support requires Pro plan or higher',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.warning,
        );
        return;
      }
    }

    final codeController = TextEditingController();
    final isJoining = false.obs;
    final errorMsg = ''.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Join Organisation', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text('Enter the invite code from a team admin',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  autofocus: true,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Invite Code',
                    hintText: 'e.g. A1B2C3D4',
                    labelStyle: AppTextStyles.caption,
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
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
                Obx(() => errorMsg.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(errorMsg.value,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error)),
                      )
                    : const SizedBox.shrink()),
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
                      onTap: isJoining.value
                          ? null
                          : () async {
                              final code = codeController.text.trim();
                              if (code.isEmpty) return;
                              isJoining.value = true;
                              errorMsg.value = '';
                              try {
                                await controller.joinOrgWithCode(code);
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              } catch (e) {
                                errorMsg.value = e.toString().replaceAll('Exception: ', '');
                              } finally {
                                isJoining.value = false;
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: isJoining.value
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : Text('Join', style: AppTextStyles.button),
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

  // ── Invite Sheet (with link support) ──
  void _showInviteSheet(BuildContext context) {
    final isGenerating = false.obs;
    final generatedCode = ''.obs;

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
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Invite Members', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'Generate a code or link that others can use to join',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (generatedCode.value.isNotEmpty) {
                    final link = 'https://ventry.app/invite/${generatedCode.value}';
                    return Column(
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          borderColor: AppColors.goldGlassBorder,
                          showGlow: true,
                          glow: AppColors.goldGlow,
                          child: Column(
                            children: [
                              Text('Invite Code',
                                  style: AppTextStyles.captionMedium),
                              const SizedBox(height: 8),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.goldShimmer.createShader(bounds),
                                child: Text(
                                  generatedCode.value,
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 4,
                                  ),
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
                                  Clipboard.setData(
                                      ClipboardData(text: generatedCode.value));
                                  Get.snackbar('Copied',
                                      'Invite code copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.surfaceElevated,
                                      colorText: AppColors.textPrimary);
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
                                      backgroundColor: AppColors.surfaceElevated,
                                      colorText: AppColors.textPrimary);
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
                  return Container(
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
                      color: isGenerating.value ? AppColors.surfaceLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: isGenerating.value
                            ? null
                            : () async {
                                isGenerating.value = true;
                                try {
                                  final orgId =
                                      SupabaseService.to.activeOrgId.value;
                                  if (orgId == null) return;
                                  final code = await SupabaseService.to.client
                                      .rpc('create_invite', params: {
                                    'p_org_id': orgId,
                                  });
                                  generatedCode.value = code as String;
                                } catch (e) {
                                  Get.snackbar('Error', 'Failed to generate invite',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.surfaceElevated,
                                      colorText: AppColors.error);
                                } finally {
                                  isGenerating.value = false;
                                }
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: isGenerating.value
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : const Text(
                                    'Generate Invite Code',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textOnPrimary,
                                    ),
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
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = switch (plan) {
      'pro' => AppColors.primary,
      _ => AppColors.textTertiary,
    };
    final label = switch (plan) {
      'free' => 'Free',
      'pro' => 'Pro',
      _ => plan,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(label, style: AppTextStyles.overline.copyWith(color: color)),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Map<String, dynamic>? usage;

  const _UsageRow({
    required this.label,
    required this.icon,
    this.usage,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) return const SizedBox.shrink();
    final current = usage!['current'] as int? ?? 0;
    final limit = usage!['limit'] as int?;
    final isUnlimited = limit == null;
    final ratio = isUnlimited ? 0.0 : current / limit;
    final barColor = ratio >= 1.0
        ? AppColors.error
        : ratio >= 0.8
            ? AppColors.warning
            : AppColors.primary;

    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.captionMedium),
                  Text(
                    isUnlimited ? '$current' : '$current / $limit',
                    style: AppTextStyles.caption.copyWith(
                      color: ratio >= 0.8 ? barColor : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (!isUnlimited) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    backgroundColor: AppColors.glass,
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
