import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';

class MoreController extends GetxController {
  final _supabase = SupabaseService.to;

  String get userEmail => _supabase.currentUser?.email ?? '';

  Future<void> logout() async {
    await _supabase.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
