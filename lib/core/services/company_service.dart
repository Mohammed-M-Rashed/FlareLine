import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/company_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';

class CompanyService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Get all companies
  static Future<CompanyListResponse> getAllCompanies() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllCompanies}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CompanyListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب الشركات');
        } catch (e) {
          throw Exception('فشل في جلب الشركات: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new company
  static Future<CompanyResponse> createCompany(CompanyCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return CompanyResponse.fromJson(jsonData);
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
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء الشركة');
        } catch (e) {
          throw Exception('فشل في إنشاء الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing company
  static Future<CompanyResponse> updateCompany(CompanyUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CompanyResponse.fromJson(jsonData);
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
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث الشركة');
        } catch (e) {
          throw Exception('فشل في تحديث الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to check if user has permission to manage companies
  static bool hasCompanyManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final userData = authController.userData;
      
      if (userData == null || userData.roles.isEmpty) {
        return false;
      }
      
      // Check if user has system_administrator role
      return userData.roles.any((role) => role.name == 'system_administrator');
    } catch (e) {
      return false;
    }
  }




}
