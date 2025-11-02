import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../models/cooperative_company_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';

class CooperativeCompanyService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Get all cooperative companies
  static Future<CooperativeCompanyListResponse> getAllCooperativeCompanies() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllCooperativeCompanies}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CooperativeCompanyListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب الشركات التعاونية');
        } catch (e) {
          throw Exception('فشل في جلب الشركات التعاونية: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new cooperative company
  static Future<CooperativeCompanyResponse> createCooperativeCompany(
    CooperativeCompanyCreateRequest request, {
    PlatformFile? imageFile,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      // Use Multipart if image file is provided, otherwise use JSON
      if (imageFile != null && imageFile.bytes != null) {
        return await _createCooperativeCompanyWithMultipart(request, imageFile, token);
      } else {
        return await _createCooperativeCompanyWithJson(request, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create cooperative company with Multipart (when image file is provided)
  static Future<CooperativeCompanyResponse> _createCooperativeCompanyWithMultipart(
    CooperativeCompanyCreateRequest request,
    PlatformFile imageFile,
    String token,
  ) async {
    try {
      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiEndpoints.createCooperativeCompany}'),
      );

      // Add headers
      requestMultipart.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      requestMultipart.fields['name'] = request.name;
      requestMultipart.fields['address'] = request.address;
      requestMultipart.fields['phone'] = request.phone;
      if (request.apiUrl != null && request.apiUrl!.isNotEmpty) {
        requestMultipart.fields['api_url'] = request.apiUrl!;
      }
      if (request.countryId != null) {
        requestMultipart.fields['country_id'] = request.countryId.toString();
      }
      if (request.cityId != null) {
        requestMultipart.fields['city_id'] = request.cityId.toString();
      }

      // Add image as base64 string in form field (server expects base64, not file)
      if (imageFile.bytes != null) {
        final base64Image = base64Encode(imageFile.bytes!);
        requestMultipart.fields['image'] = base64Image;
      }

      print('═══════════════════════════════════════');
      print('📤 [CooperativeCompanyService] Creating cooperative company with Multipart');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('📁 Image File: ${imageFile.name} (${imageFile.size} bytes)');
      print('📦 Image as Base64: ${imageFile.bytes != null ? base64Encode(imageFile.bytes!).substring(0, 50) + "..." : "null"}');
      print('📋 Fields: ${requestMultipart.fields.keys.toList()}');
      print('═══════════════════════════════════════');

      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        print('✅ Cooperative company created successfully with Multipart');
        return CooperativeCompanyResponse.fromJson(jsonData);
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CooperativeCompanyService] createCooperativeCompany (Multipart) ERROR');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔢 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
        print('═══════════════════════════════════════');
        
        // Handle 413 Payload Too Large
        if (response.statusCode == 413) {
          throw Exception('حجم الصورة كبير جداً. يرجى اختيار صورة أصغر أو ضغط الصورة قبل الإرسال.');
        }
        
        // Handle HTML responses (like 503 errors)
        if (response.body.trim().toLowerCase().startsWith('<!doctype') || 
            response.body.trim().toLowerCase().startsWith('<html')) {
          String errorMessage = 'خطأ في الخادم';
          if (response.statusCode == 503) {
            errorMessage = 'الخادم غير متاح مؤقتاً (503)';
          } else if (response.statusCode >= 500) {
            errorMessage = 'خطأ في الخادم (${response.statusCode})';
          } else {
            errorMessage = 'خطأ غير متوقع (${response.statusCode})';
          }
          throw Exception(errorMessage);
        }
        
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              print('📋 Validation Errors:');
              errors.forEach((key, value) {
                print('  - $key: $value');
              });
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('خطأ في التحقق: $errorMessages');
            }
          }
          print('📝 Error Message (AR): ${errorData['message_ar']}');
          print('📝 Error Message (EN): ${errorData['message_en']}');
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء الشركة التعاونية');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || 
              e.toString().contains('فشل في إنشاء الشركة التعاونية') ||
              e.toString().contains('حجم الصورة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في إنشاء الشركة التعاونية: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create cooperative company with JSON (when no image file)
  static Future<CooperativeCompanyResponse> _createCooperativeCompanyWithJson(
    CooperativeCompanyCreateRequest request,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createCooperativeCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return CooperativeCompanyResponse.fromJson(jsonData);
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CooperativeCompanyService] createCooperativeCompany (JSON) ERROR');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔢 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
        print('═══════════════════════════════════════');
        
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              print('📋 Validation Errors:');
              errors.forEach((key, value) {
                print('  - $key: $value');
              });
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('خطأ في التحقق: $errorMessages');
            }
          }
          print('📝 Error Message (AR): ${errorData['message_ar']}');
          print('📝 Error Message (EN): ${errorData['message_en']}');
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء الشركة التعاونية');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || e.toString().contains('فشل في إنشاء الشركة التعاونية')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في إنشاء الشركة التعاونية: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing cooperative company
  static Future<CooperativeCompanyResponse> updateCooperativeCompany(
    CooperativeCompanyUpdateRequest request, {
    PlatformFile? imageFile,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      // Use Multipart if image file is provided, otherwise use JSON
      if (imageFile != null && imageFile.bytes != null) {
        return await _updateCooperativeCompanyWithMultipart(request, imageFile, token);
      } else {
        return await _updateCooperativeCompanyWithJson(request, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update cooperative company with Multipart (when image file is provided)
  static Future<CooperativeCompanyResponse> _updateCooperativeCompanyWithMultipart(
    CooperativeCompanyUpdateRequest request,
    PlatformFile imageFile,
    String token,
  ) async {
    try {
      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiEndpoints.updateCooperativeCompany}'),
      );

      // Add headers
      requestMultipart.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      requestMultipart.fields['id'] = request.id.toString();
      if (request.name != null) {
        requestMultipart.fields['name'] = request.name!;
      }
      if (request.address != null) {
        requestMultipart.fields['address'] = request.address!;
      }
      if (request.phone != null) {
        requestMultipart.fields['phone'] = request.phone!;
      }
      if (request.apiUrl != null && request.apiUrl!.isNotEmpty) {
        requestMultipart.fields['api_url'] = request.apiUrl!;
      }
      if (request.countryId != null) {
        requestMultipart.fields['country_id'] = request.countryId.toString();
      }
      if (request.cityId != null) {
        requestMultipart.fields['city_id'] = request.cityId.toString();
      }

      // Add image as base64 string in form field (server expects base64, not file)
      if (imageFile.bytes != null) {
        final base64Image = base64Encode(imageFile.bytes!);
        requestMultipart.fields['image'] = base64Image;
      }

      print('═══════════════════════════════════════');
      print('📤 [CooperativeCompanyService] Updating cooperative company with Multipart');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🆔 Company ID: ${request.id}');
      print('📁 Image File: ${imageFile.name} (${imageFile.size} bytes)');
      print('📦 Image as Base64: ${imageFile.bytes != null ? base64Encode(imageFile.bytes!).substring(0, 50) + "..." : "null"}');
      print('📋 Fields: ${requestMultipart.fields.keys.toList()}');
      print('═══════════════════════════════════════');

      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('✅ Cooperative company updated successfully with Multipart');
        return CooperativeCompanyResponse.fromJson(jsonData);
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CooperativeCompanyService] updateCooperativeCompany (Multipart) ERROR');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔢 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
        print('═══════════════════════════════════════');
        
        // Handle 413 Payload Too Large
        if (response.statusCode == 413) {
          throw Exception('حجم الصورة كبير جداً. يرجى اختيار صورة أصغر أو ضغط الصورة قبل الإرسال.');
        }
        
        // Handle HTML responses (like 503 errors)
        if (response.body.trim().toLowerCase().startsWith('<!doctype') || 
            response.body.trim().toLowerCase().startsWith('<html')) {
          String errorMessage = 'خطأ في الخادم';
          if (response.statusCode == 503) {
            errorMessage = 'الخادم غير متاح مؤقتاً (503)';
          } else if (response.statusCode >= 500) {
            errorMessage = 'خطأ في الخادم (${response.statusCode})';
          } else {
            errorMessage = 'خطأ غير متوقع (${response.statusCode})';
          }
          throw Exception(errorMessage);
        }
        
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              print('📋 Validation Errors:');
              errors.forEach((key, value) {
                print('  - $key: $value');
              });
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('خطأ في التحقق: $errorMessages');
            }
          }
          print('📝 Error Message (AR): ${errorData['message_ar']}');
          print('📝 Error Message (EN): ${errorData['message_en']}');
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث الشركة التعاونية');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || 
              e.toString().contains('فشل في تحديث الشركة التعاونية') ||
              e.toString().contains('حجم الصورة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في تحديث الشركة التعاونية: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update cooperative company with JSON (when no image file)
  static Future<CooperativeCompanyResponse> _updateCooperativeCompanyWithJson(
    CooperativeCompanyUpdateRequest request,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateCooperativeCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CooperativeCompanyResponse.fromJson(jsonData);
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
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث الشركة التعاونية');
        } catch (e) {
          throw Exception('فشل في تحديث الشركة التعاونية: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to check if user has permission to manage cooperative companies
  static bool hasCooperativeCompanyManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final userData = authController.userData;
      
      if (userData == null || userData.roles.isEmpty) {
        return false;
      }
      
      // Check if user has admin role only
      return userData.roles.any((role) => role.name == 'admin');
    } catch (e) {
      return false;
    }
  }
}
