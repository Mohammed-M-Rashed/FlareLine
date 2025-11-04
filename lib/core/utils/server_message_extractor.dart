import 'dart:convert';
import 'package:http/http.dart' as http;

/// مستخرج رسائل السيرفر
/// يتعامل مع مختلف أشكال الاستجابات ويستخرج الرسالة العربية
class ServerMessageExtractor {
  /// استخراج رسالة من استجابة HTTP
  static String extractMessage(
    http.Response response, {
    String? defaultMessage,
  }) {
    try {
      // محاولة تحليل الاستجابة كـ JSON
      final body = response.body;
      
      if (body.isEmpty) {
        return defaultMessage ?? 'لا توجد رسالة من الخادم';
      }

      // التحقق من وجود HTML في الاستجابة
      if (body.trim().startsWith('<!DOCTYPE') || 
          body.trim().startsWith('<html')) {
        return _extractFromHtml(body, response.statusCode);
      }

      try {
        final json = jsonDecode(body);
        return _extractFromJson(json, defaultMessage);
      } catch (e) {
        // إذا فشل تحليل JSON، أرجع الرسالة النصية كما هي
        return body.trim().isNotEmpty 
            ? body.trim() 
            : defaultMessage ?? 'خطأ غير معروف';
      }
    } catch (e) {
      return defaultMessage ?? 'خطأ في معالجة استجابة الخادم';
    }
  }

  /// استخراج رسالة من JSON
  static String _extractFromJson(
    Map<String, dynamic> json,
    String? defaultMessage,
  ) {
    // محاولة 1: رسالة بتنسيق {message: {ar: "...", en: "..."}}
    if (json['message'] != null && json['message'] is Map) {
      final messageMap = json['message'] as Map<String, dynamic>;
      if (messageMap['ar'] != null && messageMap['ar'].toString().isNotEmpty) {
        return messageMap['ar'].toString();
      }
      if (messageMap['en'] != null && messageMap['en'].toString().isNotEmpty) {
        return messageMap['en'].toString();
      }
    }

    // محاولة 2: رسالة بتنسيق {message: "نص مباشر"}
    if (json['message'] != null && json['message'] is String) {
      final msg = json['message'].toString().trim();
      if (msg.isNotEmpty) {
        return msg;
      }
    }

    // محاولة 3: رسالة بتنسيق {error: "..."}
    if (json['error'] != null && json['error'] is String) {
      return json['error'].toString();
    }

    // محاولة 4: رسائل الأخطاء {errors: {...}}
    if (json['errors'] != null && json['errors'] is Map) {
      final errors = json['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        // أخذ أول رسالة خطأ
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        if (firstError is String) {
          return firstError;
        }
      }
    }

    // الرجوع إلى الرسالة الافتراضية
    return defaultMessage ?? 'حدث خطأ غير متوقع';
  }

  /// استخراج رسالة من HTML
  static String _extractFromHtml(String html, int statusCode) {
    // محاولة استخراج العنوان
    final titleMatch = RegExp(r'<title>(.*?)</title>', 
      caseSensitive: false).firstMatch(html);
    
    if (titleMatch != null && titleMatch.group(1) != null) {
      final title = titleMatch.group(1)!.trim();
      if (title.isNotEmpty && !title.contains('<!DOCTYPE')) {
        return _translateHttpError(statusCode, title);
      }
    }

    // محاولة استخراج محتوى h1
    final h1Match = RegExp(r'<h1[^>]*>(.*?)</h1>', 
      caseSensitive: false).firstMatch(html);
    
    if (h1Match != null && h1Match.group(1) != null) {
      final h1 = h1Match.group(1)!.trim();
      if (h1.isNotEmpty) {
        return _translateHttpError(statusCode, h1);
      }
    }

    // الرجوع إلى رسالة عامة حسب حالة HTTP
    return _getGenericHttpErrorMessage(statusCode);
  }

  /// ترجمة أخطاء HTTP إلى العربية
  static String _translateHttpError(int statusCode, String originalMessage) {
    // إذا كانت الرسالة بالعربية بالفعل، أرجعها كما هي
    if (_isArabic(originalMessage)) {
      return originalMessage;
    }

    // ترجمة رسائل شائعة
    final lowerMessage = originalMessage.toLowerCase();
    
    if (lowerMessage.contains('payload too large')) {
      return 'حجم البيانات كبير جداً. يرجى تقليل حجم الملف المرفق';
    }
    if (lowerMessage.contains('service unavailable')) {
      return 'الخدمة غير متاحة مؤقتاً. يرجى المحاولة لاحقاً';
    }
    if (lowerMessage.contains('gateway timeout')) {
      return 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى';
    }
    if (lowerMessage.contains('bad gateway')) {
      return 'خطأ في الاتصال بالخادم. يرجى المحاولة لاحقاً';
    }
    if (lowerMessage.contains('not found')) {
      return 'المورد المطلوب غير موجود';
    }
    if (lowerMessage.contains('unauthorized')) {
      return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى';
    }
    if (lowerMessage.contains('forbidden')) {
      return 'ليس لديك صلاحية الوصول';
    }

    // الرجوع إلى رسالة عامة
    return _getGenericHttpErrorMessage(statusCode);
  }

  /// الحصول على رسالة خطأ عامة حسب حالة HTTP
  static String _getGenericHttpErrorMessage(int statusCode) {
    if (statusCode >= 500) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    }
    if (statusCode == 413) {
      return 'حجم البيانات كبير جداً';
    }
    if (statusCode == 404) {
      return 'المورد المطلوب غير موجود';
    }
    if (statusCode == 403) {
      return 'ليس لديك صلاحية الوصول';
    }
    if (statusCode == 401) {
      return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى';
    }
    if (statusCode == 400) {
      return 'طلب غير صحيح';
    }
    
    return 'حدث خطأ غير متوقع';
  }

  /// التحقق من وجود أحرف عربية في النص
  static bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// استخراج أخطاء التحقق (422) وإرجاعها كخريطة
  static Map<String, List<String>>? extractValidationErrors(
    http.Response response,
  ) {
    if (response.statusCode != 422) {
      return null;
    }

    try {
      final json = jsonDecode(response.body);
      if (json['errors'] != null && json['errors'] is Map) {
        final errors = json['errors'] as Map<String, dynamic>;
        final validationErrors = <String, List<String>>{};
        
        errors.forEach((key, value) {
          if (value is List) {
            validationErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            validationErrors[key] = [value];
          }
        });
        
        return validationErrors;
      }
    } catch (e) {
      // فشل استخراج أخطاء التحقق
    }

    return null;
  }
}

