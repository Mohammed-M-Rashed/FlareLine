import 'package:flutter/material.dart';

class CountSummaryWidget extends StatelessWidget {
  final int count;
  final String itemName;
  final String itemNamePlural;
  final IconData icon;
  final MaterialColor? color;
  final String? lastUpdated;
  final int? filteredCount;
  final bool showFilteredCount;

  const CountSummaryWidget({
    super.key,
    required this.count,
    required this.itemName,
    required this.itemNamePlural,
    required this.icon,
    this.color,
    this.lastUpdated,
    this.filteredCount,
    this.showFilteredCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.blue;
    final effectiveLastUpdated = lastUpdated ?? DateTime.now().toString().substring(0, 19);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: effectiveColor.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: effectiveColor.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _buildCountText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: effectiveColor.shade700,
              ),
            ),
          ),
          Text(
            'آخر تحديث: $effectiveLastUpdated',
            style: TextStyle(
              fontSize: 12,
              color: effectiveColor.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _buildCountText() {
    if (showFilteredCount && filteredCount != null) {
      return 'تم العثور على $filteredCount من $count $itemName';
    } else {
      return 'تم العثور على $count $itemName';
    }
  }
}

// English version for pages that use English
class CountSummaryWidgetEn extends StatelessWidget {
  final int count;
  final String itemName;
  final String itemNamePlural;
  final IconData icon;
  final MaterialColor? color;
  final String? lastUpdated;
  final int? filteredCount;
  final bool showFilteredCount;

  const CountSummaryWidgetEn({
    super.key,
    required this.count,
    required this.itemName,
    required this.itemNamePlural,
    required this.icon,
    this.color,
    this.lastUpdated,
    this.filteredCount,
    this.showFilteredCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.blue;
    final effectiveLastUpdated = lastUpdated ?? DateTime.now().toString().substring(0, 19);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: effectiveColor.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: effectiveColor.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _buildCountText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: effectiveColor.shade700,
              ),
            ),
          ),
          Text(
            'Last updated: $effectiveLastUpdated',
            style: TextStyle(
              fontSize: 12,
              color: effectiveColor.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _buildCountText() {
    if (showFilteredCount && filteredCount != null) {
      return '$filteredCount of $count $itemName${count == 1 ? '' : 's'} found';
    } else {
      return '$count $itemName${count == 1 ? '' : 's'} found';
    }
  }
}
