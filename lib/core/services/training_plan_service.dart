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
  
  // Role-based permission checks
  static bool isAdmin() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => role.name == 'admin');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isTrainingGeneralManager() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => role.name == 'training_general_manager');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isBoardChairman() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      if (user != null && user.roles.isNotEmpty) {
        return user.roles.any((role) => role.name == 'board_chairman');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

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

  // Check if user has training plan management permission (Everyone can view, Admin can manage)
  static bool hasTrainingPlanManagementPermission() {
    return true; // Everyone can access the training plans page
  }

  // Check if user can create/edit training plans (Admin only, not Training General Manager or Board Chairman)
  static bool canCreateEditTrainingPlans() {
    return isAdmin() && !isTrainingGeneralManager() && !isBoardChairman();
  }

  // Check if user can approve/reject training plans (Board Chairman only)
  static bool canApproveRejectTrainingPlans() {
    return isBoardChairman();
  }

  // Check if user can submit training plans (Admin only)
  static bool canSubmitTrainingPlans() {
    return isAdmin();
  }

  // Admin Role Methods
  
  // Get all training plans (Admin only)
  static Future<TrainingPlanListResponse> getAllTrainingPlans() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to view all training plans.');
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

  // Get training plans with plan_preparation status using admin API endpoint
  static Future<TrainingPlanListResponse> adminGetTrainingPlansPlanPreparation() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await ApiService.post(
        ApiEndpoints.adminGetTrainingPlans,
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
        messageEn: 'Failed to load training plans for plan preparation: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب لإعداد الخطة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // General Training Director Role Methods
  
  // Get training plans for General Manager (General Training Director only)
  static Future<TrainingPlanListResponse> getTrainingPlansForGeneralManager() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isTrainingGeneralManager()) {
        throw Exception('You do not have permission to view training plans for general manager.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansForGeneralManager,
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
        messageEn: 'Failed to load training plans for general manager: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب للمدير العام: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Board Chairman Role Methods
  
  // Get training plans for Board Chairman (Board Chairman only)
  static Future<TrainingPlanListResponse> getTrainingPlansForBoardChairman() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isBoardChairman()) {
        throw Exception('You do not have permission to view training plans for board chairman.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansForBoardChairman,
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
        messageEn: 'Failed to load training plans for board chairman: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب لرئيس مجلس الإدارة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Company Account Role Methods
  
  // Get training plans for Company (Company Account only)
  static Future<TrainingPlanListResponse> getTrainingPlansForCompany() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isCompanyAccount()) {
        throw Exception('You do not have permission to view training plans for company.');
      }

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansForCompany,
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
        messageEn: 'Failed to load training plans for company: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب للشركة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Get specific training plan for Company (Company Account only)
  static Future<TrainingPlanResponse> getTrainingPlanForCompany(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isCompanyAccount()) {
        throw Exception('You do not have permission to view training plan for company.');
      }

      final request = TrainingPlanShowRequest(id: id);

      final response = await ApiService.post(
        ApiEndpoints.showTrainingPlanForCompany,
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
        messageEn: 'Failed to load training plan for company: ${e.toString()}',
        messageAr: 'فشل في تحميل خطة التدريب للشركة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Get specific training plan by ID (Admin only)
  static Future<TrainingPlanResponse> getTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
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

  // Create training plan (Admin only)
  static Future<TrainingPlanResponse> createTrainingPlan(TrainingPlanCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
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

  // Update training plan (Admin only)
  static Future<TrainingPlanResponse> updateTrainingPlan(TrainingPlanUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
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

  // Get training plans by status (Admin only)
  static Future<TrainingPlanListResponse> getTrainingPlansByStatus(String status) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to view training plans by status.');
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

  // Get training plans by year (Admin only)
  static Future<TrainingPlanListResponse> getTrainingPlansByYear(int year) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to view training plans by year.');
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

  // Get training plans by company (Admin only)
  static Future<TrainingPlanListResponse> getTrainingPlansByCompany(int companyId) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to view training plans by company.');
      }

      // Validate company ID
      final companyValidation = validateCompanyId(companyId);
      if (companyValidation != null) {
        throw Exception(companyValidation);
      }

      final request = TrainingPlanByCompanyRequest(companyId: companyId);

      final response = await ApiService.post(
        ApiEndpoints.getTrainingPlansByCompany,
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
        messageEn: 'Failed to load training plans by company: ${e.toString()}',
        messageAr: 'فشل في تحميل خطط التدريب حسب الشركة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Workflow Methods

  // Move to Plan Preparation (Admin only)
  static Future<TrainingPlanResponse> moveToPlanPreparation(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to move training plans to plan preparation.');
      }

      // Validate training plan ID
      final idValidation = validateTrainingPlanId(id);
      if (idValidation != null) {
        throw Exception(idValidation);
      }

      final response = await ApiService.post(
        ApiEndpoints.moveToPlanPreparation,
        body: {'id': id},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to move training plan to plan preparation: ${e.toString()}',
        messageAr: 'فشل في نقل خطة التدريب إلى إعداد الخطة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Move to General Training Director Approval (Admin only)
  static Future<TrainingPlanResponse> moveToTrainingGeneralManagerApproval(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isAdmin()) {
        throw Exception('You do not have permission to move training plans to general manager approval.');
      }

      // Validate training plan ID
      final idValidation = validateTrainingPlanId(id);
      if (idValidation != null) {
        throw Exception(idValidation);
      }

      // Get the training plan to validate course assignments
      final planResponse = await getTrainingPlan(id);
      if (!planResponse.success || planResponse.data == null) {
        throw Exception('Failed to load training plan for validation');
      }

      final plan = planResponse.data!;
      
      // Validate workflow transition
      final transitionValidation = validateWorkflowTransition(plan, 'training_general_manager_approval');
      if (transitionValidation != null) {
        throw Exception(transitionValidation);
      }

      // Validate course assignments
      final assignmentValidation = validateCourseAssignments(plan);
      if (assignmentValidation != null) {
        throw Exception(assignmentValidation);
      }

      final response = await ApiService.post(
        ApiEndpoints.moveToTrainingGeneralManagerApproval,
        body: {'id': id},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to move training plan to general manager approval: ${e.toString()}',
        messageAr: 'فشل في نقل خطة التدريب إلى موافقة المدير العام: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Move to Board Chairman Approval (General Training Director only)
  static Future<TrainingPlanResponse> moveToBoardChairmanApproval(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isTrainingGeneralManager()) {
        throw Exception('You do not have permission to move training plans to board chairman approval.');
      }

      // Validate training plan ID
      final idValidation = validateTrainingPlanId(id);
      if (idValidation != null) {
        throw Exception(idValidation);
      }

      final response = await ApiService.post(
        ApiEndpoints.moveToBoardChairmanApproval,
        body: {'id': id},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return TrainingPlanResponse.fromJson(responseData);
    } catch (e) {
      return TrainingPlanResponse(
        messageEn: 'Failed to move training plan to board chairman approval: ${e.toString()}',
        messageAr: 'فشل في نقل خطة التدريب إلى موافقة رئيس مجلس الإدارة: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  // Approve training plan (Board Chairman only)
  static Future<TrainingPlanResponse> approveTrainingPlan(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (!isBoardChairman()) {
        throw Exception('You do not have permission to approve training plans.');
      }

      // Validate training plan ID
      final idValidation = validateTrainingPlanId(id);
      if (idValidation != null) {
        throw Exception(idValidation);
      }

      final response = await ApiService.post(
        ApiEndpoints.approveTrainingPlan,
        body: {'id': id},
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

  // Get training plans based on user role
  static Future<TrainingPlanListResponse> getTrainingPlansByUserRole() async {
    if (isAdmin()) {
      return getAllTrainingPlans();
    } else if (isTrainingGeneralManager()) {
      return getTrainingPlansForGeneralManager();
    } else if (isBoardChairman()) {
      return getTrainingPlansForBoardChairman();
    } else if (isCompanyAccount()) {
      return getTrainingPlansForCompany();
    } else {
      // For users without specific roles, return all training plans (read-only access)
      return getAllTrainingPlans();
    }
  }

  // Backward compatibility method - alias for moveToPlanPreparation
  static Future<TrainingPlanResponse> submitTrainingPlan(int id) async {
    return moveToPlanPreparation(id);
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
    if (status != null && !['draft', 'plan_preparation', 'training_general_manager_approval', 'board_chairman_approval', 'approved'].contains(status)) {
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
    if (status != null && !['draft', 'plan_preparation', 'training_general_manager_approval', 'board_chairman_approval', 'approved'].contains(status)) {
      return 'Invalid status value';
    }

    return null;
  }

  // Validation for workflow operations
  static String? validateWorkflowTransition(TrainingPlan plan, String targetStatus) {
    switch (targetStatus) {
      case 'plan_preparation':
        if (!plan.canBeMovedToPlanPreparation) {
          return 'Training plan can only be moved to plan preparation if it is in draft status';
        }
        break;
      case 'training_general_manager_approval':
        if (!plan.canBeMovedToTrainingGeneralManagerApproval) {
          return 'Training plan can only be moved to training general manager approval if it is in plan preparation status';
        }
        // Validate that courses are assigned to companies
        if (plan.planCourseAssignments == null || plan.planCourseAssignments!.isEmpty) {
          return 'Training plan must have courses assigned to companies before moving to general manager approval';
        }
        break;
      case 'board_chairman_approval':
        if (!plan.canBeMovedToBoardChairmanApproval) {
          return 'Training plan can only be moved to board chairman approval if it is in training general manager approval status';
        }
        break;
      case 'approved':
        if (!plan.canBeApproved) {
          return 'Training plan can only be approved if it is in board chairman approval status';
        }
        break;
      default:
        return 'Invalid target status for workflow transition';
    }
    return null;
  }

  // Validate course assignment requirements
  static String? validateCourseAssignments(TrainingPlan plan) {
    if (plan.planCourseAssignments == null || plan.planCourseAssignments!.isEmpty) {
      return 'Training plan must have at least one course assignment';
    }
    
    // Check if all assignments have required fields
    for (final assignment in plan.planCourseAssignments!) {
      if (assignment.companyId <= 0) {
        return 'All course assignments must have a valid company';
      }
      if (assignment.courseId <= 0) {
        return 'All course assignments must have a valid course';
      }
      if (assignment.trainingCenterBranchId <= 0) {
        return 'All course assignments must have a valid training center branch';
      }
    }
    
    return null;
  }

  // Validation for company ID
  static String? validateCompanyId(int companyId) {
    if (companyId <= 0) {
      return 'Company ID must be a positive integer';
    }
    return null;
  }

  // Validation for training plan ID
  static String? validateTrainingPlanId(int id) {
    if (id <= 0) {
      return 'Training plan ID must be a positive integer';
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


  // Get status options for dropdown based on user role
  static List<Map<String, String>> getStatusOptions() {
    if (isAdmin()) {
      return [
        {'value': 'all', 'label': 'All Statuses', 'labelAr': 'جميع الحالات'},
        {'value': 'draft', 'label': 'Draft', 'labelAr': 'مسودة'},
        {'value': 'plan_preparation', 'label': 'Plan Preparation', 'labelAr': 'إعداد الخطة'},
        {'value': 'training_general_manager_approval', 'label': 'Training General Manager Approval', 'labelAr': 'موافقة المدير العام للتدريب'},
        {'value': 'board_chairman_approval', 'label': 'Board Chairman Approval', 'labelAr': 'موافقة رئيس مجلس الإدارة'},
        {'value': 'approved', 'label': 'Approved', 'labelAr': 'موافق عليه'},
      ];
    } else if (isTrainingGeneralManager()) {
      return [
        {'value': 'all', 'label': 'All Statuses', 'labelAr': 'جميع الحالات'},
        {'value': 'training_general_manager_approval', 'label': 'Training General Manager Approval', 'labelAr': 'موافقة المدير العام للتدريب'},
      ];
    } else if (isBoardChairman()) {
      return [
        {'value': 'all', 'label': 'All Statuses', 'labelAr': 'جميع الحالات'},
        {'value': 'board_chairman_approval', 'label': 'Board Chairman Approval', 'labelAr': 'موافقة رئيس مجلس الإدارة'},
      ];
    } else if (isCompanyAccount()) {
      return [
        {'value': 'all', 'label': 'All Statuses', 'labelAr': 'جميع الحالات'},
        {'value': 'plan_preparation', 'label': 'Plan Preparation', 'labelAr': 'إعداد الخطة'},
        {'value': 'training_general_manager_approval', 'label': 'Training General Manager Approval', 'labelAr': 'موافقة المدير العام للتدريب'},
        {'value': 'board_chairman_approval', 'label': 'Board Chairman Approval', 'labelAr': 'موافقة رئيس مجلس الإدارة'},
        {'value': 'approved', 'label': 'Approved', 'labelAr': 'موافق عليه'},
      ];
    }
    return [];
  }

  // Get approved training plans with company courses (Company Account only)
  static Future<ApprovedTrainingPlansWithCoursesResponse> getApprovedTrainingPlansWithCompanyCourses() async {
    print('🔄 TRAINING PLAN SERVICE: Getting approved training plans with company courses');
    
    try {
      // Check if user is a company account
      if (!isCompanyAccount()) {
        print('❌ TRAINING PLAN SERVICE: Access denied - User is not a company account');
        return ApprovedTrainingPlansWithCoursesResponse(
          success: false,
          data: [],
          messageAr: 'غير مصرح لك بعرض خطط التدريب',
          messageEn: 'You are not authorized to view training plans',
          statusCode: 403,
        );
      }

      print('🌐 TRAINING PLAN SERVICE: Calling API endpoint: ${ApiEndpoints.getApprovedTrainingPlansWithCompanyCourses}');
      
      final response = await ApiService.post(
        ApiEndpoints.getApprovedTrainingPlansWithCompanyCourses,
        headers: {
          'Authorization': 'Bearer ${AuthService.getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      print('📡 TRAINING PLAN SERVICE: Response received - Status: ${response.statusCode}');
      print('📡 TRAINING PLAN SERVICE: Response body: ${response.body}');

      if (ApiService.isSuccessResponse(response)) {
        print('✅ TRAINING PLAN SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        final result = ApprovedTrainingPlansWithCoursesResponse.fromJson(responseData);
        
        print('✅ TRAINING PLAN SERVICE: Successfully retrieved ${result.data.length} approved training plans with courses');
        return result;
      } else {
        print('❌ TRAINING PLAN SERVICE: API call failed with status ${response.statusCode}');
        final responseData = jsonDecode(response.body);
        return ApprovedTrainingPlansWithCoursesResponse(
          success: false,
          data: [],
          messageAr: responseData['message_ar'] ?? 'فشل في جلب خطط التدريب المعتمدة',
          messageEn: responseData['message_en'] ?? 'Failed to retrieve approved training plans',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 TRAINING PLAN SERVICE: Error getting approved training plans with courses: $e');
      return ApprovedTrainingPlansWithCoursesResponse(
        success: false,
        data: [],
        messageAr: 'خطأ في الخادم',
        messageEn: 'Server error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}