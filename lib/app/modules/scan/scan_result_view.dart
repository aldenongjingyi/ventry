import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';

class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => Get.back(),
                    ),
                    Text('Scan Result', style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _buildContent(args),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic>? args) {
    if (args == null) {
      return _buildState(
        icon: Icons.qr_code_2_rounded,
        color: AppColors.textTertiary,
        title: 'Unknown QR Code',
        subtitle: 'This QR code is not recognised',
      );
    }

    final state = args['state'] as String? ?? 'unknown';

    switch (state) {
      case 'found':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Item Found', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (args['name'] != null)
                    Text(args['name'] as String,
                        style: AppTextStyles.subtitle),
                  if (args['status'] != null) ...[
                    const SizedBox(height: 4),
                    Text(args['status'] as String,
                        style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (args['itemId'] != null) ...[
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.goldGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () =>
                          Get.toNamed('/items/${args['itemId']}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child:
                              Text('View Details', style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );

      case 'wrong_org':
        return _buildState(
          icon: Icons.block_rounded,
          color: AppColors.warning,
          title: 'Wrong Organisation',
          subtitle: "This item doesn't belong to your organisation",
        );

      default:
        return _buildState(
          icon: Icons.qr_code_2_rounded,
          color: AppColors.textTertiary,
          title: 'Unknown QR Code',
          subtitle: 'This QR code is not recognised',
        );
    }
  }

  Widget _buildState({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 56, color: color),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }
}
