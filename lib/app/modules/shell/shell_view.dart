import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../home/home_view.dart';
import '../items/items_list_view.dart';
import '../scan/scan_view.dart';
import '../scan/scan_binding.dart';
import '../projects/projects_list_view.dart';
import '../account/account_view.dart';
import 'shell_controller.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Brand bar — shared across all tabs
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.acc,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ventry',
                          style: AppTextStyles.itemName.copyWith(
                            color: AppColors.t1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() => IndexedStack(
                      index: controller.currentIndex.value,
                      children: const [
                        HomeView(),           // 0
                        ProjectsListView(),   // 1
                        ItemsListView(),      // 2
                        AccountView(),        // 3
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => VentryBottomNav(
            currentIndex: controller.currentIndex.value,
            onTabSelected: controller.changePage,
            onScanTapped: () => Get.to(
              () => const ScanView(),
              fullscreenDialog: true,
              binding: ScanBinding(),
            ),
          )),
        ],
      ),
    );
  }
}

class VentryBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onScanTapped;

  static const _barHeight = 64.0;
  static const _fabSize = 56.0;
  static const _fabBorder = 3.0;
  static const _fabRaise = 28.0;

  const VentryBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: _barHeight + bottomPadding + _fabRaise,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _barHeight + bottomPadding,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface1,
                border: Border(
                  top: BorderSide(color: AppColors.border1, width: 0.5),
                ),
              ),
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                children: [
                  _NavItem(
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  _NavItem(
                    activeIcon: Icons.folder_rounded,
                    inactiveIcon: Icons.folder_outlined,
                    label: 'Projects',
                    isActive: currentIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                  // Center placeholder for FAB
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    activeIcon: Icons.inventory_2_rounded,
                    inactiveIcon: Icons.inventory_2_outlined,
                    label: 'Items',
                    isActive: currentIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                  _NavItem(
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    label: 'Account',
                    isActive: currentIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                ],
              ),
            ),
          ),
          // Center scan FAB
          Positioned(
            bottom: _barHeight - _fabRaise + bottomPadding,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onScanTapped,
                child: Container(
                  width: _fabSize + _fabBorder * 2,
                  height: _fabSize + _fabBorder * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.canvas,
                  ),
                  child: Center(
                    child: Container(
                      width: _fabSize,
                      height: _fabSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.acc,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.textOnPrimary,
                        size: 28,
                      ),
                    ),
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
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.acc : AppColors.t5;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
