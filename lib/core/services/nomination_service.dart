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
    const String endpoint = 'POST /nominations';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('📋 NOMINATION SERVICE: Request data: ${json.encode(nomination.toJson())}');
    
    try {
      // Check if user has company account role
      if (!AuthService.hasRole('company_account')) {
        print('❌ NOMINATION SERVICE: Access denied - User does not have company_account role');
        return ApiResponse<Nomination>(
          statusCode: 403,
          messageEn: 'Access denied. Only company accounts can create nominations.',
          messageAr: 'تم رفض الوصول. يمكن لحسابات الشركات فقط إنشاء الترشيحات.',
          data: null,
        );
      }
      
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }
      
      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl/nominations');

      final response = await http.post(
        Uri.parse('$_baseUrl/nominations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(nomination.toJson()),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status Code: ${response.statusCode}');
      print('📋 NOMINATION SERVICE: Response Headers: ${response.headers}');
      print('📄 NOMINATION SERVICE: Response Body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ NOMINATION SERVICE: Success - Nomination created');
        final nominationData = Nomination.fromJson(data['data'] ?? {});
        
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Nomination created successfully',
          messageAr: data['message_ar'] ?? 'تم إنشاء الترشيح بنجاح',
          data: nominationData,
        );
      } else {
        print('❌ NOMINATION SERVICE: API Error - Status: ${response.statusCode}');
        print('❌ NOMINATION SERVICE: Error Message EN: ${data['message_en']}');
        print('❌ NOMINATION SERVICE: Error Message AR: ${data['message_ar']}');
        print('❌ NOMINATION SERVICE: Full Error Response: $data');
        
        return ApiResponse<Nomination>(
          statusCode: response.statusCode,
          messageEn: data['message_en'] ?? 'Failed to create nomination',
          messageAr: data['message_ar'] ?? 'فشل في إنشاء الترشيح',
          data: nomination,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred in $endpoint');
      print('💥 NOMINATION SERVICE: Exception type: ${e.runtimeType}');
      print('💥 NOMINATION SERVICE: Exception message: ${e.toString()}');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      
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
    const String endpoint = 'POST /nomination/create';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('📋 NOMINATION SERVICE: Plan Course Assignment ID: $planCourseAssignmentId');
    print('📋 NOMINATION SERVICE: Number of nominations: ${nominations.length}');
    
    try {
      // Check if user has company account role
      if (!AuthService.hasRole('company_account')) {
        print('❌ NOMINATION SERVICE: Access denied - User does not have company_account role');
        return ApiResponse<List<Nomination>>(
          statusCode: 403,
          messageEn: 'Access denied. Only company accounts can create nominations.',
          messageAr: 'تم رفض الوصول. يمكن لحسابات الشركات فقط إنشاء الترشيحات.',
          data: [],
        );
      }
      
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
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

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.createNominations}');
      print('📋 NOMINATION SERVICE: Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createNominations}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status Code: ${response.statusCode}');
      print('📋 NOMINATION SERVICE: Response Headers: ${response.headers}');
      print('📄 NOMINATION SERVICE: Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ NOMINATION SERVICE: Success - Nominations created');
        final List<dynamic> nominationsJson = data['data'] ?? [];
        final createdNominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        print('✅ NOMINATION SERVICE: Created ${createdNominations.length} nominations');
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Nominations created successfully',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'تم إنشاء الترشيحات بنجاح',
          data: createdNominations,
        );
      } else {
        print('❌ NOMINATION SERVICE: API Error - Status: ${response.statusCode}');
        print('❌ NOMINATION SERVICE: Error Message EN: ${data['m_en'] ?? data['message_en']}');
        print('❌ NOMINATION SERVICE: Error Message AR: ${data['m_ar'] ?? data['message_ar']}');
        print('❌ NOMINATION SERVICE: Full Error Response: $data');
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: data['m_en'] ?? data['message_en'] ?? 'Failed to create nominations',
          messageAr: data['m_ar'] ?? data['message_ar'] ?? 'فشل في إنشاء الترشيحات',
          data: [],
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred in $endpoint');
      print('💥 NOMINATION SERVICE: Exception type: ${e.runtimeType}');
      print('💥 NOMINATION SERVICE: Exception message: ${e.toString()}');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error creating nominations: ${e.toString()}',
        messageAr: 'خطأ في إنشاء الترشيحات: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Retrieve all nominations for a specific plan course assignment (legacy method)
  /// POST /api/nomination/by-plan-course-assignment
  static Future<ApiResponse<List<Nomination>>> getNominationsByPlanCourseAssignment({
    required int planCourseAssignmentId,
  }) async {
    const String endpoint = 'POST /nomination/by-plan-course-assignment';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('📋 NOMINATION SERVICE: Plan Course Assignment ID: $planCourseAssignmentId');
    
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'plan_course_assignment_id': planCourseAssignmentId,
      };

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.getNominationsByPlanCourseAssignment}');
      print('📊 NOMINATION SERVICE: Request body: ${jsonEncode(requestBody)}');
      print('🔐 NOMINATION SERVICE: Authorization header: Bearer ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getNominationsByPlanCourseAssignment}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status code: ${response.statusCode}');
      print('📄 NOMINATION SERVICE: Response headers: ${response.headers}');
      print('📄 NOMINATION SERVICE: Response body: ${response.body}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ NOMINATION SERVICE: Authentication failed with status ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = jsonData['data'] ?? [];
        final List<Nomination> nominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        print('✅ NOMINATION SERVICE: Successfully retrieved ${nominations.length} nominations');
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['message_en'] ?? 'Nominations retrieved successfully',
          messageAr: jsonData['message_ar'] ?? 'تم استرداد الترشيحات بنجاح',
          data: nominations,
        );
      } else {
        print('❌ NOMINATION SERVICE: Error response: ${jsonData['message_en']}');
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['message_en'] ?? 'Failed to retrieve nominations',
          messageAr: jsonData['message_ar'] ?? 'فشل في استرداد الترشيحات',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred');
      print('💥 NOMINATION SERVICE: Exception: $e');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error retrieving nominations: ${e.toString()}',
        messageAr: 'خطأ في استرداد الترشيحات: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Retrieve nominations by training plan, company, and course
  /// POST /api/nomination/by-plan-course-assignment (new endpoint)
  static Future<ApiResponse<List<Nomination>>> getNominationsByTrainingPlanAndCourse({
    required int trainingPlanId,
    required int companyId,
    required int courseId,
  }) async {
    const String endpoint = 'POST /nomination/by-plan-course-assignment';
    print('🚀 NOMINATION SERVICE: Starting $endpoint (new version)');
    print('📊 NOMINATION SERVICE: Training Plan ID: $trainingPlanId');
    print('🏢 NOMINATION SERVICE: Company ID: $companyId');
    print('🎓 NOMINATION SERVICE: Course ID: $courseId');
    
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'training_plan_id': trainingPlanId,
        'company_id': companyId,
        'course_id': courseId,
      };

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.getNominationsByPlanCourseAssignment}');
      print('📊 NOMINATION SERVICE: Request body: ${jsonEncode(requestBody)}');
      print('🔐 NOMINATION SERVICE: Authorization header: Bearer ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getNominationsByPlanCourseAssignment}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status code: ${response.statusCode}');
      print('📄 NOMINATION SERVICE: Response headers: ${response.headers}');
      print('📄 NOMINATION SERVICE: Response body: ${response.body}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ NOMINATION SERVICE: Authentication failed with status ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = jsonData['data'] ?? [];
        final List<Nomination> nominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        print('✅ NOMINATION SERVICE: Successfully retrieved ${nominations.length} nominations');
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['message_en'] ?? 'Nominations retrieved successfully',
          messageAr: jsonData['message_ar'] ?? 'تم استرداد الترشيحات بنجاح',
          data: nominations,
        );
      } else {
        print('❌ NOMINATION SERVICE: Error response: ${jsonData['message_en']}');
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['message_en'] ?? 'Failed to retrieve nominations',
          messageAr: jsonData['message_ar'] ?? 'فشل في استرداد الترشيحات',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred');
      print('💥 NOMINATION SERVICE: Exception: $e');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error retrieving nominations: ${e.toString()}',
        messageAr: 'خطأ في استرداد الترشيحات: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get training and fully approved nominations (Admin only)
  /// POST /api/nomination/training-fully-approved
  static Future<ApiResponse<List<Nomination>>> getTrainingFullyApprovedNominations({
    required int companyId,
    required int planId,
    required int courseId,
  }) async {
    const String endpoint = 'POST /nomination/training-fully-approved';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('🏢 NOMINATION SERVICE: Company ID: $companyId');
    print('📊 NOMINATION SERVICE: Plan ID: $planId');
    print('🎓 NOMINATION SERVICE: Course ID: $courseId');
    
    try {
      // Check if user has admin role
      if (!AuthService.hasRole('admin')) {
        print('❌ NOMINATION SERVICE: Access denied - User does not have admin role');
        return ApiResponse<List<Nomination>>(
          statusCode: 403,
          messageEn: 'Access denied. Only admin users can view training and fully approved nominations.',
          messageAr: 'تم رفض الوصول. يمكن للمديرين فقط عرض الترشيحات المعتمدة تدريبياً والكاملة.',
          data: [],
        );
      }
      
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'company_id': companyId,
        'plan_id': planId,
        'course_id': courseId,
      };

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.getTrainingFullyApprovedNominations}');
      print('📋 NOMINATION SERVICE: Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getTrainingFullyApprovedNominations}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status Code: ${response.statusCode}');
      print('📄 NOMINATION SERVICE: Response body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> nominationsJson = jsonData['data'] ?? [];
        final List<Nomination> nominations = nominationsJson
            .map((json) => Nomination.fromJson(json))
            .toList();
        
        print('✅ NOMINATION SERVICE: Successfully retrieved ${nominations.length} training/fully approved nominations');
        
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Training and fully approved nominations retrieved successfully',
          messageAr: jsonData['m_ar'] ?? 'تم استرداد الترشيحات المعتمدة تدريبياً والكاملة بنجاح',
          data: nominations,
        );
      } else {
        print('❌ NOMINATION SERVICE: Error response: ${jsonData['m_en']}');
        return ApiResponse<List<Nomination>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Failed to retrieve training and fully approved nominations',
          messageAr: jsonData['m_ar'] ?? 'فشل في استرداد الترشيحات المعتمدة تدريبياً والكاملة',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred');
      print('💥 NOMINATION SERVICE: Exception: $e');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      return ApiResponse<List<Nomination>>(
        statusCode: 500,
        messageEn: 'Error retrieving training and fully approved nominations: ${e.toString()}',
        messageAr: 'خطأ في استرداد الترشيحات المعتمدة تدريبياً والكاملة: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update nominations to company approved status (Company Account only)
  /// POST /api/nomination/update-to-company-approved
  static Future<ApiResponse<Map<String, dynamic>>> updateToCompanyApproved({
    required int companyId,
    required int planId,
    required int courseId,
  }) async {
    const String endpoint = 'POST /nomination/update-to-company-approved';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('🏢 NOMINATION SERVICE: Company ID: $companyId');
    print('📊 NOMINATION SERVICE: Plan ID: $planId');
    print('🎓 NOMINATION SERVICE: Course ID: $courseId');
    
    try {
      // Check if user has company account role
      if (!AuthService.hasRole('company_account')) {
        print('❌ NOMINATION SERVICE: Access denied - User does not have company_account role');
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 403,
          messageEn: 'Access denied. Only company accounts can update nominations to company approved.',
          messageAr: 'تم رفض الوصول. يمكن لحسابات الشركات فقط تحديث الترشيحات إلى معتمد من الشركة.',
          data: null,
        );
      }
      
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'company_id': companyId,
        'plan_id': planId,
        'course_id': courseId,
      };

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.updateToCompanyApproved}');
      print('📋 NOMINATION SERVICE: Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateToCompanyApproved}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status Code: ${response.statusCode}');
      print('📄 NOMINATION SERVICE: Response body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonData['data'] ?? {};
        
        print('✅ NOMINATION SERVICE: Successfully updated nominations to company approved');
        print('📊 NOMINATION SERVICE: Updated count: ${data['updated_count']}');
        
        return ApiResponse<Map<String, dynamic>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Nominations updated to company approved successfully',
          messageAr: jsonData['m_ar'] ?? 'تم تحديث الترشيحات إلى معتمد من الشركة بنجاح',
          data: data,
        );
      } else {
        print('❌ NOMINATION SERVICE: Error response: ${jsonData['m_en']}');
        return ApiResponse<Map<String, dynamic>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Failed to update nominations to company approved',
          messageAr: jsonData['m_ar'] ?? 'فشل في تحديث الترشيحات إلى معتمد من الشركة',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred');
      print('💥 NOMINATION SERVICE: Exception: $e');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        messageEn: 'Error updating nominations to company approved: ${e.toString()}',
        messageAr: 'خطأ في تحديث الترشيحات إلى معتمد من الشركة: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update nominations to training approved status (Admin only)
  /// POST /api/nomination/update-to-training-approved
  static Future<ApiResponse<Map<String, dynamic>>> updateToTrainingApproved({
    required int companyId,
    required int planId,
    required int courseId,
  }) async {
    const String endpoint = 'POST /nomination/update-to-training-approved';
    print('🚀 NOMINATION SERVICE: Starting $endpoint');
    print('🏢 NOMINATION SERVICE: Company ID: $companyId');
    print('📊 NOMINATION SERVICE: Plan ID: $planId');
    print('🎓 NOMINATION SERVICE: Course ID: $courseId');
    
    try {
      // Check if user has admin role
      if (!AuthService.hasRole('admin')) {
        print('❌ NOMINATION SERVICE: Access denied - User does not have admin role');
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 403,
          messageEn: 'Access denied. Only admin users can update nominations to training approved.',
          messageAr: 'تم رفض الوصول. يمكن للمديرين فقط تحديث الترشيحات إلى معتمد تدريبياً.',
          data: null,
        );
      }
      
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        print('❌ NOMINATION SERVICE: Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'company_id': companyId,
        'plan_id': planId,
        'course_id': courseId,
      };

      print('🔑 NOMINATION SERVICE: Token found, making API call to $_baseUrl${ApiEndpoints.updateToTrainingApproved}');
      print('📋 NOMINATION SERVICE: Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateToTrainingApproved}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 NOMINATION SERVICE: Response received');
      print('📊 NOMINATION SERVICE: Status Code: ${response.statusCode}');
      print('📄 NOMINATION SERVICE: Response body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonData['data'] ?? {};
        
        print('✅ NOMINATION SERVICE: Successfully updated nominations to training approved');
        print('📊 NOMINATION SERVICE: Updated count: ${data['updated_count']}');
        
        return ApiResponse<Map<String, dynamic>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Nominations updated to training approved successfully',
          messageAr: jsonData['m_ar'] ?? 'تم تحديث الترشيحات إلى معتمد تدريبياً بنجاح',
          data: data,
        );
      } else {
        print('❌ NOMINATION SERVICE: Error response: ${jsonData['m_en']}');
        return ApiResponse<Map<String, dynamic>>(
          statusCode: response.statusCode,
          messageEn: jsonData['m_en'] ?? 'Failed to update nominations to training approved',
          messageAr: jsonData['m_ar'] ?? 'فشل في تحديث الترشيحات إلى معتمد تدريبياً',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION SERVICE: Exception occurred');
      print('💥 NOMINATION SERVICE: Exception: $e');
      print('💥 NOMINATION SERVICE: Stack trace: $stackTrace');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        messageEn: 'Error updating nominations to training approved: ${e.toString()}',
        messageAr: 'خطأ في تحديث الترشيحات إلى معتمد تدريبياً: ${e.toString()}',
        data: null,
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
