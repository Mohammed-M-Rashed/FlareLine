import 'package:flareline/core/config/api_endpoints.dart';
import 'package:flareline/core/config/api_config.dart';
import 'package:flareline/core/models/nomination_model.dart';
import 'package:flareline/core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NominationService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  static Future<ApiResponse<List<Nomination>>> getAllNominations() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/nominations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = data['data'] ?? [];
        final nominations = nominationsJson.map((json) => Nomination.fromJson(json)).toList();
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Success',
          messageAr: data['message_ar'] ?? 'تم بنجاح',
          data: nominations,
        );
      } else {
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Failed to load nominations',
          messageAr: data['message_ar'] ?? 'فشل في تحميل الترشيحات',
          data: [],
        );
      }
    } catch (e) {
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error loading nominations: ${e.toString()}',
        messageAr: 'خطأ في تحميل الترشيحات: ${e.toString()}',
        data: [],
      );
    }
  }

  static Future<ApiResponse<Nomination>> createNomination(Nomination nomination) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/nominations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(nomination.toJson()),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final nominationData = Nomination.fromJson(data['data'] ?? {});
        
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Nomination created successfully',
          messageAr: data['message_ar'] ?? 'تم إنشاء الترشيح بنجاح',
          data: nominationData,
        );
      } else {
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Failed to create nomination',
          messageAr: data['message_ar'] ?? 'فشل في إنشاء الترشيح',
          data: nomination,
        );
      }
    } catch (e) {
      return ApiResponse<Nomination>(
        statusCode: 500,
        messageEn: 'Error creating nomination: ${e.toString()}',
        messageAr: 'خطأ في إنشاء الترشيح: ${e.toString()}',
        data: nomination,
      );
    }
  }

  static Future<ApiResponse<Nomination>> updateNomination(Nomination nomination) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/nominations/${nomination.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(nomination.toJson()),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final nominationData = Nomination.fromJson(data['data'] ?? {});
        
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Nomination updated successfully',
          messageAr: data['message_ar'] ?? 'تم تحديث الترشيح بنجاح',
          data: nominationData,
        );
      } else {
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Failed to update nomination',
          messageAr: data['message_ar'] ?? 'فشل في تحديث الترشيح',
          data: nomination,
        );
      }
    } catch (e) {
      return ApiResponse<Nomination>(
        statusCode: 500,
        messageEn: 'Error updating nomination: ${e.toString()}',
        messageAr: 'خطأ في تحديث الترشيح: ${e.toString()}',
        data: nomination,
      );
    }
  }

  static Future<ApiResponse<void>> deleteNomination(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/nominations/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse<void>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Nomination deleted successfully',
          messageAr: data['message_ar'] ?? 'تم حذف الترشيح بنجاح',
          data: null,
        );
      } else {
        return ApiResponse<void>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Failed to delete nomination',
          messageAr: data['message_ar'] ?? 'فشل في حذف الترشيح',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        statusCode: 500,
        messageEn: 'Error deleting nomination: ${e.toString()}',
        messageAr: 'خطأ في حذف الترشيح: ${e.toString()}',
        data: null,
      );
    }
  }

  // New API methods based on the documentation

  /// Create or replace nominations for a specific plan course assignment
  /// POST /api/nomination/create
  static Future<ApiResponse<List<Nomination>>> createNominations({
    required int planCourseAssignmentId,
    required List<Nomination> nominations,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Convert nominations to API format
      final List<Map<String, dynamic>> nominationsData = nominations
          .map((nomination) => nomination.toApiJson())
          .toList();

      final requestBody = {
        'plan_course_assignment_id': planCourseAssignmentId,
        'nominations': nominationsData,
      };

      print('📡 Creating nominations for plan course assignment: $planCourseAssignmentId');
      print('📊 Nominations data: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createNominations}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);
      
      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${json.encode(data)}');

      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = data['data'] ?? [];
        final createdNominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Nominations created successfully',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'تم إنشاء الترشيحات بنجاح',
          data: createdNominations,
        );
      } else {
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Failed to create nominations',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'فشل في إنشاء الترشيحات',
          data: [],
        );
      }
    } catch (e) {
      print('💥 Error creating nominations: $e');
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error creating nominations: ${e.toString()}',
        messageAr: 'خطأ في إنشاء الترشيحات: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Retrieve all nominations for a specific plan course assignment
  /// POST /api/nomination/by-plan-course-assignment
  static Future<ApiResponse<List<Nomination>>> getNominationsByPlanCourseAssignment({
    required int planCourseAssignmentId,
  }) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'plan_course_assignment_id': planCourseAssignmentId,
      };

      print('📡 Getting nominations for plan course assignment: $planCourseAssignmentId');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getNominationsByPlanCourseAssignment}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);
      
      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${json.encode(data)}');

      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = data['data'] ?? [];
        final nominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Nominations retrieved successfully',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'تم استرجاع الترشيحات بنجاح',
          data: nominations,
        );
      } else {
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Failed to retrieve nominations',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'فشل في استرجاع الترشيحات',
          data: [],
        );
      }
    } catch (e) {
      print('💥 Error getting nominations: $e');
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error getting nominations: ${e.toString()}',
        messageAr: 'خطأ في استرجاع الترشيحات: ${e.toString()}',
        data: [],
      );
    }
  }
}

class ApiResponse<T> {
  final int statusCode;
  final String messageEn;
  final String messageAr;
  final T? data;

  ApiResponse({
    required this.statusCode,
    required this.messageEn,
    required this.messageAr,
    this.data,
  });

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, messageEn: $messageEn, messageAr: $messageAr, data: $data)';
  }
}
