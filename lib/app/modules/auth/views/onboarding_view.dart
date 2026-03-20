import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              const Icon(
                Icons.business_rounded,
                size: 64,
                color: AppColors.acc,
              ),
              const SizedBox(height: 16),
              Text(
                'Get Started',
                style: AppTextStyles.screenTitle.copyWith(color: AppColors.t1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new organisation or join an existing one',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.t3),
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

              // Create org form
              Obx(() => controller.onboardingMode.value == 'create'
                  ? _buildCreateForm()
                  : _buildJoinForm()),

              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.logout,
                child: Text(
                  'Sign out',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.t3),
                ),
              ),
            ],
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
          Text('New Organisation', style: AppTextStyles.itemName),
          const SizedBox(height: 4),
          Text(
            'Start on the free plan \u2014 upgrade anytime',
            style: AppTextStyles.caption,
          ),
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
          Text('Join Organisation', style: AppTextStyles.itemName),
          const SizedBox(height: 4),
          Text(
            'Enter the invite code from your team admin',
            style: AppTextStyles.caption,
          ),
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
              style: AppTextStyles.caption.copyWith(color: AppColors.reText),
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
          color: isActive ? AppColors.accBg : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.acc : AppColors.border1,
            width: isActive ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.acc : AppColors.t3,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isActive ? AppColors.acc : AppColors.t3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
