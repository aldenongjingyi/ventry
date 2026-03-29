import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../data/models/item_model.dart';
import '../data/models/activity_log_model.dart';
import '../data/services/supabase_service.dart';
import '../modules/items/items_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/qr_label_export.dart';
import 'glass_card.dart';
import 'item_visual_avatar.dart';
import 'relocate_sheet.dart';

/// Reusable item detail content. Can be used in a full page or a modal.
class ItemDetailContent extends StatelessWidget {
  final ItemModel item;
  final List<ActivityLogModel> activities;
  final VoidCallback onRelocated;
  final VoidCallback? onDelete;

  const ItemDetailContent({
    super.key,
    required this.item,
    required this.activities,
    required this.onRelocated,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(context),
          const SizedBox(height: 12),

          // ── Status + meta row ──
          _buildMetaRow(),
          const SizedBox(height: 24),

          // ── QR Code ──
          _buildQrCard(context),
          const SizedBox(height: 16),

          // ── Details card ──
          _buildDetailsCard(),
          const SizedBox(height: 16),

          // ── Relocate button ──
          _buildRelocateButton(context),
          const SizedBox(height: 24),

          // ── Activity History ──
          _buildActivitySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final itemsCtrl = Get.find<ItemsController>();
    final visual = itemsCtrl.getVisual(item.name);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ItemVisualAvatar(
          visual: visual,
          size: 56,
          iconSize: 30,
          borderRadius: 16,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: AppTextStyles.screenTitle),
              const SizedBox(height: 4),
              Row(
                children: [
                  // ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(item.displayId,
                        style: AppTextStyles.micro.copyWith(color: AppColors.accText)),
                  ),
                  // Label color
                  if (item.labelColor != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getLabelColor(item.labelColor!),
                        border: Border.all(
                          color: item.labelColor == 'black'
                              ? AppColors.border3
                              : Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Meta row (status + group) ───────────────────────────────────────

  Widget _buildMetaRow() {
    final badge = AppColors.statusBadge(item.status);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badge.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badge.border, width: 0.5),
          ),
          child: Text(
            item.displayStatus,
            style: AppTextStyles.micro.copyWith(color: badge.text, fontWeight: FontWeight.w500),
          ),
        ),
        // Group pill
        if (item.itemGroupName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.emBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.emBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_outlined, size: 12, color: AppColors.emText),
                const SizedBox(width: 4),
                Text(
                  item.itemGroupName!,
                  style: AppTextStyles.micro.copyWith(color: AppColors.emText),
                ),
              ],
            ),
          ),
        // Project pill
        if (item.projectName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.accBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rocket_launch_outlined, size: 12, color: AppColors.accText),
                const SizedBox(width: 4),
                Text(
                  item.projectName!,
                  style: AppTextStyles.micro.copyWith(color: AppColors.accText),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── QR Card ─────────────────────────────────────────────────────────

  Widget _buildQrCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQrFullscreen(context),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('QR CODE', style: AppTextStyles.sectionLabel),
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
            Text('Tap to enlarge', style: AppTextStyles.micro.copyWith(color: AppColors.t4)),
          ],
        ),
      ),
    );
  }

  // ─── Details card ────────────────────────────────────────────────────

  Widget _buildDetailsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAILS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          _DetailRow(label: 'Status', value: item.displayStatus,
              valueColor: AppColors.getStatusColor(item.status)),
          if (item.projectName != null)
            _DetailRow(label: 'Project', value: item.projectName!, valueColor: AppColors.accText),
          if (item.itemGroupName != null)
            _DetailRow(label: 'Group', value: item.itemGroupName!),
          if (item.labelColor != null)
            _DetailRow(label: 'Label', value: item.labelColor!, widget: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getLabelColor(item.labelColor!),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
            )),
          _DetailRow(label: 'Item #', value: '#${item.itemNumber}'),
          if (item.notes != null && item.notes!.isNotEmpty)
            _DetailRow(label: 'Notes', value: item.notes!),
          _DetailRow(label: 'Created', value: DateFormat.yMMMd().format(item.createdAt)),
          _DetailRow(label: 'Updated', value: DateFormat.yMMMd().format(item.updatedAt)),
        ],
      ),
    );
  }

  // ─── Relocate ────────────────────────────────────────────────────────

  Widget _buildRelocateButton(BuildContext context) {
    return SizedBox(
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
            onComplete: onRelocated,
          ),
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Relocate', style: TextStyle(
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
    );
  }

  // ─── Activity ────────────────────────────────────────────────────────

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACTIVITY HISTORY', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 12),
        if (!SupabaseService.to.canViewActivityLog)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.t4, size: 28),
                const SizedBox(height: 8),
                Text('Activity history is available on Pro',
                    style: AppTextStyles.bodySecondary.copyWith(color: AppColors.t3),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Get.toNamed('/upgrade'),
                  child: Text('Upgrade',
                      style: AppTextStyles.body.copyWith(color: AppColors.accText)),
                ),
              ],
            ),
          )
        else if (activities.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text('No activity yet', style: AppTextStyles.bodySecondary),
            ),
          )
        else
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface3,
                          borderRadius: BorderRadius.circular(8),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.displayAction,
                              style: AppTextStyles.bodySecondary.copyWith(color: AppColors.t1),
                            ),
                            Text(
                              '${a.userName ?? 'Unknown'} \u2022 ${DateFormat.yMMMd().format(a.createdAt)}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ─── QR fullscreen ───────────────────────────────────────────────────

  void _showQrFullscreen(BuildContext context) {
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
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.acc),
                          )
                        : const Icon(Icons.share_outlined, color: AppColors.acc),
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
                  Text(item.displayId, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  IconData _getActionIcon(String action) {
    return switch (action) {
      'create' => Icons.add_circle_outline,
      'move_to_project' => Icons.arrow_forward,
      'return_to_storage' => Icons.warehouse_outlined,
      'mark_missing' => Icons.error_outline,
      'mark_repair' => Icons.build_outlined,
      'update' => Icons.edit_outlined,
      _ => Icons.history,
    };
  }

  static const _labelColorMap = <String, Color>{
    'red': Color(0xFFEF4444),
    'green': Color(0xFF22C55E),
    'blue': Color(0xFF3B82F6),
    'yellow': Color(0xFFEAB308),
    'pink': Color(0xFFEC4899),
    'cyan': Color(0xFF06B6D4),
    'white': Color(0xFFFFFFFF),
    'black': Color(0xFF000000),
  };

  Color _getLabelColor(String colorValue) {
    return _labelColorMap[colorValue] ?? _parseHex(colorValue);
  }

  Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) return Color(int.parse('FF$cleaned', radix: 16));
    return AppColors.t4;
  }
}

// ─── Detail row widget ─────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? widget;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.widget,
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
          if (widget != null) ...[
            widget!,
            const SizedBox(width: 8),
          ],
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
