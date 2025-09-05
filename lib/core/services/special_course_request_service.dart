import 'dart:convert';
import 'package:flareline/core/services/api_service.dart';
import 'package:get/get.dart';
import '../models/special_course_request_model.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class SpecialCourseRequestService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Check if user has special course request management permission
  static bool hasSpecialCourseRequestManagementPermission() {
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

  // Check if user can approve/reject special course requests (System Administrator only)
  static bool canApproveRejectSpecialCourseRequests() {
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

  // Get all special course requests
  static Future<SpecialCourseRequestListResponse> getAllSpecialCourseRequests() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasSpecialCourseRequestManagementPermission()) {
        throw Exception('You do not have permission to view special course requests.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getAllSpecialCourseRequests,
        body: {}, // Empty JSON object as per API spec
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestListResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestListResponse(
        data: [],
        messageEn: 'Failed to load special course requests: ${e.toString()}',
        messageAr: 'فشل في تحميل طلبات الدورات الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Create special course request
  static Future<SpecialCourseRequestResponse> createSpecialCourseRequest(SpecialCourseRequestCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasSpecialCourseRequestManagementPermission()) {
        throw Exception('You do not have permission to create special course requests.');
      }

      // Validate request data
      final validationError = validateSpecialCourseRequestData(
        companyId: request.companyId,
        title: request.title,
        description: request.description,
        fileAttachment: request.fileAttachment,
        status: request.status,
      );
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await ApiService.post(
        ApiEndpoints.createSpecialCourseRequest,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestResponse(
        messageEn: 'Failed to create special course request: ${e.toString()}',
        messageAr: 'فشل في إنشاء طلب الدورة الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Update special course request
  static Future<SpecialCourseRequestResponse> updateSpecialCourseRequest(SpecialCourseRequestUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasSpecialCourseRequestManagementPermission()) {
        throw Exception('You do not have permission to update special course requests.');
      }

      // Validate request data
      final validationError = validateSpecialCourseRequestUpdateData(
        id: request.id,
        companyId: request.companyId,
        title: request.title,
        description: request.description,
        fileAttachment: request.fileAttachment,
        status: request.status,
      );
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await ApiService.post(
        ApiEndpoints.updateSpecialCourseRequest,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestResponse(
        messageEn: 'Failed to update special course request: ${e.toString()}',
        messageAr: 'فشل في تحديث طلب الدورة الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Get special course requests by status
  static Future<SpecialCourseRequestListResponse> getSpecialCourseRequestsByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!hasSpecialCourseRequestManagementPermission()) {
        throw Exception('You do not have permission to view special course requests.');
      }

      final request = SpecialCourseRequestByStatusRequest(status: status);

      final response = await ApiService.post(
        ApiEndpoints.getSpecialCourseRequestsByStatus,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestListResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestListResponse(
        data: [],
        messageEn: 'Failed to load special course requests by status: ${e.toString()}',
        messageAr: 'فشل في تحميل طلبات الدورات الخاصة حسب الحالة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Approve special course request (System Administrator only)
  static Future<SpecialCourseRequestResponse> approveSpecialCourseRequest(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectSpecialCourseRequests()) {
        throw Exception('You do not have permission to approve special course requests.');
      }

      final request = SpecialCourseRequestApproveRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.approveSpecialCourseRequest,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestResponse(
        messageEn: 'Failed to approve special course request: ${e.toString()}',
        messageAr: 'فشل في قبول طلب الدورة الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Reject special course request (System Administrator only)
  static Future<SpecialCourseRequestResponse> rejectSpecialCourseRequest(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectSpecialCourseRequests()) {
        throw Exception('You do not have permission to reject special course requests.');
      }

      final request = SpecialCourseRequestRejectRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.rejectSpecialCourseRequest,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return SpecialCourseRequestResponse.fromJson(responseData);
    } catch (e) {
      return SpecialCourseRequestResponse(
        messageEn: 'Failed to reject special course request: ${e.toString()}',
        messageAr: 'فشل في رفض طلب الدورة الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Validation helper for create request
  static String? validateSpecialCourseRequestData({
    required int companyId,
    required String title,
    required String description,
    String? fileAttachment,
    String? status,
  }) {
    if (companyId <= 0) {
      return 'Please select a valid company';
    }

    if (title.trim().isEmpty) {
      return 'Please enter a title';
    }

    if (title.trim().length > 255) {
      return 'Title must be less than 255 characters';
    }

    if (description.trim().isEmpty) {
      return 'Please enter a description';
    }

    if (status != null && !['pending', 'approved', 'rejected'].contains(status)) {
      return 'Invalid status value';
    }

    return null;
  }

  // Validation helper for update request
  static String? validateSpecialCourseRequestUpdateData({
    required int id,
    int? companyId,
    String? title,
    String? description,
    String? fileAttachment,
    String? status,
  }) {
    if (id <= 0) {
      return 'Invalid special course request ID';
    }

    if (companyId != null && companyId <= 0) {
      return 'Please select a valid company';
    }

    if (title != null && title.trim().isEmpty) {
      return 'Please enter a title';
    }

    if (title != null && title.trim().length > 255) {
      return 'Title must be less than 255 characters';
    }

    if (description != null && description.trim().isEmpty) {
      return 'Please enter a description';
    }

    if (status != null && !['pending', 'approved', 'rejected'].contains(status)) {
      return 'Invalid status value';
    }

    return null;
  }

  // Helper method to get current user's company ID (for company accounts)
  static int? getCurrentUserCompanyId() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null) {
        // This would need to be implemented based on your user model structure
        // For now, return null and let the form handle company selection
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create special course request for current company (convenience method)
  static Future<SpecialCourseRequestResponse> createSpecialCourseRequestForCurrentCompany({
    required int companyId,
    required String title,
    required String description,
    String? fileAttachment,
    String? createdBy,
  }) async {
    final request = SpecialCourseRequestCreateRequest(
      companyId: companyId,
      title: title,
      description: description,
      fileAttachment: fileAttachment,
      status: 'pending', // Default status
      createdBy: createdBy ?? 'company_request', // Default created_by
    );

    return await createSpecialCourseRequest(request);
  }
}