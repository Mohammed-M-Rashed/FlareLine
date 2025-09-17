import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/utils/validation_helper.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/training_plan_model.dart';
import 'package:flareline/core/services/training_plan_service.dart';
import 'package:flareline/core/services/plan_course_assignment_service.dart';
import 'package:flareline/core/models/plan_course_assignment_model.dart' as pca_model;
import 'package:flareline/core/services/auth_service.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer

class TrainingPlanManagementPage extends LayoutWidget {
  const TrainingPlanManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Training Plan Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainingPlanManagementWidget(),
      ],
    );
  }
}

class TrainingPlanManagementWidget extends StatefulWidget {
  const TrainingPlanManagementWidget({super.key});

  @override
  State<TrainingPlanManagementWidget> createState() => _TrainingPlanManagementWidgetState();
}

class _TrainingPlanManagementWidgetState extends State<TrainingPlanManagementWidget> {

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TrainingPlanDataProvider>(
          init: TrainingPlanDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  // Helper method to get role color
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.blue;
      case 'General Training Director':
        return Colors.orange;
      case 'Board Chairman':
        return Colors.purple;
      case 'Company Account':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Show workflow confirmation dialog
  void _showWorkflowConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWidget(BuildContext context, TrainingPlanDataProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Training Plan Management',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage annual training plans and their information',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Obx(() => ButtonWidget(
                                btnText: provider.isLoading ? 'Loading...' : 'Refresh',
                                type: 'secondary',
                                onTap: provider.isLoading ? null : () async {
                                  try {
                                    await provider.refreshData();
                                    _showSuccessToast('Training plans data refreshed successfully');
                                  } catch (e) {
                                    _showErrorToast('خطأ في تحديث بيانات خطط التدريب: ${e.toString()}');
                                  }
                                },
                              )),
                            ),
                            const SizedBox(width: 16),
                            Builder(
                              builder: (context) {
                                if (TrainingPlanService.canCreateEditTrainingPlans()) {
                                  return SizedBox(
                                    width: 140,
                                    child: ButtonWidget(
                                      btnText: 'Add Training Plan',
                                      type: 'primary',
                                      onTap: () {
                                        _showAddTrainingPlanForm(context);
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                    if (provider.isLoading) {
                      return const LoadingWidget();
                    }

                    final trainingPlans = provider.trainingPlans;

                    if (trainingPlans.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Training Plans Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding the first annual training plan to the system.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (TrainingPlanService.canCreateEditTrainingPlans())
                              ButtonWidget(
                                btnText: 'Add First Training Plan',
                                type: 'primary',
                                onTap: () => _showAddTrainingPlanForm(context),
                              ),
                          ],
                        ),
                      );
                    }

                    return _buildTrainingPlansTable(context, provider, constraints);
                  }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingPlansTable(BuildContext context, TrainingPlanDataProvider provider, BoxConstraints constraints) {
    final trainingPlans = provider.pagedTrainingPlans;
    final filteredPlans = provider.filteredTrainingPlans;

    return Column(
      children: [
        // Training Plans count and summary
        CountSummaryWidgetEn(
          count: provider.trainingPlans.length,
          itemName: 'training plan',
          itemNamePlural: 'training plans',
          icon: Icons.assignment,
          color: Colors.blue,
          filteredCount: filteredPlans.length,
          showFilteredCount: true,
        ),
        const SizedBox(height: 16),
        
        // Search and filter section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              // Search field
              Container(
                width: constraints.maxWidth > 800 ? 300 : double.infinity,
                child: OutBorderTextFormField(
                  controller: provider.searchController,
                  labelText: 'Search',
                  hintText: 'Search by year, title, description...',
                  icon: const Icon(Icons.search, size: 20),
                ),
              ),
              
              // Status filter
              Container(
                width: constraints.maxWidth > 800 ? 300 : double.infinity,
                child: DropdownButtonFormField<String>(
                  value: provider.selectedStatusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: TrainingPlanService.getStatusOptions().map((status) {
                    return DropdownMenuItem(
                      value: status['value'],
                      child: Text(status['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setSelectedStatusFilter(value);
                  },
                ),
              ),
              
              // Year filter
              Container(
                width: constraints.maxWidth > 800 ? 300 : double.infinity,
                child: DropdownButtonFormField<String>(
                  value: provider.selectedYearFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Year',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Years')),
                    ...provider.availableYears.map((year) => DropdownMenuItem<String>(
                      value: year.toString(),
                      child: Text(year.toString()),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSelectedYearFilter(value);
                  },
                ),
              ),
            ],
          ),
        ),

        // Clear filters button
        if (provider.searchQuery.isNotEmpty || provider.selectedStatusFilter != 'all' || provider.selectedYearFilter != 'all')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    provider.searchController.clear();
                    provider.setSearchQuery('');
                    provider.setSelectedStatusFilter('all');
                    provider.setSelectedYearFilter('all');
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Data table
        Container(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => GlobalColors.lightGray,
            ),
            horizontalMargin: 12,
            showBottomBorder: true,
            showCheckboxColumn: false,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 13,
            ),
            dividerThickness: 1,
            columnSpacing: 8,
            dataTextStyle: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            headingRowHeight: 50,
            columns: [
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Year',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Title',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Status',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Created By',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Created',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Actions',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
            ],
            rows: trainingPlans.map((item) => DataRow(
              onSelectChanged: (selected) {},
              cells: [
                DataCell(_buildYearCell(item)),
                DataCell(_buildTitleCell(item)),
                DataCell(_buildStatusCell(item)),
                DataCell(_buildCreatedByCell(item)),
                DataCell(_buildCreatedCell(item)),
                DataCell(_buildActionsCell(context, item)),
              ],
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pagination
        _buildPagination(provider),
      ],
    );
  }

  Widget _buildYearCell(TrainingPlan item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        item.year.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTitleCell(TrainingPlan item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCell(TrainingPlan item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 250,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: item.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          item.statusDisplay,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: item.statusColor,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCreatedByCell(TrainingPlan item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
      ),
      child: Text(
        item.creatorName,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCreatedCell(TrainingPlan item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 120,
      ),
      child: Text(
        item.createdAt != null ? _formatDate(item.createdAt!) : '-',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionsCell(BuildContext context, TrainingPlan item) {
    return GetBuilder<TrainingPlanDataProvider>(
      builder: (provider) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button
          IconButton(
            icon: const Icon(
              Icons.visibility,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'view', item);
            },
            tooltip: 'View Details',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              foregroundColor: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          
          // Edit button (Admin only, only for draft plans)
          if (provider.isAdmin && item.canBeEdited)
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 18,
              ),
              onPressed: () {
                _handleAction(context, 'edit', item);
              },
              tooltip: 'Edit Training Plan',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
              ),
            ),

          // Workflow action buttons based on role and status
          if (provider.isAdmin) ...[
            // Move to Plan Preparation (Admin only, Draft status)
            if (item.canBeMovedToPlanPreparation) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.build,
                  size: 18,
                ),
                onPressed: () {
                  _showWorkflowConfirmation(
                    context,
                    'Move to Plan Preparation',
                    'Are you sure you want to move this training plan to plan preparation?',
                    () => provider.moveToPlanPreparation(item.id!),
                  );
                },
                tooltip: 'Move to Plan Preparation',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange.shade700,
                ),
              ),
            ],
            
            // Move to General Manager Approval (Admin only, Plan Preparation status)
            if (item.canBeMovedToTrainingGeneralManagerApproval) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  size: 18,
                ),
                onPressed: () {
                  _showWorkflowConfirmation(
                    context,
                    'Move to General Manager Approval',
                    'Are you sure you want to move this training plan to general manager approval?',
                    () => provider.moveToGeneralManagerApproval(item.id!),
                  );
                },
                tooltip: 'Move to General Manager Approval',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple.shade700,
                ),
              ),
            ],
          ],

          // Move to Board Chairman Approval (General Training Director only)
          if (provider.isTrainingGeneralManager && item.canBeMovedToBoardChairmanApproval) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.groups,
                size: 18,
              ),
              onPressed: () {
                _showWorkflowConfirmation(
                  context,
                  'Move to Board Chairman Approval',
                  'Are you sure you want to move this training plan to board chairman approval?',
                  () => provider.moveToBoardChairmanApproval(item.id!),
                );
              },
              tooltip: 'Move to Board Chairman Approval',
              style: IconButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo.shade700,
              ),
            ),
          ],

          // Approve Training Plan (Board Chairman only)
          if (provider.isBoardChairman && item.canBeApproved) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                size: 18,
              ),
              onPressed: () {
                _showWorkflowConfirmation(
                  context,
                  'Approve Training Plan',
                  'Are you sure you want to approve this training plan?',
                  () => provider.approveTrainingPlan(item.id!),
                );
              },
              tooltip: 'Approve Training Plan',
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(TrainingPlanDataProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              if (constraints.maxWidth < 600) ...[
                // Mobile layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${provider.currentPage + 1} of ${provider.totalPages}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: provider.currentPage > 0
                              ? () => provider.prevPage()
                              : null,
                          tooltip: 'Previous page',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: (provider.currentPage + 1) < provider.totalPages
                              ? () => provider.nextPage()
                              : null,
                          tooltip: 'Next page',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${provider.totalItems}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    DropdownButton<int>(
                      value: provider.rowsPerPage,
                      items: const [10, 20, 50]
                          .map((n) => DropdownMenuItem<int>(
                                value: n,
                                child: Text('$n per page', style: TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) provider.setRowsPerPage(value);
                      },
                    ),
                  ],
                ),
              ] else ...[
                // Desktop layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${(provider.currentPage * provider.rowsPerPage) + 1} to ${provider.currentPage * provider.rowsPerPage + provider.pagedTrainingPlans.length} of ${provider.totalItems} entries',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          'Rows per page:',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: provider.rowsPerPage,
                          items: const [10, 20, 50]
                              .map((n) => DropdownMenuItem<int>(
                                    value: n,
                                    child: Text('$n', style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) provider.setRowsPerPage(value);
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Page ${provider.currentPage + 1} of ${provider.totalPages}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: provider.currentPage > 0
                              ? () => provider.prevPage()
                              : null,
                          tooltip: 'Previous page',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: (provider.currentPage + 1) < provider.totalPages
                              ? () => provider.nextPage()
                              : null,
                          tooltip: 'Next page',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, String action, TrainingPlan item) {
    switch (action) {
      case 'view':
        _showViewTrainingPlanDialog(context, item);
        break;
      case 'edit':
        _showEditTrainingPlanForm(context, item);
        break;
      case 'submit':
        _submitTrainingPlan(context, item);
        break;
    }
  }

  void _showViewTrainingPlanDialog(BuildContext context, TrainingPlan item) {
    ModalDialog.show(
      context: context,
      title: 'Complete Training Plan Details',
      showTitle: true,
      modalType: ModalType.large,
      showCancel: false,
      showFooter: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Expanded(
              child: ViewTrainingPlanDetailsWidget(plan: item),
            ),
            // Custom footer with only Cancel button
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    child: ButtonWidget(
                      btnText: 'Cancel',
                      textColor: FlarelineColors.darkBlackText,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _submitTrainingPlan(BuildContext context, TrainingPlan item) async {
    // Validate business rules
    final businessRuleErrors = ValidationHelper.validateBusinessRules(
      operation: 'submit',
      currentStatus: item.status,
      hasPermission: TrainingPlanService.canSubmitTrainingPlans(),
    );

    if (businessRuleErrors.isNotEmpty) {
      _showErrorToast(businessRuleErrors.values.first);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to submit the training plan "${item.title}" for year ${item.year}?'),
            const SizedBox(height: 12),
            const Text(
              'Once submitted, this training plan cannot be edited.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Row(
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Submitting Training Plan...'),
                ],
              ),
            ),
          );
        },
      );

      try {
        final response = await TrainingPlanService.submitTrainingPlan(item.id!);
        
        // Close loading dialog
        Navigator.of(context).pop();
        
        if (response.success) {
          // Refresh the data to reflect the status change
          Get.find<TrainingPlanDataProvider>().refreshData();
          _showSuccessToast('Training plan submitted successfully. It can no longer be edited.');
        } else {
          // Handle specific error cases
          String errorMessage = response.messageEn ?? 'Failed to submit training plan';
          
          if (errorMessage.contains('draft') && errorMessage.contains('only')) {
            errorMessage = 'Only draft training plans can be submitted.';
          } else if (errorMessage.contains('permission')) {
            errorMessage = 'You do not have permission to submit training plans.';
          } else if (errorMessage.contains('not found')) {
            errorMessage = 'Training plan not found.';
          }
          
          throw Exception(errorMessage);
        }
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();
        _showErrorToast(e.toString());
      }
    }
  }


  void _showAddTrainingPlanForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? selectedYear;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    // Get available years
    final availableYears = TrainingPlanService.getAvailableYears();

    ModalDialog.show(
      context: context,
      title: 'Add New Training Plan',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Training Plan Information Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Training Plan Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Year field label
                              const Text(
                                'Year *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Year Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedYear,
                                decoration: const InputDecoration(
                                  hintText: 'Select a year',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: availableYears.map((year) => DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                )).toList(),
                                validator: ValidationHelper.validateYear,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedYear = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Title field label
                              const Text(
                                'Title *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Title Field
                              OutBorderTextFormField(
                                hintText: 'Enter training plan title (max 255 characters)',
                                controller: titleController,
                                enabled: !isSubmitting,
                                validator: ValidationHelper.validateTitle,
                              ),
                              const SizedBox(height: 16),
                                
                              // Description field label
                              const Text(
                                'Description (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Description Field
                              TextFormField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter detailed description of the training plan',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                maxLines: 4,
                                enabled: !isSubmitting,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Overlay
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Creating Training Plan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we process your request',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      onSaveTap: () async {
        if (formKey.currentState!.validate()) {
          // Show loading state
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Creating Training Plan...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingPlanCreateRequest(
              year: selectedYear!,
              title: titleController.text.trim(),
              description: descriptionController.text.trim().isNotEmpty 
                  ? descriptionController.text.trim() 
                  : null,
              status: 'draft', // Default status for new training plans
            );
            
            final response = await TrainingPlanService.createTrainingPlan(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingPlanDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Training plan created successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to create training plan');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            // Handle specific validation errors
            String errorMessage = e.toString();
            if (errorMessage.contains('year already exists') || 
                errorMessage.contains('unique') ||
                errorMessage.contains('duplicate')) {
              errorMessage = 'A training plan for year $selectedYear already exists. Please choose a different year.';
            }
            
            _showErrorToast(errorMessage);
          }
        }
      },
    );
  }

  void _showEditTrainingPlanForm(BuildContext context, TrainingPlan trainingPlan) {
    // Validate business rules
    final businessRuleErrors = ValidationHelper.validateBusinessRules(
      operation: 'edit',
      currentStatus: trainingPlan.status,
      hasPermission: TrainingPlanService.hasTrainingPlanManagementPermission(),
    );

    if (businessRuleErrors.isNotEmpty) {
      _showErrorToast(businessRuleErrors.values.first);
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? selectedYear = trainingPlan.year;
    final titleController = TextEditingController(text: trainingPlan.title);
    final descriptionController = TextEditingController(text: trainingPlan.description ?? '');

    // Get available years
    final availableYears = TrainingPlanService.getAvailableYears();

    ModalDialog.show(
      context: context,
      title: 'Edit Training Plan',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Training Plan Information Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Training Plan Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Year field label
                              const Text(
                                'Year *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Year Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedYear,
                                decoration: const InputDecoration(
                                  hintText: 'Select a year',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: availableYears.map((year) => DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                )).toList(),
                                validator: ValidationHelper.validateYear,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedYear = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Title field label
                              const Text(
                                'Title *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Title Field
                              OutBorderTextFormField(
                                hintText: 'Enter training plan title (max 255 characters)',
                                controller: titleController,
                                enabled: !isSubmitting,
                                validator: ValidationHelper.validateTitle,
                              ),
                              const SizedBox(height: 16),
                                
                              // Description field label
                              const Text(
                                'Description (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Description Field
                              TextFormField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter detailed description of the training plan',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                maxLines: 4,
                                enabled: !isSubmitting,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Overlay
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Updating Training Plan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we process your request',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      onSaveTap: () async {
        if (formKey.currentState!.validate()) {
          // Show loading state
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Updating Training Plan...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingPlanUpdateRequest(
              id: trainingPlan.id!,
              year: selectedYear,
              title: titleController.text.trim(),
              description: descriptionController.text.trim().isNotEmpty 
                  ? descriptionController.text.trim() 
                  : null,
              status: trainingPlan.status, // Keep the current status
            );
            
            final response = await TrainingPlanService.updateTrainingPlan(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingPlanDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Training plan updated successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to update training plan');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            // Handle specific validation errors
            String errorMessage = e.toString();
            if (errorMessage.contains('year already exists') || 
                errorMessage.contains('unique') ||
                errorMessage.contains('duplicate')) {
              errorMessage = 'A training plan for year $selectedYear already exists. Please choose a different year.';
            }
            
            _showErrorToast(errorMessage);
          }
        }
      },
    );
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }
}

class TrainingPlanDataProvider extends GetxController {
  final _trainingPlans = <TrainingPlan>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _selectedYearFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<TrainingPlan> get trainingPlans => _trainingPlans;
  
  // Role checking methods
  bool get isAdmin => TrainingPlanService.isAdmin();
  bool get isTrainingGeneralManager => TrainingPlanService.isTrainingGeneralManager();
  bool get isBoardChairman => TrainingPlanService.isBoardChairman();
  bool get isCompanyAccount => TrainingPlanService.isCompanyAccount();
  
  // Get user role display name
  String get userRoleDisplay {
    if (isAdmin) return 'Admin';
    if (isTrainingGeneralManager) return 'General Training Director';
    if (isBoardChairman) return 'Board Chairman';
    if (isCompanyAccount) return 'Company Account';
    return 'Unknown';
  }
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get selectedYearFilter => _selectedYearFilter.value;
  String get searchQuery => _searchQuery.value;
  int get totalItems => filteredTrainingPlans.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<int> get availableYears {
    final years = _trainingPlans.map((tp) => tp.year).toSet().toList();
    years.sort();
    return years;
  }
  
  List<TrainingPlan> get filteredTrainingPlans {
    var filtered = _trainingPlans.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((tp) => tp.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by year
    if (_selectedYearFilter.value != 'all') {
      final selectedYear = int.tryParse(_selectedYearFilter.value);
      if (selectedYear != null) {
        filtered = filtered.where((tp) => tp.year == selectedYear).toList();
      }
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tp) =>
        tp.year.toString().contains(query) ||
        tp.title.toLowerCase().contains(query) ||
        (tp.description?.toLowerCase().contains(query) ?? false) ||
        tp.creatorName.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }
  
  List<TrainingPlan> get pagedTrainingPlans {
    if (totalItems == 0) return const <TrainingPlan>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedTrainingPlans;
    }
    if (end > totalItems) end = totalItems;
    return filteredTrainingPlans.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // Add listener to search controller
    searchController.addListener(() {
      setSearchQuery(searchController.text);
    });
  }

  Future<List<TrainingPlan>> loadData() async {
    try {
      _isLoading.value = true;
      
      // Load training plans based on user role
      final response = await TrainingPlanService.getTrainingPlansByUserRole();
      
      if (response.success) {
        _trainingPlans.value = response.data;
        _currentPage.value = 0; // reset page on new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _trainingPlans.clear();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      await loadData();
      update();
    } catch (e) {
      rethrow;
    }
  }

  void setRowsPerPage(int value) {
    _rowsPerPage.value = value;
    _currentPage.value = 0;
    update();
  }

  void nextPage() {
    if ((currentPage + 1) * rowsPerPage < totalItems) {
      _currentPage.value++;
      update();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      _currentPage.value--;
      update();
    }
  }

  void setSelectedStatusFilter(String value) {
    _selectedStatusFilter.value = value;
    _currentPage.value = 0;
    update();
  }

  void setSelectedYearFilter(String value) {
    _selectedYearFilter.value = value;
    _currentPage.value = 0;
    update();
  }

  void setSearchQuery(String value) {
    _searchQuery.value = value;
    _currentPage.value = 0;
    update();
  }

  // Workflow action methods
  Future<void> moveToPlanPreparation(int planId) async {
    try {
      _isLoading.value = true;
      final response = await TrainingPlanService.moveToPlanPreparation(planId);
      
      if (response.success) {
        await refreshData();
        _showSuccessToast('Training plan moved to plan preparation successfully');
      } else {
        _showErrorToast(response.messageEn ?? 'Failed to move training plan');
      }
    } catch (e) {
      _showErrorToast('Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> moveToGeneralManagerApproval(int planId) async {
    try {
      _isLoading.value = true;
      final response = await TrainingPlanService.moveToTrainingGeneralManagerApproval(planId);
      
      if (response.success) {
        await refreshData();
        _showSuccessToast('Training plan moved to general manager approval successfully');
      } else {
        _showErrorToast(response.messageEn ?? 'Failed to move training plan');
      }
    } catch (e) {
      _showErrorToast('Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> moveToBoardChairmanApproval(int planId) async {
    try {
      _isLoading.value = true;
      final response = await TrainingPlanService.moveToBoardChairmanApproval(planId);
      
      if (response.success) {
        await refreshData();
        _showSuccessToast('Training plan moved to board chairman approval successfully');
      } else {
        _showErrorToast(response.messageEn ?? 'Failed to move training plan');
      }
    } catch (e) {
      _showErrorToast('Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> approveTrainingPlan(int planId) async {
    try {
      _isLoading.value = true;
      final response = await TrainingPlanService.approveTrainingPlan(planId);
      
      if (response.success) {
        await refreshData();
        _showSuccessToast('Training plan approved successfully');
      } else {
        _showErrorToast(response.messageEn ?? 'Failed to approve training plan');
      }
    } catch (e) {
      _showErrorToast('Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Helper methods for toast notifications
  void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.success,
      title: const Text('Success'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.error,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
 

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class ViewTrainingPlanDetailsWidget extends StatefulWidget {
  final TrainingPlan plan;

  const ViewTrainingPlanDetailsWidget({super.key, required this.plan});

  @override
  State<ViewTrainingPlanDetailsWidget> createState() => _ViewTrainingPlanDetailsWidgetState();
}

class _ViewTrainingPlanDetailsWidgetState extends State<ViewTrainingPlanDetailsWidget> {
  List<pca_model.PlanCourseAssignment> _assignments = [];
  bool _isLoadingAssignments = false;

  @override
  void initState() {
    super.initState();
    // Load assignments for all roles
    _loadPlanAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Training Plan Information Section
          _buildPlanInfoSection(),

          // Course Assignments Section (visible to all roles)
          const SizedBox(height: 24),
          _buildAssignmentsSection(),
        ],
      ),
    );
  }

  Widget _buildPlanInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Training Plan Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow('Plan ID', widget.plan.id.toString()),
          _buildInfoRow('Title', widget.plan.title),
          _buildInfoRow('Year', widget.plan.year.toString()),
          _buildInfoRow('Status', widget.plan.statusDisplay),
          if (widget.plan.description != null && widget.plan.description!.isNotEmpty)
            _buildInfoRow('Description', widget.plan.description!),
          _buildInfoRow('Created By', widget.plan.creatorName),
          if (widget.plan.createdAt != null)
            _buildInfoRow('Created At', _formatDateTime(widget.plan.createdAt!)),
          if (widget.plan.updatedAt != null)
            _buildInfoRow('Updated At', _formatDateTime(widget.plan.updatedAt!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          label == 'Status' 
              ? _buildStatusHighlight(value)
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatusHighlight(String statusText) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 250,
      ),
      decoration: BoxDecoration(
        color: widget.plan.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child:  Text(
        statusText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: widget.plan.statusColor,
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection() {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Course Assignments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              if (_isLoadingAssignments)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingAssignments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_assignments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No course assignments found for this training plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildAssignmentsTable(),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTable() {
    if (_assignments.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: _getFlexibleColumnWidths(),
        border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            children: [
              _buildTableHeaderCell('Company Name'),
              _buildTableHeaderCell('Course Name'),
              _buildTableHeaderCell('Specialization'),
              _buildTableHeaderCell('Training Center Branch'),
              _buildTableHeaderCell('Start Date'),
              _buildTableHeaderCell('End Date'),
              _buildTableHeaderCell('Seats'),
            ],
          ),
          // Data rows
          ..._assignments.map((assignment) => TableRow(
            children: [
              _buildTableCell(assignment.company?.name ?? 'N/A'),
              _buildTableCell(assignment.course?.title ?? 'N/A'),
              _buildTableCell(assignment.course?.specialization?.name ?? assignment.course?.specializationName ?? 'N/A'),
              _buildTableCell(assignment.trainingCenterBranch?.name ?? 'N/A'),
              _buildTableCell(_formatDate(assignment.startDate)),
              _buildTableCell(_formatDate(assignment.endDate)),
              _buildTableCell(assignment.seats.toString()),
            ],
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Map<int, TableColumnWidth> _getFlexibleColumnWidths() {
    // Use flexible column widths that adapt to container size
    // The numbers represent relative proportions - higher numbers = more space
    return {
      0: const FlexColumnWidth(2.0), // Company Name - important, give more space
      1: const FlexColumnWidth(2.5), // Course Name - most important, give most space
      2: const FlexColumnWidth(1.5), // Specialization - moderate importance
      3: const FlexColumnWidth(2.0), // Training Center Branch - important
      4: const FlexColumnWidth(1.0), // Start Date - fixed width content
      5: const FlexColumnWidth(1.0), // End Date - fixed width content
      6: const FlexColumnWidth(0.8), // Seats - least space needed
    };
  }

  Future<void> _loadPlanAssignments() async {
    setState(() {
      _isLoadingAssignments = true;
    });

    try {
      if (widget.plan.id == null) {
        _showErrorToast('Training plan ID is not available');
        return;
      }

      final response = await PlanCourseAssignmentService.getPlanCourseAssignmentsByTrainingPlan(
        trainingPlanId: widget.plan.id!,
      );

      if (response.statusCode == 200) {
        print('✅ Successfully loaded ${response.data.length} assignments');
        print('📊 Sample assignment data:');
        if (response.data.isNotEmpty) {
          final sample = response.data.first;
          print('   Company: ${sample.company?.name}');
          print('   Course: ${sample.course?.title}');
          print('   Specialization: ${sample.course?.specialization?.name ?? sample.course?.specializationName}');
          print('   Branch: ${sample.trainingCenterBranch?.name}');
          print('   Start Date: ${sample.startDate}');
          print('   End Date: ${sample.endDate}');
          print('   Seats: ${sample.seats}');
        }
        setState(() {
          _assignments = response.data;
        });
      } else {
        _showErrorToast('Failed to load assignments: ${response.messageEn}');
      }
    } catch (e) {
      _showErrorToast('Error loading assignments: $e');
    } finally {
      setState(() {
        _isLoadingAssignments = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }


}