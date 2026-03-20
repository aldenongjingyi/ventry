import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
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
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.acc,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.textOnPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text('Item added', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: AppTextStyles.itemName
                    .copyWith(color: AppColors.t3),
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
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Get.back(); // pop confirmation
                      Get.toNamed('/items/${item.id}');
                    },
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
                      child: Center(
                        child: Text(
                          'Done',
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.t2),
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
    );
  }
}
