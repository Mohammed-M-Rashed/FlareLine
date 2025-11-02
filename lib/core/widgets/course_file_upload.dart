import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/image_utils.dart';
import '../theme/global_theme.dart';
import 'package:file_picker/file_picker.dart';

class CourseFileUpload extends StatefulWidget {
  final String? initialFile; // BASE64 string or file URL
  final Function(String?) onFileChanged; // Callback when file changes (BASE64)
  final Function(PlatformFile?)? onFileAttachmentChanged; // Callback when file attachment changes
  final String? errorText; // Validation error text
  final bool isRequired; // Whether file is required
  final double width; // Widget width
  final double height; // Widget height

  const CourseFileUpload({
    super.key,
    this.initialFile,
    required this.onFileChanged,
    this.onFileAttachmentChanged,
    this.errorText,
    this.isRequired = false,
    this.width = 300,
    this.height = 120,
  });

  @override
  State<CourseFileUpload> createState() => _CourseFileUploadState();
}

class _CourseFileUploadState extends State<CourseFileUpload> {
  String? _base64File;
  PlatformFile? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _base64File = widget.initialFile;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              'مرفق الملف',
              style: GlobalTheme.textStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: GlobalTheme.textStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // File Display and Picker
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorText != null ? Colors.red : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // File Display
                if (_base64File != null && _fileName != null)
                  Positioned.fill(
                    child: _buildFileDisplay(),
                  )
                else
                  // Placeholder
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لم يتم اختيار ملف',
                            style: GlobalTheme.textStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Loading Overlay
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),

                // File Actions Overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Change File Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: _isLoading ? null : _pickFile,
                          tooltip: 'تغيير الملف',
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Remove File Button
                      if (_base64File != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: _isLoading ? null : _removeFile,
                            tooltip: 'إزالة الملف',
                            iconSize: 16,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Error Text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText!,
              style: GlobalTheme.textStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ),

        // Add File Button (when no file is selected)
        if (_base64File == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: widget.width,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text('اختيار ملف', style: GlobalTheme.textStyle()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileDisplay() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 32,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            _fileName ?? 'ملف',
            style: GlobalTheme.textStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'تم رفع الملف بنجاح',
            style: GlobalTheme.textStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String? base64 = await _showFilePickerDialog();
      
      if (base64 != null) {
        setState(() {
          _base64File = base64;
        });
        
        // Notify parent with both base64 (for display) and file (for upload)
        widget.onFileChanged(base64);
        widget.onFileAttachmentChanged?.call(_selectedFile);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeFile() {
    setState(() {
      _base64File = null;
      _fileName = null;
      _selectedFile = null;
    });
    
    // Notify parent
    widget.onFileChanged(null);
    widget.onFileAttachmentChanged?.call(null);
  }

  Future<String?> _showFilePickerDialog() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size (10MB limit for documents)
        if (file.size > 10 * 1024 * 1024) {
          throw Exception('حجم الملف يجب أن يكون أقل من 10 ميجابايت');
        }
        
        // Store file name and file object
        _fileName = file.name;
        _selectedFile = file;
        
        // Convert to BASE64 for display/backward compatibility
        if (file.bytes != null) {
          return base64Encode(file.bytes!);
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

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GlobalTheme.textStyle()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Getter for the current BASE64 file
  String? get currentFile => _base64File;
  
  // Getter for the current file name
  String? get currentFileName => _fileName;
  
  // Getter for the current file attachment
  PlatformFile? get currentFileAttachment => _selectedFile;
}
