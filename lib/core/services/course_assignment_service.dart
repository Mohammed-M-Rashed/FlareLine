import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_assignment_model.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CourseAssignmentService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // Get courses by training plan and company
  static Future<CourseAssignmentListResponse> getCoursesByPlanAndCompany({
    required int trainingPlanId,
    required int companyId,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = CourseAssignmentRequest(
        trainingPlanId: trainingPlanId,
        companyId: companyId,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getCoursesByPlanAndCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('📡 Course Assignment API Raw Response: $jsonData');
        return CourseAssignmentListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب الدورات');
        } catch (e) {
          throw Exception('فشل في جلب الدورات: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
