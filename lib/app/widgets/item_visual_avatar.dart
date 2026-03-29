import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../data/models/item_visual_model.dart';
import '../theme/app_colors.dart';

/// Displays the visual (icon or photo) for an item.
/// Falls back to a default inventory icon if no visual is set.
class ItemVisualAvatar extends StatelessWidget {
  final ItemVisualModel? visual;
  final double size;
  final double iconSize;
  final double borderRadius;

  const ItemVisualAvatar({
    super.key,
    this.visual,
    this.size = 40,
    this.iconSize = 22,
    this.borderRadius = 10,
  });

  static const _iconMap = <String, IconData>{
    'build': Icons.build_outlined,
    'handyman': Icons.handyman_outlined,
    'hardware': Icons.hardware_outlined,
    'construction': Icons.construction_outlined,
    'carpenter': Icons.carpenter_outlined,
    'plumbing': Icons.plumbing_outlined,
    'electrical': Icons.electrical_services_outlined,
    'power': Icons.power_outlined,
    'cable': Icons.cable_outlined,
    'bolt': Icons.bolt_outlined,
    'flashlight': Icons.flashlight_on_outlined,
    'safety': Icons.health_and_safety_outlined,
    'shield': Icons.shield_outlined,
    'hard_hat': Icons.engineering_outlined,
    'fire_extinguisher': Icons.fire_extinguisher_outlined,
    'warning': Icons.warning_amber_outlined,
    'straighten': Icons.straighten_outlined,
    'square_foot': Icons.square_foot_outlined,
    'speed': Icons.speed_outlined,
    'thermostat': Icons.thermostat_outlined,
    'scale': Icons.scale_outlined,
    'local_shipping': Icons.local_shipping_outlined,
    'precision_manufacturing': Icons.precision_manufacturing_outlined,
    'agriculture': Icons.agriculture_outlined,
    'rv_hookup': Icons.rv_hookup_outlined,
    'computer': Icons.computer_outlined,
    'phone': Icons.phone_android_outlined,
    'tablet': Icons.tablet_android_outlined,
    'camera': Icons.camera_alt_outlined,
    'router': Icons.router_outlined,
    'print': Icons.print_outlined,
    'headset': Icons.headset_outlined,
    'speaker': Icons.speaker_outlined,
    'inventory': Icons.inventory_2_outlined,
    'chair': Icons.chair_outlined,
    'desk': Icons.desk_outlined,
    'light': Icons.light_outlined,
    'key': Icons.key_outlined,
    'lock': Icons.lock_outlined,
    'cleaning': Icons.cleaning_services_outlined,
    'medical': Icons.medical_services_outlined,
    'medication': Icons.medication_outlined,
    'monitor_heart': Icons.monitor_heart_outlined,
    'park': Icons.park_outlined,
    'water': Icons.water_drop_outlined,
    'solar': Icons.solar_power_outlined,
    'air': Icons.air_outlined,
  };

  @override
  Widget build(BuildContext context) {
    if (visual != null && visual!.isPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: visual!.visualValue,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _placeholder(),
          errorWidget: (context, url, error) => _fallback(),
        ),
      );
    }

    if (visual != null && visual!.isIcon) {
      final iconData = _iconMap[visual!.visualValue] ?? Icons.inventory_2_outlined;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.accBg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(iconData, size: iconSize, color: AppColors.acc),
      );
    }

    return _fallback();
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: iconSize * 0.6,
          height: iconSize * 0.6,
          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.t4),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(Icons.inventory_2_outlined, size: iconSize, color: AppColors.t4),
    );
  }
}
