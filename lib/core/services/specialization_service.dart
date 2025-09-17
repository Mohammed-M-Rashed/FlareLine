import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../models/specialization_model.dart';
import '../models/course_model.dart';
import 'api_service.dart';
import '../auth/auth_provider.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../config/api_endpoints.dart';
import 'auth_service.dart';

class SpecializationService {
  // Check if user has specialization management permission (System Admin, Admin)
  static bool hasSpecializationManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => 
          role.name == 'system_administrator' || 
          role.name == 'admin'
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can view specializations (System Admin, Admin only)
  static bool canViewSpecializations() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => 
          role.name == 'system_administrator' || 
          role.name == 'admin'
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Shows a success toast notification for specialization operations in Arabic
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

  /// Shows an error toast notification for specialization operations in Arabic
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

  /// Shows an info toast notification for specialization operations in Arabic
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


  // Get courses by specialization ID using admin API endpoint
  static Future<List<Course>> adminGetCoursesBySpecialization(BuildContext context, int specializationId) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await ApiService.post(
        ApiEndpoints.adminGetCoursesBySpecialization,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: {
          'specialization_id': specializationId,
        },
      );

      if (ApiService.isSuccessResponse(response)) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        }
        return [];
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return [];
      }
    } catch (e) {
      _showErrorToast(context, 'خطأ في جلب الدورات: $e');
      return [];
    }
  }

  // Get all specializations (System Admin, Admin, Company Employee)
  static Future<List<Specialization>> getSpecializations(BuildContext context) async {
    try {
      // Check if user has permission to view specializations
      if (!canViewSpecializations()) {
        _showErrorToast(context, 'غير مصرح لك بعرض التخصصات');
        return [];
      }

      final response = await ApiService.post(
        ApiEndpoints.selectSpecializations,
        body: {},
      );
      
      if (ApiService.isSuccessResponse(response)) {
        final List<dynamic> data = response.body.isNotEmpty 
            ? json.decode(response.body)['data'] ?? []
            : [];
        
        return data.map((json) => Specialization.fromJson(json)).toList();
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return [];
      }
    } catch (e) {
      _showErrorToast(context, 'خطأ في جلب التخصصات: $e');
      return [];
    }
  }

  // Get specializations for company account (Company Account only)
  static Future<List<Specialization>> getSpecializationsForCompanyAccount(BuildContext context) async {
    try {
      // Check if user is a company account
      if (!AuthService.hasRole('company_account')) {
        _showErrorToast(context, 'غير مصرح لك بعرض التخصصات');
        return [];
      }

      final response = await ApiService.post(
        ApiEndpoints.selectSpecializationsForCompanyAccount,
        body: {},
      );
      
      if (ApiService.isSuccessResponse(response)) {
        final List<dynamic> data = response.body.isNotEmpty 
            ? json.decode(response.body)['data'] ?? []
            : [];
        
        return data.map((json) => Specialization.fromJson(json)).toList();
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return [];
      }
    } catch (e) {
      _showErrorToast(context, 'خطأ في جلب التخصصات: $e');
      return [];
    }
  }

  // Create a new specialization (System Admin, Admin)
  static Future<dynamic> createSpecialization(BuildContext context, Specialization specialization) async {
    try {
      // Check if user has permission to create specializations
      if (!hasSpecializationManagementPermission()) {
        _showErrorToast(context, 'غير مصرح لك بإنشاء التخصصات');
        return false;
      }

      final response = await ApiService.post(
        ApiEndpoints.createSpecialization,
        body: {
          'name': specialization.name,
          'description': specialization.description,
        },
      );
      
      if (ApiService.isSuccessResponse(response)) {
        _showSuccessToast(context, 'تم إنشاء التخصص بنجاح');
        return true;
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return errorMessage;
      }
    } catch (e) {
      return 'خطأ في إنشاء التخصص: $e';
    }
  }

  // Update an existing specialization (System Admin, Admin)
  static Future<dynamic> updateSpecialization(BuildContext context, Specialization specialization) async {
    try {
      // Check if user has permission to update specializations
      if (!hasSpecializationManagementPermission()) {
        _showErrorToast(context, 'غير مصرح لك بتحديث التخصصات');
        return false;
      }

      final response = await ApiService.post(
        ApiEndpoints.updateSpecialization,
        body: {
          'id': specialization.id,
          'name': specialization.name,
          'description': specialization.description,
        },
      );
      
      if (ApiService.isSuccessResponse(response)) {
        _showSuccessToast(context, 'تم تحديث التخصص بنجاح');
        return true;
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        _showErrorToast(context, errorMessage);
        return errorMessage;
      }
    } catch (e) {
      return 'خطأ في تحديث التخصص: $e';
    }
  }

  // Delete a specialization - NOT SUPPORTED by API
  static Future<bool> deleteSpecialization(BuildContext context, int specializationId) async {
    _showInfoToast(context, 'عملية الحذف غير مدعومة للتخصصات');
    return false;
  }

  // Get specialization by ID - NOT SUPPORTED by API
  static Future<Specialization?> getSpecializationById(BuildContext context, int specializationId) async {
    _showInfoToast(context, 'استرجاع التخصص الفردي غير مدعوم من قبل API');
    return null;
  }

  // Search specializations - NOT SUPPORTED by API
  static Future<List<Specialization>> searchSpecializations(BuildContext context, String query) async {
    _showInfoToast(context, 'وظيفة البحث غير مدعومة من قبل API');
    return [];
  }

  // Get specialization statistics - NOT SUPPORTED by API
  static Future<Map<String, dynamic>?> getSpecializationStats(BuildContext context) async {
    _showInfoToast(context, 'وظيفة الإحصائيات غير مدعومة من قبل API');
    return null;
  }

  // Validate specialization data according to API requirements
  static String? validateSpecialization(Specialization specialization) {
    if (specialization.name.trim().isEmpty) {
      return 'اسم التخصص مطلوب';
    }
    
    if (specialization.name.trim().length > 255) {
      return 'اسم التخصص يجب ألا يتجاوز 255 حرف';
    }
    
    // Description is now optional, so no validation needed
    
    return null;
  }


  // Get localized message from API response
  static String getLocalizedMessage(Map<String, dynamic> response, String field) {
    final messages = response[field];
    if (messages is Map<String, dynamic>) {
      // Return Arabic message by default, or English if Arabic not available
      return messages['m_ar'] ?? messages['m_en'] ?? 'رسالة غير معروفة';
    }
    return response[field]?.toString() ?? 'رسالة غير معروفة';
  }

  // Check if specialization name exists
  static Future<bool> checkSpecializationNameExists(BuildContext context, String name, {int? excludeId}) async {
    try {
      // Since the API doesn't support this directly, we'll check against existing specializations
      final existingSpecializations = await getSpecializations(context);
      return existingSpecializations.any((spec) => 
        spec.name.toLowerCase() == name.toLowerCase() && 
        (excludeId == null || spec.id != excludeId)
      );
    } catch (e) {
      return false;
    }
  }

  // Bulk operations - NOT SUPPORTED by API
  static Future<bool> bulkDeleteSpecializations(BuildContext context, List<int> specializationIds) async {
    _showInfoToast(context, 'العمليات المجمعة غير مدعومة من قبل API');
    return false;
  }

  static Future<bool> bulkUpdateSpecializations(BuildContext context, List<Specialization> specializations) async {
    _showInfoToast(context, 'العمليات المجمعة غير مدعومة من قبل API');
    return false;
  }
}
