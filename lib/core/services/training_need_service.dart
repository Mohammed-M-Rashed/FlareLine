import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/training_need_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class TrainingNeedService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has training need management permission
  static bool hasTrainingNeedManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        // System Administrator, Admin, and Company Account have access
        return user.roles.any((role) => 
          role.name == 'system_administrator' || 
          role.name == 'admin' ||
          role.name == 'company_account'
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can approve/reject training needs (System Administrator and Admin)
  static bool canApproveRejectTrainingNeeds() {
    try {
      return AuthService.hasRole('system_administrator') || AuthService.hasRole('admin');
    } catch (e) {
      print('❌ Error checking canApproveRejectTrainingNeeds: $e');
      return false;
    }
  }

  // Check if user can forward training needs (Company Account only)
  static bool canForwardTrainingNeeds() {
    try {
      return AuthService.hasRole('company_account');
    } catch (e) {
      print('❌ Error checking canForwardTrainingNeeds: $e');
      return false;
    }
  }

  // Get all training needs (System Administrator and Admin only)
  static Future<TrainingNeedListResponse> getAllTrainingNeeds() async {
    try {
      print('🔍 TRAINING NEEDS SERVICE - getAllTrainingNeeds() [POST]');
      print('👥 This method is for Admin and System Administrator roles only');
      print('==========================================');
      
      if (!canViewAllTrainingNeeds()) {
        print('❌ Permission denied: User cannot view all training needs');
        throw Exception('ليس لديك صلاحية لعرض جميع احتياجات التدريب');
      }

      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ No authentication token found');
        throw Exception('رمز المصادقة غير موجود');
      }

      final endpoint = '$_baseUrl${ApiEndpoints.getAllTrainingNeeds}';
      print('🌐 Using endpoint: $endpoint');
      print('📋 Endpoint purpose: Get all training needs for Admin/System Admin');
      print('🔑 Token present: ${token.isNotEmpty}');
      print('==========================================');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = TrainingNeedListResponse.fromJson(jsonData);
        print('✅ Successfully loaded ${result.data.length} training needs');
        print('==========================================');
        return result;
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Error response: ${errorData}');
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب احتياجات التدريب');
        } catch (e) {
          print('❌ Error parsing response: $e');
          throw Exception('فشل في جلب احتياجات التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if user can view all training needs (System Administrator and Admin only)
  static bool canViewAllTrainingNeeds() {
    try {
      final hasSystemAdmin = AuthService.hasRole('system_administrator');
      final hasAdmin = AuthService.hasRole('admin');
      final result = hasSystemAdmin || hasAdmin;
      print('🔐 canViewAllTrainingNeeds: $result (SystemAdmin: $hasSystemAdmin, Admin: $hasAdmin)');
      return result;
    } catch (e) {
      print('❌ Error checking canViewAllTrainingNeeds: $e');
      return false;
    }
  }

  // Check if user can view company-specific training needs (Company Account only)
  static bool canViewCompanyTrainingNeeds() {
    try {
      final hasCompanyAccount = AuthService.hasRole('company_account');
      print('🔐 canViewCompanyTrainingNeeds: $hasCompanyAccount');
      return hasCompanyAccount;
    } catch (e) {
      print('❌ Error checking canViewCompanyTrainingNeeds: $e');
      return false;
    }
  }

  // Create a new training need
  static Future<TrainingNeedResponse> createTrainingNeed(TrainingNeedCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.addTrainingNeed}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return TrainingNeedResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errorMessage = errorData['message_ar'] ?? errorData['message_en'] ?? 'فشل في إنشاء طلب التدريب';
            throw Exception(errorMessage);
          }
          throw Exception(errorData['message_ar'] ?? 'فشل في إنشاء طلب التدريب');
        } catch (e) {
          throw Exception('فشل في إنشاء طلب التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing training need
  static Future<TrainingNeedResponse> updateTrainingNeed(TrainingNeedUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateTrainingNeed}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingNeedResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error or edit restriction
            final errorMessage = errorData['message_ar'] ?? errorData['message_en'] ?? 'فشل في تحديث طلب التدريب';
            throw Exception(errorMessage);
          }
          if (response.statusCode == 404) {
            throw Exception('طلب التدريب غير موجود');
          }
          throw Exception(errorData['message_ar'] ?? 'فشل في تحديث طلب التدريب');
        } catch (e) {
          throw Exception('فشل في تحديث طلب التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Approve training need (System Administrator and Admin only)
  static Future<TrainingNeedResponse> approveTrainingNeed(int id) async {
    try {
      if (!canApproveRejectTrainingNeeds()) {
        throw Exception('ليس لديك صلاحية للموافقة على احتياجات التدريب');
      }

      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      print('✅ TRAINING NEEDS SERVICE - approveTrainingNeed() [POST]');
      print('👥 This method is for Admin and System Administrator roles only');
      print('==========================================');
      print('🆔 Training Need ID: $id');
      print('🌐 Using endpoint: $_baseUrl${ApiEndpoints.approveTrainingNeed}');
      print('==========================================');

      final request = ApproveTrainingNeedRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.approveTrainingNeed}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingNeedResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 403) {
            throw Exception('ليس لديك صلاحية للموافقة على طلبات التدريب');
          }
          throw Exception(errorData['message_en'] ?? 'Failed to approve training need');
        } catch (e) {
          throw Exception('Failed to approve training need: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Forward training need (Company Account only)
  static Future<TrainingNeedResponse> forwardTrainingNeed(int id) async {
    try {
      print('📤 TRAINING NEEDS SERVICE - forwardTrainingNeed() [POST]');
      print('🏢 This method is for Company Account roles only');
      print('==========================================');
      
      if (!canForwardTrainingNeeds()) {
        print('❌ Permission denied: User cannot forward training needs');
        throw Exception('ليس لديك صلاحية لإرسال احتياجات التدريب');
      }

      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ No authentication token found');
        throw Exception('رمز المصادقة غير موجود');
      }

      final endpoint = '$_baseUrl${ApiEndpoints.forwardTrainingNeed}';
      print('🌐 Using endpoint: $endpoint');
      print('📋 Endpoint purpose: Forward training need from Draft to Pending');
      print('🔑 Token present: ${token.isNotEmpty}');
      print('🆔 Training Need ID: $id');
      print('==========================================');

      final request = ForwardTrainingNeedRequest(id: id);
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final result = TrainingNeedResponse.fromJson(jsonData);
        print('✅ Successfully forwarded training need');
        print('==========================================');
        return result;
      } else {
        final errorData = jsonData as Map<String, dynamic>;
        print('❌ Error response: ${errorData}');
        throw Exception(errorData['message_en'] ?? 'Failed to forward training need');
      }
    } catch (e) {
      print('❌ Error forwarding training need: $e');
      throw Exception('Failed to forward training need: ${e.toString()}');
    }
  }

  // Reject training need (System Administrator and Admin)
  static Future<TrainingNeedResponse> rejectTrainingNeed(int id, String reason) async {
    try {
      if (!canApproveRejectTrainingNeeds()) {
        throw Exception('ليس لديك صلاحية لرفض احتياجات التدريب');
      }

      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      print('❌ TRAINING NEEDS SERVICE - rejectTrainingNeed() [POST]');
      print('👥 This method is for Admin and System Administrator roles only');
      print('==========================================');
      print('🆔 Training Need ID: $id');
      print('❌ Rejection Reason: $reason');
      print('📝 Field Name: rejection_reason');
      print('🌐 Using endpoint: $_baseUrl${ApiEndpoints.rejectTrainingNeed}');
      print('==========================================');

      final request = RejectTrainingNeedRequest(id: id, rejection_reason: reason);
      final requestJson = request.toJson();
      print('📤 REJECTION REQUEST - Payload: $requestJson');
      print('📤 REJECTION REQUEST - JSON String: ${jsonEncode(requestJson)}');
      print('==========================================');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.rejectTrainingNeed}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 REJECTION RESPONSE - Status: ${response.statusCode}');
      print('📄 REJECTION RESPONSE - Body: ${response.body}');
      print('🔍 REJECTION RESPONSE - Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = TrainingNeedResponse.fromJson(jsonData);
        print('✅ REJECTION SUCCESS - Training need rejected successfully');
        print('==========================================');
        return result;
      } else {
        // Enhanced error logging for debugging
        print('❌ REJECTION ERROR - Server returned error status: ${response.statusCode}');
        print('📄 REJECTION ERROR - Response body: ${response.body}');
        
        try {
          final errorData = jsonDecode(response.body);
          print('🔍 REJECTION ERROR - Parsed error data: $errorData');
          
          // Log specific error fields
          if (errorData.containsKey('message_en')) {
            print('❌ REJECTION ERROR - English message: ${errorData['message_en']}');
          }
          if (errorData.containsKey('message_ar')) {
            print('❌ REJECTION ERROR - Arabic message: ${errorData['message_ar']}');
          }
          if (errorData.containsKey('errors')) {
            print('❌ REJECTION ERROR - Validation errors: ${errorData['errors']}');
          }
          if (errorData.containsKey('error')) {
            print('❌ REJECTION ERROR - General error: ${errorData['error']}');
          }
          
          if (response.statusCode == 403) {
            print('🚫 REJECTION ERROR - Permission denied (403)');
            throw Exception('ليس لديك صلاحية لرفض طلبات التدريب');
          } else if (response.statusCode == 400) {
            print('🚫 REJECTION ERROR - Bad request (400)');
            throw Exception(errorData['message_en'] ?? 'Invalid request data');
          } else if (response.statusCode == 404) {
            print('🚫 REJECTION ERROR - Not found (404)');
            throw Exception(errorData['message_en'] ?? 'Training need not found');
          } else if (response.statusCode == 500) {
            print('🚫 REJECTION ERROR - Server error (500)');
            throw Exception(errorData['message_en'] ?? 'Internal server error');
          } else {
            print('🚫 REJECTION ERROR - Unknown error status: ${response.statusCode}');
            throw Exception(errorData['message_en'] ?? 'Failed to reject training need');
          }
        } catch (parseError) {
          print('❌ REJECTION ERROR - Failed to parse error response: $parseError');
          print('📄 REJECTION ERROR - Raw response body: ${response.body}');
          throw Exception('Failed to reject training need: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training needs by company (Company Account only)
  static Future<TrainingNeedListResponse> getTrainingNeedsByCompany() async {
    try {
      print('🏢 TRAINING NEEDS SERVICE - getTrainingNeedsByCompany() [POST]');
      print('==========================================');
      
      if (!canViewCompanyTrainingNeeds()) {
        print('❌ Permission denied: User cannot view company training needs');
        throw Exception('ليس لديك صلاحية لعرض احتياجات التدريب للشركة');
      }

      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ No authentication token found');
        throw Exception('رمز المصادقة غير موجود');
      }

      final endpoint = '$_baseUrl${ApiEndpoints.getTrainingNeedsByCompany}';
      print('🌐 Using endpoint: $endpoint');
      print('🔑 Token present: ${token.isNotEmpty}');
      print('==========================================');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = TrainingNeedListResponse.fromJson(jsonData);
        print('✅ Successfully loaded ${result.data.length} company training needs');
        print('==========================================');
        return result;
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Error response: ${errorData}');
          if (response.statusCode == 403) {
            throw Exception('ليس لديك صلاحية لعرض طلبات التدريب');
          }
          throw Exception(errorData['message_en'] ?? 'Failed to get training needs by company');
        } catch (e) {
          print('❌ Error parsing response: $e');
          throw Exception('Failed to get training needs by company: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training needs by status
  static Future<TrainingNeedListResponse> getTrainingNeedsByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = GetTrainingNeedsByStatusRequest(status: status);
      final response = await http.post(
        Uri.parse('$_baseUrl/training-need/by-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingNeedListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_en'] ?? 'Failed to get training needs by status');
        } catch (e) {
          throw Exception('Failed to get training needs by status: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training needs statistics
  static Future<Map<String, dynamic>> getTrainingNeedStats() async {
    try {
      final allTrainingNeeds = await getAllTrainingNeeds();
      
      final int total = allTrainingNeeds.data.length;
      final int pending = allTrainingNeeds.data.where((tn) => tn.isPending).length;
      final int approved = allTrainingNeeds.data.where((tn) => tn.isApproved).length;
      final int rejected = allTrainingNeeds.data.where((tn) => tn.isRejected).length;
      
      return {
        'total': total,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'pendingRate': total > 0 ? (pending / total * 100).toStringAsFixed(1) : '0.0',
        'approvedRate': total > 0 ? (approved / total * 100).toStringAsFixed(1) : '0.0',
        'rejectedRate': total > 0 ? (rejected / total * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات احتياجات التدريب: $e');
    }
  }

  // Validate training need data before API call
  static String? validateTrainingNeedData({
    required int companyId,
    required int courseId,
    required int specializationId,
    required int numberOfParticipants,
    String? status,
  }) {
    if (companyId <= 0) {
      return 'Please select a valid company';
    }
    
    if (courseId <= 0) {
      return 'Please select a valid course';
    }
    
    if (specializationId <= 0) {
      return 'Please select a valid specialization';
    }
    
    if (numberOfParticipants < 1 || numberOfParticipants > 1000) {
      return 'Number of participants must be between 1 and 1000';
    }
    
    if (status != null && status.isNotEmpty) {
      if (status != 'pending' && status != 'approved' && status != 'rejected') {
        return 'Status must be either pending, approved, or rejected';
      }
    }
    
    return null;
  }

  // Show success toast notification
  static void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
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

  // Show error toast notification
  static void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
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

  // Show info toast notification
  static void _showInfoToast(String message) {
    toastification.show(
      context: Get.context!,
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
}
