import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/training_center_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class TrainingCenterService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has training center management permission
  static bool hasTrainingCenterManagementPermission() {
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

  // Get all training centers
  static Future<TrainingCenterListResponse> getAllTrainingCenters() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final uri = Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenters}');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = jsonEncode({}); // Empty body as per API spec

      // Debug request
      print('📡 TrainingCenterService.getAllTrainingCenters → POST ' + uri.toString());
      print('📡 Headers: ' + headers.toString());
      print('📡 Body: ' + body);

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          print('❌ TrainingCenterService.getAllTrainingCenters ERROR ' + response.statusCode.toString());
          print('❌ Response body: ' + response.body);
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب مراكز التدريب');
        } catch (e) {
          print('❌ TrainingCenterService.getAllTrainingCenters Unparsed error. Status: ' + response.statusCode.toString());
          print('❌ Raw body: ' + response.body);
          throw Exception('فشل في جلب مراكز التدريب: \\${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ TrainingCenterService.getAllTrainingCenters Exception: ' + e.toString());
      rethrow;
    }
  }

  // Get all training centers using admin API endpoint
  static Future<TrainingCenterListResponse> adminGetAllTrainingCenters() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.adminGetAllTrainingCenters}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب مراكز التدريب');
        } catch (e) {
          throw Exception('فشل في جلب مراكز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get approved training centers only
  static Future<TrainingCenterListResponse> getApprovedTrainingCenters() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getApprovedTrainingCenters}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب مراكز التدريب المعتمدة');
        } catch (e) {
          throw Exception('فشل في جلب مراكز التدريب المعتمدة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new training center
  static Future<TrainingCenterResponse> createTrainingCenter(TrainingCenterCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createTrainingCenter}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterResponse.fromJson(jsonData);
      } else {
        // Handle error responses according to API documentation
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage;
          
          switch (response.statusCode) {
            case 401:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح';
              break;
            case 403:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح لك بإنشاء مركز تدريب';
              break;
            case 422:
              // Validation error - show specific field errors
              if (errorData['errors'] != null) {
                final errors = errorData['errors'] as Map<String, dynamic>;
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first.toString();
                } else {
                  errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
                }
              } else {
                errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
              }
              break;
            default:
              errorMessage = errorData['message_ar'] ?? errorData['message_en'] ?? 'فشل في إنشاء مركز التدريب';
          }
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('فشل في إنشاء مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing training center
  static Future<TrainingCenterResponse> updateTrainingCenter(TrainingCenterUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateTrainingCenter}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterResponse.fromJson(jsonData);
      } else {
        // Handle error responses according to API documentation
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage;
          
          switch (response.statusCode) {
            case 401:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح';
              break;
            case 403:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح لك بتحديث مركز التدريب';
              break;
            case 404:
              errorMessage = errorData['message_ar'] ?? 'مركز التدريب غير موجود';
              break;
            case 422:
              // Validation error - show specific field errors
              if (errorData['errors'] != null) {
                final errors = errorData['errors'] as Map<String, dynamic>;
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first.toString();
                } else {
                  errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
                }
              } else {
                errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
              }
              break;
            default:
              errorMessage = errorData['message_ar'] ?? errorData['message_en'] ?? 'فشل في تحديث مركز التدريب';
          }
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('فشل في تحديث مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Accept training center (change status from pending to approved)
  static Future<TrainingCenterResponse> acceptTrainingCenter(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = AcceptTrainingCenterRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.acceptTrainingCenter}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_en'] ?? 'Failed to accept training center');
        } catch (e) {
          throw Exception('Failed to accept training center: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reject training center (change status from pending to rejected)
  static Future<TrainingCenterResponse> rejectTrainingCenter(int id, {required String rejectionReason}) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      // Validate rejection reason is provided
      if (rejectionReason.trim().isEmpty) {
        throw Exception('Rejection reason is required');
      }

      final request = RejectTrainingCenterRequest(id: id, rejectionReason: rejectionReason);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.rejectTrainingCenter}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterResponse.fromJson(jsonData);
      } else {
        // Handle error responses according to API documentation
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage;
          
          switch (response.statusCode) {
            case 401:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح';
              break;
            case 403:
              errorMessage = errorData['message_ar'] ?? 'غير مصرح لك برفض مركز التدريب';
              break;
            case 404:
              errorMessage = errorData['message_ar'] ?? 'مركز التدريب غير موجود';
              break;
            case 422:
              // Validation error - show specific field errors
              if (errorData['errors'] != null) {
                final errors = errorData['errors'] as Map<String, dynamic>;
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first.toString();
                } else {
                  errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
                }
              } else {
                errorMessage = errorData['message_ar'] ?? 'بيانات غير صحيحة';
              }
              break;
            default:
              errorMessage = errorData['message_ar'] ?? errorData['message_en'] ?? 'فشل في رفض مركز التدريب';
          }
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('فشل في رفض مركز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training centers by status (supports pending, approved, rejected)
  static Future<TrainingCenterListResponse> getTrainingCentersByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = GetTrainingCentersByStatusRequest(status: status);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getTrainingCentersByStatus}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_en'] ?? 'Failed to get training centers by status');
        } catch (e) {
          throw Exception('Failed to get training centers by status: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search training centers
  static Future<TrainingCenterListResponse> searchTrainingCenters(String query) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainingCenters}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'search': query}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingCenterListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في البحث عن مراكز التدريب');
        } catch (e) {
          throw Exception('فشل في البحث عن مراكز التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get training center statistics
  static Future<Map<String, dynamic>> getTrainingCenterStats() async {
    try {
      final allTrainingCenters = await getAllTrainingCenters();
      
      final int total = allTrainingCenters.data.length;
      final int pending = allTrainingCenters.data.where((tc) => tc.isPending).length;
      final int approved = allTrainingCenters.data.where((tc) => tc.isApproved).length;
      final int rejected = allTrainingCenters.data.where((tc) => tc.isRejected).length;
      
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
      throw Exception('خطأ في جلب إحصائيات مراكز التدريب: $e');
    }
  }

  // Validate training center data before API call
  static String? validateTrainingCenterData({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? website,
    String? description,
    String? status,
  }) {
    if (name.trim().isEmpty) {
      return 'Training center name is required';
    }
    
    if (name.length > 255) {
      return 'Training center name must not exceed 255 characters';
    }
    
    if (email.trim().isEmpty) {
      return 'Email address is required';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please provide a valid email address';
    }
    
    if (phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    if (phone.length > 20) {
      return 'Phone number must not exceed 20 characters';
    }
    
    if (address.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (website != null && website.isNotEmpty) {
      if (website.length > 255) {
        return 'Website URL cannot exceed 255 characters';
      }
      final uri = Uri.tryParse(website);
      if (uri == null || !uri.hasAbsolutePath) {
        return 'Please provide a valid website URL';
      }
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
