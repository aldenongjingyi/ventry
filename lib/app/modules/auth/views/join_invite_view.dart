import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/glass_background.dart';
import '../../../data/services/supabase_service.dart';
import '../../../routes/app_routes.dart';

class JoinInviteView extends StatefulWidget {
  const JoinInviteView({super.key});

  @override
  State<JoinInviteView> createState() => _JoinInviteViewState();
}

class _JoinInviteViewState extends State<JoinInviteView> {
  final _isJoining = false.obs;
  final _error = ''.obs;

  String get code => Get.parameters['code'] ?? '';

  Future<void> _join() async {
    if (code.isEmpty) return;
    _isJoining.value = true;
    _error.value = '';

    try {
      final supabase = SupabaseService.to;
      final fullName = supabase.currentUser?.userMetadata?['full_name'] ??
          supabase.currentUser?.email ?? 'User';

      await supabase.client.rpc('accept_invite', params: {
        'p_code': code,
        'p_full_name': fullName,
      });

      // Fetch newly joined org
      final membership = await supabase.client
          .from('org_memberships')
          .select('organisation_id, role, organisations!inner(name, plan)')
          .eq('user_id', supabase.userId!)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final orgId = membership['organisation_id'] as String;
      final role = membership['role'] as String;
      final orgData = membership['organisations'] as Map<String, dynamic>;
      final orgName = orgData['name'] as String;
      final plan = orgData['plan'] as String? ?? 'free';

      await supabase.setActiveOrg(orgId, orgName, role, plan);
      await supabase.loadOrgUsage();

      Get.offAllNamed(AppRoutes.shell);
      Get.snackbar('Joined', 'You joined $orgName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.textPrimary,
      );
    } on PostgrestException catch (e) {
      _error.value = e.message;
    } catch (_) {
      _error.value = 'This invite link is invalid or has expired';
    } finally {
      _isJoining.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.group_add_rounded,
                    size: 56, color: AppColors.primary),
                const SizedBox(height: 20),
                Text('Join Organisation',
                    style: AppTextStyles.h2, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  "You've been invited to join an organisation",
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vpn_key_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text('Code: $code', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                Obx(() => _error.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error.value,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                            textAlign: TextAlign.center),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 24),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _isJoining.value ? null : _join,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: _isJoining.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : Text('Join', style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
