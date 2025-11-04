// Authentication Service - SEPARATE from User Management
import 'package:flutter/material.dart';
import 'package:flareline/core/models/auth_model.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/auth/auth_provider.dart';
import 'package:flareline/core/config/api_endpoints.dart';
import 'package:flareline/core/ui/notification_service.dart';
import 'package:flareline/core/utils/server_message_extractor.dart';
import 'package:flareline/core/i18n/strings_ar.dart';
import 'package:get/get.dart';
import 'dart:convert';

class AuthService {

  // Sign in user
  static Future<bool> signIn(BuildContext context, String email, String password) async {
    print('🔐 AUTH SERVICE: ===== STARTING SIGN IN PROCESS =====');
    print('🔐 AUTH SERVICE: Email: $email');
    print('🔐 AUTH SERVICE: Password length: ${password.length}');
    print('🔐 AUTH SERVICE: Using endpoint: ${ApiEndpoints.login}');
    
    try {
      final loginData = {
        'email': email,
        'password': password,
      };
      
      print('📤 AUTH SERVICE: Preparing login data: $loginData');
      print('📤 AUTH SERVICE: Data type: ${loginData.runtimeType}');
      
      print('🚀 AUTH SERVICE: Making API call to: ${ApiEndpoints.login}');
      final response = await ApiService.post(ApiEndpoints.login, body: loginData);
      
      print('📡 AUTH SERVICE: API response received');
      print('📡 AUTH SERVICE: Response status code: ${response.statusCode}');
      print('📡 AUTH SERVICE: Response headers: ${response.headers}');
      print('📡 AUTH SERVICE: Response body length: ${response.body.length}');
      print('📡 AUTH SERVICE: Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ AUTH SERVICE: API call successful (HTTP 200-299)');
        
        try {
          print('🔍 AUTH SERVICE: Attempting to parse response body as JSON');
          final responseData = jsonDecode(response.body);
          print('🔍 AUTH SERVICE: JSON parsed successfully');
          print('🔍 AUTH SERVICE: Parsed data type: ${responseData.runtimeType}');
          print('🔍 AUTH SERVICE: Parsed data: $responseData');
          
          print('🏗️ AUTH SERVICE: Building LoginResponse from parsed data');
          final loginResponse = LoginResponse.fromJson(responseData);
          print('🏗️ AUTH SERVICE: LoginResponse built successfully');
          
          print('✅ AUTH SERVICE: Login successful according to API response');
          print('✅ AUTH SERVICE: Token: ${loginResponse.accessToken.substring(0, 20)}...');
          print('✅ AUTH SERVICE: User: ${loginResponse.user.name} (${loginResponse.user.email})');
          print('✅ AUTH SERVICE: Company: ${loginResponse.user.company?.name ?? 'No company'}');
          
          // Store authentication data
          print('💾 AUTH SERVICE: Storing authentication data in AuthController');
          final authController = Get.find<AuthController>();
          authController.signIn(
            email,
            token: loginResponse.accessToken,
            user: loginResponse.user,
          );
          print('💾 AUTH SERVICE: Authentication data stored successfully');
          
          print('🎉 AUTH SERVICE: Sign in process completed successfully');
          NotificationService.showSuccess(
            context,
            StringsAr.loginSuccess,
            operationId: 'auth:login:$email',
          );
          return true;
        } catch (jsonError) {
          print('💥 AUTH SERVICE: JSON parsing error: $jsonError');
          print('💥 AUTH SERVICE: Raw response body: ${response.body}');
          print('💥 AUTH SERVICE: Response body type: ${response.body.runtimeType}');
          
          NotificationService.showError(
            context,
            'خطأ في تحليل استجابة API',
            operationId: 'auth:login:error:$email',
          );
          return false;
        }
      } else {
        print('❌ AUTH SERVICE: API call failed (HTTP error)');
        print('❌ AUTH SERVICE: HTTP status code: ${response.statusCode}');
        print('❌ AUTH SERVICE: Response body: ${response.body}');
        
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        
        print('🔍 AUTH SERVICE: Error analysis:');
        print('🔍 AUTH SERVICE: - Error message: $errorMessage');
        print('🔍 AUTH SERVICE: - Error type: $errorType');
        print('🔍 AUTH SERVICE: - Is validation error: ${ApiService.isValidationError(response)}');
        print('🔍 AUTH SERVICE: - Is auth error: ${ApiService.isAuthError(response)}');
        print('🔍 AUTH SERVICE: - Is not found error: ${ApiService.isNotFoundError(response)}');
        
        if (ApiService.isValidationError(response)) {
          print('📝 AUTH SERVICE: Validation error detected');
          final message = ServerMessageExtractor.extractMessage(response, 
            defaultMessage: 'خطأ في التحقق من البيانات');
          NotificationService.showError(context, message, 
            operationId: 'auth:login:validation:$email');
        } else if (ApiService.isAuthError(response)) {
          print('🔐 AUTH SERVICE: Authentication error detected');
          NotificationService.showError(context, 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
            operationId: 'auth:login:credentials:$email');
        } else if (response.statusCode == 422) {
          print('📝 AUTH SERVICE: Validation error (422) detected');
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['errors'] != null) {
              final errors = errorData['errors'] as Map<String, dynamic>;
              final errorMessages = errors.values
                  .map((e) => (e as List).join(', '))
                  .join('; ');
              NotificationService.showError(context, 'خطأ في التحقق: $errorMessages',
                operationId: 'auth:login:422:$email');
            } else {
              NotificationService.showError(context, errorData['message'] ?? 'خطأ في التحقق',
                operationId: 'auth:login:422:$email');
            }
          } catch (e) {
            NotificationService.showError(context, 'خطأ في التحقق',
              operationId: 'auth:login:422:$email');
          }
        } else if (response.statusCode == 401) {
          print('🔐 AUTH SERVICE: Unauthorized error detected');
          NotificationService.showError(context, 'بيانات الاعتماد غير صحيحة',
            operationId: 'auth:login:401:$email');
        } else if (response.statusCode == 403) {
          print('🔐 AUTH SERVICE: Forbidden error detected');
          NotificationService.showError(context, 'تم رفض الوصول',
            operationId: 'auth:login:403:$email');
        } else {
          print('💥 AUTH SERVICE: General error detected');
          final message = ServerMessageExtractor.extractMessage(response,
            defaultMessage: StringsAr.loginError);
          NotificationService.showError(context, message,
            operationId: 'auth:login:error:$email');
        }
        return false;
      }
    } catch (e, stackTrace) {
      print('💥 AUTH SERVICE: Network/parsing error occurred');
      print('💥 AUTH SERVICE: Error type: ${e.runtimeType}');
      print('💥 AUTH SERVICE: Error message: $e');
      print('💥 AUTH SERVICE: Stack trace: $stackTrace');
      
      NotificationService.showError(context, StringsAr.networkError,
        operationId: 'auth:login:network:$email');
      return false;
    } finally {
      print('🔐 AUTH SERVICE: ===== SIGN IN PROCESS COMPLETED =====');
    }
  }

  // Sign out user
  static Future<bool> signOut(BuildContext context) async {
    print('🚪 AUTH SERVICE: ===== STARTING SIGN OUT PROCESS =====');
    try {
      print('🔍 AUTH SERVICE: Finding AuthController');
      final authController = Get.find<AuthController>();
      print('🔍 AUTH SERVICE: AuthController found successfully');
      
      // Call logout API if user has token
      if (authController.hasValidToken()) {
        print('🌐 AUTH SERVICE: Calling logout API');
        try {
          final response = await ApiService.post(ApiEndpoints.logout);
          if (ApiService.isSuccessResponse(response)) {
            print('✅ AUTH SERVICE: Logout API call successful');
            try {
              final responseData = jsonDecode(response.body);
              if (responseData['message'] != null) {
                print('✅ AUTH SERVICE: Logout message: ${responseData['message']}');
              }
            } catch (e) {
              print('⚠️ AUTH SERVICE: Could not parse logout response: $e');
            }
          } else {
            print('⚠️ AUTH SERVICE: Logout API call failed, but continuing with local logout');
            if (response.statusCode == 401) {
              print('⚠️ AUTH SERVICE: Token already invalid or expired');
            }
          }
        } catch (e) {
          print('⚠️ AUTH SERVICE: Logout API call failed, but continuing with local logout: $e');
        }
      }
      
      print('🧹 AUTH SERVICE: Clearing authentication data');
      authController.signOut();
      print('🧹 AUTH SERVICE: Authentication data cleared');
      
      print('✅ AUTH SERVICE: User signed out successfully');
      NotificationService.showSuccess(context, StringsAr.logoutSuccess,
        operationId: 'auth:logout');
      return true;
    } catch (e, stackTrace) {
      print('💥 AUTH SERVICE: Error during sign out');
      print('💥 AUTH SERVICE: Error type: ${e.runtimeType}');
      print('💥 AUTH SERVICE: Error message: $e');
      print('💥 AUTH SERVICE: Stack trace: $stackTrace');
      
      NotificationService.showError(context, StringsAr.logoutError,
        operationId: 'auth:logout:error');
      return false;
    } finally {
      print('🚪 AUTH SERVICE: ===== SIGN OUT PROCESS COMPLETED =====');
    }
  }

  // Refresh authentication token
  static Future<bool> refreshToken(BuildContext context) async {
    print('🔄 AUTH SERVICE: ===== STARTING TOKEN REFRESH =====');
    try {
      final authController = Get.find<AuthController>();
      if (!authController.hasValidToken()) {
        print('❌ AUTH SERVICE: No valid token to refresh');
        return false;
      }

      print('🌐 AUTH SERVICE: Calling refresh token API');
      final response = await ApiService.post(ApiEndpoints.refreshToken);
      
      if (ApiService.isSuccessResponse(response)) {
        try {
          final responseData = jsonDecode(response.body);
          final refreshResponse = LoginResponse.fromJson(responseData);
          
          print('✅ AUTH SERVICE: Token refreshed successfully');
          print('✅ AUTH SERVICE: New token: ${refreshResponse.accessToken.substring(0, 20)}...');
          print('✅ AUTH SERVICE: Token expires in: ${refreshResponse.expiresIn} seconds');
          
          authController.updateToken(refreshResponse.accessToken);
          authController.updateUser(refreshResponse.user);
          
          return true;
        } catch (e) {
          print('❌ AUTH SERVICE: Error parsing refresh response: $e');
          return false;
        }
      } else {
        print('❌ AUTH SERVICE: Token refresh failed');
        if (response.statusCode == 401) {
          print('❌ AUTH SERVICE: Token refresh unauthorized - user needs to login again');
          // Optionally trigger re-login here
        }
        return false;
      }
    } catch (e) {
      print('💥 AUTH SERVICE: Error refreshing token: $e');
      return false;
    } finally {
      print('🔄 AUTH SERVICE: ===== TOKEN REFRESH COMPLETED =====');
    }
  }

  // Get current user from API
  static Future<AuthUserModel?> getCurrentUserFromAPI(BuildContext context) async {
    print('👤 AUTH SERVICE: ===== GETTING CURRENT USER FROM API =====');
    try {
      final authController = Get.find<AuthController>();
      if (!authController.hasValidToken()) {
        print('❌ AUTH SERVICE: No valid token to get user data');
        return null;
      }

      print('🌐 AUTH SERVICE: Calling get current user API');
      final response = await ApiService.post(ApiEndpoints.getCurrentUser);
      
      if (ApiService.isSuccessResponse(response)) {
        try {
          final responseData = jsonDecode(response.body);
          final user = AuthUserModel.fromJson(responseData);
          
          print('✅ AUTH SERVICE: Current user data retrieved successfully');
          print('✅ AUTH SERVICE: User: ${user.name} (${user.email})');
          print('✅ AUTH SERVICE: User roles: ${user.roles.map((r) => r.name).join(', ')}');
          print('✅ AUTH SERVICE: User status: ${user.status}');
          
          authController.updateUser(user);
          return user;
        } catch (e) {
          print('❌ AUTH SERVICE: Error parsing user data: $e');
          return null;
        }
      } else {
        print('❌ AUTH SERVICE: Failed to get current user data');
        if (response.statusCode == 401) {
          print('❌ AUTH SERVICE: Unauthorized - token may be expired');
        }
        return null;
      }
    } catch (e) {
      print('💥 AUTH SERVICE: Error getting current user: $e');
      return null;
    } finally {
      print('👤 AUTH SERVICE: ===== GET CURRENT USER COMPLETED =====');
    }
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    print('🔍 AUTH SERVICE: Checking authentication status');
    try {
      final authController = Get.find<AuthController>();
      final isAuth = authController.isAuthenticated;
      print('🔍 AUTH SERVICE: Authentication status: $isAuth');
      return isAuth;
    } catch (e) {
      print('❌ AUTH SERVICE: Error checking authentication: $e');
      return false;
    }
  }

  // Get current user data
  static AuthUserModel? getCurrentUser() {
    print('🔍 AUTH SERVICE: Getting current user data');
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null) {
        print('🔍 AUTH SERVICE: Current user: ${user.name} (${user.email})');
      } else {
        print('🔍 AUTH SERVICE: No current user found');
      }
      return user;
    } catch (e) {
      print('❌ AUTH SERVICE: Error getting current user: $e');
      return null;
    }
  }

  // Get authentication token
  static String getAuthToken() {
    print('🔍 AUTH SERVICE: Getting authentication token');
    try {
      final authController = Get.find<AuthController>();
      final token = authController.userToken;
      if (token.isNotEmpty) {
        print('🔍 AUTH SERVICE: Token found: ${token.substring(0, 20)}...');
      } else {
        print('🔍 AUTH SERVICE: No token found');
      }
      return token;
    } catch (e) {
      print('❌ AUTH SERVICE: Error getting auth token: $e');
      return '';
    }
  }

  // Check if token needs refresh (80% of TTL)
  static bool shouldRefreshToken() {
    print('🔍 AUTH SERVICE: Checking if token needs refresh');
    try {
      final authController = Get.find<AuthController>();
      final token = authController.userToken;
      
      if (token.isEmpty) {
        print('🔍 AUTH SERVICE: No token to check');
        return false;
      }
      
      // For now, we'll use a simple approach
      // In a production app, you'd decode the JWT and check expiration
      // For now, we'll assume token expires in 1 hour (3600 seconds)
      // and suggest refresh at 80% (2880 seconds)
      
      // This is a placeholder - implement proper JWT expiration checking
      print('🔍 AUTH SERVICE: Token refresh check - implement proper JWT expiration logic');
      return false;
    } catch (e) {
      print('❌ AUTH SERVICE: Error checking token refresh: $e');
      return false;
    }
  }

  // Auto-refresh token if needed
  static Future<bool> autoRefreshTokenIfNeeded(BuildContext context) async {
    print('🔄 AUTH SERVICE: Checking if auto-refresh is needed');
    
    if (shouldRefreshToken()) {
      print('🔄 AUTH SERVICE: Auto-refresh needed, refreshing token');
      return await refreshToken(context);
    } else {
      print('🔄 AUTH SERVICE: No auto-refresh needed');
      return true;
    }
  }

  // Handle authentication errors and redirect to login if needed
  static void handleAuthError(BuildContext context, int statusCode, {String? message}) {
    print('🔐 AUTH SERVICE: Handling authentication error: $statusCode');
    
    if (statusCode == 401) {
      print('🔐 AUTH SERVICE: Unauthorized - redirecting to login');
      // Clear local auth data
      try {
        final authController = Get.find<AuthController>();
        authController.signOut();
      } catch (e) {
        print('⚠️ AUTH SERVICE: Error clearing auth data: $e');
      }
      
      // Show message to user
      NotificationService.showInfo(context, 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
        operationId: 'auth:session-expired');
      
      // TODO: Navigate to login page
      // Get.toNamed('/login');
    } else if (statusCode == 403) {
      print('🔐 AUTH SERVICE: Forbidden - insufficient permissions');
      NotificationService.showError(context, message ?? StringsAr.permissionError,
        operationId: 'auth:forbidden');
    } else {
      print('🔐 AUTH SERVICE: Other auth error: $statusCode');
      NotificationService.showError(context, message ?? StringsAr.authError,
        operationId: 'auth:error:$statusCode');
    }
  }

  // Check if user has specific role
  static bool hasRole(String roleName) {
    print('🔐 AUTH SERVICE: Checking if user has role: $roleName');
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        print('🔐 AUTH SERVICE: No user or roles found');
        return false;
      }
      
      final hasRole = user.roles.any((role) => role.name == roleName);
      print('🔐 AUTH SERVICE: User has role "$roleName": $hasRole');
      
      // Special debug for admin role
      if (roleName == 'admin') {
        print('🔐 AUTH SERVICE: All user roles: ${user.roles.map((r) => r.name).toList()}');
        print('🔐 AUTH SERVICE: Looking for role: $roleName');
        print('🔐 AUTH SERVICE: Role names: ${user.roles.map((r) => r.name).toList()}');
      }
      
      return hasRole;
    } catch (e) {
      print('❌ AUTH SERVICE: Error checking user role: $e');
      return false;
    }
  }

  // Check if user has any of the specified roles
  static bool hasAnyRole(List<String> roleNames) {
    print('🔐 AUTH SERVICE: Checking if user has any of roles: ${roleNames.join(', ')}');
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        print('🔐 AUTH SERVICE: No user or roles found');
        return false;
      }
      
      final hasAnyRole = user.roles.any((role) => roleNames.contains(role.name));
      print('🔐 AUTH SERVICE: User has any of roles: $hasAnyRole');
      return hasAnyRole;
    } catch (e) {
      print('❌ AUTH SERVICE: Error checking user roles: $e');
      return false;
    }
  }

  // Check if user is system administrator
  static bool isSystemAdministrator() {
    return hasRole('system_administrator');
  }

  // Check if user is admin
  static bool isAdmin() {
    return hasRole('admin') || isSystemAdministrator();
  }

  // Validate login form
  static String? validateLoginForm(String email, String password) {
    print('🔍 AUTH SERVICE: Validating login form');
    print('🔍 AUTH SERVICE: Email: $email');
    print('🔍 AUTH SERVICE: Password length: ${password.length}');
    
    if (email.trim().isEmpty) {
      print('❌ AUTH SERVICE: Validation failed - Email is empty');
      return 'Please enter your email';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      print('❌ AUTH SERVICE: Validation failed - Invalid email format');
      return 'Please enter a valid email address';
    }
    
    if (password.isEmpty) {
      print('❌ AUTH SERVICE: Validation failed - Password is empty');
      return 'Please enter your password';
    }
    
    if (password.length < 6) {
      print('❌ AUTH SERVICE: Validation failed - Password too short');
      return 'Password must be at least 6 characters';
    }
    
    print('✅ AUTH SERVICE: Form validation passed');
    return null;
  }
}
