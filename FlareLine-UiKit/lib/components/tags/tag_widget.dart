library flareline_uikit;

import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

enum TagType {
  success,
  warning,
  error,
  info,
  primary,
  secondary,
  custom,
}

extension TagTypeExtension on TagType {
  static TagType getTagType(String? type) {
    switch (type?.toLowerCase()) {
      case 'success':
        return TagType.success;
      case 'warning':
        return TagType.warning;
      case 'error':
        return TagType.error;
      case 'info':
        return TagType.info;
      case 'primary':
        return TagType.primary;
      case 'secondary':
        return TagType.secondary;
      default:
        return TagType.custom;
    }
  }

  Color getBackgroundColor() {
    switch (this) {
      case TagType.success:
        return Colors.green.shade100;
      case TagType.warning:
        return Colors.orange.shade100;
      case TagType.error:
        return Colors.red.shade100;
      case TagType.info:
        return Colors.blue.shade100;
      case TagType.primary:
        return FlarelineColors.primary.withOpacity(0.1);
      case TagType.secondary:
        return Colors.grey.shade100;
      case TagType.custom:
        return Colors.purple.shade100;
    }
  }

  Color getTextColor() {
    switch (this) {
      case TagType.success:
        return Colors.green.shade700;
      case TagType.warning:
        return Colors.orange.shade700;
      case TagType.error:
        return Colors.red.shade700;
      case TagType.info:
        return Colors.blue.shade700;
      case TagType.primary:
        return FlarelineColors.primary;
      case TagType.secondary:
        return Colors.grey.shade700;
      case TagType.custom:
        return Colors.purple.shade700;
    }
  }

  Color getBorderColor() {
    switch (this) {
      case TagType.success:
        return Colors.green.shade300;
      case TagType.warning:
        return Colors.orange.shade300;
      case TagType.error:
        return Colors.red.shade300;
      case TagType.info:
        return Colors.blue.shade300;
      case TagType.primary:
        return FlarelineColors.primary.withOpacity(0.3);
      case TagType.secondary:
        return Colors.grey.shade300;
      case TagType.custom:
        return Colors.purple.shade300;
    }
  }
}

class TagWidget extends StatelessWidget {
  final String text;
  final TagType tagType;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final VoidCallback? onTap;
  final bool isRemovable;
  final VoidCallback? onRemove;

  const TagWidget({
    super.key,
    required this.text,
    this.tagType = TagType.primary,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
    this.onTap,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: tagType.getBackgroundColor(),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: showBorder
              ? Border.all(
                  color: tagType.getBorderColor(),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: tagType.getTextColor(),
                  fontSize: fontSize ?? 11,
                  fontFamily: 'Tajawal', // Use Tajawal font
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRemovable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: tagType.getTextColor(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
