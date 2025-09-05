import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/training_center_branch_model.dart';
import '../models/training_center_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import 'training_center_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class TrainingCenterBranchService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has training center branch management permission
  static bool hasTrainingCenterBranchManagementPermission() {
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

  // Get all training center branches (with optional center filter)
  static Future<TrainingCenterBranchListResponse> getAllTrainingCenterBranches({int? centerId}) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = GetTrainingCenterBranchesRequest(centerId: centerId);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenterBranches}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب فروع مراكز التدريب');
        } catch (e) {
          throw Exception('فشل في جلب فروع مراكز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new training center branch
  static Future<TrainingCenterBranchResponse> createTrainingCenterBranch(TrainingCenterBranchCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createTrainingCenterBranch}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 400) {
            // Validation error
            final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في إنشاء فرع مركز التدريب';
            throw Exception(errorMessage);
          }
          throw Exception(errorData['m_ar'] ?? 'فشل في إنشاء فرع مركز التدريب');
        } catch (e) {
          throw Exception('فشل في إنشاء فرع مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing training center branch
  static Future<TrainingCenterBranchResponse> updateTrainingCenterBranch(TrainingCenterBranchUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateTrainingCenterBranch}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 400) {
            // Validation error
            final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في تحديث فرع مركز التدريب';
            throw Exception(errorMessage);
          }
          if (response.statusCode == 404) {
            throw Exception('فرع مركز التدريب غير موجود');
          }
          throw Exception(errorData['m_ar'] ?? 'فشل في تحديث فرع مركز التدريب');
        } catch (e) {
          throw Exception('فشل في تحديث فرع مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training center branches by status
  static Future<TrainingCenterBranchListResponse> getTrainingCenterBranchesByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenterBranches}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب فروع مراكز التدريب حسب الحالة');
        } catch (e) {
          throw Exception('فشل في جلب فروع مراكز التدريب حسب الحالة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training center branches by training center ID
  static Future<TrainingCenterBranchListResponse> getTrainingCenterBranchesByTrainingCenter(int trainingCenterId) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenterBranches}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'center_id': trainingCenterId}), // Using center_id as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب فروع مركز التدريب');
        } catch (e) {
          throw Exception('فشل في جلب فروع مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search training center branches
  static Future<TrainingCenterBranchListResponse> searchTrainingCenterBranches(String query) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenterBranches}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'search': query}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterBranchListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في البحث عن فروع مراكز التدريب');
        } catch (e) {
          throw Exception('فشل في البحث عن فروع مراكز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training center branch statistics
  static Future<Map<String, dynamic>> getTrainingCenterBranchStats() async {
    try {
      final allBranches = await getAllTrainingCenterBranches();
      
      final int total = allBranches.data.length;
      
      return {
        'total': total,
        'totalRate': '100.0',
      };
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات فروع مراكز التدريب: $e');
    }
  }

  // Get all training centers for dropdown selection
  static Future<List<TrainingCenter>> getAllTrainingCentersForSelection() async {
    try {
      final response = await TrainingCenterService.getAllTrainingCenters();
      if (response.success) {
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Validate training center branch data before API call
  static String? validateTrainingCenterBranchData({
    required String name,
    required int trainingCenterId,
    required String address,
    required String phone,
    double? lat,
    double? long,
  }) {
    if (name.trim().isEmpty) {
      return 'Branch name is required';
    }
    
    if (name.length > 255) {
      return 'Branch name must not exceed 255 characters';
    }
    
    if (trainingCenterId <= 0) {
      return 'Training center must be selected';
    }
    
    if (address.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    if (phone.length > 20) {
      return 'Phone number must not exceed 20 characters';
    }
    
    // Validate latitude (-90 to 90)
    if (lat != null && (lat < -90 || lat > 90)) {
      return 'Latitude must be between -90 and 90 degrees';
    }
    
    // Validate longitude (-180 to 180)
    if (long != null && (long < -180 || long > 180)) {
      return 'Longitude must be between -180 and 180 degrees';
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
}
