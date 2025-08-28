import 'package:flutter/material.dart';
import 'base_viewmodel.dart';

/// Simple base table provider for backward compatibility
abstract class BaseTableProvider extends BaseViewModel {
  BaseTableProvider(BuildContext context) : super(context);
  
  /// Table data entity
  dynamic tableDataEntity;
  
  /// Page size for pagination
  int pageSize = 10;
  
  /// Loading state
  bool isLoading = false;
  
  /// Load data method
  Future<void> loadData(BuildContext context);
  
  /// Get item value helper method
  Map<String, dynamic> getItemValue(String key, Map<String, dynamic> item, {String? dataType}) {
    dynamic value = item[key];
    String text = value != null ? (value.toString()) : '';

    Map<String, dynamic> column = {
      'text': text,
      'key': key,
      'dataType': dataType,
      'columnName': key,
      'id': item['id'],
    };
    return column;
  }
}

/// Cell data types for backward compatibility
enum CellDataType {
  TEXT('text'),
  TOGGLE('toggle'),
  TAG('tag'),
  IMAGE('image'),
  CUSTOM('custom'),
  ACTION('action'),
  IMAGE_TEXT('imageText');

  const CellDataType(this.type);
  final String type;
}
