import 'dart:convert';
import 'package:flareline/core/services/api_service.dart';
import 'package:get/get.dart';
import '../models/plan_course_assignment_model.dart';
import '../auth/auth_provider.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';

class PlanCourseAssignmentService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Replace all plan course assignments for a training plan
  static Future<PlanCourseAssignmentListResponse> replacePlanCourseAssignments({
    required int trainingPlanId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    try {
      print('🔧 ===== SERVICE DEBUG =====');
      print('   API Endpoint: ${ApiEndpoints.storePlanCourseAssignments}');
      print('   Training Plan ID: $trainingPlanId');
      print('   Assignments Count: ${assignments.length}');
      print('   Full Request Body:');
      print('   ${jsonEncode({
        'training_plan_id': trainingPlanId,
        'assignments': assignments,
      })}');
      print('===========================');
      
      // Comprehensive authentication tracing
      print('🔐 ===== AUTHENTICATION TRACE =====');
      try {
        final authController = Get.find<AuthController>();
        print('   ✅ AuthController found');
        
        // Check authentication status
        print('   🔍 Authentication Status:');
        print('     - isAuthenticated: ${authController.isAuthenticated}');
        print('     - isLoggedIn: ${authController.isLoggedIn()}');
        print('     - hasValidToken: ${authController.hasValidToken()}');
        print('     - userEmail: ${authController.userEmail}');
        
        final token = authController.userToken;
        print('   🔑 Token Details:');
        print('     - Token length: ${token.length}');
        print('     - Token empty: ${token.isEmpty}');
        if (token.isNotEmpty) {
          print('     - Token preview: ${token.substring(0, 20)}...');
          print('     - Token ends with: ...${token.substring(token.length - 10)}');
        }
        
        // Check authorization header
        final authHeader = authController.getAuthorizationHeader();
        print('   📋 Authorization Header:');
        print('     - Header: $authHeader');
        
        if (token.isEmpty) {
          print('❌ AUTH ERROR: No authentication token found');
          print('   Possible causes:');
          print('   1. User not logged in');
          print('   2. Token expired and not refreshed');
          print('   3. AuthController not properly initialized');
          print('   4. Token cleared during session');
          return PlanCourseAssignmentListResponse(
            data: [],
            messageAr: 'غير مصرح بالوصول',
            messageEn: 'Authentication error, please log in again',
            statusCode: 401,
          );
        }

        print('✅ Authentication token found and valid');
      } catch (e) {
        print('❌ AUTH ERROR: Exception getting AuthController: $e');
        print('   Stack trace: ${StackTrace.current}');
        return PlanCourseAssignmentListResponse(
          data: [],
          messageAr: 'خطأ في المصادقة',
          messageEn: 'Authentication error, please log in again',
          statusCode: 401,
        );
      }
      print('=====================================');

      // Get the token again for the API call
      final authController = Get.find<AuthController>();
      final token = authController.userToken;
      
      final response = await ApiService.post(
        ApiEndpoints.storePlanCourseAssignments,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {
          'training_plan_id': trainingPlanId,
          'assignments': assignments,
        },
      );
      
      print('📡 API Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Success response received');
        final responseData = json.decode(response.body);
        print('   Parsed Response Data: $responseData');
        
        final List<PlanCourseAssignment> assignments = [];
        
        if (responseData['data'] != null) {
          print('   Processing ${responseData['data'].length} assignments from response');
          for (var item in responseData['data']) {
            try {
              assignments.add(PlanCourseAssignment.fromJson(item));
            } catch (e) {
              print('   ❌ Error parsing assignment: $e');
              print('   Assignment data: $item');
            }
          }
        } else {
          print('   ⚠️ No data field in response');
        }

        print('   Final assignments count: ${assignments.length}');
        return PlanCourseAssignmentListResponse(
          data: assignments,
          messageAr: responseData['message_ar'] ?? 'تم استبدال تعيينات الدورات التدريبية بنجاح',
          messageEn: responseData['message_en'] ?? 'Plan course assignments replaced successfully',
          statusCode: response.statusCode,
        );
      } else {
        print('❌ Error response received');
        final responseData = json.decode(response.body);
        print('   Error Response Data: $responseData');
        return PlanCourseAssignmentListResponse(
          data: [],
          messageAr: responseData['message_ar'] ?? 'فشل في استبدال تعيينات الدورات التدريبية',
          messageEn: responseData['message_en'] ?? 'Failed to replace plan course assignments',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ ===== SERVICE EXCEPTION DEBUG =====');
      print('   Exception Type: ${e.runtimeType}');
      print('   Exception Message: ${e.toString()}');
      print('   Stack Trace:');
      print('   ${StackTrace.current}');
      print('   ');
      print('   Request Details:');
      print('   - Training Plan ID: $trainingPlanId');
      print('   - Assignments Count: ${assignments.length}');
      print('   - API Endpoint: ${ApiEndpoints.storePlanCourseAssignments}');
      print('=====================================');
      
      return PlanCourseAssignmentListResponse(
        data: [],
        messageAr: 'خطأ في الخادم',
        messageEn: 'Server error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Get plan course assignments by training plan
  static Future<PlanCourseAssignmentListResponse> getPlanCourseAssignmentsByTrainingPlan({
    required int trainingPlanId,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.userToken;
      
      if (token.isEmpty) {
        return PlanCourseAssignmentListResponse(
          data: [],
          messageAr: 'غير مصرح بالوصول',
          messageEn: 'Unauthorized access',
          statusCode: 401,
        );
      }

      print('-------------------------');
      print('$_baseUrl${ApiEndpoints.getPlanCourseAssignmentsByTrainingPlan}');
      print('-------------------------');
      final response = await ApiService.post(
        ApiEndpoints.getPlanCourseAssignmentsByTrainingPlan,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: {
          'training_plan_id': trainingPlanId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<PlanCourseAssignment> assignments = [];
        
        if (responseData['data'] != null) {
          for (var item in responseData['data']) {
            assignments.add(PlanCourseAssignment.fromJson(item));
          }
        }

        return PlanCourseAssignmentListResponse(
          data: assignments,
          messageAr: responseData['message_ar'] ?? 'تم استرداد تعيينات الدورات التدريبية لخطة التدريب بنجاح',
          messageEn: responseData['message_en'] ?? 'Plan course assignments for training plan retrieved successfully',
          statusCode: response.statusCode,
        );
      } else {
        final responseData = json.decode(response.body);
        return PlanCourseAssignmentListResponse(
          data: [],
          messageAr: responseData['message_ar'] ?? 'فشل في استرداد تعيينات الدورات التدريبية',
          messageEn: responseData['message_en'] ?? 'Failed to retrieve plan course assignments',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return PlanCourseAssignmentListResponse(
        data: [],
        messageAr: 'خطأ في الخادم',
        messageEn: 'Server error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}

