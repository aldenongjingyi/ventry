import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/shimmer_list.dart';
import 'account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Account', style: AppTextStyles.screenTitle),
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
                        color: AppColors.acc,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          controller.userName.isNotEmpty
                              ? controller.userName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.screenTitle
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
                              style: AppTextStyles.itemName
                                  .copyWith(color: AppColors.t1)),
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
                            color: AppColors.acc, size: 20),
                        const SizedBox(width: 10),
                        Text('ORGANISATION',
                            style: AppTextStyles.sectionLabel),
                        const Spacer(),
                        Obx(() => _PlanBadge(
                            plan: SupabaseService.to.activePlan.value)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Text(controller.orgName,
                        style: AppTextStyles.itemName
                            .copyWith(color: AppColors.t1))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accBg,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: AppColors.accBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                SupabaseService.to.isAdmin ? 'Admin' : 'Member',
                                style: AppTextStyles.micro
                                    .copyWith(color: AppColors.accText),
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
                                color: AppColors.t4, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Usage data unavailable',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                      color: AppColors.t4)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  SupabaseService.to.loadOrgUsage(),
                              child: Text('Retry',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.acc)),
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
                          Text('USAGE', style: AppTextStyles.sectionLabel),
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
                                color: AppColors.accBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: const Icon(Icons.person_add_rounded,
                                  color: AppColors.acc, size: 18),
                            ),
                            title: Text('Invite Members',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.t2)),
                            subtitle: Text('Generate an invite code or link',
                                style: AppTextStyles.caption),
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.t4, size: 20),
                            onTap: () =>
                                _showInviteSheet(Get.context!),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink()),

              // Members
              GlassCard(
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(Icons.people_rounded,
                        color: AppColors.acc, size: 18),
                  ),
                  title: Text('Members',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.t2)),
                  subtitle: Text('View and manage team members',
                      style: AppTextStyles.caption),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.t4, size: 20),
                  onTap: () => Get.toNamed(AppRoutes.members),
                ),
              ),
              const SizedBox(height: 16),

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
                            color: AppColors.t4, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text("Couldn't load organisations",
                              style: AppTextStyles.bodySecondary.copyWith(
                                  color: AppColors.t2)),
                        ),
                        TextButton(
                          onPressed: controller.loadMemberships,
                          child: Text('Try again',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.acc)),
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
                        Divider(height: 1, color: AppColors.border1),
                      ],
                      _buildSettingTile(
                        icon: Icons.group_add_rounded,
                        title: 'Join Organisation',
                        onTap: () => _showJoinOrgSheet(context),
                      ),
                      Divider(height: 1, color: AppColors.border1),
                      _buildSettingTile(
                        icon: Icons.add_business_rounded,
                        title: 'Create Organisation',
                        onTap: () => _showCreateOrgSheet(context),
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
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => _showSettingsSheet(context),
                    ),
                    Divider(height: 1, color: AppColors.border1),
                    _buildSettingTile(
                      icon: Icons.qr_code_scanner,
                      title: 'Scanner Settings',
                      onTap: () => Get.toNamed(AppRoutes.scannerSettings),
                    ),
                    Divider(height: 1, color: AppColors.border1),
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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.reBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Material(
                    color: AppColors.reBg,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: controller.logout,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 18, color: AppColors.reText),
                            const SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: AppTextStyles.body.copyWith(color: AppColors.reText),
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
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.t3, size: 22),
      title: Text(title,
          style: AppTextStyles.body.copyWith(color: AppColors.t2)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.t4, size: 20),
      onTap: onTap,
    );
  }

  // ── Org Switcher Sheet ──
  void _showOrgSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: AppColors.border2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Switch Organisation', style: AppTextStyles.cardTitle),
              const SizedBox(height: 16),
              if (controller.isSwitching.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.acc)),
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
                      borderColor: isCurrent ? AppColors.accBorder : null,
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.acc : AppColors.surface3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              orgName.isNotEmpty ? orgName[0].toUpperCase() : '?',
                              style: AppTextStyles.itemName.copyWith(
                                color: isCurrent ? AppColors.textOnPrimary : AppColors.t3,
                              ),
                            ),
                          ),
                        ),
                        title: Text(orgName,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.t2)),
                        subtitle: Text(
                          '${role[0].toUpperCase()}${role.substring(1)} \u2022 ${plan[0].toUpperCase()}${plan.substring(1)}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.check_circle, color: AppColors.acc, size: 20)
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
    );
  }

  // ── Create Org Sheet ──
  void _showCreateOrgSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            Text('Create Organisation', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Start a new organisation to manage equipment',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Organisation Name',
                hintText: 'e.g. Acme Construction',
                labelStyle: AppTextStyles.caption,
                hintStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.t5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.acc, width: 1),
                ),
                filled: true,
                fillColor: AppColors.surface2,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            isSubmitting.value = true;
                            try {
                              await controller.createOrg(name);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            } catch (_) {
                              // Error snackbar shown by controller
                            } finally {
                              isSubmitting.value = false;
                            }
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
                            : Text('Create Organisation',
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
          backgroundColor: AppColors.surface3,
          colorText: AppColors.amText,
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
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Join Organisation', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Enter the invite code from a team admin',
                style: AppTextStyles.bodySecondary),
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
            Obx(() => errorMsg.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(errorMsg.value,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.reText)),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 24),
            Obx(() => Material(
              color: AppColors.acc,
              borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(10),
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
            )),
          ],
        ),
      ),
    );
  }

  // ── Settings Sheet ──
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text('Settings', style: AppTextStyles.cardTitle),
            const SizedBox(height: 24),

            // ── Preferences ──
            Text('PREFERENCES', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  Obx(() => _SettingsToggle(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Currently always dark',
                    value: true,
                    onChanged: (v) {
                      Get.snackbar('Coming Soon', 'Light mode is coming in a future update',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.surface3,
                        colorText: AppColors.t2,
                      );
                    },
                  )),
                  const Divider(height: 1, color: AppColors.border1),
                  _SettingsToggle(
                    icon: Icons.vibration_outlined,
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrate on actions',
                    value: true,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Notifications ──
            Text('NOTIFICATIONS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsToggle(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Item moves and project updates',
                    value: false,
                    onChanged: (v) {
                      Get.snackbar('Coming Soon', 'Notifications coming in a future update',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.surface3,
                        colorText: AppColors.t2,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── App Info ──
            Text('APP INFO', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Version', value: '1.0.0'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Build', value: '1'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Bundle ID', value: 'com.ventry.app'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Legal ──
            Text('LEGAL', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.border1),
                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.border1),
                  _buildSettingTile(
                    icon: Icons.source_outlined,
                    title: 'Open Source Licenses',
                    onTap: () => showLicensePage(
                      context: ctx,
                      applicationName: 'Ventry',
                      applicationVersion: '1.0.0',
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Invite Members', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              'Generate a code or link that others can use to join',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (generatedCode.value.isNotEmpty) {
                final link = 'https://ventry.app/invite/${generatedCode.value}';
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
                              Clipboard.setData(
                                  ClipboardData(text: generatedCode.value));
                              Get.snackbar('Copied',
                                  'Invite code copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.surface3,
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
                                  backgroundColor: AppColors.surface3,
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
                color: isGenerating.value ? AppColors.surface3 : AppColors.acc,
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
                            final code = await SupabaseService.to.client
                                .rpc('create_invite', params: {
                              'p_org_id': orgId,
                            });
                            generatedCode.value = code as String;
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to generate invite',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.surface3,
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
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : Text(
                              'Generate Invite Code',
                              style: AppTextStyles.button,
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

class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isPro = plan == 'pro';
    final bgColor = isPro ? AppColors.accBg : AppColors.surface3;
    final borderColor = isPro ? AppColors.accBorder : AppColors.border2;
    final textColor = isPro ? AppColors.accText : AppColors.t4;
    final label = switch (plan) {
      'free' => 'Free',
      'pro' => 'Pro',
      _ => plan,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: textColor)),
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
        ? AppColors.reText
        : ratio >= 0.8
            ? AppColors.amText
            : AppColors.acc;

    return Row(
      children: [
        Icon(icon, color: AppColors.t4, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  Text(
                    isUnlimited ? '$current' : '$current / $limit',
                    style: AppTextStyles.caption.copyWith(
                      color: ratio >= 0.8 ? barColor : AppColors.t3,
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
                    backgroundColor: AppColors.surface3,
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

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.t3, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(color: AppColors.t2)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.acc,
            activeThumbColor: Colors.white,
            inactiveTrackColor: AppColors.surface3,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.body.copyWith(color: AppColors.t2, fontSize: 13)),
      ],
    );
  }
}
