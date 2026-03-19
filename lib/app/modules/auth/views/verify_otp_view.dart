import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/glass_background.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class VerifyOtpView extends GetView<AuthController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.otpController.clear();
    controller.errorMessage.value = '';

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verify Email',
          style: AppTextStyles.h3.copyWith(color: AppColors.primary),
        ),
      ),
      body: GlassBackground(
        style: GlassBackgroundStyle.auth,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              showGlow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Check your email',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent an 8-digit code to',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.signupEmail,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller.otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    maxLength: 8,
                    style: AppTextStyles.h2.copyWith(
                      letterSpacing: 6,
                      color: AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      hintText: '00000000',
                      counterText: '',
                    ),
                    onSubmitted: (_) => controller.verifyOtp(),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 24),
                  Obx(() => GoldButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.verifyOtp,
                        isLoading: controller.isLoading.value,
                        label: 'Verify',
                      )),
                  const SizedBox(height: 16),
                  Center(
                    child: Obx(() {
                      final cooldown = controller.resendCooldown.value;
                      if (cooldown > 0) {
                        return Text(
                          'Resend code in ${cooldown}s',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                        );
                      }
                      return GestureDetector(
                        onTap: controller.isLoading.value
                            ? null
                            : controller.resendOtp,
                        child: Text(
                          'Resend code',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
