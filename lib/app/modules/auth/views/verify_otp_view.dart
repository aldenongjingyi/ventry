import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_button.dart';
import '../auth_controller.dart';

class VerifyOtpView extends GetView<AuthController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.otpController.clear();
    controller.errorMessage.value = '';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(
          'Verify Email',
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
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: AppColors.acc,
                ),
                const SizedBox(height: 16),
                Text(
                  'Check your email',
                  style: AppTextStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent an 8-digit code to',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.t3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  controller.signupEmail,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.accText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  maxLength: 8,
                  style: AppTextStyles.screenTitle.copyWith(
                    letterSpacing: 6,
                    color: AppColors.t1,
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
                              .copyWith(color: AppColors.reText),
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
                        style: AppTextStyles.bodySecondary
                            .copyWith(color: AppColors.t4),
                      );
                    }
                    return GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.resendOtp,
                      child: Text(
                        'Resend code',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.accText),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
