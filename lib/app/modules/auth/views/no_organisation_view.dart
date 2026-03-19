import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/glass_background.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class NoOrganisationView extends GetView<AuthController> {
  const NoOrganisationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 64),
                Icon(
                  Icons.business_outlined,
                  size: 56,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 20),
                Text(
                  'No Organisation',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "You're not part of any organisation.\nCreate one or enter an invite code to join.",
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Mode toggle
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        label: 'Create',
                        icon: Icons.add_business_rounded,
                        isActive: controller.onboardingMode.value == 'create',
                        onTap: () {
                          controller.onboardingMode.value = 'create';
                          controller.errorMessage.value = '';
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeTab(
                        label: 'Join',
                        icon: Icons.group_add_rounded,
                        isActive: controller.onboardingMode.value == 'join',
                        onTap: () {
                          controller.onboardingMode.value = 'join';
                          controller.errorMessage.value = '';
                        },
                      ),
                    ),
                  ],
                )),

                const SizedBox(height: 24),

                Obx(() => controller.onboardingMode.value == 'create'
                    ? _buildCreateForm()
                    : _buildJoinForm()),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.logout,
                  child: Text(
                    'Sign out',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Organisation', style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text('Start on the free plan \u2014 upgrade anytime',
              style: AppTextStyles.caption),
          const SizedBox(height: 20),
          TextField(
            controller: controller.orgNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.createOrgAndJoin(),
            decoration: const InputDecoration(
              labelText: 'Organisation Name',
              prefixIcon: Icon(Icons.business_outlined),
              hintText: 'e.g. Acme Productions',
            ),
          ),
          _buildErrorMessage(),
          const SizedBox(height: 20),
          Obx(() => GoldButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createOrgAndJoin,
                isLoading: controller.isLoading.value,
                label: 'Create Organisation',
              )),
        ],
      ),
    );
  }

  Widget _buildJoinForm() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Join Organisation', style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text('Enter the invite code from your team admin',
              style: AppTextStyles.caption),
          const SizedBox(height: 20),
          TextField(
            controller: controller.inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.joinOrgWithInvite(),
            decoration: const InputDecoration(
              labelText: 'Invite Code',
              prefixIcon: Icon(Icons.vpn_key_outlined),
              hintText: 'e.g. A1B2C3D4',
            ),
          ),
          _buildErrorMessage(),
          const SizedBox(height: 20),
          Obx(() => GoldButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.joinOrgWithInvite,
                isLoading: controller.isLoading.value,
                label: 'Join Organisation',
              )),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() => controller.errorMessage.value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink());
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryMuted : AppColors.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.glassBorder,
            width: isActive ? 1.5 : 0.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
