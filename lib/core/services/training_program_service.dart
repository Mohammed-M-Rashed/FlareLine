import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flareline/core/models/training_program_model.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:toastification/toastification.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class TrainingProgramService {
  /// Shows a success toast notification for training program operations in Arabic
  static void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
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

  /// Shows an error toast notification for training program operations in Arabic
  static void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
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

  /// Shows an info toast notification for training program operations in Arabic
  static void _showInfoToast(String message) {
    toastification.show(
      context: Get.context!,
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

  static const String baseEndpoint = '/training-program';

  /// Get all training programs
  /// Access: System Administrator Only
  /// Endpoint: POST /training-program/select
  /// Returns training programs ordered by creation date (newest first) with related data
  static Future<List<TrainingProgram>> getAllTrainingPrograms() async {
    try {
      developer.log('Fetching training programs from: $baseEndpoint/select', name: 'TrainingProgramService');
      
      final response = await ApiService.post(
        '$baseEndpoint/select',
        body: {}, // No parameters required
      );
      
      // Log the complete response for debugging
      _logApiResponse('getAllTrainingPrograms', response);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the response is successful
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          developer.log('Successfully fetched ${data.length} training programs', name: 'TrainingProgramService');
          return data.map((json) => TrainingProgram.fromJson(json)).toList();
        } else {
          // Handle unsuccessful response and log it
          final message = responseData['m_ar'] ?? 'فشل في جلب برامج التدريب';
          final arabicMessage = responseData['m_ar'];
          final statusCode = responseData['status_code'];
          
          print('❌ TRAINING PROGRAM SERVICE: API call failed');
          print('❌ TRAINING PROGRAM SERVICE: Status code: $statusCode');
          print('❌ TRAINING PROGRAM SERVICE: Message: $message');
          print('❌ TRAINING PROGRAM SERVICE: Arabic message: $arabicMessage');
          
          // Log the error response for debugging
          developer.log(
            'API call failed for getAllTrainingPrograms',
            name: 'TrainingProgramService',
            error: {
              'status_code': statusCode,
              'message_ar': arabicMessage,
            },
          );
          
          throw Exception(message);
        }
      } else {
        _handleErrorResponse(response);
        throw Exception('فشل في جلب برامج التدريب: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getAllTrainingPrograms: $e', name: 'TrainingProgramService', error: e);
      _showErrorToast('خطأ في جلب برامج التدريب: $e');
      rethrow;
    }
  }

  /// Create new training program
  /// Access: System Administrator Only
  /// Endpoint: POST /training-program/create
  /// Required fields: title, course_id, training_center_id, specialization_id, seats, start_date, end_date
  /// Optional fields: status (defaults to "open")
  static Future<TrainingProgram> createTrainingProgram(Map<String, dynamic> programData) async {
    try {
      developer.log('Creating training program with data: $programData', name: 'TrainingProgramService');
      
      // Validate required fields
      _validateCreateProgramData(programData);
      
      final response = await ApiService.post(
        '$baseEndpoint/create',
        body: programData,
      );
      
      // Log the complete response for debugging
      _logApiResponse('createTrainingProgram', response);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the response is successful
        if (responseData['success'] == true) {
          developer.log('Training program created successfully', name: 'TrainingProgramService');
          _showSuccessToast('تم إنشاء برنامج التدريب بنجاح');
          return TrainingProgram.fromJson(responseData['data']);
        } else {
          // Handle unsuccessful response and log it
          final message = responseData['m_ar'] ?? 'فشل في إنشاء برنامج التدريب';
          final arabicMessage = responseData['m_ar'];
          final statusCode = responseData['status_code'];
          
          _logServerError('createTrainingProgram', {
            'success': responseData['success'],
            'message_ar': arabicMessage,
            'status_code': statusCode,
            'response_data': responseData,
            'request_data': programData,
          });
          
          throw Exception(message);
        }
      } else {
        _handleErrorResponse(response);
        throw Exception('فشل في إنشاء برنامج التدريب: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in createTrainingProgram: $e', name: 'TrainingProgramService', error: e);
      _showErrorToast('خطأ في إنشاء برنامج التدريب: $e');
      rethrow;
    }
  }

  /// Update existing training program
  /// Access: System Administrator Only
  /// Endpoint: POST /training-program/update
  /// Required fields: id
  /// All other fields are optional for updates
  static Future<TrainingProgram> updateTrainingProgram(Map<String, dynamic> programData) async {
    try {
      developer.log('Updating training program with data: $programData', name: 'TrainingProgramService');
      
      // Validate required fields
      _validateUpdateProgramData(programData);
      
      final response = await ApiService.post(
        '$baseEndpoint/update',
        body: programData,
      );
      
      // Log the complete response for debugging
      _logApiResponse('updateTrainingProgram', response);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the response is successful
        if (responseData['success'] == true) {
          developer.log('Training program updated successfully', name: 'TrainingProgramService');
          _showSuccessToast('تم تحديث برنامج التدريب بنجاح');
          return TrainingProgram.fromJson(responseData['data']);
        } else {
          // Handle unsuccessful response and log it
          final message = responseData['m_ar'] ?? 'فشل في تحديث برنامج التدريب';
          final arabicMessage = responseData['m_ar'];
          final statusCode = responseData['status_code'];
          
          _logServerError('updateTrainingProgram', {
            'success': responseData['success'],
            'message_ar': arabicMessage,
            'status_code': statusCode,
            'response_data': responseData,
            'request_data': programData,
          });
          
          throw Exception(message);
        }
      } else {
        _handleErrorResponse(response);
        throw Exception('فشل في تحديث برنامج التدريب: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in updateTrainingProgram: $e', name: 'TrainingProgramService', error: e);
      _showErrorToast('خطأ في تحديث برنامج التدريب: $e');
      rethrow;
    }
  }

  /// Validate data for creating a training program
  static void _validateCreateProgramData(Map<String, dynamic> data) {
    final requiredFields = [
      'title',
      'course_id',
      'training_center_id',
      'specialization_id',
      'seats',
      'start_date',
      'end_date'
    ];

    for (final field in requiredFields) {
      if (data[field] == null) {
        throw Exception('الحقل المطلوب "$field" مفقود');
      }
    }

    // Validate title length
    if (data['title'] is String && (data['title'] as String).length > 255) {
      throw Exception('العنوان يجب ألا يتجاوز 255 حرف');
    }

    // Validate seats
    if (data['seats'] is int && (data['seats'] as int) < 1) {
      throw Exception('عدد المقاعد يجب أن يكون 1 على الأقل');
    }

    // Validate dates
    final startDate = DateTime.tryParse(data['start_date']);
    final endDate = DateTime.tryParse(data['end_date']);
    
    if (startDate != null && startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw Exception('تاريخ البدء يجب أن يكون بعد اليوم');
    }
    
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      throw Exception('تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء');
    }
    
    // Validate status
    final validStatuses = getValidStatuses();
    if (data['status'] != null && !validStatuses.contains(data['status'])) {
      throw Exception('الحالة يجب أن تكون واحدة من: ${validStatuses.join(', ')}');
    }
  }

  /// Validate data for updating a training program
  static void _validateUpdateProgramData(Map<String, dynamic> data) {
    if (data['id'] == null) {
      throw Exception('معرف برنامج التدريب مطلوب للتحديث');
    }

    // Validate title length if provided
    if (data['title'] != null && data['title'] is String && (data['title'] as String).length > 255) {
      throw Exception('العنوان يجب ألا يتجاوز 255 حرف');
    }

    // Validate seats if provided
    if (data['seats'] != null && data['seats'] is int && (data['seats'] as int) < 1) {
      throw Exception('عدد المقاعد يجب أن يكون 1 على الأقل');
    }

    // Validate dates if provided
    final startDate = DateTime.tryParse(data['start_date']);
    final endDate = DateTime.tryParse(data['end_date']);
    
    if (startDate != null && startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw Exception('تاريخ البدء يجب أن يكون بعد اليوم');
    }
    
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      throw Exception('تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء');
    }
    
    // Validate status if provided
    final validStatuses = getValidStatuses();
    if (data['status'] != null && !validStatuses.contains(data['status'])) {
      throw Exception('الحالة يجب أن تكون واحدة من: ${validStatuses.join(', ')}');
    }
  }

  /// Handle error responses from API
  static void _handleErrorResponse(dynamic response) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      final message = errorData['m_ar'] ?? errorData['message'] ?? 'حدث خطأ غير معروف';
      
      switch (response.statusCode) {
        case 400:
          _showErrorToast('خطأ في الطلب: $message');
          break;
        case 401:
          _showErrorToast('خطأ في المصادقة: $message');
          break;
        case 403:
          _showErrorToast('غير مصرح: $message');
          break;
        case 404:
          _showErrorToast('غير موجود: برنامج التدريب غير موجود');
          break;
        case 500:
          _showErrorToast('خطأ في الخادم: حدث خطأ داخلي في الخادم');
          break;
        default:
          _showErrorToast('خطأ: $message');
      }
    } catch (e) {
      developer.log(
        'فشل في تحليل استجابة الخطأ: $e',
        name: 'TrainingProgramService',
        error: e,
      );
      _showErrorToast('خطأ: فشل في تحليل استجابة الخطأ');
    }
  }

  /// Get default avatar for training program
  static String getDefaultAvatar() {
    return 'https://ui-avatars.com/api/?name=TP&background=random';
  }

  /// Get valid status values
  static List<String> getValidStatuses() {
    return ['open', 'closed', 'completed'];
  }

  /// Get status display name
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Log API response for debugging
  static void _logApiResponse(String methodName, dynamic response) {
    developer.log(
      'API Response for $methodName: ${response.statusCode}',
      name: 'TrainingProgramService',
      error: response.body,
    );
  }

  /// Log server errors for debugging
  static void _logServerError(String methodName, Map<String, dynamic> errorData) {
    developer.log(
      'خطأ في الخادم لـ $methodName: ${errorData['message_ar']}',
      name: 'TrainingProgramService',
      error: jsonEncode(errorData),
    );
  }
}
