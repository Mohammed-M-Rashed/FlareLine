import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/models/training_center_model.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:flutter/material.dart'; // Added for Colors

// Global service to notify about Training Center status changes
class TrainingCenterNotificationService extends GetxController {
  static TrainingCenterNotificationService get to => Get.find();
  
  final _statusUpdateStream = Rx<TrainingCenter?>(null);
  
  Rx<TrainingCenter?> get statusUpdateStream => _statusUpdateStream;
  
  void notifyStatusUpdate(TrainingCenter trainingCenter) {
    _statusUpdateStream.value = trainingCenter;
  }
}

class TrainingCenterService extends GetxController {
  /// Shows a success toast notification for training center operations in Arabic
  void _showSuccessToast(String message) {
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

  /// Shows an error toast notification for training center operations in Arabic
  void _showErrorToast(String message) {
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

  /// Shows an info toast notification for training center operations in Arabic
  void _showInfoToast(String message) {
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

  // Base endpoint for training centers
  static const String baseEndpoint = '/training-center';

  // Get all training centers
  Future<List<TrainingCenter>> getTrainingCenters() async {
    try {
      final response = await ApiService.post(
        '$baseEndpoint/select',
        body: {},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trainingCentersData = responseData['data'] ?? [];
          return trainingCentersData
              .map((json) => TrainingCenter.fromJson(json))
              .toList();
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في جلب مراكز التدريب');
          return [];
        }
      } else {
        _showErrorToast('فشل في جلب مراكز التدريب: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _showErrorToast('خطأ في جلب مراكز التدريب: $e');
      return [];
    }
  }

  // Create a new training center
  Future<TrainingCenter?> createTrainingCenter({
    required String name,
    required int specializationId,
    required String address,
    required String phone,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseEndpoint/create',
        body: {
          'name': name,
          'specialization_id': specializationId,
          'address': address,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSuccessToast(responseData['m_ar'] ?? 'تم إنشاء مركز التدريب بنجاح');
          return TrainingCenter.fromJson(responseData['data']);
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في إنشاء مركز التدريب');
          return null;
        }
      } else {
        _showErrorToast('فشل في إنشاء مركز التدريب: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showErrorToast('خطأ في إنشاء مركز التدريب: $e');
      return null;
    }
  }

  // Update an existing training center
  Future<TrainingCenter?> updateTrainingCenter({
    required int id,
    String? name,
    int? specializationId,
    String? address,
    String? phone,
  }) async {
    try {
      final Map<String, dynamic> updateData = {'id': id};
      
      if (name != null) updateData['name'] = name;
      if (specializationId != null) updateData['specialization_id'] = specializationId;
      if (address != null) updateData['address'] = address;
      if (phone != null) updateData['phone'] = phone;

      final response = await ApiService.post(
        '$baseEndpoint/update',
        body: updateData,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSuccessToast(responseData['m_ar'] ?? 'تم تحديث مركز التدريب بنجاح');
          return TrainingCenter.fromJson(responseData['data']);
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في تحديث مركز التدريب');
          return null;
        }
      } else {
        _showErrorToast('فشل في تحديث مركز التدريب: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showErrorToast('خطأ في تحديث مركز التدريب: $e');
      return null;
    }
  }

  // Get training centers by status
  Future<List<TrainingCenter>> getTrainingCentersByStatus(String status) async {
    try {
      final response = await ApiService.post(
        '$baseEndpoint/by-status',
        body: {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trainingCentersData = responseData['data'] ?? [];
          return trainingCentersData
              .map((json) => TrainingCenter.fromJson(json))
              .toList();
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في جلب مراكز التدريب حسب الحالة');
          return [];
        }
      } else {
        _showErrorToast('فشل في جلب مراكز التدريب حسب الحالة: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _showErrorToast('خطأ في جلب مراكز التدريب حسب الحالة: $e');
      return [];
    }
  }

  // Update training center status (approve/reject)
  Future<TrainingCenter?> updateTrainingCenterStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> statusData = {
        'id': id,
        'status': status,
      };
      
      if (reason != null) statusData['reason'] = reason;

      final response = await ApiService.post(
        '$baseEndpoint/update-status',
        body: statusData,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final updatedTrainingCenter = TrainingCenter.fromJson(responseData['data']);
          
          // Notify global service about status update
          try {
            if (Get.isRegistered<TrainingCenterNotificationService>()) {
              Get.find<TrainingCenterNotificationService>().notifyStatusUpdate(updatedTrainingCenter);
            }
          } catch (e) {
            // If notification service is not registered, ignore the error
            print('TrainingCenterNotificationService not available: $e');
          }
          
          _showSuccessToast(responseData['m_ar'] ?? 'تم تحديث حالة مركز التدريب بنجاح');
          return updatedTrainingCenter;
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في تحديث حالة مركز التدريب');
          return null;
        }
      } else {
        _showErrorToast('فشل في تحديث حالة مركز التدريب: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showErrorToast('خطأ في تحديث حالة مركز التدريب: $e');
      return null;
    }
  }

  // Validate training center data before API call
  String? validateTrainingCenterData({
    required String name,
    required int specializationId,
    required String address,
    required String phone,
  }) {
    if (name.trim().isEmpty) {
      return 'Training center name is required';
    }
    
    if (name.length > 255) {
      return 'Training center name must not exceed 255 characters';
    }
    
    if (specializationId <= 0) {
      return 'Please select a valid specialization';
    }
    
    if (address.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    if (phone.length > 20) {
      return 'Phone number must not exceed 20 characters';
    }
    
    return null;
  }

  // Get training centers with pagination (if needed in future)
  Future<Map<String, dynamic>> getTrainingCentersWithPagination({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) queryParams['order'] = sortOrder;

      final response = await ApiService.post(
        '$baseEndpoint/select',
        body: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trainingCentersData = responseData['data'] ?? [];
          final List<TrainingCenter> trainingCenters = trainingCentersData
              .map((json) => TrainingCenter.fromJson(json))
              .toList();
              
          return {
            'trainingCenters': trainingCenters,
            'pagination': responseData['pagination'] ?? {},
            'total': responseData['pagination']?['total_items'] ?? trainingCenters.length,
          };
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في جلب مراكز التدريب');
          return {
            'trainingCenters': [],
            'pagination': {},
            'total': 0,
          };
        }
      } else {
        _showErrorToast('فشل في جلب مراكز التدريب: HTTP ${response.statusCode}');
        return {
          'trainingCenters': [],
          'pagination': {},
          'total': 0,
        };
      }
    } catch (e) {
      _showErrorToast('خطأ في جلب مراكز التدريب: $e');
      return {
        'trainingCenters': [],
        'pagination': {},
        'total': 0,
      };
    }
  }

  // Search training centers
  Future<List<TrainingCenter>> searchTrainingCenters(String query) async {
    try {
      final response = await ApiService.post(
        '$baseEndpoint/select',
        body: {'search': query},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trainingCentersData = responseData['data'] ?? [];
          return trainingCentersData
              .map((json) => TrainingCenter.fromJson(json))
              .toList();
        } else {
          _showErrorToast(responseData['m_ar'] ?? 'فشل في البحث عن مراكز التدريب');
          return [];
        }
      } else {
        _showErrorToast('فشل في البحث عن مراكز التدريب: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _showErrorToast('خطأ في البحث عن مراكز التدريب: $e');
      return [];
    }
  }

  // Get training center statistics
  Future<Map<String, dynamic>> getTrainingCenterStats() async {
    try {
      final allTrainingCenters = await getTrainingCenters();
      
      final int total = allTrainingCenters.length;
      final int pending = allTrainingCenters.where((tc) => tc.isPending).length;
      final int approved = allTrainingCenters.where((tc) => tc.isApproved).length;
      final int rejected = allTrainingCenters.where((tc) => tc.isRejected).length;
      final int withFiles = allTrainingCenters.where((tc) => tc.hasFile).length;
      
      return {
        'total': total,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'withFiles': withFiles,
        'approvalRate': total > 0 ? (approved / total * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      _showErrorToast('خطأ في جلب إحصائيات مراكز التدريب: $e');
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'withFiles': 0,
        'approvalRate': '0.0',
      };
    }
  }
}
