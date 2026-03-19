import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../items/items_list_view.dart';
import '../scan/scan_view.dart';
import '../scan/scan_binding.dart';
import '../projects/projects_list_view.dart';
import '../account/account_view.dart';
import '../account/members_view.dart';
import 'shell_controller.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          ItemsListView(),      // 0
          ProjectsListView(),   // 1
          MembersView(),        // 2
          AccountView(),        // 3
        ],
      )),
      extendBody: true,
      bottomNavigationBar: Obx(() => _VentryBottomBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        onScanTap: () => Get.to(
          () => const ScanView(),
          fullscreenDialog: true,
          binding: ScanBinding(),
        ),
      )),
    );
  }
}

class _VentryBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;

  const _VentryBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const barHeight = 60.0;
    const fabSize = 56.0;
    const fabRaise = 22.0;

    return SizedBox(
      height: barHeight + bottomPadding + fabRaise,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glass bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottomPadding,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x0AFFFFFF),
                    border: const Border(
                      top: BorderSide(color: Color(0x15FFFFFF), width: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Items',
                        isActive: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.folder_rounded,
                        label: 'Projects',
                        isActive: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      // Center spacer for FAB
                      const SizedBox(width: 72),
                      _NavItem(
                        icon: Icons.people_rounded,
                        label: 'Members',
                        isActive: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Account',
                        isActive: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Center scan FAB
          Positioned(
            bottom: barHeight / 2 - fabSize / 2 + bottomPadding - 2,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onScanTap,
                child: Container(
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: -4,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.textOnPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: color,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
