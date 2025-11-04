import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
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
import 'package:flareline/components/small_refresh_button.dart';
import 'package:toastification/toastification.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/core/services/auth_service.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer
import 'package:flareline/core/i18n/strings_ar.dart';
import 'package:flareline/core/ui/notification_service.dart';

class TrainingNeedManagementPage extends LayoutWidget {
  const TrainingNeedManagementPage({super.key});


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
                        Obx(() => SmallRefreshButton(
                          isLoading: provider.isLoading,
                          onTap: () async {
                            try {
                              await provider.refreshData();
                              _showSuccessToast('Training needs data refreshed successfully');
                            } catch (e) {
                              _showErrorToast('خطأ في تحديث بيانات احتياجات التدريب: ${e.toString()}');
                            }
                          },
                        )),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (TrainingNeedService.canAddTrainingNeeds()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'إضافة احتياج تدريبي',
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
                          'You do not have permission to manage training needs. Only Administrators, Company Employees, and System Administrators can access this functionality.',
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
                              TrainingNeedService.canAddTrainingNeeds() 
                                ? 'Get started by adding the first training need to the system.'
                                : 'There are no training needs to display at the moment.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Only show add button if user has permission to add training needs
                            if (TrainingNeedService.canAddTrainingNeeds()) ...[
                              const SizedBox(height: 24),
                              ButtonWidget(
                                btnText: 'Add First Training Need',
                                type: 'primary',
                                onTap: () => _showAddTrainingNeedForm(context),
                              ),
                            ],
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
    final filteredNeeds = provider.filteredTrainingNeeds;

    return Column(
      children: [
        // Training Needs count and summary
        CountSummaryWidgetEn(
          count: provider.trainingNeeds.length,
          itemName: 'training need',
          itemNamePlural: 'training needs',
          icon: Icons.psychology,
          color: Colors.orange,
          filteredCount: filteredNeeds.length,
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
                    DropdownMenuItem(value: 'all_statuses', child: Text('All Statuses')),
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
                child: Builder(
                  builder: (context) {
                    final items = provider.companyFilterDropdownItems;
                    final validatedValue = provider._validateDropdownValue(
                      provider.selectedCompanyFilter, 
                      items
                    );
                    
                    // Update the selected value if it was invalid
                    if (validatedValue != provider.selectedCompanyFilter) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setSelectedCompanyFilter(validatedValue);
                      });
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: validatedValue,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Company',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: items,
                      onChanged: (value) {
                        if (value != null) provider.setSelectedCompanyFilter(value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Clear filters button
        if (provider.searchQuery.isNotEmpty || provider.selectedStatusFilter != 'all_statuses' || provider.selectedCompanyFilter != 'filter_all_companies')
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
                    provider.setSelectedStatusFilter('all_statuses');
                    provider.setSelectedCompanyFilter('filter_all_companies');
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
                    'Individual',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Management',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Job',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Department',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Total',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
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
                DataCell(_buildIndividualNeedCell(item)),
                DataCell(_buildManagementNeedCell(item)),
                DataCell(_buildJobNeedCell(item)),
                DataCell(_buildDepartmentNeedCell(item)),
                DataCell(_buildParticipantsCell(item)),
                DataCell(_buildStatusCell(item)),
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

  Widget _buildIndividualNeedCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        '${item.individualNeed}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildManagementNeedCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        '${item.managementNeed}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildJobNeedCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        '${item.jobNeed}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDepartmentNeedCell(TrainingNeed item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        '${item.departmentNeed}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
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
        
        // Forward button (only for draft training needs and company accounts)
        if (item.isDraft && TrainingNeedService.canForwardTrainingNeeds())
          IconButton(
            icon: const Icon(
              Icons.send,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'forward', item);
            },
            tooltip: 'Forward to Pending',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
            ),
          ),
        
        if (item.isDraft && TrainingNeedService.canForwardTrainingNeeds())
          const SizedBox(width: 10,),
        
        // Edit button (only for draft training needs and users with update permission)
        if (item.isDraft && TrainingNeedService.canUpdateTrainingNeeds())
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'edit', item);
            },
            tooltip: 'تعديل الاحتياج التدريبي',
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
      case 'forward':
        _forwardTrainingNeed(context, item);
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
      title: 'تفاصيل الاحتياج التدريبي',
      showTitle: true,
      modalType: ModalType.large,
      showCancel: false, // Disable default buttons
      footer: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            const Spacer(),
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
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                              Icons.visibility,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Training Need Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Training Need ID', item.id?.toString() ?? 'Not available'),
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
                        _buildDetailRow('Individual Need', '${item.individualNeed}'),
                        _buildDetailRow('Management Need', '${item.managementNeed}'),
                        _buildDetailRow('Job Need', '${item.jobNeed}'),
                        _buildDetailRow('Department Need', '${item.departmentNeed}'),
                        _buildDetailRow('Total Number of Participants', '${item.numberOfParticipants}'),
                        _buildStatusDetailRow(item),
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

  Widget _buildStatusDetailRow(TrainingNeed item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: item.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              item.statusDisplay,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: item.statusColor,
              ),
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
        title: const Text('تأكيد الموافقة'),
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
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الاحتياج التدريبي'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to reject the training need for ${item.companyName}?'),
              const SizedBox(height: 16),
              const Text(
                'Rejection Reason *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Please provide a reason for rejection...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rejection reason is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Rejection reason must be at least 10 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop({
                  'confirmed': true,
                  'reason': reasonController.text.trim(),
                });
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result != null && result['confirmed'] == true) {
      try {
        final reason = result['reason'] as String;
        print('🚫 REJECTING TRAINING NEED');
        print('==========================================');
        print('🆔 Training Need ID: ${item.id}');
        print('🏢 Company: ${item.companyName}');
        print('📋 Course: ${item.courseName}');
        print('📊 Participants: ${item.numberOfParticipants}');
        print('📅 Current Status: ${item.status}');
        print('❌ Rejection Reason: $reason');
        print('==========================================');

        final response = await TrainingNeedService.rejectTrainingNeed(item.id!, reason);
        
        print('📊 REJECTION UI - Response received');
        print('✅ Success: ${response.success}');
        print('📝 Message (EN): ${response.messageEn}');
        print('📝 Message (AR): ${response.messageAr}');
        print('📊 Status Code: ${response.statusCode}');
        print('🆔 Training Need ID: ${response.data?.id}');
        
        if (response.success) {
          print('✅ REJECTION UI - Success, refreshing data');
          Get.find<TrainingNeedDataProvider>().refreshData();
          _showSuccessToast('Training need rejected successfully');
        } else {
          print('❌ REJECTION UI - Server returned error');
          print('❌ REJECTION UI - Error message: ${response.messageEn}');
          print('❌ REJECTION UI - Status code: ${response.statusCode}');
          throw Exception(response.messageEn ?? 'Failed to reject training need');
        }
      } catch (e) {
        print('❌ REJECTION UI - Exception caught');
        print('❌ REJECTION UI - Exception type: ${e.runtimeType}');
        print('❌ REJECTION UI - Exception message: ${e.toString()}');
        print('❌ REJECTION UI - Stack trace: ${StackTrace.current}');
        _showErrorToast(e.toString());
      }
    }
  }

  void _forwardTrainingNeed(BuildContext context, TrainingNeed item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إعادة التوجيه'),
        content: Text('Are you sure you want to forward the training need for ${item.companyName} from Draft to Pending?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Forward'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        print('📤 FORWARDING TRAINING NEED');
        print('==========================================');
        print('🆔 Training Need ID: ${item.id}');
        print('🏢 Company: ${item.companyName}');
        print('📋 Course: ${item.courseName}');
        print('📊 Participants: ${item.numberOfParticipants}');
        print('📅 Current Status: ${item.status}');
        print('==========================================');

        final response = await TrainingNeedService.forwardTrainingNeed(item.id!);
        
        // Close loading dialog
        Navigator.of(context).pop();

        if (response.success) {
          _showSuccessToast('Training need forwarded successfully');
          // Refresh the data
          final provider = Get.find<TrainingNeedDataProvider>();
          await provider.loadData();
        } else {
          _showErrorToast(response.messageEn ?? 'Failed to forward training need');
        }
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();
        print('❌ Error forwarding training need: $e');
        _showErrorToast(e.toString());
      }
    }
  }

  void _calculateTotalParticipants(
    TextEditingController individualController,
    TextEditingController managementController,
    TextEditingController jobController,
    TextEditingController departmentController,
    TextEditingController totalController,
  ) {
    final individual = int.tryParse(individualController.text) ?? 0;
    final management = int.tryParse(managementController.text) ?? 0;
    final job = int.tryParse(jobController.text) ?? 0;
    final department = int.tryParse(departmentController.text) ?? 0;
    
    final total = individual + management + job + department;
    totalController.text = total.toString();
  }

  void _showAddTrainingNeedForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    
    // Initialize with user's company if they are a company user
    final currentUser = AuthService.getCurrentUser();
    int? selectedCompanyId;
    
    // If user is company account, automatically set their company
    if (AuthService.hasRole('company_account') && currentUser?.companyId != null) {
      selectedCompanyId = currentUser!.companyId;
    }
    
    int? selectedSpecializationId;
    int? selectedCourseId;
    final individualNeedController = TextEditingController();
    final managementNeedController = TextEditingController();
    final jobNeedController = TextEditingController();
    final departmentNeedController = TextEditingController();
    final numberOfParticipantsController = TextEditingController();

    // Data for dropdowns
    List<company_model.Company> companies = [];
    List<specialization_model.Specialization> specializations = [];
    List<course_model.Course> courses = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'إضافة احتياج تدريبي جديد',
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
                               
                              // Company field - show for System Administrators and Admins
                              if (AuthService.isSystemAdministrator() || AuthService.hasRole('admin')) ...[
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
                              ],
                               
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
                                      List<course_model.Course> loadedCourses;
                                      if (AuthService.hasRole('company_account')) {
                                        loadedCourses = await CourseService.getCoursesBySpecializationForCompanyAccount(context, value);
                                      } else {
                                        loadedCourses = await CourseService.getCoursesBySpecialization(context, value);
                                      }
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
                                
                               // Training Need Fields Section
                               const Text(
                                 'Training Need Details *',
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 16),
                               
                               // Individual Need field
                               const Text(
                                 'Individual Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: individualNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter individual need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter individual need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Management Need field
                               const Text(
                                 'Management Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: managementNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter management need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter management need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Job Need field
                               const Text(
                                 'Job Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: jobNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter job need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter job need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Department Need field
                               const Text(
                                 'Department Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: departmentNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter department need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter department need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Number of Participants (calculated) field
                               const Text(
                                 'Total Number of Participants (Calculated)',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: numberOfParticipantsController,
                                 enabled: false, // Read-only
                                 keyboardType: TextInputType.number,
                                 decoration: InputDecoration(
                                   hintText: 'Auto-calculated',
                                   border: const OutlineInputBorder(),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                   filled: true,
                                   fillColor: Colors.grey.shade100,
                                 ),
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
            // Validate company access for Company Accounts
            if (AuthService.hasRole('company_account')) {
              final currentUser = AuthService.getCurrentUser();
              if (currentUser?.companyId != null && selectedCompanyId != currentUser!.companyId) {
                Navigator.of(context).pop(); // Close loading dialog
                _showErrorToast('You can only create training needs for your own company');
                return;
              }
            }
            
            final request = TrainingNeedCreateRequest(
              companyId: selectedCompanyId!,
              courseId: selectedCourseId!,
              specializationId: selectedSpecializationId!,
              individualNeed: int.parse(individualNeedController.text.trim()),
              managementNeed: int.parse(managementNeedController.text.trim()),
              jobNeed: int.parse(jobNeedController.text.trim()),
              departmentNeed: int.parse(departmentNeedController.text.trim()),
              numberOfParticipants: int.parse(numberOfParticipantsController.text.trim()),
            );
            
            // Log the payload for debugging
            print('🚀 TRAINING NEED CREATE - Payload Logging');
            print('==========================================');
            print('📋 Request Details:');
            print('  • Company ID: ${request.companyId}');
            print('  • Course ID: ${request.courseId}');
            print('  • Specialization ID: ${request.specializationId}');
            print('  • Individual Need: ${request.individualNeed}');
            print('  • Management Need: ${request.managementNeed}');
            print('  • Job Need: ${request.jobNeed}');
            print('  • Department Need: ${request.departmentNeed}');
            print('  • Number of Participants: ${request.numberOfParticipants}');
            print('');
            print('👤 User Information:');
            final currentUser = AuthService.getCurrentUser();
            print('  • User ID: ${currentUser?.id}');
            print('  • User Email: ${currentUser?.email}');
            print('  • User Roles: ${currentUser?.roles.map((r) => r.name).join(', ')}');
            print('  • User Company ID: ${currentUser?.companyId}');
            print('');
            print('📊 Form Data:');
            print('  • Selected Company ID: $selectedCompanyId');
            print('  • Selected Specialization ID: $selectedSpecializationId');
            print('  • Selected Course ID: $selectedCourseId');
            print('  • Number of Participants (Raw): ${numberOfParticipantsController.text.trim()}');
            print('');
            print('🔍 Request JSON:');
            print('  ${request.toJson()}');
            print('==========================================');
            
            final response = await TrainingNeedService.createTrainingNeed(request);
            
            // Log the response for debugging
            print('📡 TRAINING NEED CREATE - Response Logging');
            print('==========================================');
            print('✅ Response Details:');
            print('  • Success: ${response.success}');
            print('  • Message (EN): ${response.messageEn}');
            print('  • Message (AR): ${response.messageAr}');
            print('  • Training Need ID: ${response.data?.id}');
            print('  • Created At: ${response.data?.createdAt}');
            print('  • Status: ${response.data?.status}');
            print('==========================================');
            
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
            // Log the error for debugging
            print('❌ TRAINING NEED CREATE - Error Logging');
            print('==========================================');
            print('🚨 Error Details:');
            print('  • Error Type: ${e.runtimeType}');
            print('  • Error Message: ${e.toString()}');
            print('  • Stack Trace: ${StackTrace.current}');
            print('==========================================');
            
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
    
    // Only allow editing of Draft training needs
    if (!trainingNeed.isDraft) {
      _showErrorToast('Only Draft training needs can be edited');
      return;
    }
    
    // For company accounts, ensure they can only edit their own company's training needs
    final currentUser = AuthService.getCurrentUser();
    if (AuthService.hasRole('company_account') && currentUser?.companyId != null) {
      if (trainingNeed.companyId != currentUser!.companyId) {
        _showErrorToast('You can only edit training needs for your own company');
        return;
      }
    }
    
    int? selectedCompanyId = trainingNeed.companyId;
    int? selectedSpecializationId = trainingNeed.course?.specializationId;
    int? selectedCourseId = trainingNeed.courseId;
    final individualNeedController = TextEditingController(text: trainingNeed.individualNeed.toString());
    final managementNeedController = TextEditingController(text: trainingNeed.managementNeed.toString());
    final jobNeedController = TextEditingController(text: trainingNeed.jobNeed.toString());
    final departmentNeedController = TextEditingController(text: trainingNeed.departmentNeed.toString());
    final numberOfParticipantsController = TextEditingController(text: trainingNeed.numberOfParticipants.toString());

    // Data for dropdowns
    List<company_model.Company> companies = [];
    List<specialization_model.Specialization> specializations = [];
    List<course_model.Course> courses = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'تعديل الاحتياج التدريبي',
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

              // Load courses for the current specialization based on user role
              if (selectedSpecializationId != null) {
                try {
                  List<course_model.Course> loadedCourses;
                  if (AuthService.hasRole('company_account')) {
                    loadedCourses = await CourseService.getCoursesBySpecializationForCompanyAccount(context, selectedSpecializationId!);
                  } else {
                    loadedCourses = await CourseService.getCoursesBySpecialization(context, selectedSpecializationId!);
                  }
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
                               
                              // Company field - show for System Administrators and Admins
                              if (AuthService.isSystemAdministrator() || AuthService.hasRole('admin')) ...[
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
                              ],
                               
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
                                      List<course_model.Course> loadedCourses;
                                      if (AuthService.hasRole('company_account')) {
                                        loadedCourses = await CourseService.getCoursesBySpecializationForCompanyAccount(context, value);
                                      } else {
                                        loadedCourses = await CourseService.getCoursesBySpecialization(context, value);
                                      }
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
                                
                               // Training Need Fields Section
                               const Text(
                                 'Training Need Details *',
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 16),
                               
                               // Individual Need field
                               const Text(
                                 'Individual Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: individualNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter individual need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter individual need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Management Need field
                               const Text(
                                 'Management Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: managementNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter management need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter management need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Job Need field
                               const Text(
                                 'Job Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: jobNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter job need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter job need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Department Need field
                               const Text(
                                 'Department Need',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: departmentNeedController,
                                 enabled: !isSubmitting,
                                 keyboardType: TextInputType.number,
                                 decoration: const InputDecoration(
                                   hintText: 'Enter department need count',
                                   border: OutlineInputBorder(),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                 ),
                                 onChanged: (value) {
                                   _calculateTotalParticipants(
                                     individualNeedController,
                                     managementNeedController,
                                     jobNeedController,
                                     departmentNeedController,
                                     numberOfParticipantsController,
                                   );
                                 },
                                 validator: (value) {
                                   if (value == null || value.trim().isEmpty) {
                                     return 'Please enter department need count';
                                   }
                                   final number = int.tryParse(value.trim());
                                   if (number == null) {
                                     return 'Please enter a valid number';
                                   }
                                   if (number < 0) {
                                     return 'Number must be 0 or greater';
                                   }
                                   return null;
                                 },
                               ),
                               const SizedBox(height: 16),
                               
                               // Number of Participants (calculated) field
                               const Text(
                                 'Total Number of Participants (Calculated)',
                                 style: TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black87,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               TextFormField(
                                 controller: numberOfParticipantsController,
                                 enabled: false, // Read-only
                                 keyboardType: TextInputType.number,
                                 decoration: InputDecoration(
                                   hintText: 'Auto-calculated',
                                   border: const OutlineInputBorder(),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                   filled: true,
                                   fillColor: Colors.grey.shade100,
                                 ),
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
            // Validate company access for Company Accounts
            if (AuthService.hasRole('company_account')) {
              final currentUser = AuthService.getCurrentUser();
              if (currentUser?.companyId != null && selectedCompanyId != currentUser!.companyId) {
                Navigator.of(context).pop(); // Close loading dialog
                _showErrorToast('You can only edit training needs for your own company');
                return;
              }
            }
            
            final request = TrainingNeedUpdateRequest(
              id: trainingNeed.id!,
              companyId: selectedCompanyId,
              courseId: selectedCourseId,
              specializationId: selectedSpecializationId,
              individualNeed: int.parse(individualNeedController.text.trim()),
              managementNeed: int.parse(managementNeedController.text.trim()),
              jobNeed: int.parse(jobNeedController.text.trim()),
              departmentNeed: int.parse(departmentNeedController.text.trim()),
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
      // Load specializations based on user role
      List<specialization_model.Specialization> specializations;
      List<company_model.Company> companies = <company_model.Company>[];
      
      if (AuthService.hasRole('company_account')) {
        // Company accounts use the company-specific endpoint and don't need companies data
        specializations = await SpecializationService.getSpecializationsForCompanyAccount(context);
        // Companies list remains empty for Company Account users
      } else {
        // System Admin and Admin use the general endpoint and need companies data
        final companiesResponse = await CompanyService.getAllCompanies();
        companies = companiesResponse.success ? companiesResponse.data : <company_model.Company>[];
        specializations = await SpecializationService.getSpecializations(context);
      }
      
      return {
        'companies': companies,
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
    NotificationService.showSuccess(context, message, operationId: 'training_need:success');
  }

  void _showErrorToast(String message) {
    NotificationService.showError(context, message, operationId: 'training_need:error');
  }
}

class TrainingNeedDataProvider extends GetxController {
  final _trainingNeeds = <TrainingNeed>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all_statuses'.obs;
  final _selectedCompanyFilter = 'filter_all_companies'.obs;
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
  List<company_model.Company> get availableCompanies {
    // If user is system administrator or admin, show all companies
    if (AuthService.isSystemAdministrator() || AuthService.hasRole('admin')) {
      final roleType = AuthService.isSystemAdministrator() ? 'System Administrator' : 'Admin';
      print('🏢 AVAILABLE COMPANIES - $roleType: ${_companies.length} companies');
      for (var company in _companies) {
        print('   - ID: ${company.id}, Name: ${company.name}');
      }
      return _companies;
    }
    
    // If user is company user, show only their company
    final currentUser = AuthService.getCurrentUser();
    if (currentUser?.companyId != null) {
      final filteredCompanies = _companies.where((company) => company.id == currentUser!.companyId).toList();
      print('🏢 AVAILABLE COMPANIES - Company User: ${filteredCompanies.length} companies');
      for (var company in filteredCompanies) {
        print('   - ID: ${company.id}, Name: ${company.name}');
      }
      return filteredCompanies;
    }
    
    // Fallback: show all companies (should not happen in normal flow)
    print('🏢 AVAILABLE COMPANIES - Fallback: ${_companies.length} companies');
    return _companies;
  }

  List<DropdownMenuItem<String>>? _cachedDropdownItems;
  int? _lastCompaniesHash;
  bool _isCreatingItems = false;

  // Method to clear dropdown items cache
  void _clearDropdownItemsCache() {
    _cachedDropdownItems = null;
    _lastCompaniesHash = null;
  }

  // Method to validate and fix dropdown value
  String _validateDropdownValue(String currentValue, List<DropdownMenuItem<String>> items) {
    if (items.isEmpty) {
      return 'filter_all_companies'; // Default value
    }
    
    // Check if current value exists in items
    final valueExists = items.any((item) => item.value == currentValue);
    if (valueExists) {
      return currentValue;
    }
    
    // If current value doesn't exist, return the first available value
    return items.first.value ?? 'filter_all_companies';
  }

  List<DropdownMenuItem<String>> get companyFilterDropdownItems {
    // Prevent recursive calls during item creation
    if (_isCreatingItems) {
      return _cachedDropdownItems ?? [];
    }

    final companies = availableCompanies;
    final companiesHash = companies.length.hashCode ^ 
        companies.fold(0, (prev, company) => prev ^ company.id.hashCode);
    
    // Return cached items if companies haven't changed
    if (_cachedDropdownItems != null && _lastCompaniesHash == companiesHash) {
      return _cachedDropdownItems!;
    }
    
    _isCreatingItems = true;
    
    try {
      print('🏢 DROPDOWN ITEMS - Creating dropdown items for ${companies.length} companies');
      
      final items = <DropdownMenuItem<String>>[];
      final usedValues = <String>{};
      
      if (AuthService.isSystemAdministrator() || AuthService.hasRole('admin')) {
        items.add(const DropdownMenuItem(value: 'filter_all_companies', child: Text('All Companies')));
        usedValues.add('filter_all_companies');
        print('   + Added "filter_all_companies" option');
      }
      
      for (var company in companies) {
        final companyIdString = company.id.toString();
        print('   + Company ID: "$companyIdString", Name: "${company.name}"');
        
        // Ensure no duplicate values and no conflicts with reserved values
        if (companyIdString != 'filter_all_companies' && !usedValues.contains(companyIdString)) {
          items.add(DropdownMenuItem<String>(
            value: companyIdString,
            child: Text(company.name),
          ));
          usedValues.add(companyIdString);
        } else {
          print('   ⚠️ Skipping company with conflicting or duplicate ID: $companyIdString');
        }
      }
      
      print('🏢 DROPDOWN ITEMS - Final items count: ${items.length}');
      for (var item in items) {
        print('   - Value: "${item.value}", Child: "${item.child}"');
      }
      
      // Cache the result
      _cachedDropdownItems = items;
      _lastCompaniesHash = companiesHash;
      
      return items;
    } finally {
      _isCreatingItems = false;
    }
  }
  
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
    if (_selectedStatusFilter.value != 'all_statuses') {
      filtered = filtered.where((tn) => tn.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by company
    if (_selectedCompanyFilter.value != 'filter_all_companies') {
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
      
      // Load training needs based on user role
      print('🔄 TRAINING NEEDS MANAGEMENT - Loading data');
      print('==========================================');
      print('👤 Current user role: ${AuthService.getCurrentUser()?.roles.map((r) => r.name).join(', ')}');
      print('🏢 Is company account: ${AuthService.hasRole('company_account')}');
      print('👑 Is system admin: ${AuthService.hasRole('system_administrator')}');
      print('⚙️ Is admin: ${AuthService.hasRole('admin')}');
      
      TrainingNeedListResponse response;
      if (TrainingNeedService.canGetTrainingNeedsByCompany()) {
        print('🏢 Using company-specific endpoint: /training-need/get-by-company');
        response = await TrainingNeedService.getTrainingNeedsByCompany();
      } else if (TrainingNeedService.canGetAllTrainingNeeds()) {
        print('🌐 Using all training needs endpoint: /training-need/get-all');
        print('👥 This endpoint is for Admin role only');
        response = await TrainingNeedService.getAllTrainingNeeds();
      } else {
        throw Exception('You do not have permission to view training needs');
      }
      
      print('📊 Training needs loaded: ${response.data.length} items');
      print('==========================================');
      
      // Load companies for filter
      try {
        final companiesResponse = await CompanyService.getAllCompanies();
        if (companiesResponse.success) {
          _companies.value = companiesResponse.data;
          _clearDropdownItemsCache(); // Clear cache when companies are updated
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
