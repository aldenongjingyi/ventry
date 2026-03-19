import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

import '../data/repositories/item_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/services/supabase_service.dart';
import 'glass_card.dart';

void showRelocateSheet(
  BuildContext context, {
  required String itemId,
  required String itemName,
  required int itemNumber,
  VoidCallback? onComplete,
}) {
  final isProcessing = false.obs;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              left: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              right: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Relocate Item', style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          '$itemName  #$itemNumber',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (isProcessing.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }
                return Column(
                  children: [
                    _RelocateOption(
                      icon: Icons.warehouse_outlined,
                      iconColor: AppColors.success,
                      title: 'Move to Storage',
                      subtitle: 'Return item to storage',
                      onTap: () => _doRelocate(
                        context,
                        itemId: itemId,
                        targetStatus: 'storage',
                        isProcessing: isProcessing,
                        onComplete: onComplete,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RelocateOption(
                      icon: Icons.folder_outlined,
                      iconColor: AppColors.primary,
                      title: 'Assign to Project',
                      subtitle: 'Move to an active project',
                      onTap: () => _showProjectPicker(
                        context,
                        itemId: itemId,
                        isProcessing: isProcessing,
                        onComplete: onComplete,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RelocateOption(
                      icon: Icons.error_outline,
                      iconColor: AppColors.error,
                      title: 'Mark as Missing',
                      subtitle: 'Flag this item as missing',
                      onTap: () => _doRelocate(
                        context,
                        itemId: itemId,
                        targetStatus: 'missing',
                        isProcessing: isProcessing,
                        onComplete: onComplete,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RelocateOption(
                      icon: Icons.build_outlined,
                      iconColor: AppColors.warning,
                      title: 'Send to Repair',
                      subtitle: 'Mark as under repair',
                      onTap: () => _doRelocate(
                        context,
                        itemId: itemId,
                        targetStatus: 'under_repair',
                        isProcessing: isProcessing,
                        onComplete: onComplete,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _doRelocate(
  BuildContext context, {
  required String itemId,
  required String targetStatus,
  String? projectId,
  required RxBool isProcessing,
  VoidCallback? onComplete,
}) async {
  isProcessing.value = true;
  try {
    await ItemRepository().relocate(itemId, targetStatus, projectId: projectId);
    if (context.mounted) Navigator.of(context).pop();
    onComplete?.call();
    Get.snackbar('Success', 'Item relocated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surfaceElevated,
      colorText: AppColors.textPrimary,
    );
  } catch (e) {
    Get.snackbar('Error', 'Failed to relocate item',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surfaceElevated,
      colorText: AppColors.error,
    );
  } finally {
    isProcessing.value = false;
  }
}

void _showProjectPicker(
  BuildContext context, {
  required String itemId,
  required RxBool isProcessing,
  VoidCallback? onComplete,
}) async {
  final orgId = SupabaseService.to.activeOrgId.value;
  if (orgId == null) return;

  final projects = await ProjectRepository().getByStatus(orgId, 'active');
  if (projects.isEmpty) {
    Get.snackbar('No Projects', 'Create an active project first',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surfaceElevated,
      colorText: AppColors.textSecondary,
    );
    return;
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              left: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              right: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Project', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ...projects.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: ListTile(
                        leading: Icon(Icons.folder_rounded,
                            color: AppColors.primary, size: 22),
                        title: Text(p.name,
                            style: AppTextStyles.bodyMedium),
                        subtitle: Text(
                            p.location ?? 'No location',
                            style: AppTextStyles.caption),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _doRelocate(
                            context,
                            itemId: itemId,
                            targetStatus: 'in_project',
                            projectId: p.id,
                            isProcessing: isProcessing,
                            onComplete: onComplete,
                          );
                        },
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RelocateOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RelocateOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Icon(Icons.chevron_right,
            color: AppColors.textTertiary, size: 20),
        onTap: onTap,
      ),
    );
  }
}
