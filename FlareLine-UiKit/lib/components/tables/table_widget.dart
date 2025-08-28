library flareline_uikit;

import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class TableWidget extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> data;
  final List<double> columnWidths;
  final Function(int)? onRowTap;
  final bool showRowNumbers;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;
  final Color? rowBackgroundColor;
  final Color? rowTextColor;
  final double? rowHeight;
  final BorderRadius? borderRadius;

  const TableWidget({
    super.key,
    required this.headers,
    required this.data,
    this.columnWidths = const [],
    this.onRowTap,
    this.showRowNumbers = false,
    this.headerBackgroundColor,
    this.headerTextColor,
    this.rowBackgroundColor,
    this.rowTextColor,
    this.rowHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: FlarelineColors.border),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            decoration: BoxDecoration(
              color: headerBackgroundColor ?? FlarelineColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: borderRadius?.topLeft ?? const Radius.circular(8),
                topRight: borderRadius?.topRight ?? const Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                if (showRowNumbers)
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Text(
                      '#',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: headerTextColor ?? Colors.white,
                        fontFamily: 'Tajawal', // Use Tajawal font
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...headers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final header = entry.value;
                  final width = index < columnWidths.length ? columnWidths[index] : null;
                  
                  return Expanded(
                    flex: width != null ? (width * 100).round() : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Text(
                        header,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: headerTextColor ?? Colors.white,
                          fontFamily: 'Tajawal', // Use Tajawal font
                        ),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Data Rows
          ...data.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;
            
            return InkWell(
              onTap: onRowTap != null ? () => onRowTap!(rowIndex) : null,
              child: Container(
                height: rowHeight ?? 56,
                decoration: BoxDecoration(
                  color: rowIndex.isEven 
                      ? (rowBackgroundColor ?? Colors.grey.shade50)
                      : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: FlarelineColors.border,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (showRowNumbers)
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Text(
                          '${rowIndex + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: rowTextColor ?? FlarelineColors.darkTextBody,
                            fontFamily: 'Tajawal', // Use Tajawal font
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ...row.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cell = entry.value;
                      final width = index < columnWidths.length ? columnWidths[index] : null;
                      
                      return Expanded(
                        flex: width != null ? (width * 100).round() : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Text(
                            cell,
                            style: TextStyle(
                              fontSize: 14,
                              color: rowTextColor ?? FlarelineColors.darkTextBody,
                              fontFamily: 'Tajawal', // Use Tajawal font
                            ),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
