import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/training_plan_model.dart';
import 'package:flareline/core/services/training_plan_service.dart';
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
                child: Row(
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
                            if (TrainingPlanService.hasTrainingPlanManagementPermission()) {
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
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  if (!TrainingPlanService.hasTrainingPlanManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage training plans. Only System Administrators can access this functionality.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Obx(() {
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
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingPlansTable(BuildContext context, TrainingPlanDataProvider provider, BoxConstraints constraints) {
    final trainingPlans = provider.pagedTrainingPlans;

    return Column(
      children: [
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
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
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
        maxWidth: 100,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: item.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.statusColor.withOpacity(0.3)),
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
    return Row(
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
        
        // Edit button (only for draft or rejected plans)
        if (item.canBeEdited)
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

        const SizedBox(width: 8),

        // Submit button (only for draft or rejected plans)
        if (item.canBeSubmitted && TrainingPlanService.canSubmitTrainingPlans())
          IconButton(
            icon: const Icon(
              Icons.send,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'submit', item);
            },
            tooltip: 'Submit Training Plan',
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
            ),
          ),

        const SizedBox(width: 8),

        // Approve button (only for submitted plans)
        if (item.canBeApproved && TrainingPlanService.canApproveRejectTrainingPlans())
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'approve', item);
            },
            tooltip: 'Approve Training Plan',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade700,
            ),
          ),

        const SizedBox(width: 8),

        // Reject button (only for submitted plans)
        if (item.canBeRejected && TrainingPlanService.canApproveRejectTrainingPlans())
          IconButton(
            icon: const Icon(
              Icons.cancel,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'reject', item);
            },
            tooltip: 'Reject Training Plan',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
          ),
      ],
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
      case 'approve':
        _approveTrainingPlan(context, item);
        break;
      case 'reject':
        _rejectTrainingPlan(context, item);
        break;
    }
  }

  void _showViewTrainingPlanDialog(BuildContext context, TrainingPlan item) {
    ModalDialog.show(
      context: context,
      title: 'Training Plan Details',
      showTitle: true,
      modalType: ModalType.large,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                              Icons.visibility,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Training Plan Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Year', item.year.toString()),
                        _buildDetailRow('Title', item.title),
                        if (item.description != null && item.description!.isNotEmpty)
                          _buildDetailRow('Description', item.description!),
                        _buildDetailRow('Status', item.statusDisplay),
                        _buildDetailRow('Created By', item.creatorName),
                        if (item.createdAt != null)
                          _buildDetailRow('Created At', _formatDateTime(item.createdAt!)),
                        if (item.updatedAt != null)
                          _buildDetailRow('Updated At', _formatDateTime(item.updatedAt!)),
                      ],
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Text('Are you sure you want to submit the training plan "${item.title}" for year ${item.year}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await TrainingPlanService.submitTrainingPlan(item.id!);
        if (response.success) {
          Get.find<TrainingPlanDataProvider>().refreshData();
          _showSuccessToast('Training plan submitted successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _approveTrainingPlan(BuildContext context, TrainingPlan item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve the training plan "${item.title}" for year ${item.year}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await TrainingPlanService.approveTrainingPlan(item.id!);
        if (response.success) {
          Get.find<TrainingPlanDataProvider>().refreshData();
          _showSuccessToast('Training plan approved successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _rejectTrainingPlan(BuildContext context, TrainingPlan item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: Text('Are you sure you want to reject the training plan "${item.title}" for year ${item.year}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await TrainingPlanService.rejectTrainingPlan(item.id!);
        if (response.success) {
          Get.find<TrainingPlanDataProvider>().refreshData();
          _showSuccessToast('Training plan rejected successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _showAddTrainingPlanForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? selectedYear;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedStatus = 'draft';

    // Get available years
    final availableYears = TrainingPlanService.getAvailableYears();
    final statusOptions = TrainingPlanService.getStatusOptions();

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
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a year';
                                  }
                                  return null;
                                },
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Title must be less than 255 characters';
                                  }
                                  return null;
                                },
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
                              const SizedBox(height: 16),
                              
                              // Status field label
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Status Dropdown
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                decoration: const InputDecoration(
                                  hintText: 'Select status',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: statusOptions.map((status) => DropdownMenuItem<String>(
                                  value: status['value'],
                                  child: Text(status['label']!),
                                )).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedStatus = value;
                                  });
                                },
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
              status: selectedStatus,
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
    final formKey = GlobalKey<FormState>();
    int? selectedYear = trainingPlan.year;
    final titleController = TextEditingController(text: trainingPlan.title);
    final descriptionController = TextEditingController(text: trainingPlan.description ?? '');
    String? selectedStatus = trainingPlan.status;

    // Get available years
    final availableYears = TrainingPlanService.getAvailableYears();
    final statusOptions = TrainingPlanService.getStatusOptions();

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
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a year';
                                  }
                                  return null;
                                },
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Title must be less than 255 characters';
                                  }
                                  return null;
                                },
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
                              const SizedBox(height: 16),
                              
                              // Status field label
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Status Dropdown
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                decoration: const InputDecoration(
                                  hintText: 'Select status',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: statusOptions.map((status) => DropdownMenuItem<String>(
                                  value: status['value'],
                                  child: Text(status['label']!),
                                )).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedStatus = value;
                                  });
                                },
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
              status: selectedStatus,
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
      
      // Load training plans
      final response = await TrainingPlanService.getAllTrainingPlans();
      
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

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}