import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/training_need_model.dart';
import 'package:flareline/core/services/training_need_service.dart';
import 'package:flareline/core/models/company_model.dart' as company_model;
import 'package:flareline/core/services/company_service.dart';
import 'package:flareline/core/models/specialization_model.dart' as specialization_model;
import 'package:flareline/core/services/specialization_service.dart';
import 'package:flareline/core/models/course_model.dart' as course_model;
import 'package:flareline/core/services/course_service.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer

class TrainingNeedManagementPage extends LayoutWidget {
  const TrainingNeedManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Training Need Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainingNeedManagementWidget(),
      ],
    );
  }
}

class TrainingNeedManagementWidget extends StatefulWidget {
  const TrainingNeedManagementWidget({super.key});

  @override
  State<TrainingNeedManagementWidget> createState() => _TrainingNeedManagementWidgetState();
}

class _TrainingNeedManagementWidgetState extends State<TrainingNeedManagementWidget> {

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TrainingNeedDataProvider>(
          init: TrainingNeedDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, TrainingNeedDataProvider provider) {
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
                            'Training Need Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage training needs and their information',
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
                                _showSuccessToast('Training needs data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات احتياجات التدريب: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (TrainingNeedService.hasTrainingNeedManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Training Need',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddTrainingNeedForm(context);
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
                  if (!TrainingNeedService.hasTrainingNeedManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage training needs. Only System Administrators and Company Accounts can access this functionality.',
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

                    final trainingNeeds = provider.trainingNeeds;

                    if (trainingNeeds.isEmpty) {
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
                              'No Training Needs Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding the first training need to the system.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ButtonWidget(
                              btnText: 'Add First Training Need',
                              type: 'primary',
                              onTap: () => _showAddTrainingNeedForm(context),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildTrainingNeedsTable(context, provider, constraints);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingNeedsTable(BuildContext context, TrainingNeedDataProvider provider, BoxConstraints constraints) {
    final trainingNeeds = provider.pagedTrainingNeeds;

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
                  hintText: 'Search by company name, course title...',
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
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSelectedStatusFilter(value);
                  },
                ),
              ),
              
              // Company filter
              Container(
                width: constraints.maxWidth > 800 ? 300 : double.infinity,
                child: DropdownButtonFormField<String>(
                  value: provider.selectedCompanyFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Company',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Companies')),
                    ...provider.companies.map((company) => DropdownMenuItem<String>(
                      value: company.id.toString(),
                      child: Text(company.name),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSelectedCompanyFilter(value);
                  },
                ),
              ),
            ],
          ),
        ),

        // Clear filters button
        if (provider.searchQuery.isNotEmpty || provider.selectedStatusFilter != 'all' || provider.selectedCompanyFilter != 'all')
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
                    provider.setSelectedCompanyFilter('all');
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
                    'Company',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Course',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: false,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Participants',
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
            rows: trainingNeeds.map((item) => DataRow(
              onSelectChanged: (selected) {},
              cells: [
                DataCell(_buildCompanyCell(item)),
                DataCell(_buildCourseCell(item)),
                DataCell(_buildParticipantsCell(item)),
                DataCell(_buildStatusCell(item)),
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



  Widget _buildCompanyCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 180,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.companyName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.company?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              item.company!.email!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 180,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.courseName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.course?.specialization?.name != null) ...[
            const SizedBox(height: 4),
            Text(
              item.course!.specialization!.name,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantsCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 100,
      ),
      child: Text(
        '${item.numberOfParticipants}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatusCell(TrainingNeed item) {
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

  Widget _buildCreatedCell(TrainingNeed item) {
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



  Widget _buildActionsCell(BuildContext context, TrainingNeed item) {
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
        const SizedBox(width: 10,),
        // Edit button (only for pending training needs)
        if (item.isPending)
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'edit', item);
            },
            tooltip: 'Edit Training Need',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
            ),
          ),

        const SizedBox(width: 10,),

        // Approve button (only for pending training needs and users with permission)
        if (item.isPending && TrainingNeedService.canApproveRejectTrainingNeeds())
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'approve', item);
            },
            tooltip: 'Approve Training Need',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade700,
            ),
          ),

        const SizedBox(width: 10,),

        // Reject button (only for pending training needs and users with permission)
        if (item.isPending && TrainingNeedService.canApproveRejectTrainingNeeds())
          IconButton(
            icon: const Icon(
              Icons.cancel,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'reject', item);
            },
            tooltip: 'Reject Training Need',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
          ),
      ],
    );
  }

  Widget _buildPagination(TrainingNeedDataProvider provider) {
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
                      'Showing ${(provider.currentPage * provider.rowsPerPage) + 1} to ${provider.currentPage * provider.rowsPerPage + provider.pagedTrainingNeeds.length} of ${provider.totalItems} entries',
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

  void _handleAction(BuildContext context, String action, TrainingNeed item) {
    switch (action) {
      case 'view':
        _showViewTrainingNeedDialog(context, item);
        break;
      case 'edit':
        _showEditTrainingNeedForm(context, item);
        break;
      case 'approve':
        _approveTrainingNeed(context, item);
        break;
      case 'reject':
        _rejectTrainingNeed(context, item);
        break;
    }
  }

  void _showViewTrainingNeedDialog(BuildContext context, TrainingNeed item) {
    ModalDialog.show(
      context: context,
      title: 'Training Need Details',
      showTitle: true,
      modalType: ModalType.medium,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Company', item.companyName),
                    if (item.company?.email != null)
                      _buildDetailRow('Company Email', item.company!.email!),
                    if (item.company?.phone != null)
                      _buildDetailRow('Company Phone', item.company!.phone!),
                    _buildDetailRow('Course', item.courseName),
                    if (item.course?.description != null)
                      _buildDetailRow('Course Description', item.course!.description!),
                    if (item.course?.specialization?.name != null)
                      _buildDetailRow('Specialization', item.course!.specialization!.name),
                    _buildDetailRow('Number of Participants', '${item.numberOfParticipants}'),
                    _buildDetailRow('Status', item.statusDisplay),
                    if (item.createdAt != null)
                      _buildDetailRow('Created At', _formatDateTime(item.createdAt!)),
                    if (item.updatedAt != null)
                      _buildDetailRow('Updated At', _formatDateTime(item.updatedAt!)),
                  ],
                ),
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

  void _approveTrainingNeed(BuildContext context, TrainingNeed item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve the training need for ${item.companyName}?'),
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
        final response = await TrainingNeedService.approveTrainingNeed(item.id!);
        if (response.success) {
          Get.find<TrainingNeedDataProvider>().refreshData();
          _showSuccessToast('Training need approved successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _rejectTrainingNeed(BuildContext context, TrainingNeed item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: Text('Are you sure you want to reject the training need for ${item.companyName}?'),
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
        final response = await TrainingNeedService.rejectTrainingNeed(item.id!);
        if (response.success) {
          Get.find<TrainingNeedDataProvider>().refreshData();
          _showSuccessToast('Training need rejected successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _showAddTrainingNeedForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? selectedCompanyId;
    int? selectedSpecializationId;
    int? selectedCourseId;
    final numberOfParticipantsController = TextEditingController();

    // Data for dropdowns
    List<company_model.Company> companies = [];
    List<specialization_model.Specialization> specializations = [];
    List<course_model.Course> courses = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'Add New Training Need',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          // Load dropdown data on first build
          if (isLoadingDropdownData) {
            isLoadingDropdownData = false;
            _loadDropdownData(context).then((data) {
              setModalState(() {
                companies = (data['companies'] as List<dynamic>?)?.cast<company_model.Company>() ?? [];
                specializations = (data['specializations'] as List<dynamic>?)?.cast<specialization_model.Specialization>() ?? [];
              });
            });
          }
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Training Need Information Section
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
                                    'Training Need Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Company field label
                              const Text(
                                'Company *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Company Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedCompanyId,
                                decoration: const InputDecoration(
                                  hintText: 'Select a company',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: companies.map((company) => DropdownMenuItem<int>(
                                  value: company.id,
                                  child: Text(company.name),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a company';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedCompanyId = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Specialization field label
                              const Text(
                                'Specialization *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Specialization Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedSpecializationId,
                                decoration: const InputDecoration(
                                  hintText: 'Select a specialization',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: specializations.map((specialization) => DropdownMenuItem<int>(
                                  value: specialization.id,
                                  child: Text(specialization.name),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a specialization';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  setModalState(() {
                                    selectedSpecializationId = value;
                                    selectedCourseId = null; // Reset course when specialization changes
                                    courses = []; // Clear courses
                                  });

                                  if (value != null) {
                                    // Load courses for selected specialization
                                    try {
                                      final loadedCourses = await CourseService.getCoursesBySpecialization(context, value);
                                                            setModalState(() {
                        courses = loadedCourses.cast<course_model.Course>();
                      });
                                    } catch (e) {
                                      print('Error loading courses: $e');
                                    }
                                  }
                                },
                              ),
                                                             const SizedBox(height: 16),
                                
                               // Course field label
                               const Text(
                                 'Course *',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               
                               // Course Dropdown
                               DropdownButtonFormField<int>(
                                 value: selectedCourseId,
                                 decoration: const InputDecoration(
                                   hintText: 'Select a course',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                items: courses.map((course) => DropdownMenuItem<int>(
                                  value: course.id,
                                  child: Text(course.title),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a course';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedCourseId = value;
                                  });
                                },
                              ),
                                                             const SizedBox(height: 16),
                                
                               // Number of Participants field label
                               const Text(
                                 'Number of Participants *',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               
                               // Number of Participants Field
                               OutBorderTextFormField(
                                 hintText: 'Enter number (1-1000)',
                                controller: numberOfParticipantsController,
                                enabled: !isSubmitting,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter number of participants';
                                  }
                                  final number = int.tryParse(value.trim());
                                  if (number == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (number < 1 || number > 1000) {
                                    return 'Number must be between 1 and 1000';
                                  }
                                  return null;
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
                                'Creating Training Need...',
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
                      const Text('Creating Training Need...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingNeedCreateRequest(
              companyId: selectedCompanyId!,
              courseId: selectedCourseId!,
              numberOfParticipants: int.parse(numberOfParticipantsController.text.trim()),
            );
            
            final response = await TrainingNeedService.createTrainingNeed(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingNeedDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Training need created successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to create training need');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showEditTrainingNeedForm(BuildContext context, TrainingNeed trainingNeed) {
    final formKey = GlobalKey<FormState>();
    int? selectedCompanyId = trainingNeed.companyId;
    int? selectedSpecializationId = trainingNeed.course?.specializationId;
    int? selectedCourseId = trainingNeed.courseId;
    final numberOfParticipantsController = TextEditingController(text: trainingNeed.numberOfParticipants.toString());

    // Data for dropdowns
    List<company_model.Company> companies = [];
    List<specialization_model.Specialization> specializations = [];
    List<course_model.Course> courses = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'Edit Training Need',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          // Load dropdown data on first build
          if (isLoadingDropdownData) {
            isLoadingDropdownData = false;
            _loadDropdownData(context).then((data) async {
              setModalState(() {
                companies = (data['companies'] as List<dynamic>?)?.cast<company_model.Company>() ?? [];
                specializations = (data['specializations'] as List<dynamic>?)?.cast<specialization_model.Specialization>() ?? [];
              });

              // Load courses for the current specialization
              if (selectedSpecializationId != null) {
                try {
                  final loadedCourses = await CourseService.getCoursesBySpecialization(context, selectedSpecializationId!);
                                        setModalState(() {
                        courses = loadedCourses.cast<course_model.Course>();
                      });
                } catch (e) {
                  print('Error loading courses for edit: $e');
                }
              }
            });
          }
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Training Need Information Section
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
                                    'Training Need Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Company field label
                              const Text(
                                'Company *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Company Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedCompanyId,
                                decoration: const InputDecoration(
                                  hintText: 'Select a company',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: companies.map((company) => DropdownMenuItem<int>(
                                  value: company.id,
                                  child: Text(company.name),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a company';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedCompanyId = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Specialization field label
                              const Text(
                                'Specialization *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Specialization Dropdown
                              DropdownButtonFormField<int>(
                                value: selectedSpecializationId,
                                decoration: const InputDecoration(
                                  hintText: 'Select a specialization',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: specializations.map((specialization) => DropdownMenuItem<int>(
                                  value: specialization.id,
                                  child: Text(specialization.name),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a specialization';
                                  }
                                  return null;
                                },
                                onChanged: (value) async {
                                  setModalState(() {
                                    selectedSpecializationId = value;
                                    selectedCourseId = null; // Reset course when specialization changes
                                    courses = []; // Clear courses
                                  });

                                  if (value != null) {
                                    // Load courses for selected specialization
                                    try {
                                      final loadedCourses = await CourseService.getCoursesBySpecialization(context, value);
                                                            setModalState(() {
                        courses = loadedCourses.cast<course_model.Course>();
                      });
                                    } catch (e) {
                                      print('Error loading courses: $e');
                                    }
                                  }
                                },
                              ),
                                                             const SizedBox(height: 16),
                                
                               // Course field label
                               const Text(
                                 'Course *',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               
                               // Course Dropdown
                               DropdownButtonFormField<int>(
                                 value: selectedCourseId,
                                 decoration: const InputDecoration(
                                   hintText: 'Select a course',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                items: courses.map((course) => DropdownMenuItem<int>(
                                  value: course.id,
                                  child: Text(course.title),
                                )).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a course';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedCourseId = value;
                                  });
                                },
                              ),
                                                             const SizedBox(height: 16),
                                
                               // Number of Participants field label
                               const Text(
                                 'Number of Participants *',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               
                               // Number of Participants Field
                               OutBorderTextFormField(
                                 hintText: 'Enter number (1-1000)',
                                controller: numberOfParticipantsController,
                                enabled: !isSubmitting,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.toString().trim().isEmpty) {
                                    return 'Please enter number of participants';
                                  }
                                  final number = int.tryParse(value.toString().trim());
                                  if (number == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (number < 1 || number > 1000) {
                                    return 'Number must be between 1 and 1000';
                                  }
                                  return null;
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
                                'Updating Training Need...',
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
                      const Text('Updating Training Need...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingNeedUpdateRequest(
              id: trainingNeed.id!,
              companyId: selectedCompanyId,
              courseId: selectedCourseId,
              numberOfParticipants: int.parse(numberOfParticipantsController.text.trim()),
            );
            
            final response = await TrainingNeedService.updateTrainingNeed(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingNeedDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Training need updated successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to update training need');
            }
          } catch (e) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  // Load dropdown data for forms
  Future<Map<String, List<dynamic>>> _loadDropdownData(BuildContext context) async {
    try {
      final companiesResponse = await CompanyService.getAllCompanies();
      final specializations = await SpecializationService.getSpecializations(context);
      
      return {
        'companies': companiesResponse.success ? companiesResponse.data : <company_model.Company>[],
        'specializations': specializations,
      };
    } catch (e) {
      print('Error loading dropdown data: $e');
      return {
        'companies': <company_model.Company>[],
        'specializations': <specialization_model.Specialization>[],
      };
    }
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

class TrainingNeedDataProvider extends GetxController {
  final _trainingNeeds = <TrainingNeed>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _selectedCompanyFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  final _companies = <company_model.Company>[].obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<TrainingNeed> get trainingNeeds => _trainingNeeds;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get selectedCompanyFilter => _selectedCompanyFilter.value;
  String get searchQuery => _searchQuery.value;
  List<company_model.Company> get companies => _companies;
  int get totalItems => filteredTrainingNeeds.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<TrainingNeed> get filteredTrainingNeeds {
    var filtered = _trainingNeeds.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((tn) => tn.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by company
    if (_selectedCompanyFilter.value != 'all') {
      filtered = filtered.where((tn) => tn.companyId.toString() == _selectedCompanyFilter.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tn) =>
        tn.companyName.toLowerCase().contains(query) ||
        tn.courseName.toLowerCase().contains(query) ||
        (tn.company?.email?.toLowerCase().contains(query) ?? false) ||
        (tn.course?.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  }
  
  List<TrainingNeed> get pagedTrainingNeeds {
    if (totalItems == 0) return const <TrainingNeed>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedTrainingNeeds;
    }
    if (end > totalItems) end = totalItems;
    return filteredTrainingNeeds.sublist(start, end);
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

  Future<List<TrainingNeed>> loadData() async {
    try {
      _isLoading.value = true;
      
      // Load training needs
      final response = await TrainingNeedService.getAllTrainingNeeds();
      
      // Load companies for filter
      try {
        final companiesResponse = await CompanyService.getAllCompanies();
        if (companiesResponse.success) {
          _companies.value = companiesResponse.data;
        }
      } catch (e) {
        print('Error loading companies for filter: $e');
        // Don't fail the whole operation if companies can't be loaded
      }
      
      if (response.success) {
        _trainingNeeds.value = response.data;
        _currentPage.value = 0; // reset page on new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _trainingNeeds.clear();
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

  void setSelectedCompanyFilter(String value) {
    _selectedCompanyFilter.value = value;
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
