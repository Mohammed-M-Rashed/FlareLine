import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/training_center_branch_model.dart';
import 'package:flareline/core/models/training_center_model.dart';
import 'package:flareline/core/services/training_center_branch_service.dart';
import 'package:flareline/core/services/training_center_service.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'dart:async';

class TrainingCenterBranchManagementPage extends LayoutWidget {
  const TrainingCenterBranchManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Training Center Branch Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainingCenterBranchManagementWidget(),
      ],
    );
  }
}

class TrainingCenterBranchManagementWidget extends StatelessWidget {
  const TrainingCenterBranchManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TrainingCenterBranchDataProvider>(
          init: TrainingCenterBranchDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, TrainingCenterBranchDataProvider provider) {
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
                            'Training Center Branch Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage training center branches and their information',
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
                                _showSuccessToast('Branches data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات الفروع: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (TrainingCenterBranchService.hasTrainingCenterBranchManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Branch',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddBranchForm(context);
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
                  if (!TrainingCenterBranchService.hasTrainingCenterBranchManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage training center branches. Only System Administrators can access this functionality.',
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

                    final branches = provider.branches;

                    if (branches.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد فروع',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first branch',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Branch',
                              type: 'primary',
                              onTap: () {
                                _showAddBranchForm(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch count and summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.blue.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${branches.length} branc${branches.length == 1 ? 'h' : 'hes'} found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Last updated: ${DateTime.now().toString().substring(0, 19)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Search and filter section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Search & Filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Search text field
                                  Expanded(
                                    flex: 2,
                                                                       child: TextFormField(
                                     controller: provider.searchController,
                                     decoration: InputDecoration(
                                       hintText: 'Search branches...',
                                       prefixIcon: const Icon(Icons.search),
                                       border: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(8),
                                       ),
                                       contentPadding: const EdgeInsets.symmetric(
                                         horizontal: 16,
                                         vertical: 16,
                                       ),
                                     ),
                                     onChanged: (value) {
                                       provider.setSearchQuery(value);
                                     },
                                   ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Training center filter dropdown
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Obx(() => DropdownButtonFormField<int>(
                                        value: provider.selectedTrainingCenterId == 0 ? null : provider.selectedTrainingCenterId,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                                          hintText: 'Filter by Training Center',
                                        ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('All Training Centers'),
                                          ),
                                          ...provider.trainingCenters.map((center) => DropdownMenuItem<int>(
                                            value: center.id,
                                            child: Text(center.name),
                                          )),
                                        ],
                                        onChanged: (value) {
                                          provider.setSelectedTrainingCenterId(value ?? 0);
                                        },
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Data table
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
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
                                        'Branch Name',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Training Center',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Address',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Coordinates',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Phone',
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
                                rows: provider.pagedBranches
                                    .map((branch) => DataRow(
                                          onSelectChanged: (selected) {},
                                          cells: [
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 120,
                                                  maxWidth: 180,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Branch Icon
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.blue.shade300),
                                                      ),
                                                      child: Icon(
                                                        Icons.business_outlined,
                                                        color: Colors.blue.shade700,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        branch.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 120,
                                                  maxWidth: 180,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: Colors.green.shade200,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    branch.trainingCenterName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: Colors.green.shade700,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 150,
                                                  maxWidth: 200,
                                                ),
                                                child: Text(
                                                  branch.address,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Tooltip(
                                                message: branch.hasCoordinates 
                                                    ? 'Coordinates: ${_formatCoordinates(branch.lat, branch.long)}'
                                                    : 'No coordinates set',
                                                child: Container(
                                                  constraints: const BoxConstraints(
                                                    minWidth: 100,
                                                    maxWidth: 120,
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: branch.hasCoordinates ? Colors.green.shade50 : Colors.grey.shade50,
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(
                                                        color: branch.hasCoordinates ? Colors.green.shade200 : Colors.grey.shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 14,
                                                          color: branch.hasCoordinates ? Colors.green.shade700 : Colors.grey.shade600,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          branch.hasCoordinates ? 'Available' : 'Not Set',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 10,
                                                            color: branch.hasCoordinates ? Colors.green.shade700 : Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Text(
                                                  branch.phone,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      _formatBranchDate(branch.createdAt),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (branch.updatedAt != null)
                                                      Text(
                                                        'Updated: ${_formatBranchDate(branch.updatedAt)}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _showEditBranchForm(context, branch);
                                                  },
                                                  tooltip: 'Edit Branch',
                                                  style: IconButton.styleFrom(
                                                    backgroundColor: Colors.blue.shade50,
                                                    foregroundColor: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Pagination controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Rows per page:',
                              style: TextStyle(fontSize: 12),
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
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBranchDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formats coordinates for display
  String _formatCoordinates(double? lat, double? long) {
    if (lat == null || long == null) return 'Not set';
    return '${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}';
  }

  /// Validates phone number format according to business rules
  /// Must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after prefix
  String? _validatePhoneNumber(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Please enter a phone number';
    }
    
    final phoneNumber = value.toString().trim();
    
    // Check if phone number starts with valid prefixes
    final validPrefixes = ['091', '092', '093', '094', '120'];
    bool hasValidPrefix = false;
    
    for (String prefix in validPrefixes) {
      if (phoneNumber.startsWith(prefix)) {
        hasValidPrefix = true;
        break;
      }
    }
    
    if (!hasValidPrefix) {
      return 'Phone number must start with 091, 092, 093, 094, or 120';
    }
    
    // Check if the remaining part after prefix contains exactly 7 digits
    String remainingPart = '';
    if (phoneNumber.startsWith('091') || phoneNumber.startsWith('092') || 
        phoneNumber.startsWith('093') || phoneNumber.startsWith('094')) {
      remainingPart = phoneNumber.substring(3); // Remove 3-digit prefix
    } else if (phoneNumber.startsWith('120')) {
      remainingPart = phoneNumber.substring(3); // Remove 3-digit prefix
    }
    
    // Check if remaining part contains exactly 7 digits
    if (remainingPart.length != 7) {
      return 'Phone number must contain exactly 7 digits after the prefix';
    }
    
    // Check if remaining part contains only digits
    if (!RegExp(r'^[0-9]{7}$').hasMatch(remainingPart)) {
      return 'Phone number must contain only digits after the prefix';
    }
    
    return null; // Validation passed
  }

  void _showAddBranchForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final latController = TextEditingController();
    final longController = TextEditingController();
    int selectedTrainingCenterId = 0;

    ModalDialog.show(
      context: context,
      title: 'Add New Branch',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch Information Section
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
                                    Icons.business,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Branch Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Training Center Selection
                              FutureBuilder<List<TrainingCenter>>(
                                future: TrainingCenterBranchService.getAllTrainingCentersForSelection(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error loading training centers: ${snapshot.error}',
                                      style: TextStyle(color: Colors.red),
                                    );
                                  }
                                  
                                  final trainingCenters = snapshot.data ?? [];
                                  
                                  if (trainingCenters.isEmpty) {
                                    return Text(
                                      'No training centers available',
                                      style: TextStyle(color: Colors.orange),
                                    );
                                  }
                                  
                                  return DropdownButtonFormField<int>(
                                    value: selectedTrainingCenterId > 0 ? selectedTrainingCenterId : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Training Center *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: trainingCenters.map((tc) => DropdownMenuItem<int>(
                                      value: tc.id,
                                      child: Text(tc.name),
                                    )).toList(),
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedTrainingCenterId = value ?? 0;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value == 0) {
                                        return 'Please select a training center';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Branch Name *',
                                hintText: 'Enter branch name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a branch name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Branch name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address *',
                                hintText: 'Enter branch address',
                                controller: addressController,
                                maxLines: 3,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a branch address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Phone Field
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Phone number must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after the prefix (e.g., 0911234567)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutBorderTextFormField(
                                labelText: 'Phone Number *',
                                hintText: 'Enter branch phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                               // Geographic Coordinates Section
                               Container(
                                 width: double.infinity,
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: Colors.green.shade50,
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.green.shade200),
                                 ),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Colors.green.shade600,
                                           size: 20,
                                         ),
                                         const SizedBox(width: 8),
                                         Text(
                                           'Geographic Coordinates (Optional)',
                                           style: TextStyle(
                                             fontSize: 16,
                                             fontWeight: FontWeight.w600,
                                             color: Colors.green.shade700,
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 8),
                                     Text(
                                       'Add coordinates to display this branch on maps. Leave empty if coordinates are not available.',
                                       style: TextStyle(
                                         fontSize: 12,
                                         color: Colors.green.shade700,
                                       ),
                                     ),
                                     const SizedBox(height: 16),
                                     
                                     // Latitude and Longitude Fields
                                     Row(
                                       children: [
                                         Expanded(
                                           child: OutBorderTextFormField(
                                             labelText: 'Latitude',
                                             hintText: 'e.g., 40.7128',
                                             controller: latController,
                                             enabled: !isSubmitting,
                                             keyboardType: TextInputType.numberWithOptions(decimal: true),
                                             validator: (value) {
                                               if (value != null && value.trim().isNotEmpty) {
                                                 final lat = double.tryParse(value.trim());
                                                 if (lat == null) {
                                                   return 'Please enter a valid number';
                                                 }
                                                 if (lat < -90 || lat > 90) {
                                                   return 'Latitude must be between -90 and 90';
                                                 }
                                               }
                                               return null;
                                             },
                                           ),
                                         ),
                                         const SizedBox(width: 16),
                                         Expanded(
                                           child: OutBorderTextFormField(
                                             labelText: 'Longitude',
                                             hintText: 'e.g., -74.0060',
                                             controller: longController,
                                             enabled: !isSubmitting,
                                             keyboardType: TextInputType.numberWithOptions(decimal: true),
                                             validator: (value) {
                                               if (value != null && value.trim().isNotEmpty) {
                                                 final long = double.tryParse(value.trim());
                                                 if (long == null) {
                                                   return 'Please enter a valid number';
                                                 }
                                                 if (long < -180 || long > 180) {
                                                   return 'Longitude must be between -180 and 180';
                                                 }
                                               }
                                               return null;
                                             },
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
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
                                'Creating Branch...',
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
                      const Text('Creating Branch...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingCenterBranchCreateRequest(
              name: nameController.text.trim(),
              trainingCenterId: selectedTrainingCenterId,
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              lat: latController.text.trim().isNotEmpty ? double.tryParse(latController.text.trim()) : null,
              long: longController.text.trim().isNotEmpty ? double.tryParse(longController.text.trim()) : null,
            );
            
            final response = await TrainingCenterBranchService.createTrainingCenterBranch(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingCenterBranchDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn);
            } else {
              throw Exception(response.messageEn);
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

  void _showEditBranchForm(BuildContext context, TrainingCenterBranch branch) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: branch.name);
    final addressController = TextEditingController(text: branch.address);
    final phoneController = TextEditingController(text: branch.phone);
    final latController = TextEditingController(text: branch.lat?.toString() ?? '');
    final longController = TextEditingController(text: branch.long?.toString() ?? '');
    int selectedTrainingCenterId = branch.trainingCenterId;

    ModalDialog.show(
      context: context,
      title: 'Edit Branch',
      showTitle: true,
      modalType: ModalType.large,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch Information Section
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
                                    Icons.business,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Branch Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Training Center Selection
                              FutureBuilder<List<TrainingCenter>>(
                                future: TrainingCenterBranchService.getAllTrainingCentersForSelection(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error loading training centers: ${snapshot.error}',
                                      style: TextStyle(color: Colors.red),
                                    );
                                  }
                                  
                                  final trainingCenters = snapshot.data ?? [];
                                  
                                  if (trainingCenters.isEmpty) {
                                    return Text(
                                      'No training centers available',
                                      style: TextStyle(color: Colors.orange),
                                    );
                                  }
                                  
                                  return DropdownButtonFormField<int>(
                                    value: selectedTrainingCenterId > 0 ? selectedTrainingCenterId : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Training Center *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: trainingCenters.map((tc) => DropdownMenuItem<int>(
                                      value: tc.id,
                                      child: Text(tc.name),
                                    )).toList(),
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedTrainingCenterId = value ?? 0;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value == 0) {
                                        return 'Please select a training center';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Branch Name *',
                                hintText: 'Enter branch name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a branch name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Branch name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address *',
                                hintText: 'Enter branch address',
                                controller: addressController,
                                maxLines: 3,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a branch address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Phone Field
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Phone number must start with 091, 092, 093, 094, or 120 and contain exactly 7 digits after the prefix (e.g., 0911234567)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutBorderTextFormField(
                                labelText: 'Phone Number *',
                                hintText: 'Enter branch phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                               // Geographic Coordinates Section
                               Container(
                                 width: double.infinity,
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: Colors.green.shade50,
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.green.shade200),
                                 ),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Icon(
                                           Icons.location_on,
                                           color: Colors.green.shade600,
                                           size: 20,
                                         ),
                                         const SizedBox(width: 8),
                                         Text(
                                           'Geographic Coordinates (Optional)',
                                           style: TextStyle(
                                             fontSize: 16,
                                             fontWeight: FontWeight.w600,
                                             color: Colors.green.shade700,
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 8),
                                     Text(
                                       'Add coordinates to display this branch on maps. Leave empty if coordinates are not available.',
                                       style: TextStyle(
                                         fontSize: 12,
                                         color: Colors.green.shade700,
                                       ),
                                     ),
                                     const SizedBox(height: 16),
                                     
                                     // Latitude and Longitude Fields
                                     Row(
                                       children: [
                                         Expanded(
                                           child: OutBorderTextFormField(
                                             labelText: 'Latitude',
                                             hintText: 'e.g., 40.7128',
                                             controller: latController,
                                             enabled: !isSubmitting,
                                             keyboardType: TextInputType.numberWithOptions(decimal: true),
                                             validator: (value) {
                                               if (value != null && value.trim().isNotEmpty) {
                                                 final lat = double.tryParse(value.trim());
                                                 if (lat == null) {
                                                   return 'Please enter a valid number';
                                                 }
                                                 if (lat < -90 || lat > 90) {
                                                   return 'Latitude must be between -90 and 90';
                                                 }
                                               }
                                               return null;
                                             },
                                           ),
                                         ),
                                         const SizedBox(width: 16),
                                         Expanded(
                                           child: OutBorderTextFormField(
                                             labelText: 'Longitude',
                                             hintText: 'e.g., -74.0060',
                                             controller: longController,
                                             enabled: !isSubmitting,
                                             keyboardType: TextInputType.numberWithOptions(decimal: true),
                                             validator: (value) {
                                               if (value != null && value.trim().isNotEmpty) {
                                                 final long = double.tryParse(value.trim());
                                                 if (long == null) {
                                                   return 'Please enter a valid number';
                                                 }
                                                 if (long < -180 || long > 180) {
                                                   return 'Longitude must be between -180 and 180';
                                                 }
                                               }
                                               return null;
                                             },
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
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
                                'Updating Branch...',
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
                      const Text('Updating Branch...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = TrainingCenterBranchUpdateRequest(
              id: branch.id!,
              name: nameController.text.trim(),
              trainingCenterId: selectedTrainingCenterId,
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              lat: latController.text.trim().isNotEmpty ? double.tryParse(latController.text.trim()) : null,
              long: longController.text.trim().isNotEmpty ? double.tryParse(longController.text.trim()) : null,
            );
            
            final response = await TrainingCenterBranchService.updateTrainingCenterBranch(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<TrainingCenterBranchDataProvider>().refreshData();
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEn);
            } else {
              throw Exception(response.messageEn);
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

  void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
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
      context: Get.context!,
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

class TrainingCenterBranchDataProvider extends GetxController {
  final _branches = <TrainingCenterBranch>[].obs;
  final _trainingCenters = <TrainingCenter>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedTrainingCenterId = 0.obs;
  final _searchQuery = ''.obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<TrainingCenterBranch> get branches => _branches;
  List<TrainingCenter> get trainingCenters => _trainingCenters;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  int get selectedTrainingCenterId => _selectedTrainingCenterId.value;
  String get searchQuery => _searchQuery.value;
  
  int get totalItems => filteredBranches.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<TrainingCenterBranch> get filteredBranches {
    var filtered = _branches.toList();
    
    if (_selectedTrainingCenterId.value > 0) {
      filtered = filtered.where((branch) => branch.trainingCenterId == _selectedTrainingCenterId.value).toList();
    }
    
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((branch) =>
        branch.name.toLowerCase().contains(query) ||
        branch.address.toLowerCase().contains(query) ||
        branch.phone.toLowerCase().contains(query) ||
        branch.trainingCenterName.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }
  
  List<TrainingCenterBranch> get pagedBranches {
    if (totalItems == 0) return const <TrainingCenterBranch>[];
    final start = currentPage * rowsPerPage;
    if (start >= totalItems) return const <TrainingCenterBranch>[];
    var end = start + rowsPerPage;
    if (end > totalItems) end = totalItems;
    return filteredBranches.sublist(start, end);
  }
  
  int get startIndex => currentPage * rowsPerPage;
  int get endIndex {
    if (totalItems == 0) return 0;
    return (startIndex + rowsPerPage - 1).clamp(0, totalItems - 1);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadTrainingCenters();
  }

  Future<List<TrainingCenterBranch>> loadData() async {
    try {
      _isLoading.value = true;
      final response = await TrainingCenterBranchService.getAllTrainingCenterBranches();
      
      if (response.success) {
        _branches.value = response.data;
        _currentPage.value = 0; // reset page on new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _branches.clear();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadTrainingCenters() async {
    try {
      final response = await TrainingCenterService.getAllTrainingCenters();
      
      if (response.success) {
        _trainingCenters.value = response.data;
      } else {
        _trainingCenters.clear();
      }
    } catch (e) {
      _trainingCenters.clear();
      // Don't rethrow as this is not critical for the main functionality
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

  void setSelectedTrainingCenterId(int value) {
    _selectedTrainingCenterId.value = value;
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
