import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/trainer_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class TrainerService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has trainer management permission
  static bool hasTrainerManagementPermission() {
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

  // Get all trainers
  static Future<TrainerListResponse> getAllTrainers() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllTrainers}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API spec
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في جلب المدربين');
        } catch (e) {
          throw Exception('فشل في جلب المدربين: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new trainer
  static Future<TrainerResponse> createTrainer(TrainerCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createTrainer}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return TrainerResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 400) {
            // Validation error
            final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في إنشاء المدرب';
            throw Exception(errorMessage);
          }
          throw Exception(errorData['m_ar'] ?? 'فشل في إنشاء المدرب');
        } catch (e) {
          throw Exception('فشل في إنشاء المدرب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing trainer
  static Future<TrainerResponse> updateTrainer(TrainerUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateTrainer}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 400) {
            // Validation error
            final errorMessage = errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في تحديث المدرب';
            throw Exception(errorMessage);
          }
          throw Exception(errorData['m_ar'] ?? 'فشل في تحديث المدرب');
        } catch (e) {
          throw Exception('فشل في تحديث المدرب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a trainer
  static Future<TrainerResponse> deleteTrainer(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/trainers/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? 'فشل في حذف المدرب');
        } catch (e) {
          throw Exception('فشل في حذف المدرب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Accept trainer (change status from pending to approved)
  static Future<TrainerResponse> acceptTrainer(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = AcceptTrainerRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.acceptTrainer}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في قبول المدرب');
        } catch (e) {
          throw Exception('فشل في قبول المدرب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reject trainer (change status from pending to rejected)
  static Future<TrainerResponse> rejectTrainer(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = RejectTrainerRequest(id: id);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.rejectTrainer}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في رفض المدرب');
        } catch (e) {
          throw Exception('فشل في رفض المدرب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get trainers by status (supports pending, approved, rejected)
  static Future<TrainerListResponse> getTrainersByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = GetTrainersByStatusRequest(status: status);
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getTrainersByStatus}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainerListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['m_ar'] ?? errorData['m_en'] ?? 'فشل في جلب المدربين حسب الحالة');
        } catch (e) {
          throw Exception('فشل في جلب المدربين حسب الحالة: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Validate trainer data according to API specification
  static String? validateTrainerData({
    String? name,
    String? email,
    String? phone,
    List<String>? specializations,
    String? bio,
    String? qualifications,
    int? yearsExperience,
    List<String>? certifications,
  }) {
    if (name != null && name.isEmpty) {
      return 'Name is required';
    }
    
    if (email != null && email.isEmpty) {
      return 'Email is required';
    }
    
    if (email != null && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Invalid email format';
    }
    
    if (phone != null && phone.isEmpty) {
      return 'Phone is required';
    }
    
    if (specializations != null && specializations.isEmpty) {
      return 'Specializations are required';
    }
    
    if (yearsExperience != null && (yearsExperience < 0 || yearsExperience > 50)) {
      return 'Years of experience must be between 0 and 50';
    }
    
    return null;
  }

  // Helper method to show success toast
  static void showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.success,
      title: const Text('Success'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  // Helper method to show error toast
  static void showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.error,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  // Helper method to show warning toast
  static void showWarningToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.warning,
      title: const Text('Warning'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
