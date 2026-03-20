import 'package:get/get.dart';
import 'shell_controller.dart';
import '../home/home_controller.dart';
import '../items/items_controller.dart';
import '../projects/projects_controller.dart';
import '../account/account_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ItemsController>(() => ItemsController());
    Get.lazyPut<ProjectsController>(() => ProjectsController());
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
