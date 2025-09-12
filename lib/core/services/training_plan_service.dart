import 'dart:convert';
import 'package:flareline/core/services/api_service.dart';
import 'package:get/get.dart';
import '../models/training_plan_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class TrainingPlanService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has training plan management permission (System Administrator only)
  static bool hasTrainingPlanManagementPermission() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        // Only System Administrator has access to training plans
        return user.roles.any((role) => role.name == 'system_administrator');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can approve/reject training plans (System Administrator only)
  static bool canApproveRejectTrainingPlans() {
    return hasTrainingPlanManagementPermission();
  }

  // Check if user can submit training plans (System Administrator only)
  static bool canSubmitTrainingPlans() {
    return hasTrainingPlanManagementPermission();
  }

  // Get all training plans
  static Future<TrainingPlanListResponse> getAllTrainingPlans() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to view training plans.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getAllTrainingPlans,
        body: {}, // Empty JSON object as per API spec
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanListResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanListResponse(
        data: [],
        messageEn: 'Failed to load training plans: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Get specific training plan by ID
  static Future<TrainingPlanResponse> getTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to view training plans.');
      }

      final request = TrainingPlanShowRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.showTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to load training plan: ${e.toString()}',
        messageAr: 'فشل في تحميل خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Create training plan
  static Future<TrainingPlanResponse> createTrainingPlan(TrainingPlanCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to create training plans.');
      }

      // Validate request data
      final validationError = validateTrainingPlanData(
        year: request.year,
        title: request.title,
        description: request.description,
        status: request.status,
      );
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await ApiService.post(
        ApiEndpoints.createTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to create training plan: ${e.toString()}',
        messageAr: 'فشل في إنشاء خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Update training plan
  static Future<TrainingPlanResponse> updateTrainingPlan(TrainingPlanUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to update training plans.');
      }

      // Validate request data
      final validationError = validateTrainingPlanUpdateData(
        id: request.id,
        year: request.year,
        title: request.title,
        description: request.description,
        status: request.status,
      );
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await ApiService.post(
        ApiEndpoints.updateTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to update training plan: ${e.toString()}',
        messageAr: 'فشل في تحديث خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Get training plans by status
  static Future<TrainingPlanListResponse> getTrainingPlansByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to view training plans.');
      }

      final request = TrainingPlanByStatusRequest(status: status);

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansByStatus,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanListResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanListResponse(
        data: [],
        messageEn: 'Failed to load training plans by status: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب حسب الحالة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Get training plans by year
  static Future<TrainingPlanListResponse> getTrainingPlansByYear(int year) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasTrainingPlanManagementPermission()) {
        throw Exception('You do not have permission to view training plans.');
      }

      final request = TrainingPlanByYearRequest(year: year);

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansByYear,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanListResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanListResponse(
        data: [],
        messageEn: 'Failed to load training plans by year: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب حسب السنة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Submit training plan (change status from draft/rejected to submitted)
  static Future<TrainingPlanResponse> submitTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canSubmitTrainingPlans()) {
        throw Exception('You do not have permission to submit training plans.');
      }

      final request = TrainingPlanSubmitRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.submitTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to submit training plan: ${e.toString()}',
        messageAr: 'فشل في إرسال خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Approve training plan (System Administrator only)
  static Future<TrainingPlanResponse> approveTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectTrainingPlans()) {
        throw Exception('You do not have permission to approve training plans.');
      }

      final request = TrainingPlanApproveRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.approveTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to approve training plan: ${e.toString()}',
        messageAr: 'فشل في قبول خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Reject training plan (System Administrator only)
  static Future<TrainingPlanResponse> rejectTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectTrainingPlans()) {
        throw Exception('You do not have permission to reject training plans.');
      }

      final request = TrainingPlanRejectRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.rejectTrainingPlan,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to reject training plan: ${e.toString()}',
        messageAr: 'فشل في رفض خطة التدريب: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Validation helper for create request
  static String? validateTrainingPlanData({
    required int year,
    required String title,
    String? description,
    String? status,
  }) {
    // Validate year
    if (year < 2020 || year > 2050) {
      return 'Year must be between 2020 and 2050';
    }

    // Note: Year uniqueness is now enforced at backend level
    // Frontend should handle duplicate year errors from API response

    // Validate title
    if (title.trim().isEmpty) {
      return 'Please enter a title';
    }

    if (title.trim().length > 255) {
      return 'Title must be less than 255 characters';
    }

    // Validate status if provided
    if (status != null && !['draft', 'submitted', 'approved', 'rejected'].contains(status)) {
      return 'Invalid status value';
    }

    return null;
  }

  // Validation helper for update request
  static String? validateTrainingPlanUpdateData({
    required int id,
    int? year,
    String? title,
    String? description,
    String? status,
  }) {
    if (id <= 0) {
      return 'Invalid training plan ID';
    }

    // Validate year if provided
    if (year != null && (year < 2020 || year > 2050)) {
      return 'Year must be between 2020 and 2050';
    }

    // Validate title if provided
    if (title != null && title.trim().isEmpty) {
      return 'Please enter a title';
    }

    if (title != null && title.trim().length > 255) {
      return 'Title must be less than 255 characters';
    }

    // Validate status if provided
    if (status != null && !['draft', 'submitted', 'approved', 'rejected'].contains(status)) {
      return 'Invalid status value';
    }

    return null;
  }

  // Helper method to get current user ID
  static int? getCurrentUserId() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      return user?.id;
    } catch (e) {
      return null;
    }
  }

  // Create training plan with current user as creator (convenience method)
  static Future<TrainingPlanResponse> createTrainingPlanForCurrentUser({
    required int year,
    required String title,
    String? description,
    String? status,
  }) async {
    final currentUserId = getCurrentUserId();
    
    final request = TrainingPlanCreateRequest(
      year: year,
      title: title,
      description: description,
      createdBy: currentUserId,
      status: status ?? 'draft', // Default status
    );

    return await createTrainingPlan(request);
  }

  // Get available years for dropdown (helper method)
  static List<int> getAvailableYears() {
    final currentYear = DateTime.now().year;
    final years = <int>[];
    
    // Include past 5 years, current year, and next 5 years
    for (int i = currentYear - 5; i <= currentYear + 5; i++) {
      if (i >= 2020 && i <= 2050) {
        years.add(i);
      }
    }
    
    return years;
  }

  // Get status options for dropdown (helper method)
  static List<Map<String, String>> getStatusOptions() {
    return [
      {'value': 'draft', 'label': 'Draft', 'labelAr': 'مسودة'},
      {'value': 'submitted', 'label': 'Submitted', 'labelAr': 'مُرسل'},
    ];
  }
}