import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/verify_otp_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/no_organisation_view.dart';
import '../modules/auth/views/join_invite_view.dart';
import '../modules/shell/shell_binding.dart';
import '../modules/shell/shell_view.dart';
import '../modules/items/item_detail_view.dart';
import '../modules/items/item_detail_controller.dart';
import '../modules/scan/scan_binding.dart';
import '../modules/scan/scan_view.dart';
import '../modules/scan/scan_result_view.dart';
import '../modules/projects/project_detail_view.dart';
import '../modules/projects/project_detail_controller.dart';
import '../modules/account/about_view.dart';
import '../modules/account/scanner_settings_view.dart';
import '../modules/account/upgrade_view.dart';

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
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.noOrganisation,
      page: () => const NoOrganisationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.itemDetail,
      page: () => const ItemDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ItemDetailController>(() => ItemDetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.scan,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: AppRoutes.scanResult,
      page: () => const ScanResultView(),
    ),
    GetPage(
      name: AppRoutes.projectDetail,
      page: () => const ProjectDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProjectDetailController>(() => ProjectDetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
    ),
    GetPage(
      name: AppRoutes.scannerSettings,
      page: () => const ScannerSettingsView(),
    ),
    GetPage(
      name: AppRoutes.joinInvite,
      page: () => const JoinInviteView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.upgrade,
      page: () => const UpgradeView(),
    ),
  ];
}
