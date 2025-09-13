import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/trainer_model.dart';
import 'package:flareline/core/services/trainer_service.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

class TrainerManagementPage extends LayoutWidget {
  const TrainerManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Trainer Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainerManagementWidget(),
      ],
    );
  }
}

class TrainerManagementWidget extends StatefulWidget {
  const TrainerManagementWidget({super.key});

  @override
  State<TrainerManagementWidget> createState() => _TrainerManagementWidgetState();
}

class _TrainerManagementWidgetState extends State<TrainerManagementWidget> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app becomes visible
      try {
        final provider = Get.find<TrainerDataProvider>();
        if (provider.trainers.isEmpty && !provider.isLoading) {
          provider.loadData();
        }
      } catch (e) {
        // Provider not found, ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TrainerDataProvider>(
          init: Get.put(TrainerDataProvider(), permanent: false),
          global: false,
          builder: (provider) {
            // Ensure provider is properly initialized
            if (provider == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            // Ensure data is loaded if not already loaded
            if (provider.trainers.isEmpty && !provider.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.loadData();
              });
            }
            
            return _buildWidget(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, TrainerDataProvider provider) {
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
                            'Trainer Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage system trainers and their information',
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
                                _showSuccessToast('Trainers data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات المدربين: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (TrainerService.hasTrainerManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Trainer',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddTrainerForm(context);
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
                  if (!TrainerService.hasTrainerManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage trainers. Only System Administrators can access this functionality.',
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

                    final trainers = provider.trainers;

                    if (trainers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد مدربون',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first trainer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Trainer',
                              type: 'primary',
                              onTap: () {
                                _showAddTrainerForm(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trainer count and summary
                        CountSummaryWidgetEn(
                          count: trainers.length,
                          itemName: 'trainer',
                          itemNamePlural: 'trainers',
                          icon: Icons.person,
                          color: Colors.blue,
                          filteredCount: provider.filteredTrainers.length,
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
                                        hintText: 'Search trainers...',
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
                                'Search by name, email, phone, specializations, or qualifications',
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
                                  'Showing ${provider.filteredTrainers.length} result${provider.filteredTrainers.length == 1 ? '' : 's'}',
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
                            if (provider.filteredTrainers.isEmpty) {
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
                                      'No trainers found',
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
                                        'Specializations',
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
                                rows: provider.pagedTrainers
                                    .map((trainer) => DataRow(
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
                                                    // Trainer Avatar or Placeholder
                                                    _buildTrainerPlaceholder(trainer.name),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        trainer.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
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
                               'Search by name, email, phone, specializations, years of experience, qualifications, certifications, or bio',
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
                                'Showing ${provider.filteredTrainers.length} result${provider.filteredTrainers.length == 1 ? '' : 's'}',
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
                          if (provider.filteredTrainers.isEmpty) {
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
                                    'No trainers found',
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
                                      'Specializations',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Experience',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Status',
                                      textAlign: TextAlign.center,
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
                              rows: provider.pagedTrainers
                                  .map((trainer) => DataRow(
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
                                          // Trainer Avatar or Placeholder
                                          _buildTrainerAvatar(trainer.name),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              trainer.name,
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
                                        minWidth: 150,
                                        maxWidth: 200,
                                      ),
                                      child: Text(
                                        trainer.email,
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          trainer.phone,
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
                                         minWidth: 120,
                                         maxWidth: 200,
                                       ),
                                       child: Container(
                                         padding: const EdgeInsets.symmetric(
                                           horizontal: 8,
                                           vertical: 4,
                                         ),
                                         child: Text(
                                           trainer.specializations.isNotEmpty 
                                               ? trainer.specializations.join(', ')
                                               : 'No specializations',
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
                                         maxWidth: 120,
                                       ),
                                       child: Container(
                                         padding: const EdgeInsets.symmetric(
                                           horizontal: 8,
                                           vertical: 4,
                                         ),
                                         child: Text(
                                           trainer.yearsExperience != null 
                                               ? '${trainer.yearsExperience} years'
                                               : 'N/A',
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
                                        minWidth: 80,
                                        maxWidth: 250,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: trainer.statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          trainer.statusDisplay,
                                          style: TextStyle(
                                            color: trainer.statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // View button
                                        IconButton(
                                          icon: const Icon(Icons.visibility, size: 18),
                                          onPressed: () => _showViewTrainerDialog(context, trainer),
                                          tooltip: 'View Details',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey.shade50,
                                            foregroundColor: Colors.grey.shade700,
                                          ),
                                        ),
                                        // Edit button (only for non-rejected trainers)
                                        if (!trainer.isRejected) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () => _showEditTrainerForm(context, trainer),
                                            tooltip: 'Edit Trainer',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.blue.shade50,
                                              foregroundColor: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                        // Accept/Reject buttons (only for pending trainers)
                                        if (trainer.isPending) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.check, size: 18),
                                            onPressed: () => _acceptTrainer(trainer),
                                            tooltip: 'Accept Trainer',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.green.shade50,
                                              foregroundColor: Colors.green.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            onPressed: () => _rejectTrainer(trainer),
                                            tooltip: 'Reject Trainer',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.red.shade50,
                                              foregroundColor: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ],
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

                      // Results summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Showing ${provider.filteredTrainers.length} of ${provider.trainers.length} trainers',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }), // Fixed: Properly close Obx with } and )
            ],
          ),
        );
      },
    );
  }

  // Build trainer avatar with initials
  Widget _buildTrainerAvatar(String name) {
    final initials = name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join('').toUpperCase();
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showAddTrainerForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final bioController = TextEditingController();
    final qualificationsController = TextEditingController();
    final yearsExperienceController = TextEditingController();

    final certificationsController = TextEditingController();
    List<String> selectedSpecializations = [];

    ModalDialog.show(
      context: context,
      title: 'Add New Trainer',
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
                        // Trainer Information Section
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
                                    Icons.person,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Basic Information',
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
                                labelText: 'Full Name *',
                                hintText: 'Enter trainer full name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a trainer name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Trainer name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Email Field
                              OutBorderTextFormField(
                                labelText: 'Email Address *',
                                hintText: 'Enter trainer email',
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
                              OutBorderTextFormField(
                                labelText: 'Phone Number *',
                                hintText: 'Enter trainer phone number',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Specializations Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Specializations *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            hintText: 'Select specialization',
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Web Development', child: Text('Web Development')),
                                            DropdownMenuItem(value: 'Mobile Development', child: Text('Mobile Development')),
                                            DropdownMenuItem(value: 'Data Science', child: Text('Data Science')),
                                            DropdownMenuItem(value: 'Machine Learning', child: Text('Machine Learning')),
                                            DropdownMenuItem(value: 'Artificial Intelligence', child: Text('Artificial Intelligence')),
                                            DropdownMenuItem(value: 'Cybersecurity', child: Text('Cybersecurity')),
                                            DropdownMenuItem(value: 'Cloud Computing', child: Text('Cloud Computing')),
                                            DropdownMenuItem(value: 'DevOps', child: Text('DevOps')),
                                            DropdownMenuItem(value: 'UI/UX Design', child: Text('UI/UX Design')),
                                            DropdownMenuItem(value: 'Project Management', child: Text('Project Management')),
                                            DropdownMenuItem(value: 'Business Analysis', child: Text('Business Analysis')),
                                            DropdownMenuItem(value: 'Digital Marketing', child: Text('Digital Marketing')),
                                            DropdownMenuItem(value: 'Sales Training', child: Text('Sales Training')),
                                            DropdownMenuItem(value: 'Leadership Skills', child: Text('Leadership Skills')),
                                            DropdownMenuItem(value: 'Communication Skills', child: Text('Communication Skills')),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setModalState(() {
                                                if (!selectedSpecializations.contains(value)) {
                                                  selectedSpecializations.add(value);
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedSpecializations.clear();
                                          });
                                        },
                                        icon: const Icon(Icons.clear_all, size: 16),
                                        label: const Text('Clear All'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red.shade700,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedSpecializations.isNotEmpty) ...[
                                    Text(
                                      'Selected Specializations:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedSpecializations.map((specialization) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                specialization,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedSpecializations.remove(specialization);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Years of Experience Field
                              OutBorderTextFormField(
                                labelText: 'Years of Experience',
                                hintText: 'Enter years of experience (0-100)',
                                controller: yearsExperienceController,
                                enabled: !isSubmitting,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final years = int.tryParse(value.trim());
                                    if (years == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (years < 0 || years > 100) {
                                      return 'Years of experience must be between 0 and 100';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Qualifications Field
                              OutBorderTextFormField(
                                labelText: 'Qualifications',
                                hintText: 'Enter trainer qualifications and certifications',
                                controller: qualificationsController,
                                enabled: !isSubmitting,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              
                              // Certifications Field
                              OutBorderTextFormField(
                                labelText: 'Certifications',
                                hintText: 'Enter certifications (comma-separated)',
                                controller: certificationsController,
                                enabled: !isSubmitting,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              
                              // Bio Field
                              OutBorderTextFormField(
                                labelText: 'Bio',
                                hintText: 'Enter trainer bio/description (optional)',
                                controller: bioController,
                                enabled: !isSubmitting,
                                maxLines: 4,
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
                                'Creating Trainer...',
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
          if (selectedSpecializations.isEmpty) {
            _showErrorToast('Please select at least one specialization');
            return;
          }
          try {
                         final request = TrainerCreateRequest(
               name: nameController.text.trim(),
               email: emailController.text.trim(),
               phone: phoneController.text.trim(),
               bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
               qualifications: qualificationsController.text.trim().isEmpty ? null : qualificationsController.text.trim(),
               yearsExperience: yearsExperienceController.text.trim().isNotEmpty ? int.tryParse(yearsExperienceController.text.trim()) : null,
               specializations: selectedSpecializations,
               certifications: certificationsController.text.trim().isEmpty ? null : certificationsController.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
             );
            
                         final response = await TrainerService.createTrainer(request);
             
             if (response.success) {
               // Refresh the data
               try {
                 Get.find<TrainerDataProvider>().refreshData();
               } catch (e) {
                 // Provider not found, ignore
               }
                
               // Close modal
               Get.back();
                
               // Show success message
               _showSuccessToast('Trainer created successfully');
             } else {
               throw Exception(response.messageEn);
             }
          } catch (e) {
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }

  void _showEditTrainerForm(BuildContext context, Trainer trainer) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: trainer.name);
    final emailController = TextEditingController(text: trainer.email);
    final phoneController = TextEditingController(text: trainer.phone);
    final bioController = TextEditingController(text: trainer.bio ?? '');
    final qualificationsController = TextEditingController(text: trainer.qualifications ?? '');
    final yearsExperienceController = TextEditingController(text: trainer.yearsExperience?.toString() ?? '');

    final certificationsController = TextEditingController(text: trainer.certifications?.join(', ') ?? '');
    List<String> selectedSpecializations = List<String>.from(trainer.specializations);

    ModalDialog.show(
      context: context,
      title: 'Edit Trainer',
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
                        // Basic Information Section
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
                                    Icons.person,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Basic Information',
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
                                labelText: 'Full Name *',
                                hintText: 'Enter trainer full name',
                                controller: nameController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a trainer name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Trainer name must not exceed 255 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                               
                              // Email Field
                              OutBorderTextFormField(
                                labelText: 'Email Address *',
                                hintText: 'Enter trainer email',
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
                              OutBorderTextFormField(
                                labelText: 'Phone Number *',
                                hintText: 'Enter trainer phone number',
                                controller: phoneController,
                                enabled: !isSubmitting,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Professional Information Section
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
                                    Icons.work,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Professional Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Specializations Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Specializations *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            hintText: 'Select specialization',
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Web Development', child: Text('Web Development')),
                                            DropdownMenuItem(value: 'Mobile Development', child: Text('Mobile Development')),
                                            DropdownMenuItem(value: 'Data Science', child: Text('Data Science')),
                                            DropdownMenuItem(value: 'Machine Learning', child: Text('Machine Learning')),
                                            DropdownMenuItem(value: 'Artificial Intelligence', child: Text('Artificial Intelligence')),
                                            DropdownMenuItem(value: 'Cybersecurity', child: Text('Cybersecurity')),
                                            DropdownMenuItem(value: 'Cloud Computing', child: Text('Cloud Computing')),
                                            DropdownMenuItem(value: 'DevOps', child: Text('DevOps')),
                                            DropdownMenuItem(value: 'UI/UX Design', child: Text('UI/UX Design')),
                                            DropdownMenuItem(value: 'Project Management', child: Text('Project Management')),
                                            DropdownMenuItem(value: 'Business Analysis', child: Text('Business Analysis')),
                                            DropdownMenuItem(value: 'Digital Marketing', child: Text('Digital Marketing')),
                                            DropdownMenuItem(value: 'Sales Training', child: Text('Sales Training')),
                                            DropdownMenuItem(value: 'Leadership Skills', child: Text('Leadership Skills')),
                                            DropdownMenuItem(value: 'Communication Skills', child: Text('Communication Skills')),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setModalState(() {
                                                if (!selectedSpecializations.contains(value)) {
                                                  selectedSpecializations.add(value);
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setModalState(() {
                                            selectedSpecializations.clear();
                                          });
                                        },
                                        icon: const Icon(Icons.clear_all, size: 16),
                                        label: const Text('Clear All'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red.shade700,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedSpecializations.isNotEmpty) ...[
                                    Text(
                                      'Selected Specializations:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedSpecializations.map((specialization) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                specialization,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedSpecializations.remove(specialization);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Years of Experience Field
                              OutBorderTextFormField(
                                labelText: 'Years of Experience',
                                hintText: 'Enter years of experience (0-100)',
                                controller: yearsExperienceController,
                                enabled: !isSubmitting,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final years = int.tryParse(value.trim());
                                    if (years == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (years < 0 || years > 100) {
                                      return 'Years of experience must be between 0 and 100';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Qualifications Field
                              OutBorderTextFormField(
                                labelText: 'Qualifications',
                                hintText: 'Enter trainer qualifications and certifications',
                                controller: qualificationsController,
                                enabled: !isSubmitting,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              
                              // Certifications Field
                              OutBorderTextFormField(
                                labelText: 'Certifications',
                                hintText: 'Enter certifications (comma-separated)',
                                controller: certificationsController,
                                enabled: !isSubmitting,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Additional Information Section
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
                                    Icons.info,
                                    color: Colors.orange.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Additional Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Bio Field
                              OutBorderTextFormField(
                                labelText: 'Bio',
                                hintText: 'Enter trainer bio/description (optional)',
                                controller: bioController,
                                enabled: !isSubmitting,
                                maxLines: 4,
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
                                'Updating Trainer...',
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
          if (selectedSpecializations.isEmpty) {
            _showErrorToast('Please select at least one specialization');
            return;
          }
          try {
                         final request = TrainerUpdateRequest(
               id: trainer.id!,
               name: nameController.text.trim(),
               email: emailController.text.trim(),
               phone: phoneController.text.trim(),
               bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
               qualifications: qualificationsController.text.trim().isEmpty ? null : qualificationsController.text.trim(),
               yearsExperience: yearsExperienceController.text.trim().isNotEmpty ? int.tryParse(yearsExperienceController.text.trim()) : null,
               specializations: selectedSpecializations,
               certifications: certificationsController.text.trim().isEmpty ? null : certificationsController.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
             );
            
                         final response = await TrainerService.updateTrainer(request);
             
             if (response.success) {
               // Refresh the data
               try {
                 Get.find<TrainerDataProvider>().refreshData();
               } catch (e) {
                 // Provider not found, ignore
               }
                
               // Close modal
               Get.back();
                
               // Show success message
               _showSuccessToast('Trainer updated successfully');
             } else {
               throw Exception(response.messageEn);
             }
          } catch (e) {
            _showErrorToast(e.toString());
          }
        }
      },
    );
  }





  // Accept trainer
  void _acceptTrainer(Trainer trainer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Trainer'),
          content: Text('Are you sure you want to accept "${trainer.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performAcceptTrainer(trainer);
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

  // Reject trainer
  void _rejectTrainer(Trainer trainer) {
    final rejectionReasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Trainer'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to reject "${trainer.name}"?'),
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
                  await _performRejectTrainer(trainer, rejectionReasonController.text.trim());
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

  // Perform accept trainer
  Future<void> _performAcceptTrainer(Trainer trainer) async {
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
                    'Accepting Trainer...',
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

      final response = await TrainerService.acceptTrainer(trainer.id!);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (response.success) {
        // Re-fetch all trainers from the database
        try {
          final provider = Get.find<TrainerDataProvider>();
          await provider.refreshData();
        } catch (e) {
          // Provider not found, ignore
        }
        
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

  // Perform reject trainer
  Future<void> _performRejectTrainer(Trainer trainer, String rejectionReason) async {
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
                    'Rejecting Trainer...',
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

      final response = await TrainerService.rejectTrainer(trainer.id!, rejectionReason: rejectionReason);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (response.success) {
        // Re-fetch all trainers from the database
        try {
          final provider = Get.find<TrainerDataProvider>();
          await provider.refreshData();
        } catch (e) {
          print(e.toString());
          // Provider not found, ignore
        }
        
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

  /// Shows a success toast notification for trainer operations in Arabic
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

  /// Shows an error toast notification for trainer operations in Arabic
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

  void _showViewTrainerDialog(BuildContext context, Trainer trainer) {
    ModalDialog.show(
      context: context,
      title: 'Trainer Details',
      showTitle: true,
      modalType: ModalType.large,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
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
                          Icons.person,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trainer Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Trainer Name', trainer.name),
                    if (trainer.email != null && trainer.email!.isNotEmpty)
                      _buildDetailRow('Email', trainer.email!),
                    if (trainer.phone != null && trainer.phone!.isNotEmpty)
                      _buildDetailRow('Phone', trainer.phone!),
                    _buildStatusRow('Status', trainer.statusDisplay, trainer.statusColor),
                    if (trainer.rejectionReason != null && trainer.rejectionReason!.isNotEmpty)
                      _buildRejectionReasonRow('Rejection Reason', trainer.rejectionReason!),
                    if (trainer.createdAt != null)
                      _buildDetailRow('Created At', _formatTrainerDate(trainer.createdAt!)),
                    if (trainer.updatedAt != null)
                      _buildDetailRow('Updated At', _formatTrainerDate(trainer.updatedAt!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Professional Information Section
              if (trainer.bio != null || trainer.qualifications != null || trainer.yearsExperience != null)
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
                            Icons.work,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Professional Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (trainer.bio != null && trainer.bio!.isNotEmpty)
                        _buildDetailRow('Bio', trainer.bio!),
                      if (trainer.qualifications != null && trainer.qualifications!.isNotEmpty)
                        _buildDetailRow('Qualifications', trainer.qualifications!),
                      if (trainer.yearsExperience != null)
                        _buildDetailRow('Years of Experience', '${trainer.yearsExperience} years'),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Specializations and Certifications Section
              if (trainer.specializations.isNotEmpty || (trainer.certifications != null && trainer.certifications!.isNotEmpty))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Specializations & Certifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (trainer.specializations.isNotEmpty)
                        _buildListDetailRow('Specializations', trainer.specializations),
                      if (trainer.certifications != null && trainer.certifications!.isNotEmpty)
                        _buildListDetailRow('Certifications', trainer.certifications!),
                    ],
                  ),
                ),
            ],
          ),
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

  Widget _buildListDetailRow(String label, List<String> values) {
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
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: values.map((value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            )).toList(),
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
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTrainerDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TrainerDataProvider extends GetxController {
  final _trainers = <Trainer>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<Trainer> get trainers => _trainers;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get searchQuery => _searchQuery.value;
  int get totalItems => filteredTrainers.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<Trainer> get filteredTrainers {
    var filtered = _trainers.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((t) => t.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
             filtered = filtered.where((t) =>
           t.name.toLowerCase().contains(query) ||
           t.email.toLowerCase().contains(query) ||
           t.phone.toLowerCase().contains(query) ||
           t.specializations.any((spec) => spec.toLowerCase().contains(query)) ||
           (t.yearsExperience?.toString().toLowerCase().contains(query) ?? false) ||
           (t.qualifications?.toLowerCase().contains(query) ?? false) ||
           (t.certifications?.any((cert) => cert.toLowerCase().contains(query)) ?? false) ||
           t.bio?.toLowerCase().contains(query) == true
         ).toList();
    }
    
    return filtered;
  }
  
  List<Trainer> get pagedTrainers {
    if (totalItems == 0) return const <Trainer>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedTrainers;
    }
    if (end > totalItems) end = totalItems;
    return filteredTrainers.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure data is loaded when controller is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<List<Trainer>> loadData() async {
    try {
      _isLoading.value = true;
      update(); // Update UI to show loading state
      
      // Add timeout to prevent infinite loading
      final response = await TrainerService.getAllTrainers().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection and try again.');
        },
      );
      
      if (response.success) {
        _trainers.value = response.data;
        _currentPage.value = 0; // reset page on new data
        update(); // Update UI with new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _trainers.clear();
      // Log the error for debugging
      print('Error loading trainers: $e');
      update(); // Update UI to show error state
      rethrow;
    } finally {
      _isLoading.value = false;
      update(); // Ensure loading state is updated
    }
  }

  Future<void> refreshData() async {
    try {
      await loadData();
      // loadData already calls update(), so no need to call it again
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

  // Method to manually trigger data loading (useful for debugging)
  void forceLoadData() {
    loadData();
  }

  // Update trainer status immediately without API call
  void updateTrainerStatus(int trainerId, String newStatus, {String? rejectionReason}) {
    final index = _trainers.indexWhere((trainer) => trainer.id == trainerId);
    if (index != -1) {
      final updatedTrainer = _trainers[index].copyWith(
        status: newStatus,
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );
      _trainers[index] = updatedTrainer;
      update(); // Trigger UI update
    }
  }

  // Update trainer data immediately without API call
  void updateTrainerInList(Trainer updatedTrainer) {
    final index = _trainers.indexWhere((trainer) => trainer.id == updatedTrainer.id);
    if (index != -1) {
      _trainers[index] = updatedTrainer;
      update(); // Trigger UI update
    }
  }

}
