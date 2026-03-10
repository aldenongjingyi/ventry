import 'package:get/get.dart';
import '../data/services/supabase_service.dart';
import '../data/services/scanner_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SupabaseService(), permanent: true);
    Get.put(ScannerService(), permanent: true);
  }
}
