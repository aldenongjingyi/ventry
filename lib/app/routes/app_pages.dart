import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/shell/shell_binding.dart';
import '../modules/shell/shell_view.dart';
import '../modules/equipment/equipment_binding.dart';
import '../modules/equipment/equipment_detail_view.dart';
import '../modules/scan/scan_binding.dart';
import '../modules/scan/scan_view.dart';
import '../modules/checkout/checkout_binding.dart';
import '../modules/checkout/checkout_view.dart';
import '../modules/checkin/checkin_binding.dart';
import '../modules/checkin/checkin_view.dart';
import '../modules/projects/project_detail_view.dart';
import '../modules/more/screens/placeholder_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.equipmentDetail,
      page: () => const EquipmentDetailView(),
      binding: EquipmentBinding(),
    ),
    GetPage(
      name: AppRoutes.scan,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.checkin,
      page: () => const CheckinView(),
      binding: CheckinBinding(),
    ),
    GetPage(
      name: AppRoutes.projectDetail,
      page: () => const ProjectDetailView(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const PlaceholderScreen(title: 'Reports'),
    ),
    GetPage(
      name: AppRoutes.printLabels,
      page: () => const PlaceholderScreen(title: 'Print Labels'),
    ),
    GetPage(
      name: AppRoutes.maintenanceLog,
      page: () => const PlaceholderScreen(title: 'Maintenance Log'),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const PlaceholderScreen(title: 'Settings'),
    ),
  ];
}
