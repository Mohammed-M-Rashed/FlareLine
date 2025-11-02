import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
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

      final uri = Uri.parse('$_baseUrl${ApiEndpoints.getAllCompanies}');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = jsonEncode({}); // Empty body as per API spec

      // Debug request
      print('📡 CompanyService.getAllCompanies → POST ' + uri.toString());
      print('📡 Headers: ' + headers.toString());
      print('📡 Body: ' + body);

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CompanyListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          print('═══════════════════════════════════════');
          print('❌ [CompanyService] getAllCompanies ERROR');
          print('═══════════════════════════════════════');
          print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
          print('🔢 Status Code: ${response.statusCode}');
          print('📦 Response Body: ${response.body}');
          print('═══════════════════════════════════════');
          
          final errorData = jsonDecode(response.body);
          print('📝 Error Message (AR): ${errorData['message_ar']}');
          print('📝 Error Message (EN): ${errorData['message_en']}');
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب الشركات');
        } catch (e) {
          if (e.toString().contains('فشل في جلب الشركات')) {
            rethrow;
          }
          print('❌ Failed to parse error response as JSON: $e');
          print('❌ Raw body: ${response.body}');
          print('═══════════════════════════════════════');
          throw Exception('فشل في جلب الشركات: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('فشل في جلب الشركات')) {
        rethrow;
      }
      print('═══════════════════════════════════════');
      print('❌ [CompanyService] getAllCompanies Exception');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🔴 Error Type: ${e.runtimeType}');
      print('📝 Error Message: ${e.toString()}');
      print('📍 Stack Trace:');
      print(stackTrace.toString());
      print('═══════════════════════════════════════');
      rethrow;
    }
  }

  // Create a new company
  static Future<CompanyResponse> createCompany(
    CompanyCreateRequest request, {
    PlatformFile? imageFile,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      // Use Multipart if image file is provided, otherwise use JSON
      if (imageFile != null && imageFile.bytes != null) {
        return await _createCompanyWithMultipart(request, imageFile, token);
      } else {
        return await _createCompanyWithJson(request, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create company with Multipart (when image file is provided)
  static Future<CompanyResponse> _createCompanyWithMultipart(
    CompanyCreateRequest request,
    PlatformFile imageFile,
    String token,
  ) async {
    try {
      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiEndpoints.createCompany}'),
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
      print('📤 [CompanyService] Creating company with Multipart');
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
        print('✅ Company created successfully with Multipart');
        return CompanyResponse.fromJson(jsonData);
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CompanyService] createCompany (Multipart) ERROR');
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
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء الشركة');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || 
              e.toString().contains('فشل في إنشاء الشركة') ||
              e.toString().contains('حجم الصورة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في إنشاء الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create company with JSON (when no image file)
  static Future<CompanyResponse> _createCompanyWithJson(
    CompanyCreateRequest request,
    String token,
  ) async {
    try {
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
        print('═══════════════════════════════════════');
        print('❌ [CompanyService] createCompany (JSON) ERROR');
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
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء الشركة');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || e.toString().contains('فشل في إنشاء الشركة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في إنشاء الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing company
  static Future<CompanyResponse> updateCompany(
    CompanyUpdateRequest request, {
    PlatformFile? imageFile,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      // Use Multipart if image file is provided, otherwise use JSON
      if (imageFile != null && imageFile.bytes != null) {
        return await _updateCompanyWithMultipart(request, imageFile, token);
      } else {
        return await _updateCompanyWithJson(request, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update company with Multipart (when image file is provided)
  static Future<CompanyResponse> _updateCompanyWithMultipart(
    CompanyUpdateRequest request,
    PlatformFile imageFile,
    String token,
  ) async {
    try {
      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiEndpoints.updateCompany}'),
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
      print('📤 [CompanyService] Updating company with Multipart');
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
        print('✅ Company updated successfully with Multipart');
        return CompanyResponse.fromJson(jsonData);
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CompanyService] updateCompany (Multipart) ERROR');
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
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث الشركة');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || 
              e.toString().contains('فشل في تحديث الشركة') ||
              e.toString().contains('حجم الصورة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في تحديث الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update company with JSON (when no image file)
  static Future<CompanyResponse> _updateCompanyWithJson(
    CompanyUpdateRequest request,
    String token,
  ) async {
    try {
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
        print('═══════════════════════════════════════');
        print('❌ [CompanyService] updateCompany (JSON) ERROR');
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
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث الشركة');
        } catch (e) {
          if (e.toString().contains('خطأ في التحقق') || e.toString().contains('فشل في تحديث الشركة')) {
            rethrow;
          }
          print('❌ Failed to parse error response: $e');
          throw Exception('فشل في تحديث الشركة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }


  // Get all companies using admin API endpoint
  static Future<CompanyListResponse> adminGetAllCompanies() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final uri = Uri.parse('$_baseUrl${ApiEndpoints.adminGetAllCompanies}');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = jsonEncode({});

      // Debug request
      print('📡 CompanyService.adminGetAllCompanies → POST ' + uri.toString());
      print('📡 Headers: ' + headers.toString());
      print('📡 Body: ' + body);

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CompanyListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          print('❌ CompanyService.adminGetAllCompanies ERROR ' + response.statusCode.toString());
          print('❌ Response body: ' + response.body);
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب الشركات');
        } catch (e) {
          print('❌ CompanyService.adminGetAllCompanies Unparsed error. Status: ' + response.statusCode.toString());
          print('❌ Raw body: ' + response.body);
          throw Exception('فشل في جلب الشركات: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ CompanyService.adminGetAllCompanies Exception: ' + e.toString());
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
