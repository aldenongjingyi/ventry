import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
              const SizedBox(height: 60),
              // Logo
              const Icon(
                Icons.inventory_2_rounded,
                size: 64,
                color: AppColors.acc,
              ),
              const SizedBox(height: 16),
              Text(
                'Ventry',
                style: AppTextStyles.screenTitle.copyWith(color: AppColors.t1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Equipment management made easy',
                style: AppTextStyles.body.copyWith(color: AppColors.t3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.login(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => controller.errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              controller.errorMessage.value,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.reText),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),
                    const SizedBox(height: 24),
                    Obx(() => GoldButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          isLoading: controller.isLoading.value,
                          label: 'Sign In',
                        )),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.border1)),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.t4),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.border1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(() => _GoogleButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.signInWithGoogle,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  controller.clearFields();
                  Get.toNamed(AppRoutes.signup);
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.accText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border2,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                height: 20,
                width: 20,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.g_mobiledata, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.t1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
