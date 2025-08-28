import 'package:flareline/core/models/course_model.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/config/api_endpoints.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
  static Future<bool> createCourse(BuildContext context, Course course) async {
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
      
      // Create CourseCreateRequest from Course model
      final createRequest = CourseCreateRequest(
        specializationId: course.specializationId,
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
  static Future<bool> updateCourse(BuildContext context, Course course) async {
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
      
      // Create CourseUpdateRequest from Course model
      final updateRequest = CourseUpdateRequest(
        id: course.id!,
        specializationId: course.specializationId,
        title: course.title,
        description: course.description,
        fileAttachment: course.fileAttachment,
      );
      print('✅ COURSE SERVICE: CourseUpdateRequest created successfully');
      print('📤 COURSE SERVICE: Request payload: ${updateRequest.toJson()}');
      
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
}
