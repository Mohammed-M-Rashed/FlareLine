import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/services/training_center_service.dart';
import 'package:flareline/core/models/training_center_model.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'dart:math';
import 'dart:convert';

class TrainingCenterManagementPage extends LayoutWidget {
  const TrainingCenterManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Training Center Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const TrainingCenterManagementWidget(),
      ],
    );
  }

  void _showAddTrainingCenterForm(BuildContext context, _TrainingCenterDataProvider provider) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    int selectedSpecializationId = 1; // Default to first specialization

    ModalDialog.show(
      context: context,
      title: 'Add Training Center',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutBorderTextFormField(
            labelText: 'Training Center Name',
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Training center name is required';
              }
              if (value.length > 255) {
                return 'Name must not exceed 255 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Address',
            controller: addressController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.length > 20) {
                return 'Phone number must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // TODO: Add specialization dropdown when specialization service is available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Specialization will be set to ID 1 by default. Please implement specialization selection when the service is available.',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Cancel',
              type: ButtonType.normal.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'Create Training Center',
              type: ButtonType.primary.type,
              onTap: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                  Get.find<_TrainingCenterDataProvider>()._showErrorToast('يرجى ملء جميع الحقول المطلوبة');
                  return;
                }

                Navigator.of(context).pop();
                
                final trainingCenterService = Get.find<TrainingCenterService>();
                final newTrainingCenter = await trainingCenterService.createTrainingCenter(
                  name: name,
                  specializationId: selectedSpecializationId,
                  address: address,
                  phone: phone,
                );

                if (newTrainingCenter != null) {
                  provider.addTrainingCenter(newTrainingCenter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTrainingCenterForm(BuildContext context, TrainingCenter trainingCenter, _TrainingCenterDataProvider provider) {
    final nameController = TextEditingController(text: trainingCenter.name);
    final addressController = TextEditingController(text: trainingCenter.address);
    final phoneController = TextEditingController(text: trainingCenter.phone);
    int selectedSpecializationId = trainingCenter.specializationId;

    ModalDialog.show(
      context: context,
      title: 'Edit Training Center',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutBorderTextFormField(
            labelText: 'Training Center Name',
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Training center name is required';
              }
              if (value.length > 255) {
                return 'Name must not exceed 255 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Address',
            controller: addressController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.length > 20) {
                return 'Phone number must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // TODO: Add specialization dropdown when specialization service is available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current specialization: ${trainingCenter.specialization?.name ?? 'ID: $selectedSpecializationId'}. Please implement specialization selection when the service is available.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Cancel',
              type: ButtonType.normal.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'Update Training Center',
              type: ButtonType.primary.type,
              onTap: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                  Get.find<_TrainingCenterDataProvider>()._showErrorToast('يرجى ملء جميع الحقول المطلوبة');
                  return;
                }

                Navigator.of(context).pop();
                
                final trainingCenterService = Get.find<TrainingCenterService>();
                final updatedTrainingCenter = await trainingCenterService.updateTrainingCenter(
                  id: trainingCenter.id!,
                  name: name,
                  address: address,
                  phone: phone,
                );

                if (updatedTrainingCenter != null) {
                  provider.updateTrainingCenter(updatedTrainingCenter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrainingCenter trainingCenter, _TrainingCenterDataProvider provider) {
    // Note: Delete functionality is not available in the API
    ModalDialog.show(
      context: context,
      title: 'Delete Not Available',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Delete functionality is not available for training centers in the current API.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Training centers can only be approved, rejected, or updated.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Close',
              type: ButtonType.primary.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingCenterManagementWidget extends StatelessWidget {
  const TrainingCenterManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<_TrainingCenterDataProvider>(
          init: _TrainingCenterDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, _TrainingCenterDataProvider provider) {
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            'Manage training centers, their specializations, and approval status',
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
                            onTap: provider.isLoading ? null : () {
                              provider.refreshData();
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 160,
                          child: ButtonWidget(
                            btnText: 'Add Training Center',
                            type: 'primary',
                            onTap: () {
                              _showAddTrainingCenterForm(context, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: LoadingWidget(),
                    ),
                  );
                }

                final trainingCenters = provider.trainingCenters;

                if (trainingCenters.isEmpty) {
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
                            _showAddTrainingCenterForm(context, provider);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Training Center count and summary
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
                            '${trainingCenters.length} training center${trainingCenters.length == 1 ? '' : 's'} found',
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
                    const SizedBox(height: 24),
                    
                    // Data table
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => GlobalColors.lightGray,
                            ),
                            horizontalMargin: 8, // Reduced from 24/16 to 8
                            showBottomBorder: true,
                            showCheckboxColumn: false,
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 12, // Reduced from 16/14 to 12
                            ),
                            dividerThickness: 0.5, // Reduced from 1 to 0.5
                            columnSpacing: 8, // Reduced from 32/24 to 8
                            dataTextStyle: TextStyle(
                              fontSize: 11, // Reduced from 15/14 to 11
                              color: Colors.black87,
                            ),
                            dataRowMinHeight: 60, // Reduced from 80 to 60
                            dataRowMaxHeight: 60, // Reduced from 80 to 60
                            headingRowHeight: 45, // Reduced from 60 to 45
                            columns: const [
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
                                    'Specialization',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Contact Info',
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
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Files',
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
                            rows: trainingCenters
                                .map((trainingCenter) => DataRow(
                                      onSelectChanged: (selected) {},
                                      cells: [
                                        // Training Center Name & Info
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 150, // Reduced from 200
                                              maxWidth: 200, // Reduced from 280
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6), // Reduced from 10
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100,
                                                    borderRadius: BorderRadius.circular(6), // Reduced from 8
                                                  ),
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.blue.shade700,
                                                    size: 16, // Reduced from 20
                                                  ),
                                                ),
                                                const SizedBox(width: 8), // Reduced from 12
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        trainingCenter.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12, // Reduced from 15
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (trainingCenter.createdAt != null)
                                                        Text(
                                                          'Created: ${_formatDate(trainingCenter.createdAt!)}',
                                                          style: TextStyle(
                                                            fontSize: 10, // Reduced from 12
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Specialization
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 120, // Reduced from 180
                                              maxWidth: 160, // Reduced from 250
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  trainingCenter.specialization?.name ?? 'No specialization',
                                                  style: const TextStyle(
                                                    fontSize: 11, // Reduced from 14
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (trainingCenter.specialization?.description != null)
                                                  Text(
                                                    trainingCenter.specialization!.description!,
                                                    style: TextStyle(
                                                      fontSize: 9, // Reduced from 12
                                                      color: Colors.grey[600],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Contact Info (Address & Phone)
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 140, // Reduced from 200
                                              maxWidth: 180, // Reduced from 280
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14, // Reduced from 16
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    const SizedBox(width: 4), // Reduced from 6
                                                    Expanded(
                                                      child: Text(
                                                        trainingCenter.address,
                                                        style: const TextStyle(
                                                          fontSize: 11, // Reduced from 14
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4), // Reduced from 6
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 14, // Reduced from 16
                                                      color: Colors.green.shade600,
                                                    ),
                                                    const SizedBox(width: 4), // Reduced from 6
                                                    Text(
                                                      trainingCenter.phone,
                                                      style: const TextStyle(
                                                        fontSize: 11, // Reduced from 14
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Status
                                        DataCell(
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12, // Reduced from 16
                                                vertical: 6, // Reduced from 8
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16), // Reduced from 20
                                                color: trainingCenter.statusColor.withOpacity(0.1),
                                                border: Border.all(
                                                  color: trainingCenter.statusColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                trainingCenter.statusDisplay,
                                                style: TextStyle(
                                                  color: trainingCenter.statusColor,
                                                  fontSize: 10, // Reduced from 13
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Files
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 100, // Reduced from 140
                                              maxWidth: 140, // Reduced from 200
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (trainingCenter.hasFile)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.attach_file,
                                                        size: 14, // Reduced from 16
                                                        color: Colors.blue.shade600,
                                                      ),
                                                      const SizedBox(width: 6), // Reduced from 8
                                                      Expanded(
                                                        child: Text(
                                                          trainingCenter.fileName ?? 'Document',
                                                          style: TextStyle(
                                                            fontSize: 10, // Reduced from 13
                                                            color: Colors.blue.shade700,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Text(
                                                    'No files',
                                                    style: TextStyle(
                                                      fontSize: 10, // Reduced from 13
                                                      color: Colors.grey[500],
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                if (trainingCenter.hasFile)
                                                  Text(
                                                    'Size: ${trainingCenter.fileSizeHuman}',
                                                    style: TextStyle(
                                                      fontSize: 9, // Reduced from 11
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18), // Reduced from 20
                                                onPressed: () {
                                                  _showEditTrainingCenterForm(context, trainingCenter, provider);
                                                },
                                                tooltip: 'Edit Training Center',
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.blue.shade50,
                                                  foregroundColor: Colors.blue.shade700,
                                                  padding: const EdgeInsets.all(6), // Reduced from 8
                                                ),
                                              ),
                                              const SizedBox(width: 6), // Reduced from 8
                                              IconButton(
                                                icon: const Icon(Icons.check_circle, size: 18), // Reduced from 20
                                                onPressed: () {
                                                  _showStatusUpdateDialog(context, trainingCenter, provider);
                                                },
                                                tooltip: 'Update Status',
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.green.shade50,
                                                  foregroundColor: Colors.green.shade700,
                                                  padding: const EdgeInsets.all(6), // Reduced from 8
                                                ),
                                              ),
                                              const SizedBox(width: 6), // Reduced from 8
                                              IconButton(
                                                icon: const Icon(Icons.info_outline, size: 18), // Reduced from 20
                                                onPressed: () {
                                                  _showTrainingCenterDetails(context, trainingCenter);
                                                },
                                                tooltip: 'View Details',
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.purple.shade50,
                                                  foregroundColor: Colors.purple.shade700,
                                                  padding: const EdgeInsets.all(6), // Reduced from 8
                                                ),
                                              ),
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
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text, Color color, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddTrainingCenterForm(BuildContext context, _TrainingCenterDataProvider provider) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    int selectedSpecializationId = 1; // Default to first specialization

    ModalDialog.show(
      context: context,
      title: 'Add Training Center',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutBorderTextFormField(
            labelText: 'Training Center Name',
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Training center name is required';
              }
              if (value.length > 255) {
                return 'Name must not exceed 255 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Address',
            controller: addressController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.length > 20) {
                return 'Phone number must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // TODO: Add specialization dropdown when specialization service is available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Specialization will be set to ID 1 by default. Please implement specialization selection when the service is available.',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Cancel',
              type: ButtonType.normal.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'Create Training Center',
              type: ButtonType.primary.type,
              onTap: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                  Get.find<_TrainingCenterDataProvider>()._showErrorToast('يرجى ملء جميع الحقول المطلوبة');
                  return;
                }

                Navigator.of(context).pop();
                
                final trainingCenterService = Get.find<TrainingCenterService>();
                final newTrainingCenter = await trainingCenterService.createTrainingCenter(
                  name: name,
                  specializationId: selectedSpecializationId,
                  address: address,
                  phone: phone,
                );

                if (newTrainingCenter != null) {
                  provider.addTrainingCenter(newTrainingCenter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTrainingCenterForm(BuildContext context, TrainingCenter trainingCenter, _TrainingCenterDataProvider provider) {
    final nameController = TextEditingController(text: trainingCenter.name);
    final addressController = TextEditingController(text: trainingCenter.address);
    final phoneController = TextEditingController(text: trainingCenter.phone);
    int selectedSpecializationId = trainingCenter.specializationId;

    ModalDialog.show(
      context: context,
      title: 'Edit Training Center',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutBorderTextFormField(
            labelText: 'Training Center Name',
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Training center name is required';
              }
              if (value.length > 255) {
                return 'Name must not exceed 255 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Address',
            controller: addressController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.length > 20) {
                return 'Phone number must not exceed 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // TODO: Add specialization dropdown when specialization service is available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current specialization: ${trainingCenter.specialization?.name ?? 'ID: $selectedSpecializationId'}. Please implement specialization selection when the service is available.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Cancel',
              type: ButtonType.normal.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'Update Training Center',
              type: ButtonType.primary.type,
              onTap: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                  Get.find<_TrainingCenterDataProvider>()._showErrorToast('يرجى ملء جميع الحقول المطلوبة');
                  return;
                }

                Navigator.of(context).pop();
                
                final trainingCenterService = Get.find<TrainingCenterService>();
                final updatedTrainingCenter = await trainingCenterService.updateTrainingCenter(
                  id: trainingCenter.id!,
                  name: name,
                  address: address,
                  phone: phone,
                );

                if (updatedTrainingCenter != null) {
                  provider.updateTrainingCenter(updatedTrainingCenter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, TrainingCenter trainingCenter, _TrainingCenterDataProvider provider) {
    String? selectedStatus;
    final reasonController = TextEditingController();

    ModalDialog.show(
      context: context,
      title: 'Update Training Center Status',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Status: ${trainingCenter.statusDisplay}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: trainingCenter.statusColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select New Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: Text('Approved'),
                  value: 'approved',
                  groupValue: selectedStatus,
                  onChanged: (value) => selectedStatus = value,
                ),
                RadioListTile<String>(
                  title: Text('Rejected'),
                  value: 'rejected',
                  groupValue: selectedStatus,
                  onChanged: (value) => selectedStatus = value,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: 'Reason (Optional)',
            controller: reasonController,
            maxLines: 3,
            hintText: 'Enter reason for status change...',
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Cancel',
              type: ButtonType.normal.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'Update Status',
              type: ButtonType.primary.type,
              onTap: () async {
                if (selectedStatus == null) {
                  Get.find<_TrainingCenterDataProvider>()._showErrorToast('يرجى اختيار حالة جديدة');
                  return;
                }

                Navigator.of(context).pop();
                
                final trainingCenterService = Get.find<TrainingCenterService>();
                final updatedTrainingCenter = await trainingCenterService.updateTrainingCenterStatus(
                  id: trainingCenter.id!,
                  status: selectedStatus!,
                  reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : null,
                );

                if (updatedTrainingCenter != null) {
                  provider.updateTrainingCenter(updatedTrainingCenter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTrainingCenterDetails(BuildContext context, TrainingCenter trainingCenter) {
    ModalDialog.show(
      context: context,
      title: 'Training Center Details',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', trainingCenter.name),
          _buildDetailRow('Specialization', trainingCenter.specialization?.name ?? 'No specialization'),
          _buildDetailRow('Address', trainingCenter.address),
          _buildDetailRow('Phone', trainingCenter.phone),
          _buildDetailRow('Status', trainingCenter.statusDisplay, 
            valueColor: trainingCenter.statusColor),
          _buildDetailRow('Created', trainingCenter.createdAt != null 
            ? _formatDate(trainingCenter.createdAt!) : 'N/A'),
          _buildDetailRow('Updated', trainingCenter.updatedAt != null 
            ? _formatDate(trainingCenter.updatedAt!) : 'N/A'),
          if (trainingCenter.hasFile) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('File Name', trainingCenter.fileName ?? 'N/A'),
                  _buildDetailRow('File Type', trainingCenter.fileType ?? 'N/A'),
                  _buildDetailRow('File Size', trainingCenter.fileSizeHuman),
                ],
              ),
            ),
          ],
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: ButtonWidget(
              btnText: 'Close',
              type: ButtonType.primary.type,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingCenterDataProvider extends GetxController {
  final _trainingCenters = <TrainingCenter>[].obs;
  final _isLoading = false.obs;

  List<TrainingCenter> get trainingCenters => _trainingCenters;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Ensure TrainingCenterService is available
    if (!Get.isRegistered<TrainingCenterService>()) {
      Get.put(TrainingCenterService());
    }
    loadData();
  }

  Future<List<TrainingCenter>> loadData() async {
    _isLoading.value = true;
    try {
      final trainingCenterService = Get.find<TrainingCenterService>();
      final trainingCenters = await trainingCenterService.getTrainingCenters();
      _trainingCenters.value = trainingCenters;
      update(); // Notify GetX that data has changed
      return trainingCenters;
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshData() {
    loadData();
  }

  // Add a new training center to the local array
  void addTrainingCenter(TrainingCenter newTrainingCenter) {
    _trainingCenters.add(newTrainingCenter);
    update(); // Notify GetX that data has changed
  }

  // Update an existing training center in the local array
  void updateTrainingCenter(TrainingCenter updatedTrainingCenter) {
    final index = _trainingCenters.indexWhere((trainingCenter) => trainingCenter.id == updatedTrainingCenter.id);
    if (index != -1) {
      _trainingCenters[index] = updatedTrainingCenter;
      update(); // Notify GetX that data has changed
      
      // Notify global service about the status update
      try {
        if (Get.isRegistered<TrainingCenterNotificationService>()) {
          Get.find<TrainingCenterNotificationService>().notifyStatusUpdate(updatedTrainingCenter);
        }
      } catch (e) {
        print('Could not notify TrainingCenterNotificationService: $e');
      }
    }
  }

  /// Shows a success toast notification for training center operations in Arabic
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

  /// Shows an error toast notification for training center operations in Arabic
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

  /// Shows an info toast notification for training center operations in Arabic
  void _showInfoToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }
}

// Helper method to format dates
String _formatDate(DateTime date) {
  try {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  } catch (e) {
    return 'تاريخ غير صالح';
  }
}
