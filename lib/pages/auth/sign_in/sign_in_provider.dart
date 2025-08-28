

import 'package:flutter/material.dart';
import 'package:flareline/core/services/auth_service.dart';
import 'package:get/get.dart';

class SignInProvider extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _rememberMe = false.obs;
  final _isLoading = false.obs;

  bool get rememberMe => _rememberMe.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  Future<bool> signIn(BuildContext context) async {
    print('🔐 SIGN IN PROVIDER: ===== STARTING SIGN IN PROCESS =====');
    
    // Get the email and password from the form
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    print('🔐 SIGN IN PROVIDER: Form data extracted:');
    print('🔐 SIGN IN PROVIDER: - Email: $email');
    print('🔐 SIGN IN PROVIDER: - Password length: ${password.length}');
    
    // Validate form data
    print('🔐 SIGN IN PROVIDER: Validating form data...');
    final validationError = AuthService.validateLoginForm(email, password);
    if (validationError != null) {
      print('❌ SIGN IN PROVIDER: Form validation failed: $validationError');
      return false;
    }
    print('✅ SIGN IN PROVIDER: Form validation passed');

    _isLoading.value = true;
    print('🔄 SIGN IN PROVIDER: Loading state set to true');
    
    try {
      print('🚀 SIGN IN PROVIDER: Calling AuthService to sign in...');
      final success = await AuthService.signIn(context, email, password);
      
      if (success) {
        print('✅ SIGN IN PROVIDER: Sign in successful, navigating to dashboard');
        // Navigate to dashboard on success
        Get.offAllNamed('/dashboard');
      } else {
        print('❌ SIGN IN PROVIDER: Sign in failed');
      }
      
      return success;
    } catch (e, stackTrace) {
      print('💥 SIGN IN PROVIDER: Error during sign in');
      print('💥 SIGN IN PROVIDER: Error type: ${e.runtimeType}');
      print('💥 SIGN IN PROVIDER: Error message: $e');
      print('💥 SIGN IN PROVIDER: Stack trace: $stackTrace');
      return false;
    } finally {
      _isLoading.value = false;
      print('🔄 SIGN IN PROVIDER: Loading state set to false');
      print('🔐 SIGN IN PROVIDER: ===== SIGN IN PROCESS COMPLETED =====');
    }
  }
}
