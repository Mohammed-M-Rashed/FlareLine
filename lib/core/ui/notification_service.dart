import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// خدمة الإشعارات المركزية
/// توفر واجهة موحدة لعرض إشعارات النجاح والخطأ والمعلومات
class NotificationService {
  // خريطة لتتبع العمليات وتجنب التكرار
  static final Map<String, DateTime> _operationTimestamps = {};
  
  // مدة النافذة الزمنية لمنع التكرار (بالثواني)
  static const int _deduplicationWindowSeconds = 3;

  /// عرض إشعار نجاح
  static void showSuccess(
    BuildContext context,
    String message, {
    String? operationId,
    Duration? duration,
  }) {
    if (_shouldShowNotification(operationId)) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text(
          'نجح',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        description: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        autoCloseDuration: duration ?? const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        alignment: Alignment.topRight,
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
      );
      _recordOperation(operationId);
    }
  }

  /// عرض إشعار خطأ
  static void showError(
    BuildContext context,
    String message, {
    String? operationId,
    Duration? duration,
  }) {
    if (_shouldShowNotification(operationId)) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: const Text(
          'خطأ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        description: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        autoCloseDuration: duration ?? const Duration(seconds: 6),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        alignment: Alignment.topRight,
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
      );
      _recordOperation(operationId);
    }
  }

  /// عرض إشعار معلومات
  static void showInfo(
    BuildContext context,
    String message, {
    String? operationId,
    Duration? duration,
  }) {
    if (_shouldShowNotification(operationId)) {
      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: const Text(
          'معلومات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        description: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        autoCloseDuration: duration ?? const Duration(seconds: 4),
        icon: const Icon(Icons.info_outline, color: Colors.white),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        alignment: Alignment.topRight,
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
      );
      _recordOperation(operationId);
    }
  }

  /// عرض إشعار تحذير
  static void showWarning(
    BuildContext context,
    String message, {
    String? operationId,
    Duration? duration,
  }) {
    if (_shouldShowNotification(operationId)) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        title: const Text(
          'تحذير',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        description: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        autoCloseDuration: duration ?? const Duration(seconds: 5),
        icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        alignment: Alignment.topRight,
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
      );
      _recordOperation(operationId);
    }
  }

  /// التحقق من عرض الإشعار (منع التكرار)
  static bool _shouldShowNotification(String? operationId) {
    if (operationId == null || operationId.isEmpty) {
      return true; // إذا لم يتم تحديد معرف العملية، اعرض الإشعار
    }

    final now = DateTime.now();
    final lastShown = _operationTimestamps[operationId];

    if (lastShown == null) {
      return true; // لم يتم عرض إشعار لهذه العملية من قبل
    }

    final difference = now.difference(lastShown);
    if (difference.inSeconds > _deduplicationWindowSeconds) {
      return true; // انتهت النافذة الزمنية، يمكن عرض إشعار جديد
    }

    return false; // لا تعرض، لا زلنا في النافذة الزمنية
  }

  /// تسجيل عملية
  static void _recordOperation(String? operationId) {
    if (operationId != null && operationId.isNotEmpty) {
      _operationTimestamps[operationId] = DateTime.now();
      
      // تنظيف العمليات القديمة (أكثر من ساعة)
      _operationTimestamps.removeWhere((key, value) {
        return DateTime.now().difference(value).inHours > 1;
      });
    }
  }

  /// مسح سجل جميع العمليات (للاستخدام في الاختبار أو إعادة التعيين)
  static void clearOperationHistory() {
    _operationTimestamps.clear();
  }
}

