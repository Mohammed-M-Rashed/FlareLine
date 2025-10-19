import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/education_level_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';

class EducationLevelService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Get all education levels
  static Future<EducationLevelListResponse> getAllEducationLevels() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllEducationLevels}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return EducationLevelListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب مستويات التعليم');
        } catch (e) {
          throw Exception('فشل في جلب مستويات التعليم: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new education level
  static Future<EducationLevelResponse> createEducationLevel(EducationLevelCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createEducationLevel}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return EducationLevelResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('خطأ في التحقق: $errorMessages');
            }
          }
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء مستوى التعليم');
        } catch (e) {
          throw Exception('فشل في إنشاء مستوى التعليم: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing education level
  static Future<EducationLevelResponse> updateEducationLevel(EducationLevelUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateEducationLevel}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return EducationLevelResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('خطأ في التحقق: $errorMessages');
            }
          }
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث مستوى التعليم');
        } catch (e) {
          throw Exception('فشل في تحديث مستوى التعليم: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to check if user has permission to manage education levels
  static bool hasEducationLevelManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final userData = authController.userData;
      
      if (userData == null || userData.roles.isEmpty) {
        return false;
      }
      
      // Check if user has system_administrator or admin role
      return userData.roles.any((role) => 
        role.name == 'system_administrator' || 
        role.name == 'admin'
      );
    } catch (e) {
      return false;
    }
  }
}
