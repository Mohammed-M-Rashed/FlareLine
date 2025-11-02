import 'package:flareline/core/models/course_model.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/services/auth_service.dart';
import 'package:flareline/core/config/api_endpoints.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flareline/core/config/api_config.dart';

class CourseService {
  /// Shows a success toast notification for course operations in Arabic
  static void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for course operations in Arabic
  static void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for course operations in Arabic
  static void _showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Get all courses
  static Future<List<Course>> getCourses(BuildContext context, {int? specializationId}) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSES =====');
    print('🔍 COURSE SERVICE: Specialization ID: $specializationId');
    
    try {
      final requestBody = CourseFilterRequest(specializationId: specializationId).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.selectCourses}');
      final response = await ApiService.post(ApiEndpoints.selectCourses, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseListResponse = CourseListResponse.fromJson(responseData);
        
        if (courseListResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved ${courseListResponse.data.length} courses');
          print('🔍 COURSE SERVICE: First course data: ${courseListResponse.data.isNotEmpty ? courseListResponse.data.first.toJson() : 'No courses'}');
          _showSuccessToast(context, courseListResponse.message);
          return courseListResponse.data;
        } else {
          print('❌ COURSE SERVICE: API response indicates failure');
          _showErrorToast(context, courseListResponse.message);
          return [];
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return [];
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while getting courses: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return [];
    }
  }

  // Create new course
  static Future<bool> createCourse(
    BuildContext context, 
    Course course, {
    PlatformFile? fileAttachment,
  }) async {
    print('📚 COURSE SERVICE: ===== CREATING NEW COURSE =====');
    print('🔍 COURSE SERVICE: Course details - Title: ${course.title}, Specialization: ${course.specializationId}');
    
    try {
      // Validate course data
      final validationError = _validateCourseData(course);
      if (validationError != null) {
        print('❌ COURSE SERVICE: Validation failed: $validationError');
        _showErrorToast(context, validationError);
        return false;
      }
      
      // Use Multipart if file attachment is provided, otherwise use JSON
      if (fileAttachment != null && fileAttachment.bytes != null) {
        return await _createCourseWithMultipart(context, course, fileAttachment);
      } else {
        return await _createCourseWithJson(context, course);
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while creating course: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Create course with Multipart (when file attachment is provided)
  static Future<bool> _createCourseWithMultipart(
    BuildContext context,
    Course course,
    PlatformFile fileAttachment,
  ) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        _showErrorToast(context, 'رمز المصادقة غير موجود');
        return false;
      }

      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.createCourse}'),
      );

      // Add headers
      requestMultipart.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      requestMultipart.fields['specialization_id'] = course.specializationId.toString();
      requestMultipart.fields['code'] = course.code;
      requestMultipart.fields['title'] = course.title;
      requestMultipart.fields['description'] = course.description;
      if (course.createdBy != null && course.createdBy!.isNotEmpty) {
        requestMultipart.fields['created_by'] = course.createdBy!;
      } else {
        requestMultipart.fields['created_by'] = 'admin';
      }

      // Add file attachment as base64 string in form field (server expects base64, not file)
      if (fileAttachment.bytes != null) {
        final base64File = base64Encode(fileAttachment.bytes!);
        requestMultipart.fields['file_attachment'] = base64File;
      }

      print('═══════════════════════════════════════');
      print('📤 [CourseService] Creating course with Multipart');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('📁 File Attachment: ${fileAttachment.name} (${fileAttachment.size} bytes)');
      print('📦 File as Base64: ${fileAttachment.bytes != null ? base64Encode(fileAttachment.bytes!).substring(0, 50) + "..." : "null"}');
      print('📋 Fields: ${requestMultipart.fields.keys.toList()}');
      print('═══════════════════════════════════════');

      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final courseResponse = CourseResponse.fromJson(responseData);
        
        if (courseResponse.success) {
          print('✅ Course created successfully with Multipart');
          _showSuccessToast(context, courseResponse.message);
          return true;
        } else {
          _showErrorToast(context, courseResponse.message);
          return false;
        }
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CourseService] createCourse (Multipart) ERROR');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔢 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
        print('═══════════════════════════════════════');
        
        // Handle 413 Payload Too Large
        if (response.statusCode == 413) {
          _showErrorToast(context, 'حجم الملف كبير جداً. يرجى اختيار ملف أصغر.');
          return false;
        }
        
        // Handle HTML responses
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
          _showErrorToast(context, errorMessage);
          return false;
        }
        
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
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
              _showErrorToast(context, 'خطأ في التحقق: $errorMessages');
              return false;
            }
          }
          print('📝 Error Message (AR): ${errorData['m_ar']}');
          print('📝 Error Message (EN): ${errorData['m_en']}');
          final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في إنشاء الدورة';
          _showErrorToast(context, errorMessage);
          return false;
        } catch (e) {
          print('❌ Failed to parse error response: $e');
          _showErrorToast(context, 'فشل في إنشاء الدورة: ${response.statusCode}');
          return false;
        }
      }
    } catch (e) {
      print('💥 Exception in _createCourseWithMultipart: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Create course with JSON (when no file attachment)
  static Future<bool> _createCourseWithJson(BuildContext context, Course course) async {
    try {
      // Create CourseCreateRequest from Course model
      final createRequest = CourseCreateRequest(
        specializationId: course.specializationId,
        code: course.code,
        title: course.title,
        description: course.description,
        fileAttachment: course.fileAttachment,
      );
      print('✅ COURSE SERVICE: CourseCreateRequest created successfully');
      print('📤 COURSE SERVICE: Request payload: ${createRequest.toJson()}');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.createCourse}');
      final response = await ApiService.post(ApiEndpoints.createCourse, body: createRequest.toJson());
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseResponse = CourseResponse.fromJson(responseData);
        
        if (courseResponse.success) {
          print('✅ COURSE SERVICE: Course created successfully on server');
          print('🔍 COURSE SERVICE: Response data: ${courseResponse.data?.toJson()}');
          print('🔍 COURSE SERVICE: Response message: ${courseResponse.message}');
          _showSuccessToast(context, courseResponse.message);
          return true;
        } else {
          print('❌ COURSE SERVICE: Server returned success=false');
          print('🔍 COURSE SERVICE: Response message: ${courseResponse.message}');
          _showErrorToast(context, courseResponse.message);
          return false;
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while creating course: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Update existing course
  static Future<bool> updateCourse(
    BuildContext context, 
    Course course, {
    PlatformFile? fileAttachment,
  }) async {
    print('📚 COURSE SERVICE: ===== UPDATING EXISTING COURSE =====');
    print('🔍 COURSE SERVICE: Course details - ID: ${course.id}, Title: ${course.title}');
    
    try {
      if (course.id == null) {
        print('❌ COURSE SERVICE: Course ID is null, cannot update');
        _showErrorToast(context, 'معرف الدورة مطلوب للتحديث');
        return false;
      }
      
      // Validate course data
      final validationError = _validateCourseData(course);
      if (validationError != null) {
        print('❌ COURSE SERVICE: Validation failed: $validationError');
        _showErrorToast(context, validationError);
        return false;
      }
      
      // Use Multipart if file attachment is provided, otherwise use JSON
      if (fileAttachment != null && fileAttachment.bytes != null) {
        return await _updateCourseWithMultipart(context, course, fileAttachment);
      } else {
        return await _updateCourseWithJson(context, course);
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while updating course: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Update course with Multipart (when file attachment is provided)
  static Future<bool> _updateCourseWithMultipart(
    BuildContext context,
    Course course,
    PlatformFile fileAttachment,
  ) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        _showErrorToast(context, 'رمز المصادقة غير موجود');
        return false;
      }

      var requestMultipart = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.updateCourse}'),
      );

      // Add headers
      requestMultipart.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      requestMultipart.fields['id'] = course.id!.toString();
      // Always send specialization_id (required by server)
      requestMultipart.fields['specialization_id'] = course.specializationId.toString();
      if (course.code.isNotEmpty) {
        requestMultipart.fields['code'] = course.code;
      }
      if (course.title.isNotEmpty) {
        requestMultipart.fields['title'] = course.title;
      }
      if (course.description.isNotEmpty) {
        requestMultipart.fields['description'] = course.description;
      }
      if (course.createdBy != null && course.createdBy!.isNotEmpty) {
        requestMultipart.fields['created_by'] = course.createdBy!;
      }

      // Add file attachment as base64 string in form field (server expects base64, not file)
      if (fileAttachment.bytes != null) {
        final base64File = base64Encode(fileAttachment.bytes!);
        requestMultipart.fields['file_attachment'] = base64File;
      }

      print('═══════════════════════════════════════');
      print('📤 [CourseService] Updating course with Multipart');
      print('═══════════════════════════════════════');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🆔 Course ID: ${course.id}');
      print('📚 Specialization ID: ${course.specializationId}');
      print('📁 File Attachment: ${fileAttachment.name} (${fileAttachment.size} bytes)');
      print('📦 File as Base64: ${fileAttachment.bytes != null ? base64Encode(fileAttachment.bytes!).substring(0, 50) + "..." : "null"}');
      print('📋 Fields: ${requestMultipart.fields.keys.toList()}');
      print('📋 All Fields with Values:');
      requestMultipart.fields.forEach((key, value) {
        if (key == 'file_attachment') {
          print('   - $key: ${value.length > 100 ? value.substring(0, 100) + "..." : value} (${value.length} chars)');
        } else {
          print('   - $key: $value');
        }
      });
      print('═══════════════════════════════════════');

      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final courseResponse = CourseResponse.fromJson(responseData);
        
        if (courseResponse.success) {
          print('✅ Course updated successfully with Multipart');
          _showSuccessToast(context, courseResponse.message);
          return true;
        } else {
          _showErrorToast(context, courseResponse.message);
          return false;
        }
      } else {
        print('═══════════════════════════════════════');
        print('❌ [CourseService] updateCourse (Multipart) ERROR');
        print('═══════════════════════════════════════');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        print('🔢 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
        print('═══════════════════════════════════════');
        
        // Handle 413 Payload Too Large
        if (response.statusCode == 413) {
          _showErrorToast(context, 'حجم الملف كبير جداً. يرجى اختيار ملف أصغر.');
          return false;
        }
        
        // Handle HTML responses
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
          _showErrorToast(context, errorMessage);
          return false;
        }
        
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
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
              _showErrorToast(context, 'خطأ في التحقق: $errorMessages');
              return false;
            }
          }
          print('📝 Error Message (AR): ${errorData['m_ar']}');
          print('📝 Error Message (EN): ${errorData['m_en']}');
          final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في تحديث الدورة';
          _showErrorToast(context, errorMessage);
          return false;
        } catch (e) {
          print('❌ Failed to parse error response: $e');
          _showErrorToast(context, 'فشل في تحديث الدورة: ${response.statusCode}');
          return false;
        }
      }
    } catch (e) {
      print('💥 Exception in _updateCourseWithMultipart: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Update course with JSON (when no file attachment)
  static Future<bool> _updateCourseWithJson(BuildContext context, Course course) async {
    try {
      // Create CourseUpdateRequest from Course model
      final updateRequest = CourseUpdateRequest(
        id: course.id!,
        specializationId: course.specializationId,
        code: course.code,
        title: course.title,
        description: course.description,
        fileAttachment: course.fileAttachment,
      );
      print('✅ COURSE SERVICE: CourseUpdateRequest created successfully');
      print('📤 COURSE SERVICE: Course details - ID: ${course.id}, Specialization ID: ${course.specializationId}');
      print('📤 COURSE SERVICE: Request payload: ${updateRequest.toJson()}');
      print('🔍 COURSE SERVICE: specialization_id in payload: ${updateRequest.toJson()['specialization_id']}');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.updateCourse}');
      final response = await ApiService.post(ApiEndpoints.updateCourse, body: updateRequest.toJson());
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseResponse = CourseResponse.fromJson(responseData);
        
        if (courseResponse.success) {
          print('✅ COURSE SERVICE: Course updated successfully on server');
          _showSuccessToast(context, courseResponse.message);
          return true;
        } else {
          print('❌ COURSE SERVICE: Server returned success=false');
          _showErrorToast(context, courseResponse.message);
          return false;
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else if (ApiService.isNotFoundError(response)) {
          _showErrorToast(context, 'الدورة غير موجودة');
        } else if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while updating course: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Validate course data before sending to API
  static String? _validateCourseData(Course course) {
    if (course.code.trim().isEmpty) {
      print('❌ COURSE SERVICE: Validation failed - Code is empty');
      return 'كود الدورة مطلوب';
    }
    
    if (course.code.length > 50) {
      print('❌ COURSE SERVICE: Validation failed - Code too long: ${course.code.length} characters');
      return 'كود الدورة يجب أن يكون أقل من 50 حرف';
    }
    
    if (course.title.trim().isEmpty) {
      print('❌ COURSE SERVICE: Validation failed - Title is empty');
      return 'عنوان الدورة مطلوب';
    }
    
    if (course.title.length > 255) {
      print('❌ COURSE SERVICE: Validation failed - Title too long: ${course.title.length} characters');
      return 'عنوان الدورة يجب أن يكون أقل من 255 حرف';
    }
    
    if (course.description.trim().isEmpty) {
      print('❌ COURSE SERVICE: Validation failed - Description is empty');
      return 'وصف الدورة مطلوب';
    }
    
    if (course.specializationId <= 0) {
      print('❌ COURSE SERVICE: Validation failed - Invalid specialization ID: ${course.specializationId}');
      return 'يجب اختيار تخصص صحيح';
    }
    
    print('✅ COURSE SERVICE: Course data validation passed');
    return null;
  }

  // Get courses by specialization
  static Future<List<Course>> getCoursesBySpecialization(BuildContext context, int specializationId) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSES BY SPECIALIZATION =====');
    print('🔍 COURSE SERVICE: Specialization ID: $specializationId');
    
    return await getCourses(context, specializationId: specializationId);
  }

  // Get all courses (no filter)
  static Future<List<Course>> getAllCourses(BuildContext context) async {
    print('📚 COURSE SERVICE: ===== GETTING ALL COURSES =====');
    
    return await getCourses(context);
  }

  // Get courses for company account (Company Account only)
  static Future<List<Course>> getCoursesForCompanyAccount(BuildContext context, {int? specializationId}) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSES FOR COMPANY ACCOUNT =====');
    print('🔍 COURSE SERVICE: Specialization ID: $specializationId');
    
    try {
      // Check if user is a company account
      if (!AuthService.hasRole('company_account')) {
        _showErrorToast(context, 'غير مصرح لك بعرض الدورات');
        return [];
      }

      final requestBody = CourseFilterRequest(specializationId: specializationId).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.selectCoursesForCompanyAccount}');
      final response = await ApiService.post(ApiEndpoints.selectCoursesForCompanyAccount, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseListResponse = CourseListResponse.fromJson(responseData);
        
        if (courseListResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved ${courseListResponse.data.length} courses');
          return courseListResponse.data;
        } else {
          print('❌ COURSE SERVICE: API returned success=false');
          _showErrorToast(context, courseListResponse.message ?? 'فشل في جلب الدورات');
          return [];
        }
      } else {
        print('❌ COURSE SERVICE: API call failed - Status: ${response.statusCode}');
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return [];
      }
    } catch (e) {
      print('❌ COURSE SERVICE: Exception occurred: $e');
      _showErrorToast(context, 'خطأ في جلب الدورات: $e');
      return [];
    }
  }

  // Get courses by specialization for company account (Company Account only)
  static Future<List<Course>> getCoursesBySpecializationForCompanyAccount(BuildContext context, int specializationId) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSES BY SPECIALIZATION FOR COMPANY ACCOUNT =====');
    print('🔍 COURSE SERVICE: Specialization ID: $specializationId');
    
    try {
      // Check if user is a company account
      if (!AuthService.hasRole('company_account')) {
        _showErrorToast(context, 'غير مصرح لك بعرض الدورات');
        return [];
      }

      final requestBody = CourseFilterRequest(specializationId: specializationId).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.getCoursesBySpecializationForCompanyAccount}');
      final response = await ApiService.post(ApiEndpoints.getCoursesBySpecializationForCompanyAccount, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseListResponse = CourseListResponse.fromJson(responseData);
        
        if (courseListResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved ${courseListResponse.data.length} courses');
          return courseListResponse.data;
        } else {
          print('❌ COURSE SERVICE: API returned success=false');
          _showErrorToast(context, courseListResponse.message ?? 'فشل في جلب الدورات');
          return [];
        }
      } else {
        print('❌ COURSE SERVICE: API call failed - Status: ${response.statusCode}');
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return [];
      }
    } catch (e) {
      print('❌ COURSE SERVICE: Exception occurred: $e');
      _showErrorToast(context, 'خطأ في جلب الدورات: $e');
      return [];
    }
  }

  // Search courses by code or title
  static Future<List<Course>> searchCourses(BuildContext context, String searchTerm) async {
    print('📚 COURSE SERVICE: ===== SEARCHING COURSES =====');
    print('🔍 COURSE SERVICE: Search term: $searchTerm');
    
    try {
      final requestBody = CourseSearchRequest(searchTerm: searchTerm).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.courseSearch}');
      final response = await ApiService.post(ApiEndpoints.courseSearch, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseListResponse = CourseListResponse.fromJson(responseData);
        
        if (courseListResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved ${courseListResponse.data.length} courses');
          _showSuccessToast(context, courseListResponse.message);
          return courseListResponse.data;
        } else {
          print('❌ COURSE SERVICE: API response indicates failure');
          _showErrorToast(context, courseListResponse.message);
          return [];
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return [];
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while searching courses: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return [];
    }
  }

  // Get course by code
  static Future<Course?> getCourseByCode(BuildContext context, String code) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSE BY CODE =====');
    print('🔍 COURSE SERVICE: Course code: $code');
    
    try {
      final requestBody = CourseByCodeRequest(code: code).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.courseByCode}');
      final response = await ApiService.post(ApiEndpoints.courseByCode, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseResponse = CourseResponse.fromJson(responseData);
        
        if (courseResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved course');
          _showSuccessToast(context, courseResponse.message);
          return courseResponse.data;
        } else {
          print('❌ COURSE SERVICE: API response indicates failure');
          _showErrorToast(context, courseResponse.message);
          return null;
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isNotFoundError(response)) {
          _showErrorToast(context, 'الدورة غير موجودة');
        } else if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return null;
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while getting course by code: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return null;
    }
  }

  // Get courses by status
  static Future<List<Course>> getCoursesByStatus(BuildContext context, String status) async {
    print('📚 COURSE SERVICE: ===== GETTING COURSES BY STATUS =====');
    print('🔍 COURSE SERVICE: Status: $status');
    
    try {
      final requestBody = CourseByStatusRequest(status: status).toJson();
      print('📤 COURSE SERVICE: Request body: $requestBody');
      
      print('🌐 COURSE SERVICE: Calling API endpoint: ${ApiEndpoints.courseByStatus}');
      final response = await ApiService.post(ApiEndpoints.courseByStatus, body: requestBody);
      print('📡 COURSE SERVICE: Response received - Status: ${response.statusCode}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ COURSE SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 COURSE SERVICE: Response data: $responseData');
        
        final courseListResponse = CourseListResponse.fromJson(responseData);
        
        if (courseListResponse.success) {
          print('✅ COURSE SERVICE: Successfully retrieved ${courseListResponse.data.length} courses');
          _showSuccessToast(context, courseListResponse.message);
          return courseListResponse.data;
        } else {
          print('❌ COURSE SERVICE: API response indicates failure');
          _showErrorToast(context, courseListResponse.message);
          return [];
        }
      } else {
        print('❌ COURSE SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 COURSE SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ في المصادقة: يرجى تسجيل الدخول مرة أخرى');
        } else if (ApiService.isValidationError(response)) {
          _showErrorToast(context, 'خطأ في التحقق: $errorMessage');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return [];
      }
    } catch (e) {
      print('💥 COURSE SERVICE: Exception occurred while getting courses by status: $e');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return [];
    }
  }

  // Get available status options
  static List<Map<String, String>> getStatusOptions() {
    return [
      {'value': 'active', 'label': 'Active', 'labelAr': 'نشط'},
      {'value': 'pending', 'label': 'Pending', 'labelAr': 'قيد الانتظار'},
      {'value': 'approved', 'label': 'Approved', 'labelAr': 'مقبول'},
      {'value': 'rejected', 'label': 'Rejected', 'labelAr': 'مرفوض'},
    ];
  }
}
