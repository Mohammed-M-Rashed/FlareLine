import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/services/specialization_service.dart';
import 'package:flareline/core/models/specialization_model.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'dart:math';
import 'dart:convert';

class SpecializationManagementPage extends LayoutWidget {
  const SpecializationManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Specialization Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        SpecializationManagementWidget(),
      ],
    );
  }
}

class SpecializationManagementWidget extends StatelessWidget {
  const SpecializationManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<_SpecializationDataProvider>(
          init: _SpecializationDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, _SpecializationDataProvider provider) {
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
                            'Specialization Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage system specializations, training fields, and educational categories',
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
                          width: 140,
                          child: ButtonWidget(
                            btnText: 'Add Specialization',
                            type: 'primary',
                            onTap: () {
                              _showAddSpecializationForm(context, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Data display section
              Obx(() {
                if (provider.isLoading) {
                  return const LoadingWidget();
                }

                final specializations = provider.specializations;

                if (specializations.isEmpty) {
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
                          'لا توجد تخصصات',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get started by adding your first specialization',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ButtonWidget(
                          btnText: 'Add First Specialization',
                          type: 'primary',
                          onTap: () {
                            _showAddSpecializationForm(context, provider);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialization count and summary
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
                            Icons.school,
                            color: Colors.blue.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${specializations.length} specialization${specializations.length == 1 ? '' : 's'} found',
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
                                    'Description',
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
                            rows: provider.pagedSpecializations
                                .map((specialization) => DataRow(
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
                                            CircleAvatar(
                                              backgroundColor: Colors.green.shade100,
                                              child: Icon(
                                                Icons.school,
                                                color: Colors.green.shade700,
                                                size: 16,
                                              ),
                                              radius: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    specialization.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        child: Text(
                                          specialization.description ?? 'No description',
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
                                        child: Text(
                                          _formatDate(specialization.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
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
                                            _showEditSpecializationForm(context, specialization, provider);
                                          },
                                          tooltip: 'Edit Specialization',
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
              }),
            ],
          ),
        );
      },
    );
  }

  // Add Specialization Form
  void _showAddSpecializationForm(BuildContext context, _SpecializationDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // Loading state for form submission
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: 'Add New Specialization',
      showTitle: true,
      modalType: ModalType.medium,
      footer: StatefulBuilder(
        builder: (BuildContext context, StateSetter setFooterState) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'Creating...' : 'Save',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        // Set loading state
                        setFooterState(() {
                          isSubmitting = true;
                        });
                       
                        try {
                          // Create specialization with new model structure
                          final newSpecialization = Specialization(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                            createdAt: DateTime.now().toIso8601String(),
                            updatedAt: DateTime.now().toIso8601String(),
                          );
                          
                          // Create specialization via API
                          final result = await SpecializationService.createSpecialization(context, newSpecialization);
                          if (result is bool && result) {
                            // Close modal first for smooth UX
                            Get.back();
                            // Show success message
                            Get.find<_SpecializationDataProvider>()._showSuccessToast('تم إنشاء التخصص بنجاح');
                            // Add specialization to local array for instant table update
                            provider.addSpecialization(newSpecialization);
                          } else if (result is String) {
                            try {
                              // Parse the JSON response to extract m_ar message
                              final Map<String, dynamic> responseData = json.decode(result as String);
                              final String? mArMessage = responseData['m_ar'];
                              
                              // Close modal first for smooth UX
                              Get.back();
                              
                              // Show success notification with m_ar message
                              Get.find<_SpecializationDataProvider>()._showSuccessToast(mArMessage ?? 'تم إنشاء التخصص بنجاح');
                              // Add specialization to local array for instant table update
                              provider.addSpecialization(newSpecialization);
                            } catch (e) {
                              // If parsing fails, show the original result
                              Get.back();
                              Get.find<_SpecializationDataProvider>()._showSuccessToast(result.toString());
                              // Add specialization to local array for instant table update
                              provider.addSpecialization(newSpecialization);
                            }
                          }
                        } catch (e) {
                          // Handle any errors
                          Get.find<_SpecializationDataProvider>()._showErrorToast('خطأ في إنشاء التخصص: ${e.toString()}');
                        } finally {
                          // Reset loading state
                          setFooterState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                    type: ButtonType.primary.type,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Stack(
            children: [
              Container(
                width: 800,  // Increased width to accommodate two columns

                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),  // Reduced bottom padding for compact form
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Single column layout for form fields
                        // Name Field
                        OutBorderTextFormField(
                          labelText: 'Specialization Name',
                          hintText: 'Enter specialization name',
                          controller: nameController,
                          enabled: !isSubmitting, // Disable when submitting
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a specialization name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description Field
                        OutBorderTextFormField(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter specialization description (optional)',
                          controller: descriptionController,
                          maxLines: 3,
                          enabled: !isSubmitting, // Disable when submitting
                          validator: (value) {
                            // Description is now optional, so no validation needed
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Info box
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
                                Icons.info_outline,
                                size: 20,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  'Specialization names should be descriptive and reflect the training field or educational category.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
                              'Creating Specialization...',
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
          );
        },
      ),
    );
  }

  // Edit Specialization Form
  void _showEditSpecializationForm(BuildContext context, Specialization specialization, _SpecializationDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: specialization.name);
    final descriptionController = TextEditingController(text: specialization.description);
    
    // Loading state for form submission
    bool isSubmitting = false;

    ModalDialog.show(
      context: context,
      title: 'Edit Specialization',
      showTitle: true,
      modalType: ModalType.medium,
      footer: StatefulBuilder(
        builder: (BuildContext context, StateSetter setFooterState) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'Updating...' : 'Save',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        // Set loading state
                        setFooterState(() {
                          isSubmitting = true;
                        });
                       
                        try {
                          // Create updated specialization with new model structure
                          final updatedSpecialization = Specialization(
                            id: specialization.id,
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                            createdAt: specialization.createdAt,
                            updatedAt: DateTime.now().toIso8601String(),
                          );
                          
                          // Update specialization via API
                          final result = await SpecializationService.updateSpecialization(context, updatedSpecialization);
                          if (result is bool && result) {
                            // Close modal first for smooth UX
                            Get.back();
                            // Show success notification
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Specialization updated successfully'),
                                backgroundColor: Colors.green[600],
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'Close',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                            // Update specialization in local array for instant table update
                            provider.updateSpecialization(updatedSpecialization);
                          } else if (result is String) {
                            try {
                              // Parse the JSON response to extract m_ar message
                              final Map<String, dynamic> responseData = json.decode(result as String);
                              final String? mArMessage = responseData['m_ar'];
                              
                              // Close modal first for smooth UX
                              Get.back();
                              
                              // Show success notification with m_ar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(mArMessage ?? 'تم تحديث التخصص بنجاح'),
                                  backgroundColor: Colors.green[600],
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                              // Update specialization in local array for instant table update
                              provider.updateSpecialization(updatedSpecialization);
                            } catch (e) {
                              // If parsing fails, show the original result
                              Get.back();
                              Get.find<_SpecializationDataProvider>()._showSuccessToast(result.toString());
                              // Update specialization in local array for instant table update
                              provider.updateSpecialization(updatedSpecialization);
                            }
                          }
                        } catch (e) {
                          // Handle any errors
                          Get.find<_SpecializationDataProvider>()._showErrorToast('خطأ في تحديث التخصص: ${e.toString()}');
                        } finally {
                          // Reset loading state
                          setFooterState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                    type: ButtonType.primary.type,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Stack(
            children: [
              Container(
                width: 800,  // Increased width to accommodate two columns
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),  // Reduced bottom padding for compact form
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Single column layout for form fields
                        // Name Field
                        OutBorderTextFormField(
                          labelText: 'Specialization Name',
                          hintText: 'Enter specialization name',
                          controller: nameController,
                          enabled: !isSubmitting, // Disable when submitting
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a specialization name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description Field
                        OutBorderTextFormField(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter specialization description (optional)',
                          controller: descriptionController,
                          maxLines: 3,
                          enabled: !isSubmitting, // Disable when submitting
                          validator: (value) {
                            // Description is now optional, so no validation needed
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Info box
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
                                Icons.info_outline,
                                size: 20,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  'Specialization names should be descriptive and reflect the training field or educational category.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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
                              'Updating Specialization...',
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
          );
        },
      ),
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmation(BuildContext context, Specialization specialization, _SpecializationDataProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Delete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete this specialization?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.school,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              specialization.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (specialization.description?.isNotEmpty == true)
                              Text(
                                specialization.description!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This action cannot be undone and will permanently remove the specialization from the system.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await SpecializationService.deleteSpecialization(context, specialization.id!);
                if (success) {
                  provider.refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Specialization',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }
}

class _SpecializationDataProvider extends GetxController {
  final _specializations = <Specialization>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;

  List<Specialization> get specializations => _specializations;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  int get totalItems => _specializations.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  List<Specialization> get pagedSpecializations {
    if (totalItems == 0) return const <Specialization>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      _currentPage.value = totalPages - 1;
      return pagedSpecializations;
    }
    if (end > totalItems) end = totalItems;
    return _specializations.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<List<Specialization>> loadData() async {
    _isLoading.value = true;
    try {
      final specializations = await SpecializationService.getSpecializations(Get.context!);
      _specializations.value = specializations;
      _currentPage.value = 0;
      update(); // Notify GetX that data has changed
      return specializations;
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshData() {
    loadData();
  }

  // Add a new specialization to the local array
  void addSpecialization(Specialization newSpecialization) {
    _specializations.add(newSpecialization);
    update(); // Notify GetX that data has changed
  }

  // Update an existing specialization in the local array
  void updateSpecialization(Specialization updatedSpecialization) {
    final index = _specializations.indexWhere((specialization) => specialization.id == updatedSpecialization.id);
    if (index != -1) {
      _specializations[index] = updatedSpecialization;
      update(); // Notify GetX that data has changed
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

  /// Shows a success toast notification for specialization operations in Arabic
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

  /// Shows an error toast notification for specialization operations in Arabic
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

  /// Shows an info toast notification for specialization operations in Arabic
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
String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}
