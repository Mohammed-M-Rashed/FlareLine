import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/training_center_model.dart';
import 'package:flareline/core/services/training_center_service.dart';
import 'package:flareline/core/services/country_service.dart';
import 'package:flareline/core/services/city_service.dart';
import 'package:flareline/core/models/country_model.dart';
import 'package:flareline/core/models/city_model.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/components/small_refresh_button.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'dart:convert'; // Added for base64Decode
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async'; // Added for Completer
import 'package:flareline/core/i18n/strings_ar.dart';
import 'package:flareline/core/ui/notification_service.dart';

class TrainingCenterManagementPage extends LayoutWidget {
  const TrainingCenterManagementPage({super.key});



  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainingCenterManagementWidget(),
      ],
    );
  }
}

class TrainingCenterManagementWidget extends StatefulWidget {
  const TrainingCenterManagementWidget({super.key});

  @override
  State<TrainingCenterManagementWidget> createState() => _TrainingCenterManagementWidgetState();
}

class _TrainingCenterManagementWidgetState extends State<TrainingCenterManagementWidget> {
  late CityDataProvider _cityDataProvider;

  @override
  void initState() {
    super.initState();
    print('🚀 [TrainingCenter] Initializing Training Center Management Widget');
    // Initialize the data provider early to start loading data
    _cityDataProvider = Get.put(CityDataProvider(), permanent: true);
    print('✅ [TrainingCenter] CityDataProvider initialized successfully');
  }

  @override
  void dispose() {
    // Don't dispose the provider here as it might be used elsewhere
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TrainingCenterDataProvider>(
          init: TrainingCenterDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, TrainingCenterDataProvider provider) {
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
                            'Training Center Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage system training centers and their information',
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
                              _showSuccessToast('Training centers data refreshed successfully');
                            } catch (e) {
                              _showErrorToast('خطأ في تحديث بيانات مراكز التدريب: ${e.toString()}');
                            }
                          },
                        )),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (TrainingCenterService.hasTrainingCenterManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'إضافة مركز تدريب',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddTrainingCenterForm(context);
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
                  if (!TrainingCenterService.hasTrainingCenterManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage training centers. Only System Administrators can access this functionality.',
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

                    final trainingCenters = provider.trainingCenters;

                    if (trainingCenters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد مراكز تدريب',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first training center',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Training Center',
                              type: 'primary',
                              onTap: () {
                                _showAddTrainingCenterForm(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Training center count and summary
                        CountSummaryWidgetEn(
                          count: trainingCenters.length,
                          itemName: 'training center',
                          itemNamePlural: 'training centers',
                          icon: Icons.school,
                          color: Colors.blue,
                          filteredCount: provider.filteredTrainingCenters.length,
                          showFilteredCount: true,
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
                                        hintText: 'Search training centers...',
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
                                  // Status filter dropdown
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Obx(() => DropdownButtonFormField<String>(
                                        value: provider.selectedStatusFilter == 'all' ? null : provider.selectedStatusFilter,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                                          hintText: 'Filter by Status',
                                        ),
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('All Statuses'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'pending',
                                            child: Text('Pending'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'approved',
                                            child: Text('Approved'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'rejected',
                                            child: Text('Rejected'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          provider.setSelectedStatusFilter(value ?? 'all');
                                        },
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Search help text
                              Text(
                                'Search by name, email, phone, address, website, or description',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Clear filters button
                              if (provider.searchQuery.isNotEmpty || provider.selectedStatusFilter != 'all')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        provider.searchController.clear();
                                        provider.setSearchQuery('');
                                        provider.setSelectedStatusFilter('all');
                                      },
                                      icon: const Icon(Icons.clear_all, size: 16),
                                      label: const Text('Clear All Filters'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Search results summary
                        if (provider.searchQuery.isNotEmpty || provider.selectedStatusFilter != 'all')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Showing ${provider.filteredTrainingCenters.length} result${provider.filteredTrainingCenters.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (provider.searchQuery.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'for "${provider.searchQuery}"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (provider.selectedStatusFilter != 'all') ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'with status "${provider.selectedStatusFilter}"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Data table
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (provider.filteredTrainingCenters.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No training centers found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search criteria or filters',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () {
                                        provider.searchController.clear();
                                        provider.setSearchQuery('');
                                        provider.setSelectedStatusFilter('all');
                                      },
                                      icon: const Icon(Icons.clear_all, size: 16),
                                      label: const Text('Clear All Filters'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
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
                                        'Name',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Email',
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
                                        'Country',
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
                                        'Actions',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    numeric: false,
                                  ),
                                ],
                                rows: provider.pagedTrainingCenters
                                    .map((trainingCenter) => DataRow(
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
                                                    // Training Center Logo or Placeholder
                                                    _buildTrainingCenterPlaceholder(trainingCenter.name),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        trainingCenter.name,
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
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  child: Text(
                                                    trainingCenter.email,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: Colors.black87,
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
                                                  minWidth: 100,
                                                  maxWidth: 150,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  child: Text(
                                                    trainingCenter.phone,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                child: GetBuilder<CityDataProvider>(
                                                  builder: (cityProvider) {
                                                    String countryName = _getCountryNameSync(trainingCenter, cityProvider);
                                                    return Text(
                                                      countryName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                constraints: const BoxConstraints(
                                                  minWidth: 80,
                                                  maxWidth: 200,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: trainingCenter.statusColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    trainingCenter.statusDisplay,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 11,
                                                      color: trainingCenter.statusColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // View button
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.visibility,
                                                        size: 18,
                                                      ),
                                                      onPressed: () {
                                                        _showViewTrainingCenterDialog(context, trainingCenter);
                                                      },
                                                      tooltip: 'View Details',
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: Colors.grey.shade50,
                                                        foregroundColor: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Edit button
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                      ),
                                                      onPressed: () {
                                                        _showEditTrainingCenterForm(context, trainingCenter);
                                                      },
                                                      tooltip: 'تعديل مركز التدريب',
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: Colors.blue.shade50,
                                                        foregroundColor: Colors.blue.shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Accept button (only for pending training centers)
                                                    if (trainingCenter.isPending)
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.check_circle,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          _acceptTrainingCenter(trainingCenter);
                                                        },
                                                        tooltip: 'Accept Training Center',
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.green.shade50,
                                                          foregroundColor: Colors.green.shade700,
                                                        ),
                                                      ),
                                                    const SizedBox(width: 8),
                                                    // Reject button (only for pending training centers)
                                                    if (trainingCenter.isPending)
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.cancel,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          _rejectTrainingCenter(trainingCenter);
                                                        },
                                                        tooltip: 'Reject Training Center',
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.red.shade50,
                                                          foregroundColor: Colors.red.shade700,
                                                        ),
                                                      ),
                                                  ],
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

  void _showAddTrainingCenterForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final websiteController = TextEditingController();
    final descriptionController = TextEditingController();
    int? selectedCountryId;
    int? selectedCityId;

    ModalDialog.show(
      context: context,
      title: 'إضافة مركز تدريب جديد',
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
                        // Training Center Information Section
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
                                    Icons.school,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Training Center Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Training Center Name',
                                hintText: 'Enter training center name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a training center name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Training center name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Email Field
                              OutBorderTextFormField(
                                labelText: 'Email Address',
                                hintText: 'Enter training center email',
                                controller: emailController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                    return 'Please enter a valid email address';
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
                                labelText: 'Phone Number',
                                hintText: 'Enter training center phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address',
                                hintText: 'Enter training center address',
                                controller: addressController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a training center address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCountryId = value;
                                  // Reset city selection when country changes
                                  selectedCityId = null;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),

                              // City Dropdown
                              _buildCityDropdown(
                                selectedCityId: selectedCityId,
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                               
                              // Website Field
                              OutBorderTextFormField(
                                labelText: 'Website URL',
                                hintText: 'Enter training center website (optional)',
                                controller: websiteController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final uri = Uri.tryParse(value.trim());
                                    if (uri == null || !uri.hasAbsolutePath) {
                                      return 'Please enter a valid URL';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Description Field
                              OutBorderTextFormField(
                                labelText: 'Description',
                                hintText: 'Enter training center description (optional)',
                                controller: descriptionController,
                                enabled: !isSubmitting,
                                maxLines: 3,
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
                                'Creating Training Center...',
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
                      const Text('Creating Training Center...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            // Log form data for debugging
            print('📝 TRAINING CENTER CREATE: Form data validation passed');
            print('📝 TRAINING CENTER CREATE: Name: ${nameController.text.trim()}');
            print('📝 TRAINING CENTER CREATE: Email: ${emailController.text.trim()}');
            print('📝 TRAINING CENTER CREATE: Phone: ${phoneController.text.trim()}');
            print('📝 TRAINING CENTER CREATE: Address: ${addressController.text.trim()}');
            print('📝 TRAINING CENTER CREATE: Website: ${websiteController.text.trim()}');
            print('📝 TRAINING CENTER CREATE: Description: ${descriptionController.text.trim()}');
            
            final request = TrainingCenterCreateRequest(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              phone: phoneController.text.trim(),
              address: addressController.text.trim(),
              website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
              description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            print('📤 TRAINING CENTER CREATE: Sending request to API...');
            
            final response = await TrainingCenterService.createTrainingCenter(request);
            
            print('📥 TRAINING CENTER CREATE: Received API response');
            print('📥 TRAINING CENTER CREATE: Success: ${response.success}');
            print('📥 TRAINING CENTER CREATE: Message EN: ${response.messageEn}');
            print('📥 TRAINING CENTER CREATE: Message AR: ${response.messageAr}');
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              print('✅ TRAINING CENTER CREATE: Training center created successfully');
              
              // Refresh the data
              try {
                print('🔄 TRAINING CENTER CREATE: Refreshing training center data...');
                if (Get.isRegistered<TrainingCenterDataProvider>()) {
                  await Get.find<TrainingCenterDataProvider>().refreshData();
                  print('✅ TRAINING CENTER CREATE: Data refresh completed');
                } else {
                  print('⚠️ TRAINING CENTER CREATE: TrainingCenterDataProvider not registered, attempting to register...');
                  Get.put(TrainingCenterDataProvider(), permanent: false);
                  await Get.find<TrainingCenterDataProvider>().refreshData();
                  print('✅ TRAINING CENTER CREATE: Provider registered and data refresh completed');
                }
              } catch (e) {
                print('❌ TRAINING CENTER CREATE: Error refreshing data: $e');
                print('❌ TRAINING CENTER CREATE: Attempting alternative refresh method...');
                // Try to trigger a rebuild of the GetBuilder widget
                try {
                  Get.find<TrainingCenterDataProvider>().update();
                  print('✅ TRAINING CENTER CREATE: Alternative refresh method successful');
                } catch (e2) {
                  print('❌ TRAINING CENTER CREATE: Alternative refresh also failed: $e2');
                }
              }
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEnText);
              print('✅ TRAINING CENTER CREATE: Success toast shown');
              
              // Force UI refresh
              setState(() {});
            } else {
              print('❌ TRAINING CENTER CREATE: API returned success=false');
              print('❌ TRAINING CENTER CREATE: Error message: ${response.messageEn}');
              throw Exception(response.messageEn);
            }
          } catch (e, stackTrace) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('❌ TRAINING CENTER CREATE: Exception caught during training center creation');
            print('❌ TRAINING CENTER CREATE: Error type: ${e.runtimeType}');
            print('❌ TRAINING CENTER CREATE: Error message: $e');
            print('❌ TRAINING CENTER CREATE: Stack trace: $stackTrace');
            
            // Show user-friendly error message
            String errorMessage = 'Failed to create training center';
            if (e.toString().contains('Exception:')) {
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            } else if (e.toString().isNotEmpty) {
              errorMessage = e.toString();
            }
            
            _showErrorToast(errorMessage);
            print('❌ TRAINING CENTER CREATE: Error toast shown: $errorMessage');
          }
        }
      },
    );
  }

  void _showEditTrainingCenterForm(BuildContext context, TrainingCenter trainingCenter) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: trainingCenter.name);
    final emailController = TextEditingController(text: trainingCenter.email);
    final phoneController = TextEditingController(text: trainingCenter.phone);
    final addressController = TextEditingController(text: trainingCenter.address);
    final websiteController = TextEditingController(text: trainingCenter.website);
    final descriptionController = TextEditingController(text: trainingCenter.description);
    int? selectedCountryId = trainingCenter.countryId;
    int? selectedCityId = trainingCenter.cityId;

    ModalDialog.show(
      context: context,
      title: 'تعديل مركز التدريب',
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
                        // Training Center Information Section
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
                                    Icons.school,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Training Center Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                               
                              // Name Field
                              OutBorderTextFormField(
                                labelText: 'Training Center Name',
                                hintText: 'Enter training center name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a training center name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Training center name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Email Field
                              OutBorderTextFormField(
                                labelText: 'Email Address',
                                hintText: 'Enter training center email',
                                controller: emailController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                    return 'Please enter a valid email address';
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
                                labelText: 'Phone Number',
                                hintText: 'Enter training center phone number (e.g., 0911234567)',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: _validatePhoneNumber,
                              ),
                              const SizedBox(height: 16),
                               
                              // Address Field
                              OutBorderTextFormField(
                                labelText: 'Address',
                                hintText: 'Enter training center address',
                                controller: addressController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a training center address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Country Dropdown
                              _buildCountryDropdown(
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCountryId = value;
                                  // Reset city selection when country changes
                                  selectedCityId = null;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),

                              // City Dropdown
                              _buildCityDropdown(
                                selectedCityId: selectedCityId,
                                selectedCountryId: selectedCountryId,
                                onChanged: (value) {
                                  selectedCityId = value;
                                },
                                enabled: !isSubmitting,
                                setModalState: setModalState,
                              ),
                              const SizedBox(height: 16),
                               
                              // Website Field
                              OutBorderTextFormField(
                                labelText: 'Website URL',
                                hintText: 'Enter training center website (optional)',
                                controller: websiteController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final uri = Uri.tryParse(value.trim());
                                    if (uri == null || !uri.hasAbsolutePath) {
                                      return 'Please enter a valid URL';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Description Field
                              OutBorderTextFormField(
                                labelText: 'Description',
                                hintText: 'Enter training center description (optional)',
                                controller: descriptionController,
                                enabled: !isSubmitting,
                                maxLines: 3,
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
                                'Updating Training Center...',
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
                      const Text('Updating Training Center...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            // Log form data for debugging
            print('📝 TRAINING CENTER EDIT: Form data validation passed');
            print('📝 TRAINING CENTER EDIT: ID: ${trainingCenter.id}');
            print('📝 TRAINING CENTER EDIT: Name: ${nameController.text.trim()}');
            print('📝 TRAINING CENTER EDIT: Email: ${emailController.text.trim()}');
            print('📝 TRAINING CENTER EDIT: Phone: ${phoneController.text.trim()}');
            print('📝 TRAINING CENTER EDIT: Address: ${addressController.text.trim()}');
            print('📝 TRAINING CENTER EDIT: Website: ${websiteController.text.trim()}');
            print('📝 TRAINING CENTER EDIT: Description: ${descriptionController.text.trim()}');
            
            final request = TrainingCenterUpdateRequest(
              id: trainingCenter.id!,
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              phone: phoneController.text.trim(),
              address: addressController.text.trim(),
              website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
              description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
              countryId: selectedCountryId,
              cityId: selectedCityId,
            );
            
            print('📤 TRAINING CENTER EDIT: Sending request to API...');
            
            final response = await TrainingCenterService.updateTrainingCenter(request);
            
            print('📥 TRAINING CENTER EDIT: Received API response');
            print('📥 TRAINING CENTER EDIT: Success: ${response.success}');
            print('📥 TRAINING CENTER EDIT: Message EN: ${response.messageEn}');
            print('📥 TRAINING CENTER EDIT: Message AR: ${response.messageAr}');
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              print('✅ TRAINING CENTER EDIT: Training center updated successfully');
              
              // Refresh the data
              try {
                print('🔄 TRAINING CENTER EDIT: Refreshing training center data...');
                if (Get.isRegistered<TrainingCenterDataProvider>()) {
                  await Get.find<TrainingCenterDataProvider>().refreshData();
                  print('✅ TRAINING CENTER EDIT: Data refresh completed');
                } else {
                  print('⚠️ TRAINING CENTER EDIT: TrainingCenterDataProvider not registered, attempting to register...');
                  Get.put(TrainingCenterDataProvider(), permanent: false);
                  await Get.find<TrainingCenterDataProvider>().refreshData();
                  print('✅ TRAINING CENTER EDIT: Provider registered and data refresh completed');
                }
              } catch (e) {
                print('❌ TRAINING CENTER EDIT: Error refreshing data: $e');
                print('❌ TRAINING CENTER EDIT: Attempting alternative refresh method...');
                // Try to trigger a rebuild of the GetBuilder widget
                try {
                  Get.find<TrainingCenterDataProvider>().update();
                  print('✅ TRAINING CENTER EDIT: Alternative refresh method successful');
                } catch (e2) {
                  print('❌ TRAINING CENTER EDIT: Alternative refresh also failed: $e2');
                }
              }
               
              // Close modal
              Get.back();
               
              // Show success message
              _showSuccessToast(response.messageEnText);
              print('✅ TRAINING CENTER EDIT: Success toast shown');
              
              // Force UI refresh
              setState(() {});
            } else {
              print('❌ TRAINING CENTER EDIT: API returned success=false');
              print('❌ TRAINING CENTER EDIT: Error message: ${response.messageEn}');
              throw Exception(response.messageEn);
            }
          } catch (e, stackTrace) {
            // Close loading dialog
            Navigator.of(context).pop();
            
            print('❌ TRAINING CENTER EDIT: Exception caught during training center update');
            print('❌ TRAINING CENTER EDIT: Error type: ${e.runtimeType}');
            print('❌ TRAINING CENTER EDIT: Error message: $e');
            print('❌ TRAINING CENTER EDIT: Stack trace: $stackTrace');
            
            // Show user-friendly error message
            String errorMessage = 'Failed to update training center';
            if (e.toString().contains('Exception:')) {
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            } else if (e.toString().isNotEmpty) {
              errorMessage = e.toString();
            }
            
            _showErrorToast(errorMessage);
            print('❌ TRAINING CENTER EDIT: Error toast shown: $errorMessage');
          }
        }
      },
    );
  }

  String _formatTrainingCenterDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTrainingCenterPlaceholder(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'T',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

  /// Shows a success toast notification for training center operations in Arabic
  void _showSuccessToast(String message) {
    if (Get.context != null) {
      NotificationService.showSuccess(Get.context!, message, operationId: 'training_center:success');
    }
  }

  /// Shows an error toast notification for training center operations in Arabic
  void _showErrorToast(String message) {
    if (Get.context != null) {
      NotificationService.showError(Get.context!, message, operationId: 'training_center:error');
    }
  }

  /// Helper method to get country name for a training center synchronously
  String _getCountryNameSync(TrainingCenter trainingCenter, CityDataProvider cityProvider) {
    print('🔍 [TrainingCenter] Getting country name for training center ID: ${trainingCenter.id}');
    print('📋 [TrainingCenter] Training center country data: countryId=${trainingCenter.countryId}, countryName=${trainingCenter.countryName}');
    print('📊 [TrainingCenter] Available countries in provider: ${cityProvider.countries.length}');
    
    // First check if country name is already available from API response
    if (trainingCenter.countryName != null && trainingCenter.countryName!.isNotEmpty) {
      print('✅ [TrainingCenter] Using country name from API: ${trainingCenter.countryName}');
      return trainingCenter.countryName!;
    }
    
    // If no country name but we have country ID, try to get it from the provider
    if (trainingCenter.countryId != null && cityProvider.countries.isNotEmpty) {
      final country = cityProvider.countries.firstWhereOrNull(
        (c) => c.id == trainingCenter.countryId,
      );
      if (country != null) {
        print('✅ [TrainingCenter] Found country in provider: ${country.name}');
        return country.name;
      } else {
        print('⚠️ [TrainingCenter] Country ID ${trainingCenter.countryId} not found in provider');
      }
    }
    
    print('❌ [TrainingCenter] No country data available, returning default');
    return 'No country';
  }

  /// Helper method to get city name for a training center synchronously
  String _getCityNameSync(TrainingCenter trainingCenter, CityDataProvider cityProvider) {
    print('🔍 [TrainingCenter] Getting city name for training center ID: ${trainingCenter.id}');
    print('📋 [TrainingCenter] Training center city data: cityId=${trainingCenter.cityId}, cityName=${trainingCenter.cityName}');
    print('📊 [TrainingCenter] Available cities in provider: ${cityProvider.cities.length}');
    
    // First check if city name is already available from API response
    if (trainingCenter.cityName != null && trainingCenter.cityName!.isNotEmpty) {
      print('✅ [TrainingCenter] Using city name from API: ${trainingCenter.cityName}');
      return trainingCenter.cityName!;
    }
    
    // If no city name but we have city ID, try to get it from the provider
    if (trainingCenter.cityId != null && cityProvider.cities.isNotEmpty) {
      final city = cityProvider.cities.firstWhereOrNull(
        (c) => c.id == trainingCenter.cityId,
      );
      if (city != null) {
        print('✅ [TrainingCenter] Found city in provider: ${city.name}');
        return city.name;
      } else {
        print('⚠️ [TrainingCenter] City ID ${trainingCenter.cityId} not found in provider');
      }
    }
    
    print('❌ [TrainingCenter] No city data available, returning default');
    return 'No city';
  }

  /// Builds country dropdown widget with data loading
  Widget _buildCountryDropdown({
    required int? selectedCountryId,
    required Function(int?) onChanged,
    required bool enabled,
    required StateSetter setModalState,
  }) {
    print('🏗️ [TrainingCenter] Building country dropdown with selectedCountryId: $selectedCountryId');
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        print('📊 [TrainingCenter] Country dropdown state: countries=${cityProvider.countries.length}, isLoadingCountries=${cityProvider.isLoadingCountries}');
        
        // Load data only once when form is opened (not on every rebuild)
        if (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries) {
          print('🔄 [TrainingCenter] Triggering country data loading (one-time load)...');
          // Use addPostFrameCallback to ensure this only runs once per form opening
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries) {
              cityProvider.loadCountries();
            }
          });
        }
        
        // Show loading indicator while data is being fetched
        if (cityProvider.isLoadingCountries || (cityProvider.countries.isEmpty && !cityProvider.isLoadingCountries)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Country',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: cityProvider.isLoadingCountries 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Loading countries...',
                        style: TextStyle(color: Colors.grey),
                      ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedCountryId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                hint: const Text('Select Country'),
                items: cityProvider.countries.map((Country country) {
                  return DropdownMenuItem<int>(
                    value: country.id,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: enabled ? (int? value) {
                  setModalState(() {
                    print('🌍 [TrainingCenter] Country selection changed from $selectedCountryId to $value');
                    onChanged(value);
                  });
                  // Removed cityProvider.setSelectedCountry(value) to prevent affecting other dropdowns
                } : null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a country';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds city dropdown widget with data loading and filtering
  Widget _buildCityDropdown({
    required int? selectedCityId,
    required int? selectedCountryId,
    required Function(int?) onChanged,
    required bool enabled,
    required StateSetter setModalState,
  }) {
    print('🏗️ [TrainingCenter] Building city dropdown with selectedCityId: $selectedCityId, selectedCountryId: $selectedCountryId');
    return GetBuilder<CityDataProvider>(
      builder: (cityProvider) {
        print('📊 [TrainingCenter] City dropdown state: cities=${cityProvider.cities.length}, isLoading=${cityProvider.isLoading}');
        
        // Load cities only once when form is opened (not on every rebuild)
        if (cityProvider.cities.isEmpty && !cityProvider.isLoading) {
          print('🔄 [TrainingCenter] Triggering city data loading (one-time load)...');
          // Use addPostFrameCallback to ensure this only runs once per form opening
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (cityProvider.cities.isEmpty && !cityProvider.isLoading) {
              cityProvider.refreshData();
            }
          });
        }
        
        final filteredCities = cityProvider.cities
            .where((city) => city.countryId == selectedCountryId)
            .toList();
        print('🔍 [TrainingCenter] Filtered cities for country $selectedCountryId: ${filteredCities.length}');
        
        // Show loading indicator while cities are being fetched
        if (cityProvider.isLoading || (cityProvider.cities.isEmpty && !cityProvider.isLoading)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: cityProvider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Loading cities...',
                        style: TextStyle(color: Colors.grey),
                      ),
                ),
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<int>(
                value: selectedCityId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                hint: Text(selectedCountryId == null ? 'Select Country First' : 'Select City'),
                items: filteredCities.map((City city) {
                  return DropdownMenuItem<int>(
                    value: city.id,
                    child: Text(city.name),
                  );
                }).toList(),
                onChanged: enabled && selectedCountryId != null ? (int? value) {
                  setModalState(() {
                    print('🏙️ [TrainingCenter] City selection changed from $selectedCityId to $value');
                    onChanged(value);
                  });
                } : null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Accept training center
  void _acceptTrainingCenter(TrainingCenter trainingCenter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('قبول مركز التدريب'),
          content: Text('Are you sure you want to accept "${trainingCenter.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performAcceptTrainingCenter(trainingCenter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  // Reject training center
  void _rejectTrainingCenter(TrainingCenter trainingCenter) {
    final rejectionReasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رفض مركز التدريب'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to reject "${trainingCenter.name}"?'),
                const SizedBox(height: 16),
                const Text(
                  'Rejection Reason *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: rejectionReasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason for rejection',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rejection reason is required';
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
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _performRejectTrainingCenter(trainingCenter, rejectionReasonController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // Perform accept training center
  Future<void> _performAcceptTrainingCenter(TrainingCenter trainingCenter) async {
    try {
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
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Accepting Training Center...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final response = await TrainingCenterService.acceptTrainingCenter(trainingCenter.id!);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (response.success) {
        // Refresh the data
        Get.find<TrainingCenterDataProvider>().refreshData();
        
        // Show success message
        _showSuccessToast(response.messageEnText);
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      _showErrorToast(e.toString());
    }
  }

  // Perform reject training center
  Future<void> _performRejectTrainingCenter(TrainingCenter trainingCenter, String rejectionReason) async {
    try {
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
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Rejecting Training Center...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final response = await TrainingCenterService.rejectTrainingCenter(trainingCenter.id!, rejectionReason: rejectionReason);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (response.success) {
        // Refresh the data
        Get.find<TrainingCenterDataProvider>().refreshData();
        
        // Show success message
        _showSuccessToast(response.messageEnText);
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      _showErrorToast(e.toString());
    }
  }

  void _showViewTrainingCenterDialog(BuildContext context, TrainingCenter trainingCenter) {
    ModalDialog.show(
      context: context,
      title: 'Training Center Details',
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
                  // Training Center Information Section
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
                              'Training Center Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Center Name', trainingCenter.name),
                        if (trainingCenter.description != null && trainingCenter.description!.isNotEmpty)
                          _buildDetailRow('Description', trainingCenter.description!),
                        if (trainingCenter.address != null && trainingCenter.address!.isNotEmpty)
                          _buildDetailRow('Address', trainingCenter.address!),
                        
                        // Country and City Information
                        GetBuilder<CityDataProvider>(
                          builder: (cityProvider) {
                            String countryName = _getCountryNameSync(trainingCenter, cityProvider);
                            String cityName = _getCityNameSync(trainingCenter, cityProvider);
                            
                            return Column(
                              children: [
                                if (countryName != 'No country')
                                  _buildDetailRow('Country', countryName),
                                if (cityName != 'No city')
                                  _buildDetailRow('City', cityName),
                              ],
                            );
                          },
                        ),
                        
                        if (trainingCenter.phone != null && trainingCenter.phone!.isNotEmpty)
                          _buildDetailRow('Phone', trainingCenter.phone!),
                        if (trainingCenter.email != null && trainingCenter.email!.isNotEmpty)
                          _buildDetailRow('Email', trainingCenter.email!),
                        _buildStatusDetailRow(trainingCenter),
                        if (trainingCenter.isRejected && trainingCenter.rejectionReason != null && trainingCenter.rejectionReason!.isNotEmpty)
                          _buildDetailRow('Rejection Reason', trainingCenter.rejectionReason!),
                        if (trainingCenter.createdAt != null)
                          _buildDetailRow('Created At', trainingCenter.createdAt.toString()),
                        if (trainingCenter.updatedAt != null)
                          _buildDetailRow('Updated At', trainingCenter.updatedAt.toString()),
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

  Widget _buildStatusDetailRow(TrainingCenter trainingCenter) {
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
              color: trainingCenter.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              trainingCenter.statusDisplay,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: trainingCenter.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingCenterDataProvider extends GetxController {
  final _trainingCenters = <TrainingCenter>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<TrainingCenter> get trainingCenters => _trainingCenters;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get searchQuery => _searchQuery.value;
  int get totalItems => filteredTrainingCenters.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<TrainingCenter> get filteredTrainingCenters {
    var filtered = _trainingCenters.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((tc) => tc.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((tc) =>
        tc.name.toLowerCase().contains(query) ||
        tc.email.toLowerCase().contains(query) ||
        tc.phone.toLowerCase().contains(query) ||
        tc.address.toLowerCase().contains(query) ||
        tc.website?.toLowerCase().contains(query) == true ||
        tc.description?.toLowerCase().contains(query) == true
      ).toList();
    }
    
    return filtered;
  }
  
  List<TrainingCenter> get pagedTrainingCenters {
    if (totalItems == 0) return const <TrainingCenter>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedTrainingCenters;
    }
    if (end > totalItems) end = totalItems;
    return filteredTrainingCenters.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<List<TrainingCenter>> loadData() async {
    try {
      _isLoading.value = true;
      final response = await TrainingCenterService.getAllTrainingCenters();
      
      if (response.success) {
        _trainingCenters.value = response.data;
        _currentPage.value = 0; // reset page on new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _trainingCenters.clear();
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

