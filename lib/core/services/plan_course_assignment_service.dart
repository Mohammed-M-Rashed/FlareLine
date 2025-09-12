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
          messageAr: responseData['message_ar'] ?? 'تم استبدال تعيينات الدورات التدريبية بنجاح',
          messageEn: responseData['message_en'] ?? 'Plan course assignments replaced successfully',
          statusCode: response.statusCode,
        );
      } else {
        final responseData = json.decode(response.body);
        return PlanCourseAssignmentListResponse(
          data: [],
          messageAr: responseData['message_ar'] ?? 'فشل في استبدال تعيينات الدورات التدريبية',
          messageEn: responseData['message_en'] ?? 'Failed to replace plan course assignments',
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

