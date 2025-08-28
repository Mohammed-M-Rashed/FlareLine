import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/mvvm/base_table_provider.dart';

/// Simple base table widget for backward compatibility
abstract class TableWidget<T extends BaseTableProvider> extends StatefulWidget {
  const TableWidget({super.key});

  /// Title method
  String? title(BuildContext context) {
    return null;
  }

  /// Tools widget method
  Widget? toolsWidget(BuildContext context, T viewModel) {
    return null;
  }

  /// Action column width
  double get actionColumnWidth => 200;

  /// Show paging
  bool get showPaging => true;

  /// Actions widget builder
  Widget? actionWidgetsBuilder(BuildContext context, Map<String, dynamic> columnData, T viewModel) {
    return null;
  }

  /// Custom widget builder
  Widget? customWidgetsBuilder(BuildContext context, Map<String, dynamic> columnData, T viewModel) {
    return null;
  }

  /// Toggle changed event
  void onToggleChanged(BuildContext context, bool checked, Map<String, dynamic> columnData) {}

  @override
  State<TableWidget<T>> createState() => _TableWidgetState<T>();
}

class _TableWidgetState<T extends BaseTableProvider> extends State<TableWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title(context) != null) ...[
            Text(
              widget.title(context)!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.toolsWidget(context, Get.find<T>()) != null) ...[
            widget.toolsWidget(context, Get.find<T>())!,
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Center(
              child: Text(
                'Table implementation needed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
