import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
import '../../widgets/relocate_sheet.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/qr_label_export.dart';
import 'item_detail_controller.dart';

class ItemDetailView extends GetView<ItemDetailController> {
  const ItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text("Couldn't load item",
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: controller.loadItem,
                      child: Text('Try again',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
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
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text('This item no longer exists',
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Go back',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
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
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  if (SupabaseService.to.isAdmin)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                      onPressed: () => _confirmDelete(context),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.name, style: AppTextStyles.h1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('#${item.itemNumber}',
                                style: AppTextStyles.itemNumber),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.getStatusColor(item.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.getStatusColor(item.status)
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          item.displayStatus,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.getStatusColor(item.status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // QR Code card — tappable
                      GestureDetector(
                        onTap: () => _showQrFullscreen(context, item),
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderColor: AppColors.goldGlassBorder,
                          showGlow: true,
                          glow: AppColors.subtleGlow,
                          child: Column(
                            children: [
                              Text('QR Code',
                                  style: AppTextStyles.captionMedium),
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
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textTertiary),
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
                            Text('Details',
                                style: AppTextStyles.captionMedium),
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
                                valueColor: AppColors.primary,
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

                      // Actions
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => showRelocateSheet(
                              context,
                              itemId: item.id,
                              itemName: item.name,
                              itemNumber: item.itemNumber,
                              onComplete: controller.loadItem,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.swap_horiz,
                                      color: AppColors.textOnPrimary,
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text('Relocate',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textOnPrimary,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Activity History
                      Text('Activity History',
                          style: AppTextStyles.captionMedium),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (!SupabaseService.to.canViewActivityLog) {
                          return GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.lock_outline,
                                    color: AppColors.textTertiary, size: 28),
                                const SizedBox(height: 8),
                                Text('Activity history is available on Pro',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => Get.toNamed('/upgrade'),
                                  child: Text('Upgrade',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(color: AppColors.primary)),
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
                                  style: AppTextStyles.bodySmall),
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
                                              color: AppColors.glass,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getActionIcon(a.action),
                                              color:
                                                  AppColors.textSecondary,
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
                                                      .bodySmall
                                                      .copyWith(
                                                          color: AppColors
                                                              .textPrimary),
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
      ),
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
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
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.share_outlined,
                            color: AppColors.primary),
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
                  Text(item.name, style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Text(
                    '#VT-${item.itemNumber.toString().padLeft(3, '0')}',
                    style: AppTextStyles.bodySmall,
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
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Delete Item', style: AppTextStyles.h3),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteItem();
            },
            child: Text('Delete',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
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
            child:
                Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
