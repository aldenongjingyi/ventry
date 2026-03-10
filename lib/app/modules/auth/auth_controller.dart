import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final _supabase = SupabaseService.to;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final companyNameController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  bool _isNavigating = false;

  late final _authSub;

  @override
  void onInit() {
    super.onInit();
    _listenAuthState();
  }

  void _listenAuthState() {
    _authSub = _supabase.onAuthStateChange.listen((data) {
      if (_isNavigating) return;
      if (data.event == AuthChangeEvent.signedIn) {
        _checkProfileAndNavigate();
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
      await _checkProfileAndNavigate();
    }
  }

  Future<void> _checkProfileAndNavigate() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final profile = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', _supabase.userId!)
          .maybeSingle();

      if (profile != null) {
        Get.offAllNamed(AppRoutes.shell);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.onboarding);
    } finally {
      _isNavigating = false;
    }
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
      await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {
          'full_name': fullNameController.text.trim(),
        },
      );
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCompanyAndProfile() async {
    if (companyNameController.text.isEmpty) {
      errorMessage.value = 'Please enter a company name';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Create company
      final companyResponse = await _supabase.client
          .from('companies')
          .insert({'name': companyNameController.text.trim()})
          .select()
          .single();

      final companyId = companyResponse['id'] as String;

      // Create profile
      await _supabase.client.from('profiles').insert({
        'id': _supabase.userId!,
        'company_id': companyId,
        'full_name': _supabase.currentUser?.userMetadata?['full_name'] ??
            _supabase.currentUser?.email ??
            'User',
        'role': 'owner',
      });

      // Seed default categories
      await _supabase.client.from('categories').insert([
        {'company_id': companyId, 'name': 'Lighting', 'icon': 'lightbulb', 'color': '#F59E0B'},
        {'company_id': companyId, 'name': 'Audio', 'icon': 'speaker', 'color': '#3B82F6'},
        {'company_id': companyId, 'name': 'Video', 'icon': 'videocam', 'color': '#8B5CF6'},
        {'company_id': companyId, 'name': 'Rigging', 'icon': 'link', 'color': '#6B7280'},
        {'company_id': companyId, 'name': 'Power', 'icon': 'bolt', 'color': '#EF4444'},
        {'company_id': companyId, 'name': 'Staging', 'icon': 'view_module', 'color': '#10B981'},
      ]);

      Get.offAllNamed(AppRoutes.shell);
    } on PostgrestException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to create company';
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
    await _supabase.auth.signOut();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    companyNameController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    _authSub.cancel();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    companyNameController.dispose();
    super.onClose();
  }
}
