import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/flavor_config.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';

class AuthController extends GetxController {
  final _supabase = SupabaseService.to;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final orgNameController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final onboardingMode = 'create'.obs; // 'create' or 'join'
  final resendCooldown = 0.obs;
  bool _isNavigating = false;
  String _signupEmail = '';
  Timer? _resendTimer;

  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<Uri> _deepLinkSub;

  @override
  void onInit() {
    super.onInit();
    _listenAuthState();
    _listenDeepLinks();
  }

  void _listenAuthState() {
    _authSub = _supabase.onAuthStateChange.listen((data) {
      if (_isNavigating) return;
      if (data.event == AuthChangeEvent.signedIn) {
        _checkMembershipAndNavigate();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _isNavigating = true;
        Get.offAllNamed(AppRoutes.login);
        _isNavigating = false;
      }
    });
  }

  Future<void> checkSession() async {
    if (_isNavigating) return;
    if (_supabase.isAuthenticated) {
      await _checkMembershipAndNavigate();
    }
  }

  Future<void> _checkMembershipAndNavigate() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Check for pending invite code from deep link
      final pendingCode = _supabase.pendingInviteCode.value;
      if (pendingCode != null) {
        await _processPendingInvite(pendingCode);
      }

      // Fetch ALL memberships
      final memberships = await _supabase.getAllMemberships();

      if (memberships.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final hasOnboarded = prefs.getBool('hasCompletedOnboarding') ?? false;
        Get.offAllNamed(hasOnboarded ? AppRoutes.noOrganisation : AppRoutes.onboarding);
        return;
      }

      if (memberships.length == 1) {
        // Single org — auto-select
        await _selectOrg(memberships.first);
        Get.offAllNamed(AppRoutes.shell);
        return;
      }

      // Multiple orgs — check for stored preference
      final prefs = await _getStoredOrgId();
      if (prefs != null) {
        final stored = memberships.where(
          (m) => m['organisation_id'] == prefs,
        );
        if (stored.isNotEmpty) {
          await _selectOrg(stored.first);
          Get.offAllNamed(AppRoutes.shell);
          return;
        }
        // Stored org no longer valid — clear it
        await _supabase.clearActiveOrg();
      }

      // Show org picker
      Get.offAllNamed(AppRoutes.shell); // navigate first, then show picker
      await Future.delayed(const Duration(milliseconds: 300));
      _showOrgPicker(memberships);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('hasCompletedOnboarding') ?? false;
      Get.offAllNamed(hasOnboarded ? AppRoutes.noOrganisation : AppRoutes.onboarding);
    } finally {
      _isNavigating = false;
    }
  }

  Future<String?> _getStoredOrgId() async {
    final uid = _supabase.userId;
    if (uid == null) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_org_$uid');
  }

  Future<void> _selectOrg(Map<String, dynamic> membership) async {
    final orgId = membership['organisation_id'] as String;
    final role = membership['role'] as String;
    final orgData = membership['organisations'] as Map<String, dynamic>;
    final orgName = orgData['name'] as String;
    final plan = orgData['plan'] as String? ?? 'free';
    await _supabase.setActiveOrg(orgId, orgName, role, plan);
    await _supabase.loadOrgUsage();
  }

  Future<void> _processPendingInvite(String code) async {
    try {
      final fullName = _supabase.currentUser?.userMetadata?['full_name'] ??
          _supabase.currentUser?.email ?? 'User';
      await _supabase.client.rpc('accept_invite', params: {
        'p_code': code,
        'p_full_name': fullName,
      });
    } catch (_) {
      // Invite may be invalid/expired — continue with normal flow
    } finally {
      _supabase.pendingInviteCode.value = null;
    }
  }

  void _showOrgPicker(List<Map<String, dynamic>> memberships) {
    final context = Get.context;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                left: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                right: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Organisation', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text('Choose which organisation to open',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 20),
                ...memberships.map((m) {
                  final orgData = m['organisations'] as Map<String, dynamic>;
                  final orgName = orgData['name'] as String;
                  final plan = orgData['plan'] as String? ?? 'free';
                  final role = m['role'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              orgName.isNotEmpty ? orgName[0].toUpperCase() : '?',
                              style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.textOnPrimary),
                            ),
                          ),
                        ),
                        title: Text(orgName, style: AppTextStyles.bodyMedium),
                        subtitle: Text(
                          '${role[0].toUpperCase()}${role.substring(1)} \u2022 ${plan[0].toUpperCase()}${plan.substring(1)}',
                          style: AppTextStyles.caption,
                        ),
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          await _selectOrg(m);
                          // Reload shell data
                          _supabase.onOrgSwitched?.call();
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _listenDeepLinks() {
    final appLinks = AppLinks();
    _deepLinkSub = appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
    // Check initial link (app opened via link while not running)
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Match https://ventry.app/invite/{code}
    if (uri.host == 'ventry.app' && uri.pathSegments.length == 2 && uri.pathSegments[0] == 'invite') {
      final code = uri.pathSegments[1];
      if (code.isEmpty) return;

      if (_supabase.isAuthenticated) {
        // Show confirmation sheet
        _showDeepLinkInviteConfirmation(code);
      } else {
        // Store for after auth
        _supabase.pendingInviteCode.value = code;
      }
    }
  }

  void _showDeepLinkInviteConfirmation(String code) {
    final context = Get.context;
    if (context == null) return;
    final isJoining = false.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                left: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                right: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Join Organisation', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'You\'ve been invited to join an organisation. Would you like to accept?',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text('Invite code: $code',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder, width: 0.5),
                          ),
                          child: Center(
                            child: Text('Cancel', style: AppTextStyles.bodyMedium),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => GestureDetector(
                        onTap: isJoining.value ? null : () async {
                          isJoining.value = true;
                          try {
                            final fullName = _supabase.currentUser?.userMetadata?['full_name'] ??
                                _supabase.currentUser?.email ?? 'User';
                            await _supabase.client.rpc('accept_invite', params: {
                              'p_code': code,
                              'p_full_name': fullName,
                            });

                            // Fetch newly joined org
                            final membership = await _supabase.client
                                .from('org_memberships')
                                .select('organisation_id, role, organisations!inner(name, plan)')
                                .eq('user_id', _supabase.userId!)
                                .order('created_at', ascending: false)
                                .limit(1)
                                .single();

                            final orgId = membership['organisation_id'] as String;
                            final role = membership['role'] as String;
                            final orgData = membership['organisations'] as Map<String, dynamic>;
                            final orgName = orgData['name'] as String;
                            final plan = orgData['plan'] as String? ?? 'free';

                            await _supabase.switchOrg(orgId, orgName, role, plan);

                            if (ctx.mounted) Navigator.of(ctx).pop();
                            Get.snackbar('Joined', 'You joined $orgName',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.surfaceElevated,
                              colorText: AppColors.textPrimary,
                            );
                          } catch (e) {
                            final msg = e is PostgrestException
                                ? e.message
                                : 'This invite link is invalid or has expired';
                            Get.snackbar('Error', msg,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.surfaceElevated,
                              colorText: AppColors.error,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } finally {
                            isJoining.value = false;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColors.goldGradient,
                          ),
                          child: Center(
                            child: isJoining.value
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  )
                                : Text('Join', style: AppTextStyles.button),
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  String get signupEmail => _signupEmail;

  Future<void> signup() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {
          'full_name': fullNameController.text.trim(),
        },
      );
      // Supabase returns empty identities for duplicate emails (no error thrown)
      if (response.user?.identities?.isEmpty ?? false) {
        errorMessage.value =
            'An account with this email already exists. Try signing in.';
      } else if (response.session == null) {
        // Email confirmation required — navigate to OTP screen
        _signupEmail = emailController.text.trim();
        _startResendCooldown();
        Get.toNamed(AppRoutes.verifyOtp);
      }
    } on AuthException catch (e) {
      errorMessage.value = _friendlyAuthError(e);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final code = otpController.text.trim();
    if (code.isEmpty || code.length != 8) {
      errorMessage.value = 'Please enter the 8-digit code';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _supabase.auth.verifyOTP(
        email: _signupEmail,
        token: code,
        type: OtpType.signup,
      );
      // Auth listener handles navigation
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Verification failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendCooldown.value > 0) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _signupEmail,
      );
      _startResendCooldown();
    } on AuthException catch (e) {
      final msg = _friendlyAuthError(e);
      errorMessage.value = msg;
      if (_isRateLimitError(e)) _startResendCooldown();
    } catch (e) {
      errorMessage.value = 'Failed to resend code';
    } finally {
      isLoading.value = false;
    }
  }

  bool _isRateLimitError(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('rate') || msg.contains('limit') || msg.contains('too many');
  }

  String _friendlyAuthError(AuthException e) {
    if (_isRateLimitError(e)) {
      return 'Too many attempts. Please wait a minute before trying again.';
    }
    return e.message;
  }

  void _startResendCooldown() {
    resendCooldown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendCooldown.value--;
      if (resendCooldown.value <= 0) {
        timer.cancel();
      }
    });
  }

  /// Create a new organisation and join as admin
  Future<void> createOrgAndJoin() async {
    if (orgNameController.text.isEmpty) {
      errorMessage.value = 'Please enter an organisation name';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fullName = _supabase.currentUser?.userMetadata?['full_name'] ??
          _supabase.currentUser?.email ??
          'User';

      final orgId = await _supabase.client.rpc('perform_onboarding', params: {
        'p_org_name': orgNameController.text.trim(),
        'p_full_name': fullName,
      });

      // Dev flavor: auto-upgrade to pro for testing
      final plan = FlavorConfig.isDev ? 'pro' : 'free';
      if (FlavorConfig.isDev) {
        await _supabase.client
            .from('organisations')
            .update({'plan': 'pro'})
            .eq('id', orgId);
      }

      await _supabase.setActiveOrg(
        orgId as String,
        orgNameController.text.trim(),
        'admin',
        plan,
      );
      await _supabase.loadOrgUsage();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      Get.offAllNamed(AppRoutes.shell);
    } on PostgrestException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to create organisation';
    } finally {
      isLoading.value = false;
    }
  }

  /// Join an existing organisation via invite code
  Future<void> joinOrgWithInvite() async {
    if (inviteCodeController.text.isEmpty) {
      errorMessage.value = 'Please enter an invite code';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fullName = _supabase.currentUser?.userMetadata?['full_name'] ??
          _supabase.currentUser?.email ??
          'User';

      await _supabase.client.rpc('accept_invite', params: {
        'p_code': inviteCodeController.text.trim(),
        'p_full_name': fullName,
      });

      // Fetch the membership to get org details
      final membership = await _supabase.client
          .from('org_memberships')
          .select('organisation_id, role, organisations!inner(name, plan)')
          .eq('user_id', _supabase.userId!)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final orgId = membership['organisation_id'] as String;
      final role = membership['role'] as String;
      final orgData = membership['organisations'] as Map<String, dynamic>;
      final orgName = orgData['name'] as String;
      final plan = orgData['plan'] as String? ?? 'free';
      await _supabase.setActiveOrg(orgId, orgName, role, plan);
      await _supabase.loadOrgUsage();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      Get.offAllNamed(AppRoutes.shell);
    } on PostgrestException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to join organisation';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      const webClientId =
          '321960813809-njvat391cqmsu5agtrqkf7admoe3oq2u.apps.googleusercontent.com';
      const iosClientId =
          '321960813809-4hd7gkpjsi2brmgb8rnm331dfk7rodns.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        errorMessage.value = 'Failed to get Google credentials';
        isLoading.value = false;
        return;
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Google sign-in failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _supabase.clearSession();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    orgNameController.clear();
    inviteCodeController.clear();
    otpController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    _authSub.cancel();
    _deepLinkSub.cancel();
    _resendTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    orgNameController.dispose();
    inviteCodeController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
