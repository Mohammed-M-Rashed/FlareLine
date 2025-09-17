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
  
  // Check if user is a Company Account
  static bool isCompanyAccount() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => role.name == 'company_account');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user is Admin or System Administrator
  static bool isAdminOrSystemAdministrator() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => 
          role.name == 'admin' || 
          role.name == 'system_administrator'
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user can create special course requests (Company Account only)
  static bool canCreateSpecialCourseRequests() {
    return isCompanyAccount();
  }

  // Check if user can update special course requests (Company Account only)
  static bool canUpdateSpecialCourseRequests() {
    return isCompanyAccount();
  }

  // Check if user can view all special course requests (Admin and System Administrator only)
  static bool canViewAllSpecialCourseRequests() {
    return isAdminOrSystemAdministrator();
  }

  // Check if user can view company special course requests (Company Account only)
  static bool canViewCompanySpecialCourseRequests() {
    return isCompanyAccount();
  }

  // Check if user can forward special course requests (Company Account only)
  static bool canForwardSpecialCourseRequests() {
    return isCompanyAccount();
  }

  // Check if user can approve/reject special course requests (Admin and System Administrator only)
  static bool canApproveRejectSpecialCourseRequests() {
    return isAdminOrSystemAdministrator();
  }

  // Get all special course requests (Admin and System Administrator only)
  static Future<SpecialCourseRequestListResponse> getAllSpecialCourseRequests() async {
    const String methodName = 'getAllSpecialCourseRequests';
    print('🔍 ERROR_TRACKING: Starting $methodName');
    
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ ERROR_TRACKING: $methodName - No authentication token found');
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canViewAllSpecialCourseRequests()) {
        print('❌ ERROR_TRACKING: $methodName - Permission denied. User does not have admin/system admin role');
        throw Exception('You do not have permission to view all special course requests. Only Admin and System Administrator can access this endpoint.');
      }

      print('🔍 ERROR_TRACKING: $methodName - Making API call to ${ApiEndpoints.getAllSpecialCourseRequests}');
      final response = await ApiService.post(
        ApiEndpoints.getAllSpecialCourseRequests,
        body: {}, // Empty JSON object as per API spec
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 ERROR_TRACKING: $methodName - API response status: ${response.statusCode}');
      print('🔍 ERROR_TRACKING: $methodName - API response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final result = SpecialCourseRequestListResponse.fromJson(responseData);
      
      if (result.success) {
        print('✅ ERROR_TRACKING: $methodName - Successfully loaded ${result.data.length} special course requests');
      } else {
        print('❌ ERROR_TRACKING: $methodName - API returned error: ${result.messageEn}');
      }
      
      return result;
    } catch (e, stackTrace) {
      print('❌ ERROR_TRACKING: $methodName - Exception occurred: $e');
      print('❌ ERROR_TRACKING: $methodName - Stack trace: $stackTrace');
      
      return SpecialCourseRequestListResponse(
        data: [],
        messageEn: 'Failed to load special course requests: ${e.toString()}',
        messageAr: 'فشل في تحميل طلبات الدورات الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Create special course request (Company Account only)
  static Future<SpecialCourseRequestResponse> createSpecialCourseRequest(SpecialCourseRequestCreateRequest request) async {
    const String methodName = 'createSpecialCourseRequest';
    print('🔍 ERROR_TRACKING: Starting $methodName');
    print('🔍 ERROR_TRACKING: $methodName - Request data: ${request.toJson()}');
    
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ ERROR_TRACKING: $methodName - No authentication token found');
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canCreateSpecialCourseRequests()) {
        print('❌ ERROR_TRACKING: $methodName - Permission denied. User does not have company account role');
        throw Exception('You do not have permission to create special course requests. Only Company Account can create requests.');
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
        print('❌ ERROR_TRACKING: $methodName - Validation error: $validationError');
        throw Exception(validationError);
      }

      print('🔍 ERROR_TRACKING: $methodName - Making API call to ${ApiEndpoints.createSpecialCourseRequest}');
      final response = await ApiService.post(
        ApiEndpoints.createSpecialCourseRequest,
        body: request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 ERROR_TRACKING: $methodName - API response status: ${response.statusCode}');
      print('🔍 ERROR_TRACKING: $methodName - API response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final result = SpecialCourseRequestResponse.fromJson(responseData);
      
      if (result.success) {
        print('✅ ERROR_TRACKING: $methodName - Successfully created special course request with ID: ${result.data?.id}');
      } else {
        print('❌ ERROR_TRACKING: $methodName - API returned error: ${result.messageEn}');
      }
      
      return result;
    } catch (e, stackTrace) {
      print('❌ ERROR_TRACKING: $methodName - Exception occurred: $e');
      print('❌ ERROR_TRACKING: $methodName - Stack trace: $stackTrace');
      
      return SpecialCourseRequestResponse(
        messageEn: 'Failed to create special course request: ${e.toString()}',
        messageAr: 'فشل في إنشاء طلب الدورة الخاصة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Update special course request (Company Account only)
  static Future<SpecialCourseRequestResponse> updateSpecialCourseRequest(SpecialCourseRequestUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canUpdateSpecialCourseRequests()) {
        throw Exception('You do not have permission to update special course requests. Only Company Account can update requests.');
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

  // Get special course requests by company (Company Account only)
  static Future<SpecialCourseRequestListResponse> getSpecialCourseRequestsByCompany() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canViewCompanySpecialCourseRequests()) {
        throw Exception('You do not have permission to view company special course requests. Only Company Account can access this endpoint.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getSpecialCourseRequestsByCompany,
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
        messageEn: 'Failed to load company special course requests: ${e.toString()}',
        messageAr: 'فشل في تحميل طلبات الدورات الخاصة للشركة: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Approve special course request (Admin and System Administrator only)
  static Future<SpecialCourseRequestResponse> approveSpecialCourseRequest(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectSpecialCourseRequests()) {
        throw Exception('You do not have permission to approve special course requests. Only Admin and System Administrator can approve requests.');
      }

      final request = ApproveSpecialCourseRequestRequest(id: id);

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

  // Reject special course request (Admin and System Administrator only)
  static Future<SpecialCourseRequestResponse> rejectSpecialCourseRequest(int id, String rejectionReason) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canApproveRejectSpecialCourseRequests()) {
        throw Exception('You do not have permission to reject special course requests. Only Admin and System Administrator can reject requests.');
      }

      // Validate rejection reason
      if (rejectionReason.trim().isEmpty) {
        throw Exception('Rejection reason is required and cannot be empty.');
      }

      final request = RejectSpecialCourseRequestRequest(id: id, rejectionReason: rejectionReason);

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

  // Forward special course request (Company Account only)
  static Future<SpecialCourseRequestResponse> forwardSpecialCourseRequest(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!canForwardSpecialCourseRequests()) {
        throw Exception('You do not have permission to forward special course requests. Only Company Account can forward requests.');
      }

      final request = ForwardSpecialCourseRequestRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.forwardSpecialCourseRequest,
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
        messageEn: 'Failed to forward special course request: ${e.toString()}',
        messageAr: 'فشل في إرسال طلب الدورة الخاصة: ${e.toString()}',
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
    const String methodName = 'getCurrentUserCompanyId';
    print('🔍 ERROR_TRACKING: Starting $methodName');
    
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      print('🔍 ERROR_TRACKING: $methodName - user: $user');
      
      if (user != null) {
        print('🔍 ERROR_TRACKING: $methodName - user.companyId: ${user.companyId}');
        print('🔍 ERROR_TRACKING: $methodName - user.roles: ${user.roles.map((r) => r.name).join(', ')}');
        print('🔍 ERROR_TRACKING: $methodName - user.company: ${user.company}');
        
        // Try to get company ID from user.companyId first
        if (user.companyId != null) {
          print('✅ ERROR_TRACKING: $methodName - Found company ID from user.companyId: ${user.companyId}');
          return user.companyId;
        }
        
        // Fallback: try to get company ID from user.company object
        if (user.company != null && user.company!.id != null) {
          print('✅ ERROR_TRACKING: $methodName - Found company ID from user.company.id: ${user.company!.id}');
          return user.company!.id;
        }
        
        print('❌ ERROR_TRACKING: $methodName - No company ID found in user data');
        return null;
      }
      
      print('❌ ERROR_TRACKING: $methodName - User is null');
      return null;
    } catch (e, stackTrace) {
      print('❌ ERROR_TRACKING: $methodName - Exception occurred: $e');
      print('❌ ERROR_TRACKING: $methodName - Stack trace: $stackTrace');
      return null;
    }
  }

  // Create special course request for current company (convenience method)
  static Future<SpecialCourseRequestResponse> createSpecialCourseRequestForCurrentCompany({
    required int companyId,
    required int specializationId,
    required String title,
    required String description,
    String? fileAttachment,
  }) async {
    final request = SpecialCourseRequestCreateRequest(
      companyId: companyId,
      specializationId: specializationId,
      title: title,
      description: description,
      fileAttachment: fileAttachment,
      status: 'pending', // Default status
    );

    return await createSpecialCourseRequest(request);
  }
}