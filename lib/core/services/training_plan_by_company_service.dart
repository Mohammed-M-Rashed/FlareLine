import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/training_plan_by_company_model.dart';
import '../config/api_endpoints.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class TrainingPlanByCompanyService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // Get training plans by company
  static Future<TrainingPlanByCompanyListResponse> getTrainingPlansByCompany({
    required int companyId,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('رمز المصادقة غير موجود');
      }

      final request = TrainingPlanByCompanyRequest(
        companyId: companyId,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getTrainingPlansByCompany}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TrainingPlanByCompanyListResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? 'فشل في جلب خطط التدريب');
        } catch (e) {
          throw Exception('فشل في جلب خطط التدريب: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
