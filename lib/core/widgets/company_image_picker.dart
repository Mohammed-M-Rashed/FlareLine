import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/image_utils.dart';
import '../theme/global_theme.dart';

class CompanyImagePicker extends StatefulWidget {
  final String? initialImage; // BASE64 string
  final Function(String?) onImageChanged; // Callback when image changes
  final String? errorText; // Validation error text
  final bool isRequired; // Whether image is required
  final double width; // Widget width
  final double height; // Widget height

  const CompanyImagePicker({
    super.key,
    this.initialImage,
    required this.onImageChanged,
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _base64Image = widget.initialImage;
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
                if (_base64Image != null)
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
                      if (_base64Image != null)
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
        if (_base64Image == null)
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

      final String? base64 = await ImageUtils.showImagePickerDialog(context);
      
      if (base64 != null) {
        setState(() {
          _base64Image = base64;
        });
        
        // Notify parent
        widget.onImageChanged(base64);
      }
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
    });
    
    // Notify parent
    widget.onImageChanged(null);
  }

  // Getter for the current BASE64 image
  String? get currentImage => _base64Image;
}
