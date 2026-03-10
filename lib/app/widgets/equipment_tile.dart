import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/models/equipment_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

class EquipmentTile extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showCategory;

  const EquipmentTile({
    super.key,
    required this.equipment,
    this.onTap,
    this.trailing,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (showCategory && equipment.categoryName != null) ...[
                            Text(
                              equipment.categoryName!,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (equipment.barcode != null)
                            Text(
                              equipment.barcode!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing != null) trailing! else StatusBadge(status: equipment.status, small: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
