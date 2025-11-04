import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/education_level_model.dart';
import 'package:flareline/core/services/education_level_service.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';
import 'package:flareline/core/i18n/strings_ar.dart';

class EducationLevelsManagementPage extends LayoutWidget {
  const EducationLevelsManagementPage({super.key});

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        EducationLevelsManagementWidget(),
      ],
    );
  }

}

class EducationLevelsManagementWidget extends StatefulWidget {
  const EducationLevelsManagementWidget({super.key});

  @override
  State<EducationLevelsManagementWidget> createState() => _EducationLevelsManagementWidgetState();
}

class _EducationLevelsManagementWidgetState extends State<EducationLevelsManagementWidget> {
  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<EducationLevelDataProvider>(
          init: EducationLevelDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, EducationLevelDataProvider provider) {
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
                            'Education Levels Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage education levels in the system',
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
                                _showSuccessToast('Education levels data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات مستويات التعليم: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Builder(
                          builder: (context) {
                            if (EducationLevelService.hasEducationLevelManagementPermission()) {
                              return SizedBox(
                                width: 140,
                                child: ButtonWidget(
                                  btnText: 'Add Level',
                                  type: 'primary',
                                  onTap: () {
                                    _showAddEducationLevelForm(context);
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
                  if (!EducationLevelService.hasEducationLevelManagementPermission()) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You do not have permission to manage education levels. Only System Administrators can access this functionality.',
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

                    final educationLevels = provider.educationLevels;

                    if (educationLevels.isEmpty) {
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
                              'لا توجد مستويات تعليم',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get started by adding your first education level',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ButtonWidget(
                              btnText: 'Add First Level',
                              type: 'primary',
                              onTap: () {
                                _showAddEducationLevelForm(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Education levels count and summary
                        CountSummaryWidgetEn(
                          count: educationLevels.length,
                          itemName: 'education level',
                          itemNamePlural: 'education levels',
                          icon: Icons.school,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        
                        // Education Levels Table
                        _buildEducationLevelsTable(context, provider),
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

  void _showAddEducationLevelForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    ModalDialog.show(
      context: context,
      title: 'Add New Education Level',
      showTitle: true,
      modalType: ModalType.medium,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false; // Loading state for form submission
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Education Level Information Section
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
                                    'Education Level Information',
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
                                labelText: 'Education Level Name',
                                hintText: 'Enter education level name',
                                controller: nameController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an education level name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Education level name must not exceed 255 characters';
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
                                'Creating Education Level...',
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
                      const Text('Creating Education Level...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = EducationLevelCreateRequest(
              name: nameController.text.trim(),
            );
            
            final response = await EducationLevelService.createEducationLevel(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<EducationLevelDataProvider>().refreshData();
               
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

  void _showEditEducationLevelForm(BuildContext context, EducationLevel educationLevel) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: educationLevel.name);

    ModalDialog.show(
      context: context,
      title: 'Edit Education Level',
      showTitle: true,
      modalType: ModalType.medium,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSubmitting = false; // Loading state for form submission
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Education Level Information Section
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
                                    'Education Level Information',
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
                                labelText: 'Education Level Name',
                                hintText: 'Enter education level name',
                                controller: nameController,
                                enabled: !isSubmitting, // Disable when submitting
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an education level name';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Education level name must not exceed 255 characters';
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
                                'Updating Education Level...',
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
                      const Text('Updating Education Level...'),
                    ],
                  ),
                ),
              );
            },
          );
          
          try {
            final request = EducationLevelUpdateRequest(
              id: educationLevel.id!,
              name: nameController.text.trim(),
            );
            
            final response = await EducationLevelService.updateEducationLevel(request);
            
            // Close loading dialog
            Navigator.of(context).pop();
            
            if (response.success) {
              // Refresh the data
              Get.find<EducationLevelDataProvider>().refreshData();
               
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

  String _formatEducationLevelDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Shows a success toast notification for education level operations in Arabic
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

  /// Shows an error toast notification for education level operations in Arabic
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

  void _showViewEducationLevelDialog(BuildContext context, EducationLevel educationLevel) {
    ModalDialog.show(
      context: context,
      title: 'Education Level Details',
      showTitle: true,
      modalType: ModalType.medium,
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
        height: MediaQuery.of(context).size.height * 0.4,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Education Level Information Section
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
                              'Education Level Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Education Level Name', educationLevel.name),
                        if (educationLevel.createdAt != null)
                          _buildDetailRow('Created At', _formatEducationLevelDate(educationLevel.createdAt)),
                        if (educationLevel.updatedAt != null)
                          _buildDetailRow('Updated At', _formatEducationLevelDate(educationLevel.updatedAt)),
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

  Widget _buildEducationLevelsTable(BuildContext context, EducationLevelDataProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth < 1024;
        
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: isMobile ? _buildMobileEducationLevelHeader() : _buildDesktopEducationLevelHeader(),
              ),
              // Table Body
              ...provider.pagedEducationLevels.asMap().entries.map((entry) {
                final index = entry.key;
                final educationLevel = entry.value;
                return _buildEducationLevelRow(context, provider, educationLevel, index, isMobile, isTablet);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileEducationLevelHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Education Level',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopEducationLevelHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Education Level Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationLevelRow(BuildContext context, EducationLevelDataProvider provider, EducationLevel educationLevel, int index, bool isMobile, bool isTablet) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: isMobile ? _buildMobileEducationLevelRow(context, provider, educationLevel) : _buildDesktopEducationLevelRow(context, provider, educationLevel),
    );
  }

  Widget _buildMobileEducationLevelRow(BuildContext context, EducationLevelDataProvider provider, EducationLevel educationLevel) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                educationLevel.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${educationLevel.id ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () {
                  _showEditEducationLevelForm(context, educationLevel);
                },
                tooltip: 'Edit Education Level',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopEducationLevelRow(BuildContext context, EducationLevelDataProvider provider, EducationLevel educationLevel) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            educationLevel.id?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            educationLevel.name,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () {
                  _showEditEducationLevelForm(context, educationLevel);
                },
                tooltip: 'Edit Education Level',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EducationLevelDataProvider extends GetxController {
  final _educationLevels = <EducationLevel>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;

  List<EducationLevel> get educationLevels => _educationLevels;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  int get totalItems => _educationLevels.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  List<EducationLevel> get pagedEducationLevels {
    if (totalItems == 0) return const <EducationLevel>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedEducationLevels;
    }
    if (end > totalItems) end = totalItems;
    return _educationLevels.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<List<EducationLevel>> loadData() async {
    try {
      _isLoading.value = true;
      final response = await EducationLevelService.getAllEducationLevels();
      
      if (response.success) {
        _educationLevels.value = response.data;
        _currentPage.value = 0; // reset page on new data
        return response.data;
      } else {
        throw Exception(response.messageEn);
      }
    } catch (e) {
      _educationLevels.clear();
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

}
