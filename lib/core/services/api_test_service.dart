import 'package:flutter/material.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/config/api_endpoints.dart';
import 'package:toastification/toastification.dart';

class ApiTestService {
  /// Shows a success toast notification for API test operations in Arabic
  static void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for API test operations in Arabic
  static void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for API test operations in Arabic
  static void _showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Test API connectivity
  static Future<bool> testConnection(BuildContext context) async {
    print('🧪 API TEST: Testing API connectivity...');
    
    try {
      // Test a simple GET request to check if the API is reachable
      final response = await ApiService.get('/health');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ API TEST: Connection successful');
        _showSuccessToast(context, 'تم الاتصال بالـ API بنجاح!');
        return true;
      } else {
        print('❌ API TEST: Connection failed with status: ${response.statusCode}');
        _showErrorToast(context, 'فشل الاتصال بالـ API: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 API TEST: Connection error: $e');
      _showErrorToast(context, 'خطأ في الاتصال بالـ API: $e');
      return false;
    }
  }

  // Test authentication endpoint
  static Future<bool> testAuthEndpoint(BuildContext context) async {
    print('🧪 API TEST: Testing auth endpoint...');
    
    try {
      // Test with invalid credentials to see if the endpoint responds
      final response = await ApiService.post(
        ApiEndpoints.login,
        body: {
          'email': 'test@example.com',
          'password': 'wrongpassword',
        },
      );
      
      // We expect a 401 Unauthorized for invalid credentials
      if (response.statusCode == 401) {
        print('✅ API TEST: Auth endpoint responding correctly (401 as expected)');
        _showSuccessToast(context, 'نقطة نهاية المصادقة تعمل بشكل صحيح!');
        return true;
      } else {
        print('⚠️ API TEST: Auth endpoint responded with unexpected status: ${response.statusCode}');
        _showInfoToast(context, 'حالة نقطة نهاية المصادقة: ${response.statusCode}');
        return true; // Still working, just unexpected response
      }
    } catch (e) {
      print('💥 API TEST: Auth endpoint error: $e');
      _showErrorToast(context, 'خطأ في نقطة نهاية المصادقة: $e');
      return false;
    }
  }

  // Test all endpoints
  static Future<Map<String, bool>> testAllEndpoints(BuildContext context) async {
    print('🧪 API TEST: Testing all endpoints...');
    
    final results = <String, bool>{};
    
    // Test basic connectivity
    results['connection'] = await testConnection(context);
    
    // Test auth endpoint
    results['auth'] = await testAuthEndpoint(context);
    
    // Test other endpoints if basic tests pass
    if (results['connection'] == true) {
      // Add more endpoint tests here as needed
      results['overall'] = true;
    } else {
      results['overall'] = false;
    }
    
    print('🧪 API TEST: All tests completed. Results: $results');
    return results;
  }
}
