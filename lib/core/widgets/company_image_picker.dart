import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/image_utils.dart';
import '../theme/global_theme.dart';

class CompanyImagePicker extends StatefulWidget {
  final String? initialImage; // BASE64 string or image file path
  final Function(String?) onImageChanged; // Callback when image changes (BASE64)
  final Function(PlatformFile?)? onImageFileChanged; // Callback when image file changes
  final String? errorText; // Validation error text
  final bool isRequired; // Whether image is required
  final double width; // Widget width
  final double height; // Widget height

  const CompanyImagePicker({
    super.key,
    this.initialImage,
    required this.onImageChanged,
    this.onImageFileChanged,
    this.errorText,
    this.isRequired = false,
    this.width = 200,
    this.height = 200,
  });

  @override
  State<CompanyImagePicker> createState() => _CompanyImagePickerState();
}

class _CompanyImagePickerState extends State<CompanyImagePicker> {
  String? _base64Image;
  String? _imageFilePath; // Store file path from server
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if initialImage is a file path or Base64
    if (widget.initialImage != null && widget.initialImage!.isNotEmpty) {
      if (_isBase64(widget.initialImage!)) {
        _base64Image = widget.initialImage;
      } else {
        // It's a file path from server
        _imageFilePath = widget.initialImage;
      }
    }
  }
  
  // Helper to check if string is Base64
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
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
              'شعار الشركة',
              style: GlobalTheme.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

        // Image Display and Picker
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
                // Image Display
                if (_base64Image != null || _imageFilePath != null)
                  Positioned.fill(
                    child: _buildImageDisplay(),
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
                            Icons.business,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لم يتم اختيار صورة',
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

                // Image Actions Overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Change Image Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: _isLoading ? null : _pickImage,
                          tooltip: 'تغيير الصورة',
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Remove Image Button
                      if (_base64Image != null || _imageFilePath != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: _isLoading ? null : _removeImage,
                            tooltip: 'إزالة الصورة',
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

        // Add Image Button (when no image is selected)
        if (_base64Image == null && _imageFilePath == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: widget.width,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: Text('اختيار صورة', style: GlobalTheme.textStyle()),
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

  Widget _buildImageDisplay() {
    // If we have a new Base64 image selected
    if (_base64Image != null) {
      try {
        final Uint8List bytes = base64Decode(_base64Image!);
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      } catch (e) {
        return _buildErrorPlaceholder();
      }
    }
    
    // If we have an existing image file path from server
    if (_imageFilePath != null) {
      final imageUrl = _buildCompanyImageUrl(_imageFilePath!);
      return Image.network(
        imageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }
    
    return _buildErrorPlaceholder();
  }
  
  // Build full image URL from server
  String _buildCompanyImageUrl(String imageFileName) {
    const baseUrl = 'https://noc.justhost.ly/backend-api/storage/app/public/';
    // Remove any leading slashes or spaces from imageFileName
    final cleanFileName = imageFileName.trim().replaceFirst(RegExp(r'^/'), '');
    return '$baseUrl$cleanFileName';
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'صورة غير صالحة',
            style: GlobalTheme.textStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Pick image file
      final file = await ImageUtils.pickImageFile();
      
      if (file != null && file.bytes != null) {
        // Convert to base64 for display
        final base64 = await ImageUtils.fileToBase64(file);
        
        setState(() {
          _selectedFile = file;
          _base64Image = base64;
          _imageFilePath = null; // Clear file path when new image is selected
        });
        
        // Notify parent with both base64 (for display) and file (for upload)
        if (base64 != null) {
          widget.onImageChanged(base64);
        }
        widget.onImageFileChanged?.call(file);
      }
    } catch (e) {
      // Error is already shown in ImageUtils.pickImageFile
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _base64Image = null;
      _imageFilePath = null;
      _selectedFile = null;
    });
    
    // Notify parent
    widget.onImageChanged(null);
    widget.onImageFileChanged?.call(null);
  }

  // Getter for the current BASE64 image
  String? get currentImage => _base64Image;
  
  // Getter for the current image file
  PlatformFile? get currentImageFile => _selectedFile;
}
