import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/special_course_request_model.dart';
import 'package:flareline/core/services/special_course_request_service.dart';
import 'package:flareline/core/models/company_model.dart' as company_model;
import 'package:flareline/core/services/company_service.dart';
import 'package:flareline/core/services/specialization_service.dart';
import 'package:flareline/core/models/specialization_model.dart';
import 'package:flareline/core/widgets/course_file_upload.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer
import 'package:flareline/core/i18n/strings_ar.dart';
import 'package:flareline/core/ui/notification_service.dart';
import 'package:file_picker/file_picker.dart'; // Added for PlatformFile
import 'package:url_launcher/url_launcher.dart'; // Added for opening files in new tab

class SpecialCourseRequestManagementPage extends LayoutWidget {
  const SpecialCourseRequestManagementPage({super.key});



  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        SpecialCourseRequestManagementWidget(),
      ],
    );
  }
}

class SpecialCourseRequestManagementWidget extends StatefulWidget {
  const SpecialCourseRequestManagementWidget({super.key});

  @override
  State<SpecialCourseRequestManagementWidget> createState() => _SpecialCourseRequestManagementWidgetState();
}

class _SpecialCourseRequestManagementWidgetState extends State<SpecialCourseRequestManagementWidget> {

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<SpecialCourseRequestDataProvider>(
          init: SpecialCourseRequestDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, SpecialCourseRequestDataProvider provider) {
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
                            'Special Course Request Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage special course requests and their information',
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
                          width: 140,
                          child: Obx(() => ButtonWidget(
                            btnText: provider.isLoading ? 'Loading...' : 'Refresh',
                            type: 'secondary',
                            onTap: provider.isLoading ? null : () async {
                              try {
                                await provider.refreshData();
                                _showSuccessToast('Special course requests data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات طلبات الدورات الخاصة: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (SpecialCourseRequestService.canCreateSpecialCourseRequests()) {
                              return SizedBox(
                                width: 180,
                                child: ButtonWidget(
                                  btnText: 'Add Special Course Request',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddSpecialCourseRequestForm(context);
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
                  if (!SpecialCourseRequestService.canViewAllSpecialCourseRequests() && !SpecialCourseRequestService.canViewCompanySpecialCourseRequests()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage special course requests. Only System Administrators and Company Accounts can access this functionality.',
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

                    final specialCourseRequests = provider.specialCourseRequests;

                    if (specialCourseRequests.isEmpty) {
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
                              'No Special Course Requests Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding the first special course request to the system.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (SpecialCourseRequestService.canCreateSpecialCourseRequests())
                              ButtonWidget(
                                btnText: 'Add First Special Course Request',
                                type: 'primary',
                                onTap: () => _showAddSpecialCourseRequestForm(context),
                              ),
                          ],
                        ),
                      );
                    }

                    return _buildSpecialCourseRequestsTable(context, provider, constraints);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecialCourseRequestsTable(BuildContext context, SpecialCourseRequestDataProvider provider, BoxConstraints constraints) {
    final specialCourseRequests = provider.pagedSpecialCourseRequests;

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
                  hintText: 'Search by company name, title, description...',
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
                    'File',
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
            rows: specialCourseRequests.map((item) => DataRow(
              onSelectChanged: (selected) {},
              cells: [
                DataCell(_buildCompanyCell(item)),
                DataCell(_buildTitleCell(item)),
                DataCell(_buildStatusCell(item)),
                DataCell(_buildFileCell(item)),
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

  Widget _buildCompanyCell(SpecialCourseRequest item) {
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

  Widget _buildTitleCell(SpecialCourseRequest item) {
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
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description,
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

  Widget _buildStatusCell(SpecialCourseRequest item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 100,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: item.statusColor.withOpacity(0.15),
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

  Widget _buildFileCell(SpecialCourseRequest item) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: item.hasFileAttachment
          ? Tooltip(
              message: 'انقر لفتح الملف في تبويب جديد',
              child: InkWell(
                onTap: () => _openFileInNewTab(context, item.fileAttachment!),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.attach_file,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                ),
              ),
            )
          : Icon(
              Icons.remove,
              color: Colors.grey,
              size: 18,
            ),
    );
  }

  Widget _buildCreatedCell(SpecialCourseRequest item) {
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

  Widget _buildActionsCell(BuildContext context, SpecialCourseRequest item) {
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
        // Edit button (only for Company Account users and draft status)
        if (SpecialCourseRequestService.canUpdateSpecialCourseRequests() && item.isDraft)
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'edit', item);
            },
            tooltip: 'Edit Special Course Request',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
            ),
          ),

        const SizedBox(width: 10,),

        // Forward button (only for Company Account users and draft status)
        if (SpecialCourseRequestService.canForwardSpecialCourseRequests() && item.isDraft)
          IconButton(
            icon: const Icon(
              Icons.send,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'forward', item);
            },
            tooltip: 'Forward Special Course Request',
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
            ),
          ),

        const SizedBox(width: 10,),

        // Approve button (only for pending special course requests and users with permission)
        if (item.isPending && SpecialCourseRequestService.canApproveRejectSpecialCourseRequests())
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'approve', item);
            },
            tooltip: 'Approve Special Course Request',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade700,
            ),
          ),

        const SizedBox(width: 10,),

        // Reject button (only for pending special course requests and users with permission)
        if (item.isPending && SpecialCourseRequestService.canApproveRejectSpecialCourseRequests())
          IconButton(
            icon: const Icon(
              Icons.cancel,
              size: 18,
            ),
            onPressed: () {
              _handleAction(context, 'reject', item);
            },
            tooltip: 'Reject Special Course Request',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
          ),
      ],
    );
  }

  Widget _buildPagination(SpecialCourseRequestDataProvider provider) {
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
                      'Showing ${(provider.currentPage * provider.rowsPerPage) + 1} to ${provider.currentPage * provider.rowsPerPage + provider.pagedSpecialCourseRequests.length} of ${provider.totalItems} entries',
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

  void _handleAction(BuildContext context, String action, SpecialCourseRequest item) {
    switch (action) {
      case 'view':
        _showViewSpecialCourseRequestDialog(context, item);
        break;
      case 'edit':
        _showEditSpecialCourseRequestForm(context, item);
        break;
      case 'forward':
        _forwardSpecialCourseRequest(context, item);
        break;
      case 'approve':
        _approveSpecialCourseRequest(context, item);
        break;
      case 'reject':
        _rejectSpecialCourseRequest(context, item);
        break;
    }
  }

  void _showViewSpecialCourseRequestDialog(BuildContext context, SpecialCourseRequest item) {
    ModalDialog.show(
      context: context,
      title: 'Special Course Request Details',
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
                  // Special Course Request Information Section
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
                              'Special Course Request Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Company', item.companyName),
                        if (item.company?.email != null)
                          _buildDetailRow('Company Email', item.company!.email!),
                        if (item.company?.phone != null)
                          _buildDetailRow('Company Phone', item.company!.phone!),
                        _buildDetailRow('Title', item.title),
                        _buildDetailRow('Description', item.description),
                        _buildStatusRow('Status', item.statusDisplay, item.statusColor),
                        if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty)
                          _buildRejectionReasonRow('Rejection Reason', item.rejectionReason!),
                        item.hasFileAttachment
                            ? InkWell(
                                onTap: () => _openFileInNewTab(context, item.fileAttachment!),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'File Attachment',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.attach_file,
                                              color: Colors.blue.shade700,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'انقر لفتح الملف',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue.shade700,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _buildDetailRow('File Attachment', 'None'),
                        if (item.createdBy != null)
                          _buildDetailRow('Created By', item.createdBy!.toString()),
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

  Widget _buildStatusRow(String label, String value, Color statusColor) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReasonRow(String label, String value) {
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
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade800,
                height: 1.4,
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

  /// Build full file URL from server file path
  String _buildFileUrl(String filePath) {
    const baseUrl = 'https://noc.justhost.ly/backend-api/storage/app/public/';
    // Remove any leading slashes or spaces from filePath
    final cleanFilePath = filePath.trim().replaceFirst(RegExp(r'^/'), '');
    return '$baseUrl$cleanFilePath';
  }

  /// Opens file in a new tab with the given file path
  Future<void> _openFileInNewTab(BuildContext context, String filePath) async {
    try {
      // Build full URL from file path
      final fileUrl = _buildFileUrl(filePath);
      final uri = Uri.parse(fileUrl);
      
      // Launch URL in a new tab (web) or default browser (desktop)
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in new tab/browser
        );
        print('✅ Opened file: $fileUrl');
      } else {
        print('❌ Could not launch file URL: $fileUrl');
        // Show error message to user
        if (mounted) {
          NotificationService.showError(
            context,
            'تعذر فتح الملف. يرجى التأكد من وجود متصفح متاح.',
            operationId: 'file_open_error',
          );
        }
      }
    } catch (e) {
      print('❌ Error opening file: $e');
      // Show error message to user
      if (mounted) {
        NotificationService.showError(
          context,
          'خطأ في فتح الملف: ${e.toString()}',
          operationId: 'file_open_error',
        );
      }
    }
  }

  void _forwardSpecialCourseRequest(BuildContext context, SpecialCourseRequest item) async {
    const String methodName = 'forwardSpecialCourseRequest';
    print('🔍 ERROR_TRACKING: Starting $methodName for item ID: ${item.id}');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Forward'),
        content: Text('Are you sure you want to forward the special course request "${item.title}" to administrators for review?'),
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
        print('🔍 ERROR_TRACKING: $methodName - User confirmed forward action');
        final response = await SpecialCourseRequestService.forwardSpecialCourseRequest(item.id!);
        
        if (response.success) {
          print('✅ ERROR_TRACKING: $methodName - Successfully forwarded special course request');
          Get.find<SpecialCourseRequestDataProvider>().refreshData();
          _showSuccessToast('Special course request forwarded successfully');
        } else {
          print('❌ ERROR_TRACKING: $methodName - API returned error: ${response.messageEn}');
          _showErrorToast(response.messageEn ?? 'Unknown error occurred');
        }
      } catch (e, stackTrace) {
        print('❌ ERROR_TRACKING: $methodName - Exception occurred: $e');
        print('❌ ERROR_TRACKING: $methodName - Stack trace: $stackTrace');
        _showErrorToast('Failed to forward special course request: ${e.toString()}');
      }
    } else {
      print('🔍 ERROR_TRACKING: $methodName - User cancelled forward action');
    }
  }

  void _approveSpecialCourseRequest(BuildContext context, SpecialCourseRequest item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve the special course request "${item.title}" for ${item.companyName}?'),
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
        final response = await SpecialCourseRequestService.approveSpecialCourseRequest(item.id!);
        if (response.success) {
          Get.find<SpecialCourseRequestDataProvider>().refreshData();
          _showSuccessToast('Special course request approved successfully');
        } else {
          throw Exception(response.messageEn);
        }
      } catch (e) {
        _showErrorToast(e.toString());
      }
    }
  }

  void _rejectSpecialCourseRequest(BuildContext context, SpecialCourseRequest item) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Special Course Request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please provide a reason for rejecting "${item.title}":'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the reason for rejection...',
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reason = reasonController.text.trim();
      try {
        final response = await SpecialCourseRequestService.rejectSpecialCourseRequest(item.id!, reason);
        if (response.success) {
          Get.find<SpecialCourseRequestDataProvider>().refreshData();
          _showSuccessToast('Special course request rejected successfully');
        } else {
          _showErrorToast(response.messageEn ?? 'Unknown error occurred');
        }
      } catch (e) {
        _showErrorToast('Failed to reject special course request: ${e.toString()}');
      }
    }
  }

  void _showAddSpecialCourseRequestForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? selectedSpecializationId;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? fileAttachment;
    PlatformFile? selectedFileAttachment; // Store selected file (for upload)

    // Check if user has permission to create special course requests
    if (!SpecialCourseRequestService.canCreateSpecialCourseRequests()) {
      _showErrorToast('You do not have permission to create special course requests. Only Company Account users can create requests.');
      return;
    }

    // Get current user's company ID
    final currentUserCompanyId = SpecialCourseRequestService.getCurrentUserCompanyId();
    print('🔍 DEBUG: Add form - currentUserCompanyId: $currentUserCompanyId');
    if (currentUserCompanyId == null) {
      _showErrorToast('Unable to determine your company. Please ensure you are logged in with a company account and try again.');
      return;
    }

    // Data for dropdowns
    List<Specialization> specializations = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'Add New Special Course Request',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          // Load dropdown data on first build
          if (isLoadingDropdownData) {
            isLoadingDropdownData = false;
            _loadSpecializations(context).then((data) {
              setModalState(() {
                specializations = data;
              });
            });
          }
          
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
                        // Special Course Request Information Section
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
                                    'Special Course Request Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
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
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedSpecializationId = value;
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
                                hintText: 'Enter request title (max 255 characters)',
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
                                'Description *',
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
                                  hintText: 'Enter detailed description of your request',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                maxLines: 4,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // File upload field
                              const Text(
                                'File Attachment (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CourseFileUpload(
                                onFileChanged: (base64File) {
                                  fileAttachment = base64File;
                                },
                                onFileAttachmentChanged: (PlatformFile? file) {
                                  selectedFileAttachment = file;
                                },
                                width: double.infinity,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
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
                                'Creating Special Course Request...',
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
                      const Text('Creating Special Course Request...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            print('🔍 ERROR_TRACKING: Add form submission - Creating special course request');
            print('🔍 ERROR_TRACKING: Add form submission - Company ID: $currentUserCompanyId');
            print('🔍 ERROR_TRACKING: Add form submission - Specialization ID: $selectedSpecializationId');
            print('🔍 ERROR_TRACKING: Add form submission - Title: ${titleController.text.trim()}');
            print('🔍 ERROR_TRACKING: Add form submission - Description: ${descriptionController.text.trim()}');
            
            final request = SpecialCourseRequestCreateRequest(
              companyId: currentUserCompanyId,
              specializationId: selectedSpecializationId!,
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              fileAttachment: fileAttachment,
            );
            
            final response = await SpecialCourseRequestService.createSpecialCourseRequest(
              request,
              fileAttachment: selectedFileAttachment,
            );
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              print('✅ ERROR_TRACKING: Add form submission - Successfully created special course request');
              // Refresh the data
              Get.find<SpecialCourseRequestDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Special course request created successfully');
            } else {
              print('❌ ERROR_TRACKING: Add form submission - API returned error: ${response.messageEn}');
              throw Exception(response.messageEn ?? 'Failed to create special course request');
            }
          } catch (e, stackTrace) {
            print('❌ ERROR_TRACKING: Add form submission - Exception occurred: $e');
            print('❌ ERROR_TRACKING: Add form submission - Stack trace: $stackTrace');
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showEditSpecialCourseRequestForm(BuildContext context, SpecialCourseRequest specialCourseRequest) {
    final formKey = GlobalKey<FormState>();
    int? selectedSpecializationId = specialCourseRequest.specializationId;
    final titleController = TextEditingController(text: specialCourseRequest.title);
    final descriptionController = TextEditingController(text: specialCourseRequest.description);
    String? fileAttachment = specialCourseRequest.fileAttachment;
    PlatformFile? selectedFileAttachment; // Store new file attachment (for upload)
    bool fileModified = false; // Track if user has modified the file

    // Check if user has permission to update special course requests
    if (!SpecialCourseRequestService.canUpdateSpecialCourseRequests()) {
      _showErrorToast('You do not have permission to update special course requests. Only Company Account users can update requests.');
      return;
    }

    // Get current user's company ID
    final currentUserCompanyId = SpecialCourseRequestService.getCurrentUserCompanyId();
    print('🔍 DEBUG: Edit form - currentUserCompanyId: $currentUserCompanyId');
    if (currentUserCompanyId == null) {
      _showErrorToast('Unable to determine your company. Please ensure you are logged in with a company account and try again.');
      return;
    }

    // Data for dropdowns
    List<Specialization> specializations = [];
    bool isLoadingDropdownData = true;

    ModalDialog.show(
      context: context,
      title: 'Edit Special Course Request',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;

          // Load dropdown data on first build
          if (isLoadingDropdownData) {
            isLoadingDropdownData = false;
            _loadSpecializations(context).then((data) {
              setModalState(() {
                specializations = data;
              });
            });
          }
          
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
                        // Special Course Request Information Section
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
                                    'Special Course Request Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
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
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedSpecializationId = value;
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
                                hintText: 'Enter request title (max 255 characters)',
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
                                'Description *',
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
                                  hintText: 'Enter detailed description of your request',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                maxLines: 4,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // File upload field
                              const Text(
                                'File Attachment (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CourseFileUpload(
                                initialFile: fileAttachment,
                                onFileChanged: (base64File) {
                                  fileAttachment = base64File;
                                  // Mark file as modified when user changes it
                                  if (!fileModified) {
                                    fileModified = true;
                                  }
                                },
                                onFileAttachmentChanged: (PlatformFile? file) {
                                  selectedFileAttachment = file;
                                  // Mark file as modified when user selects/changes it
                                  fileModified = true;
                                },
                                width: double.infinity,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
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
                                'Updating Special Course Request...',
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
                      const Text('Updating Special Course Request...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            // Only include fileAttachment in request if user has modified it
            // If fileModified is false, set fileAttachment to null to keep existing file on server
            final request = SpecialCourseRequestUpdateRequest(
              id: specialCourseRequest.id!,
              companyId: currentUserCompanyId,
              specializationId: selectedSpecializationId,
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              fileAttachment: fileModified ? fileAttachment : null,
            );
            
            // Only send file attachment (PlatformFile) if user has modified it
            // If fileModified is false, send null to keep existing file on server
            final response = await SpecialCourseRequestService.updateSpecialCourseRequest(
              request,
              fileAttachment: fileModified ? selectedFileAttachment : null,
            );
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<SpecialCourseRequestDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn ?? 'Special course request updated successfully');
            } else {
              throw Exception(response.messageEn ?? 'Failed to update special course request');
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
      final specializations = await SpecializationService.getSpecializationsForCompanyAccount(context);

      return {
        'companies': companiesResponse.success ? companiesResponse.data : <company_model.Company>[],
        'specializations': specializations,
      };
    } catch (e) {
      print('Error loading dropdown data: $e');
      return {
        'companies': <company_model.Company>[],
        'specializations': <Specialization>[],
      };
    }
  }

  Future<List<Specialization>> _loadSpecializations(BuildContext context) async {
    try {
      return await SpecializationService.getSpecializationsForCompanyAccount(context);
    } catch (e) {
      print('Error loading specializations: $e');
      return <Specialization>[];
    }
  }

  void _showSuccessToast(String message) {
    NotificationService.showSuccess(context, message, operationId: 'special_request:success');
  }

  void _showErrorToast(String message) {
    NotificationService.showError(context, message, operationId: 'special_request:error');
  }
}

class SpecialCourseRequestDataProvider extends GetxController {
  final _specialCourseRequests = <SpecialCourseRequest>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _selectedCompanyFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  final _companies = <company_model.Company>[].obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<SpecialCourseRequest> get specialCourseRequests => _specialCourseRequests;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get selectedCompanyFilter => _selectedCompanyFilter.value;
  String get searchQuery => _searchQuery.value;
  List<company_model.Company> get companies => _companies;
  int get totalItems => filteredSpecialCourseRequests.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<SpecialCourseRequest> get filteredSpecialCourseRequests {
    var filtered = _specialCourseRequests.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((scr) => scr.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by company
    if (_selectedCompanyFilter.value != 'all') {
      filtered = filtered.where((scr) => scr.companyId.toString() == _selectedCompanyFilter.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((scr) =>
        scr.companyName.toLowerCase().contains(query) ||
        scr.title.toLowerCase().contains(query) ||
        scr.description.toLowerCase().contains(query) ||
        (scr.company?.email?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  }
  
  List<SpecialCourseRequest> get pagedSpecialCourseRequests {
    if (totalItems == 0) return const <SpecialCourseRequest>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedSpecialCourseRequests;
    }
    if (end > totalItems) end = totalItems;
    return filteredSpecialCourseRequests.sublist(start, end);
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

  Future<List<SpecialCourseRequest>> loadData() async {
    const String methodName = 'loadData';
    print('🔍 ERROR_TRACKING: Starting $methodName');
    
    try {
      _isLoading.value = true;
      
      // Load special course requests based on user role
      SpecialCourseRequestListResponse response;
      if (SpecialCourseRequestService.canViewAllSpecialCourseRequests()) {
        print('🔍 ERROR_TRACKING: $methodName - User has admin/system admin role, using get-all endpoint');
        // Admin and System Administrator use get-all endpoint
        response = await SpecialCourseRequestService.getAllSpecialCourseRequests();
      } else if (SpecialCourseRequestService.canViewCompanySpecialCourseRequests()) {
        print('🔍 ERROR_TRACKING: $methodName - User has company account role, using get-by-company endpoint');
        // Company Account uses get-by-company endpoint
        response = await SpecialCourseRequestService.getSpecialCourseRequestsByCompany();
      } else {
        print('❌ ERROR_TRACKING: $methodName - User does not have permission to view special course requests');
        throw Exception('You do not have permission to view special course requests.');
      }
      
      // Load companies for filter (only for Admin and System Administrator)
      if (SpecialCourseRequestService.canViewAllSpecialCourseRequests()) {
        try {
          print('🔍 ERROR_TRACKING: $methodName - Loading companies for filter');
          final companiesResponse = await CompanyService.getAllCompanies();
          if (companiesResponse.success) {
            _companies.value = companiesResponse.data;
            print('✅ ERROR_TRACKING: $methodName - Successfully loaded ${companiesResponse.data.length} companies');
          } else {
            print('❌ ERROR_TRACKING: $methodName - Failed to load companies: ${companiesResponse.messageEn}');
          }
        } catch (e) {
          print('❌ ERROR_TRACKING: $methodName - Error loading companies for filter: $e');
          // Don't fail the whole operation if companies can't be loaded
        }
      }
      
      if (response.success) {
        _specialCourseRequests.value = response.data;
        _currentPage.value = 0; // reset page on new data
        print('✅ ERROR_TRACKING: $methodName - Successfully loaded ${response.data.length} special course requests');
        return response.data;
      } else {
        print('❌ ERROR_TRACKING: $methodName - API returned error: ${response.messageEn}');
        throw Exception(response.messageEn);
      }
    } catch (e, stackTrace) {
      print('❌ ERROR_TRACKING: $methodName - Exception occurred: $e');
      print('❌ ERROR_TRACKING: $methodName - Stack trace: $stackTrace');
      _specialCourseRequests.clear();
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