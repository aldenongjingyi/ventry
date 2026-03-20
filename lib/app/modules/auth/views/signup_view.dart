import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(
          'Create Account',
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.acc),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller.fullNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
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
                  onSubmitted: (_) => controller.signup(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    helperText: 'Must be at least 6 characters',
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
                          : controller.signup,
                      isLoading: controller.isLoading.value,
                      label: 'Create Account',
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
