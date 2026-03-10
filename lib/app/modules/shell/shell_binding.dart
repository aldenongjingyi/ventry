import 'package:get/get.dart';
import 'shell_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../equipment/equipment_controller.dart';
import '../projects/projects_controller.dart';
import '../team/team_controller.dart';
import '../more/more_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<EquipmentController>(() => EquipmentController());
    Get.lazyPut<ProjectsController>(() => ProjectsController());
    Get.lazyPut<TeamController>(() => TeamController());
    Get.lazyPut<MoreController>(() => MoreController());
  }
}
