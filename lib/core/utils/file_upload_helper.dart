 import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadHelper {
  /// Pick a file and convert it to Base64
  static Future<String?> pickAndConvertToBase64({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        dialogTitle: dialogTitle ?? 'Select a file',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        return base64String;
      }
      
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Convert file to Base64 from file path
  static Future<String?> convertFileToBase64(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      print('Error converting file to Base64: $e');
      return null;
    }
  }

  /// Get file extension from file name
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Validate file size (max 10MB by default)
  static bool validateFileSize(int bytes, {int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return bytes <= maxSizeInBytes;
  }

  /// Validate file extension
  static bool validateFileExtension(String fileName, List<String> allowedExtensions) {
    final extension = getFileExtension(fileName);
    return allowedExtensions.contains(extension);
  }

  /// Get file icon based on extension
  static IconData getFileIcon(String fileName) {
    final extension = getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  /// Get file color based on extension
  static Color getFileColor(String fileName) {
    final extension = getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'txt':
        return Colors.grey;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Show file picker dialog with validation
  static Future<String?> showFilePickerDialog({
    required BuildContext context,
    List<String>? allowedExtensions,
    String? dialogTitle,
    int maxSizeInMB = 10,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        dialogTitle: dialogTitle ?? 'Select a file',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size
        if (file.size != null && !validateFileSize(file.size!, maxSizeInMB: maxSizeInMB)) {
          _showErrorSnackBar(context, 'File size must be less than ${maxSizeInMB}MB');
          return null;
        }

        // Validate file extension
        if (file.name != null && !validateFileExtension(file.name!, allowedExtensions ?? ['pdf', 'doc', 'docx', 'ppt', 'pptx'])) {
          _showErrorSnackBar(context, 'File type not allowed');
          return null;
        }

        // Convert to Base64
        final base64String = await convertFileToBase64(file.path!);
        if (base64String != null) {
          _showSuccessSnackBar(context, 'File selected successfully');
          return base64String;
        } else {
          _showErrorSnackBar(context, 'Failed to process file');
          return null;
        }
      }
      
      return null;
    } catch (e) {
      print('Error in file picker dialog: $e');
      _showErrorSnackBar(context, 'Error selecting file: ${e.toString()}');
      return null;
    }
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Create a file upload widget
  static Widget buildFileUploadWidget({
    required String? currentFileName,
    required VoidCallback onTap,
    String? hintText,
    List<String>? allowedExtensions,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              currentFileName != null 
                  ? getFileIcon(currentFileName)
                  : Icons.attach_file,
              color: currentFileName != null 
                  ? getFileColor(currentFileName)
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentFileName ?? hintText ?? 'Select a file',
                    style: TextStyle(
                      color: currentFileName != null ? Colors.black87 : Colors.grey,
                      fontWeight: currentFileName != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (currentFileName != null)
                    Text(
                      'Tap to change file',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.upload_file,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
