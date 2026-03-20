import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';

class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.t1),
                    onPressed: () => Get.back(),
                  ),
                  Text('Scan Result', style: AppTextStyles.cardTitle),
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
    );
  }

  Widget _buildContent(Map<String, dynamic>? args) {
    if (args == null) {
      return _buildState(
        icon: Icons.qr_code_2_rounded,
        color: AppColors.t4,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 24, color: AppColors.acc),
            ),
            const SizedBox(height: 16),
            Text('Item Found', style: AppTextStyles.screenTitle),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (args['name'] != null)
                    Text(args['name'] as String,
                        style: AppTextStyles.itemName),
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
                child: Material(
                  color: AppColors.acc,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () =>
                        Get.toNamed('/items/${args['itemId']}'),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Center(
                        child:
                            Text('View Details', style: AppTextStyles.button),
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
          color: AppColors.amText,
          title: 'Wrong Organisation',
          subtitle: "This item doesn't belong to your organisation",
        );

      default:
        return _buildState(
          icon: Icons.qr_code_2_rounded,
          color: AppColors.t4,
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
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border2, width: 0.5),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.screenTitle),
        const SizedBox(height: 8),
        Text(subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.t3),
            textAlign: TextAlign.center),
      ],
    );
  }
}
