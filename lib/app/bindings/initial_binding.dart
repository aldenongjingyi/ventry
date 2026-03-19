import 'package:get/get.dart';
import '../data/services/supabase_service.dart';
import '../modules/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseService>()) {
      Get.put(SupabaseService(), permanent: true);
    }
    Get.put(AuthController(), permanent: true);
  }
}
