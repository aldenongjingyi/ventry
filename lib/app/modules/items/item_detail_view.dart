import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/relocate_sheet.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/qr_label_export.dart';
import 'item_detail_controller.dart';

class ItemDetailView extends GetView<ItemDetailController> {
  const ItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.acc),
          );
        }
        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: const Icon(Icons.cloud_off_rounded,
                        size: 20, color: AppColors.t5),
                  ),
                  const SizedBox(height: 16),
                  Text("Couldn't load item",
                      style: AppTextStyles.itemName
                          .copyWith(color: AppColors.t1)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: controller.loadItem,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border2, width: 0.5),
                      ),
                      child: Text('Retry',
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.t2)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final item = controller.item.value;
        if (item == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        size: 20, color: AppColors.t5),
                  ),
                  const SizedBox(height: 16),
                  Text('This item no longer exists',
                      style: AppTextStyles.itemName
                          .copyWith(color: AppColors.t1)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border2, width: 0.5),
                      ),
                      child: Text('Go back',
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.t2)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.t1),
                onPressed: () => Get.back(),
              ),
              actions: [
                if (SupabaseService.to.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.reText, size: 22),
                    onPressed: () => _confirmDelete(context),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.name,
                              style: AppTextStyles.screenTitle),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('#${item.itemNumber}',
                              style: AppTextStyles.micro
                                  .copyWith(color: AppColors.accText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status pill
                    Builder(builder: (_) {
                      final badge = AppColors.statusBadge(item.status);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: badge.bg,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: badge.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          item.displayStatus,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ).copyWith(color: badge.text),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // QR Code card -- tappable
                    GestureDetector(
                      onTap: () => _showQrFullscreen(context, item),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text('QR CODE',
                                style: AppTextStyles.sectionLabel),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                data: item.qrCode,
                                version: QrVersions.auto,
                                size: 160,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to enlarge',
                              style: AppTextStyles.micro
                                  .copyWith(color: AppColors.t4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DETAILS',
                              style: AppTextStyles.sectionLabel),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'Status',
                            value: item.displayStatus,
                            valueColor:
                                AppColors.getStatusColor(item.status),
                          ),
                          if (item.projectName != null)
                            _DetailRow(
                              label: 'Project',
                              value: item.projectName!,
                              valueColor: AppColors.accText,
                            ),
                          if (item.notes != null &&
                              item.notes!.isNotEmpty)
                            _DetailRow(
                              label: 'Notes',
                              value: item.notes!,
                            ),
                          _DetailRow(
                            label: 'Created',
                            value: DateFormat.yMMMd()
                                .format(item.createdAt),
                          ),
                          _DetailRow(
                            label: 'Updated',
                            value: DateFormat.yMMMd()
                                .format(item.updatedAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Relocate button
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppColors.acc,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => showRelocateSheet(
                            context,
                            itemId: item.id,
                            itemName: item.name,
                            itemNumber: item.itemNumber,
                            onComplete: controller.loadItem,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_horiz,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Relocate',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Activity History
                    Text('ACTIVITY HISTORY',
                        style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (!SupabaseService.to.canViewActivityLog) {
                        return GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.lock_outline,
                                  color: AppColors.t4, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                  'Activity history is available on Pro',
                                  style: AppTextStyles.bodySecondary
                                      .copyWith(color: AppColors.t3),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => Get.toNamed('/upgrade'),
                                child: Text('Upgrade',
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.accText)),
                              ),
                            ],
                          ),
                        );
                      }
                      if (controller.activities.isEmpty) {
                        return GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text('No activity yet',
                                style: AppTextStyles.bodySecondary),
                          ),
                        );
                      }
                      return Column(
                        children: controller.activities
                            .map((a) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.surface3,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getActionIcon(a.action),
                                            color: AppColors.t3,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                a.displayAction,
                                                style: AppTextStyles
                                                    .bodySecondary
                                                    .copyWith(
                                                        color: AppColors
                                                            .t1),
                                              ),
                                              Text(
                                                '${a.userName ?? 'Unknown'} \u2022 ${DateFormat.yMMMd().format(a.createdAt)}',
                                                style:
                                                    AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add_circle_outline;
      case 'move_to_project':
        return Icons.arrow_forward;
      case 'return_to_storage':
        return Icons.warehouse_outlined;
      case 'mark_missing':
        return Icons.error_outline;
      case 'mark_repair':
        return Icons.build_outlined;
      case 'update':
        return Icons.edit_outlined;
      default:
        return Icons.history;
    }
  }

  void _showQrFullscreen(BuildContext context, item) {
    final isSharing = false.obs;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.t1),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Obx(() => IconButton(
                    icon: isSharing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.acc,
                            ),
                          )
                        : const Icon(Icons.share_outlined,
                            color: AppColors.acc),
                    onPressed: isSharing.value
                        ? null
                        : () async {
                            isSharing.value = true;
                            await shareQrLabel(item);
                            isSharing.value = false;
                          },
                  )),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: item.qrCode,
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(item.name, style: AppTextStyles.screenTitle),
                  const SizedBox(height: 6),
                  Text(
                    '#VT-${item.itemNumber.toString().padLeft(3, '0')}',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface3,
        title: Text('Delete Item', style: AppTextStyles.cardTitle),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodySecondary
                    .copyWith(color: AppColors.t3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteItem();
            },
            child: Text('Delete',
                style: AppTextStyles.bodySecondary
                    .copyWith(color: AppColors.reText)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: valueColor ?? AppColors.t2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
