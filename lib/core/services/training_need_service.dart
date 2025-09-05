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
        // System Administrator has full access, Company Account has limited access
        return user.roles.any((role) => 
          role.name == 'system_administrator' || 
          role.name == 'company_account'
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can approve/reject training needs (System Administrator only)
  static bool canApproveRejectTrainingNeeds() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => role.name == 'system_administrator');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get all training needs
  static Future<TrainingNeedListResponse> getAllTrainingNeeds() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/training-need/select'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingNeedListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب احتياجات التدريب');
        } catch (e) {
          throw Exception('فشل في جلب احتياجات التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
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
        Uri.parse('$_baseUrl/training-need/create'),
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
        Uri.parse('$_baseUrl/training-need/update'),
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

  // Approve training need (System Administrator only)
  static Future<TrainingNeedResponse> approveTrainingNeed(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = ApproveTrainingNeedRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl/training-need/approve'),
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

  // Reject training need (System Administrator only)
  static Future<TrainingNeedResponse> rejectTrainingNeed(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = RejectTrainingNeedRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl/training-need/reject'),
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
            throw Exception('ليس لديك صلاحية لرفض طلبات التدريب');
          }
          throw Exception(errorData['message_en'] ?? 'Failed to reject training need');
        } catch (e) {
          throw Exception('Failed to reject training need: ${response.statusCode}');
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
    required int numberOfParticipants,
    String? status,
  }) {
    if (companyId <= 0) {
      return 'Please select a valid company';
    }
    
    if (courseId <= 0) {
      return 'Please select a valid course';
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
