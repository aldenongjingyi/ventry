import 'package:get/get.dart';
import 'equipment_controller.dart';

class EquipmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EquipmentController>(() => EquipmentController());
  }
}
