import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gold_button.dart';
import '../../utils/qr_label_export.dart';

class ItemAddedView extends StatelessWidget {
  final ItemModel item;

  const ItemAddedView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isSharing = false.obs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Success icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.textOnPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Item added', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: AppTextStyles.subtitle
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '#VT-${item.itemNumber.toString().padLeft(3, '0')}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 28),
                // QR Code
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderColor: AppColors.goldGlassBorder,
                  showGlow: true,
                  glow: AppColors.subtleGlow,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: item.qrCode,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Print label button
                Obx(() => GoldButton(
                      onPressed: isSharing.value
                          ? null
                          : () async {
                              isSharing.value = true;
                              await shareQrLabel(item);
                              isSharing.value = false;
                            },
                      isLoading: isSharing.value,
                      label: 'Print label',
                    )),
                const SizedBox(height: 12),
                // Done button
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Get.back(); // pop confirmation
                        Get.toNamed('/items/${item.id}');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Done',
                            style: AppTextStyles.subtitle
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
