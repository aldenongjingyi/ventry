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
  List<String>? bulkItemIds,
}) {
  final ids = bulkItemIds ?? [itemId];
  final isProcessing = false.obs;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.border1, width: 0.5),
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
                  color: AppColors.border2,
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
                      Text(
                        ids.length > 1 ? 'Relocate Items' : 'Relocate Item',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ids.length > 1
                            ? '${ids.length} items selected'
                            : '$itemName  #$itemNumber',
                        style: AppTextStyles.bodySecondary,
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
                        color: AppColors.acc),
                  ),
                );
              }
              return Column(
                children: [
                  _RelocateOption(
                    icon: Icons.warehouse_outlined,
                    iconBg: AppColors.emBg,
                    iconBorder: AppColors.emBorder,
                    iconColor: AppColors.em,
                    title: 'Move to Storage',
                    subtitle: 'Return item to storage',
                    onTap: () => _doBulkRelocate(
                      context,
                      itemIds: ids,
                      targetStatus: 'storage',
                      isProcessing: isProcessing,
                      onComplete: onComplete,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RelocateOption(
                    icon: Icons.folder_outlined,
                    iconBg: AppColors.accBg,
                    iconBorder: AppColors.accBorder,
                    iconColor: AppColors.acc,
                    title: 'Assign to Project',
                    subtitle: 'Move to an active project',
                    onTap: () => _showProjectPicker(
                      context,
                      itemIds: ids,
                      isProcessing: isProcessing,
                      onComplete: onComplete,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RelocateOption(
                    icon: Icons.error_outline,
                    iconBg: AppColors.reBg,
                    iconBorder: AppColors.reBorder,
                    iconColor: AppColors.re,
                    title: 'Mark as Missing',
                    subtitle: 'Flag this item as missing',
                    onTap: () => _doBulkRelocate(
                      context,
                      itemIds: ids,
                      targetStatus: 'missing',
                      isProcessing: isProcessing,
                      onComplete: onComplete,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RelocateOption(
                    icon: Icons.build_outlined,
                    iconBg: AppColors.amBg,
                    iconBorder: AppColors.amBorder,
                    iconColor: AppColors.am,
                    title: 'Send to Repair',
                    subtitle: 'Mark as under repair',
                    onTap: () => _doBulkRelocate(
                      context,
                      itemIds: ids,
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
  );
}

Future<void> _doBulkRelocate(
  BuildContext context, {
  required List<String> itemIds,
  required String targetStatus,
  String? projectId,
  required RxBool isProcessing,
  VoidCallback? onComplete,
}) async {
  isProcessing.value = true;
  try {
    final repo = ItemRepository();
    for (final id in itemIds) {
      await repo.relocate(id, targetStatus, projectId: projectId);
    }
    if (context.mounted) Navigator.of(context).pop();
    onComplete?.call();
    final label = itemIds.length > 1 ? '${itemIds.length} items relocated' : 'Item relocated';
    Get.snackbar('Success', label,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surface3,
      colorText: AppColors.t1,
    );
  } catch (e) {
    Get.snackbar('Error', 'Failed to relocate',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surface3,
      colorText: AppColors.reText,
    );
  } finally {
    isProcessing.value = false;
  }
}

void _showProjectPicker(
  BuildContext context, {
  required List<String> itemIds,
  required RxBool isProcessing,
  VoidCallback? onComplete,
}) async {
  final orgId = SupabaseService.to.activeOrgId.value;
  if (orgId == null) return;

  final projects = await ProjectRepository().getByStatus(orgId, 'active');
  if (projects.isEmpty) {
    Get.snackbar('No Projects', 'Create an active project first',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surface3,
      colorText: AppColors.t2,
    );
    return;
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).padding.bottom + 16),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.border1, width: 0.5),
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
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Project', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            ...projects.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accBorder,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(Icons.folder_rounded,
                            color: AppColors.acc, size: 20),
                      ),
                      title: Text(p.name,
                          style: AppTextStyles.body),
                      subtitle: Text(
                          p.location ?? 'No location',
                          style: AppTextStyles.caption),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _doBulkRelocate(
                          context,
                          itemIds: itemIds,
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
  );
}

class _RelocateOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RelocateOption({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
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
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: iconBorder,
              width: 0.5,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: AppTextStyles.body),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.t4, size: 20),
        onTap: onTap,
      ),
    );
  }
}
