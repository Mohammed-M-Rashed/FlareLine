import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toastification/toastification.dart';
import '../theme/global_theme.dart';

class ImageUtils {
  /// Shows an error toast notification for image operations in Arabic
  static void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: GlobalTheme.textStyle(fontWeight: FontWeight.bold)),
      description: Text(message, style: GlobalTheme.textStyle()),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  // Maximum image size in bytes (5MB)
  static const int maxImageSize = 5 * 1024 * 1024;
  
  // Supported image formats
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  
  /// Pick an image file from the user's computer
  static Future<PlatformFile?> pickImageFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedFormats,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size
        if (file.size > maxImageSize) {
          throw Exception('حجم الصورة يجب أن يكون أقل من 5 ميجابايت');
        }
        
        // Validate file extension
        final extension = file.extension?.toLowerCase();
        if (extension == null || !supportedFormats.contains(extension)) {
          throw Exception('تنسيق الصورة غير مدعوم. يرجى استخدام: ${supportedFormats.join(', ')}');
        }
        
        return file;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Convert PlatformFile to BASE64 string
  static Future<String?> fileToBase64(PlatformFile file) async {
    try {
      if (file.bytes != null) {
        return base64Encode(file.bytes!);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في تحويل BASE64 إلى بايت الصورة: $e');
      return null;
    }
  }
  
  /// Convert BASE64 string to image bytes
  static Uint8List? base64ToImageBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error converting BASE64 to image bytes: $e');
      return null;
    }
  }
  
  /// Validate BASE64 image string
  static bool isValidBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return bytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get file size in human readable format
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  /// Show image picker dialog with validation
  static Future<String?> showImagePickerDialog(BuildContext context) async {
    try {
      final file = await pickImageFile();
      if (file != null) {
        final base64 = await fileToBase64(file);
        if (base64 != null) {
          return base64;
        }
      }
      return null;
    } catch (e) {
      // Show error message
      if (context.mounted) {
        _showErrorToast(context, e.toString());
      }
      return null;
    }
  }
}
