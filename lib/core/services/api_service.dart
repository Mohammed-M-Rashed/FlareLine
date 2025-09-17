import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flareline/core/auth/auth_provider.dart';
import 'package:flareline/core/config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Get authorization header for authenticated requests
  static Map<String, String> getAuthHeaders() {
    print('🔧 API SERVICE: Getting authorization headers');
    try {
      final authController = Get.find<AuthController>();
      final token = authController.userToken;
      
      if (token.isNotEmpty) {
        print('🔧 API SERVICE: Token found: ${token.substring(0, 20)}...');
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };
        print('🔧 API SERVICE: Headers with auth: $headers');
        return headers;
      } else {
        print('🔧 API SERVICE: No token found, using basic headers');
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        print('🔧 API SERVICE: Basic headers: $headers');
        return headers;
      }
    } catch (e) {
      print('❌ API SERVICE: Error getting auth headers: $e');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  // Make a POST request
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    print('📤 API SERVICE: ===== MAKING POST REQUEST =====');
    print('📤 API SERVICE: Endpoint: $endpoint');
    print('📤 API SERVICE: Base URL: $baseUrl');
    print('📤 API SERVICE: Full URL: $baseUrl$endpoint');
    print('📤 API SERVICE: Request body: $body');
    print('📤 API SERVICE: Request body type: ${body.runtimeType}');
    
    final url = Uri.parse('$baseUrl$endpoint');
    print('📤 API SERVICE: Parsed URL: $url');
    
    final requestHeaders = {...getAuthHeaders(), ...?headers};
    print('📤 API SERVICE: Final request headers: $requestHeaders');
    
    if (body != null) {
      final jsonBody = jsonEncode(body);
      print('📤 API SERVICE: JSON encoded body: $jsonBody');
      print('📤 API SERVICE: JSON body length: ${jsonBody.length}');
    }
    
    print('📤 API SERVICE: Sending HTTP POST request...');
    final startTime = DateTime.now();
    
    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('📡 API SERVICE: ===== POST RESPONSE RECEIVED =====');
      print('📡 API SERVICE: Response time: ${duration.inMilliseconds}ms');
      print('📡 API SERVICE: HTTP status code: ${response.statusCode}');
      print('📡 API SERVICE: Response headers: ${response.headers}');
      print('📡 API SERVICE: Response body length: ${response.body.length}');
      print('📡 API SERVICE: Response body preview: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');
      
      // Check for authentication errors
      if (response.statusCode == 401) {
        print('🔐 API SERVICE: ===== AUTHENTICATION ERROR DETECTED =====');
        print('🔐 API SERVICE: Status Code: 401 Unauthorized');
        print('🔐 API SERVICE: Response body: ${response.body}');
        print('🔐 API SERVICE: This indicates the token is invalid or expired');
        print('🔐 API SERVICE: User needs to log in again');
        print('🔐 API SERVICE: ===========================================');
      } else if (response.statusCode == 403) {
        print('🔐 API SERVICE: ===== AUTHORIZATION ERROR DETECTED =====');
        print('🔐 API SERVICE: Status Code: 403 Forbidden');
        print('🔐 API SERVICE: Response body: ${response.body}');
        print('🔐 API SERVICE: This indicates insufficient permissions');
        print('🔐 API SERVICE: =========================================');
      }
      
      if (response.statusCode >= 400) {
        print('🔍 API SERVICE: Client error detected');
        print('🔍 API SERVICE: HTTP status code: ${response.statusCode}');
      } else {
        print('✅ API SERVICE: HTTP success (${response.statusCode})');
      }
      
      return response;
    } catch (e, stackTrace) {
      print('💥 API SERVICE: HTTP request failed');
      print('💥 API SERVICE: Error type: ${e.runtimeType}');
      print('💥 API SERVICE: Error message: $e');
      print('💥 API SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Make a GET request
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    print('📤 API SERVICE: ===== MAKING GET REQUEST =====');
    print('📤 API SERVICE: Endpoint: $endpoint');
    print('📤 API SERVICE: Full URL: $baseUrl$endpoint');
    
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {...getAuthHeaders(), ...?headers};
    
    print('📤 API SERVICE: Request headers: $requestHeaders');
    print('📤 API SERVICE: Sending HTTP GET request...');
    
    final startTime = DateTime.now();
    
    try {
      final response = await http.get(url, headers: requestHeaders).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('📡 API SERVICE: ===== GET RESPONSE RECEIVED =====');
      print('📡 API SERVICE: Response time: ${duration.inMilliseconds}ms');
      print('📡 API SERVICE: HTTP status code: ${response.statusCode}');
      print('📡 API SERVICE: Response body length: ${response.body.length}');
      
      return response;
    } catch (e, stackTrace) {
      print('💥 API SERVICE: HTTP GET request failed: $e');
      print('💥 API SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Make a PUT request
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    print('📤 API SERVICE: ===== MAKING PUT REQUEST =====');
    print('📤 API SERVICE: Endpoint: $endpoint');
    print('📤 API SERVICE: Request body: $body');
    
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {...getAuthHeaders(), ...?headers};
    
    print('📤 API SERVICE: Request headers: $requestHeaders');
    print('📤 API SERVICE: Sending HTTP PUT request...');
    
    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      print('📡 API SERVICE: ===== PUT RESPONSE RECEIVED =====');
      print('📡 API SERVICE: HTTP status code: ${response.statusCode}');
      print('📡 API SERVICE: Response body length: ${response.body.length}');
      
      return response;
    } catch (e, stackTrace) {
      print('💥 API SERVICE: HTTP PUT request failed: $e');
      print('💥 API SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Make a DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    print('📤 API SERVICE: ===== MAKING DELETE REQUEST =====');
    print('📤 API SERVICE: Endpoint: $endpoint');
    
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {...getAuthHeaders(), ...?headers};
    
    print('📤 API SERVICE: Request headers: $requestHeaders');
    print('📤 API SERVICE: Sending HTTP DELETE request...');
    
    try {
      final response = await http.delete(url, headers: requestHeaders).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      print('📡 API SERVICE: ===== DELETE RESPONSE RECEIVED =====');
      print('📡 API SERVICE: HTTP status code: ${response.statusCode}');
      print('📡 API SERVICE: Response body length: ${response.body.length}');
      
      return response;
    } catch (e, stackTrace) {
      print('💥 API SERVICE: HTTP DELETE request failed: $e');
      print('💥 API SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Handle common error responses
  static String handleErrorResponse(http.Response response) {
    print('🔍 API SERVICE: ===== HANDLING ERROR RESPONSE =====');
    print('🔍 API SERVICE: HTTP status code: ${response.statusCode}');
    print('🔍 API SERVICE: Response body: ${response.body}');
    print('🔍 API SERVICE: Response body length: ${response.body.length}');
    
    try {
      print('🔍 API SERVICE: Attempting to parse error response as JSON');
      final errorData = jsonDecode(response.body);
      print('🔍 API SERVICE: Parsed error data: $errorData');
      print('🔍 API SERVICE: Error data type: ${errorData.runtimeType}');
      
      // Check if it's a validation error with specific field errors
      if (errorData['errors'] != null && errorData['errors'] is Map) {
        print('🔍 API SERVICE: Errors field found: ${errorData['errors']}');
        final errors = errorData['errors'] as Map<String, dynamic>;
        final errorMessages = errors.values
            .expand((e) => e is List ? e : [e])
            .map((e) => e.toString())
            .join(', ');
        return 'خطأ في التحقق: $errorMessages';
      }
      
      // Check for general error message
      if (errorData['message_ar'] != null) {
        print('🔍 API SERVICE: Arabic error message found: ${errorData['message_ar']}');
        return errorData['message_ar'];
      } else if (errorData['message'] != null) {
        print('🔍 API SERVICE: General error message found: ${errorData['message']}');
        return errorData['message'];
      }
      
      // Check for error field
      if (errorData['error'] != null) {
        print('🔍 API SERVICE: Error field found: ${errorData['error']}');
        return errorData['error'];
      }
      
      print('🔍 API SERVICE: No specific error format found, using default message');
      return 'فشل الطلب مع الحالة ${response.statusCode}';
      
    } catch (e) {
      print('❌ API SERVICE: Error parsing error response: $e');
      print('❌ API SERVICE: Raw response body: ${response.body}');
      return 'فشل الطلب مع الحالة ${response.statusCode}';
    }
  }

  // Check if response is successful
  static bool isSuccessResponse(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    print('🔍 API SERVICE: Checking if response is successful: ${response.statusCode} -> $isSuccess');
    return isSuccess;
  }

  // Check if it's an authentication error
  static bool isAuthError(http.Response response) {
    final isAuth = response.statusCode == 401 || response.statusCode == 403;
    print('🔍 API SERVICE: Checking if response is auth error: ${response.statusCode} -> $isAuth');
    return isAuth;
  }

  // Check if token is expired
  static bool isTokenExpired(http.Response response) {
    final isExpired = response.statusCode == 401 && 
                     response.body.toLowerCase().contains('expired');
    print('🔍 API SERVICE: Checking if token is expired: $isExpired');
    return isExpired;
  }

  // Check if it's a validation error
  static bool isValidationError(http.Response response) {
    final isValidation = response.statusCode == 422;
    print('🔍 API SERVICE: Checking if response is validation error: ${response.statusCode} -> $isValidation');
    return isValidation;
  }

  // Check if it's a not found error
  static bool isNotFoundError(http.Response response) {
    final isNotFound = response.statusCode == 404;
    print('🔍 API SERVICE: Checking if response is not found error: ${response.statusCode} -> $isNotFound');
    return isNotFound;
  }

  // Get error type description
  static String getErrorType(http.Response response) {
    print('🔍 API SERVICE: Getting error type for status code: ${response.statusCode}');
    
    if (response.statusCode >= 500) {
      print('🔍 API SERVICE: Server error detected');
      return 'خطأ في الخادم';
    } else if (response.statusCode == 404) {
      print('🔍 API SERVICE: Not found error detected');
      return 'غير موجود';
    } else if (response.statusCode == 422) {
      print('🔍 API SERVICE: Unprocessable entity error detected');
      return 'خطأ في التحقق';
    } else if (response.statusCode == 401) {
      print('🔍 API SERVICE: Unauthorized error detected');
      return 'غير مصرح';
    } else if (response.statusCode == 403) {
      print('🔍 API SERVICE: Forbidden error detected');
      return 'ممنوع';
    } else if (response.statusCode >= 400) {
      print('🔍 API SERVICE: Client error detected');
      return 'خطأ في الطلب';
    } else {
      print('🔍 API SERVICE: Unknown error type detected');
      return 'خطأ غير معروف';
    }
  }
}

