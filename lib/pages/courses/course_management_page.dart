import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/services/course_service.dart';
import 'package:flareline/core/services/specialization_service.dart';
import 'package:flareline/core/models/course_model.dart';
import 'package:flareline/core/models/specialization_model.dart';
import 'package:flareline/core/widgets/course_file_upload.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'dart:math';
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Added for PlatformFile

class CourseManagementPage extends LayoutWidget {
  const CourseManagementPage({super.key});



  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const CourseManagementWidget(),
      ],
    );
  }
}

class CourseManagementWidget extends StatelessWidget {
  const CourseManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<_CourseDataProvider>(
          init: _CourseDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, _CourseDataProvider provider) {
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

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة الدورات',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'إدارة دورات التدريب والوصف والمدة',
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
                        btnText: provider.isLoading ? 'جاري التحميل...' : 'تحديث',
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
                        btnText: 'إضافة دورة',
                        type: 'primary',
                        onTap: () {
                          _showAddCourseForm(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Specialization filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter by Specialization:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: provider.selectedSpecializationFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    hint: const Text('Select Specialization'),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Specializations')),
                      ...provider.specializations.map((specialization) => DropdownMenuItem<String>(
                        value: specialization.id.toString(),
                        child: Text(
                          specialization.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )).toList(),
                    ],
                    onChanged: provider.isLoadingSpecializations ? null : (String? newValue) {
                      if (newValue != null) {
                        provider.setSelectedSpecializationFilter(newValue);
                      }
                    },
                  )),
                ),
                const SizedBox(width: 12),
                if (provider.selectedSpecializationFilter != 'all')
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      provider.setSelectedSpecializationFilter('all');
                    },
                    tooltip: 'Clear Filter',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Obx(() {
            if (provider.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: LoadingWidget(),
                ),
              );
            }

            final courses = provider.filteredCourses;

            if (courses.isEmpty) {
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
                      'لا توجد دورات',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بإضافة دورتك الأولى',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      btnText: 'إضافة أول دورة',
                      type: 'primary',
                      onTap: () {
                        _showAddCourseForm(context);
                      },
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course count and summary
                CountSummaryWidget(
                  count: courses.length,
                  itemName: 'دورة',
                  itemNamePlural: 'دورات',
                  icon: Icons.school,
                  color: Colors.blue,
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
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'عنوان الدورة',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'كود الدورة',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'التخصص',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'المرفقات',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'الإجراءات',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            numeric: false,
                          ),
                        ],
                        rows: courses
                            .map((course) => DataRow(
                                  onSelectChanged: (selected) {},
                                  cells: [
                                    DataCell(
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 150, // Reduced from 200
                                          maxWidth: 200, // Reduced from 250
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6), // Reduced from 8
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(6), // Reduced from 8
                                              ),
                                              child: Icon(
                                                Icons.school,
                                                size: 16, // Reduced from 20
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            const SizedBox(width: 8), // Reduced from 12
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    course.title,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12, // Reduced from 15
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
                                        constraints: const BoxConstraints(
                                          minWidth: 80, // Reduced from 100
                                          maxWidth: 120, // Reduced from 120
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, // Reduced from 12
                                            vertical: 6, // Reduced from 8
                                          ),
                                          child: Text(
                                            course.code,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11, // Reduced from 14
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
                                          minWidth: 80, // Reduced from 100
                                          maxWidth: 300, // Reduced from 120
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, // Reduced from 12
                                            vertical: 6, // Reduced from 8
                                          ),
                                          child: Text(
                                            course.specializationDisplayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11, // Reduced from 14
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
                                          minWidth: 80, // Reduced from 100
                                          maxWidth: 100, // Reduced from 120
                                        ),
                                        child: course.hasFileAttachment
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, // Reduced from 12
                                                  vertical: 6, // Reduced from 8
                                                ),
                                                decoration: BoxDecoration(
                                                  color: course.fileAttachmentColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(5), // Reduced from 20
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      course.fileAttachmentIcon,
                                                      size: 14, // Reduced from 16
                                                      color: course.fileAttachmentColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        course.fileAttachmentExtension,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 10, // Reduced from 12
                                                          color: course.fileAttachmentColor,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, // Reduced from 12
                                                  vertical: 6, // Reduced from 8
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius: BorderRadius.circular(5), // Reduced from 20
                                                ),
                                                child: Text(
                                                  'لا يوجد',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10, // Reduced from 12
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 100, // Reduced from 120
                                          maxWidth: 120, // Reduced from 140
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 18, // Reduced from 22
                                              ),
                                              onPressed: () {
                                                _showEditCourseForm(context, course, provider);
                                              },
                                              tooltip: 'تعديل الدورة',
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.blue.shade50,
                                                foregroundColor: Colors.blue.shade700,
                                                padding: const EdgeInsets.all(6), // Reduced from 8
                                              ),
                                            ),
                                            const SizedBox(width: 6), // Reduced from 8
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility,
                                                size: 18, // Reduced from 22
                                              ),
                                              onPressed: () {
                                                _showCourseDetails(context, course);
                                              },
                                              tooltip: 'عرض التفاصيل',
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.grey.shade50,
                                                foregroundColor: Colors.grey.shade700,
                                                padding: const EdgeInsets.all(6), // Reduced from 8
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
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddCourseForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final specializationIdController = TextEditingController();
    String? selectedFileBase64; // Store selected file as BASE64 (for display)
    PlatformFile? selectedFileAttachment; // Store selected file (for upload)
    
    // Loading state for form submission
    bool isSubmitting = false;
    // State for specializations dropdown
    List<Specialization> specializations = [];
    Specialization? selectedSpecialization;
    bool isLoadingSpecializations = true;

    // Load specializations when form opens
    Future<void> loadSpecializations() async {
      try {
        final specs = await SpecializationService.getSpecializations(context);
        specializations = specs;
        if (specs.isNotEmpty) {
          selectedSpecialization = specs.first;
          specializationIdController.text = specs.first.id.toString();
        }
      } catch (e) {
        print('Error loading specializations: $e');
      } finally {
        isLoadingSpecializations = false;
      }
    }

    ModalDialog.show(
      context: context,
      title: 'إضافة دورة جديدة',
      showTitle: true,
      modalType: ModalType.large,
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
                    btnText: 'إلغاء',
                    onTap: () => Get.back(),
                    type: ButtonType.normal.type,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'جاري الإنشاء...' : 'حفظ',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        // Additional validation for specialization
                        if (selectedSpecialization == null) {
                          Get.find<_CourseDataProvider>()._showErrorToast('يرجى اختيار التخصص');
                          return;
                        }
                        
                        // Set loading state
                        setFooterState(() {
                          isSubmitting = true;
                        });
                       
                        try {
                          // Create course with new model structure
                          final newCourse = Course(
                            specializationId: int.parse(specializationIdController.text.trim()),
                            code: codeController.text.trim(),
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            fileAttachment: null, // Don't send base64 in request when using multipart
                            createdBy: 'admin', // Set creator as System Administrator
                          );
                          
                          print('📚 Creating course: ${newCourse.title} with specialization ID: ${newCourse.specializationId}');
                          
                          // Create course via API
                          final result = await CourseService.createCourse(
                            context, 
                            newCourse,
                            fileAttachment: selectedFileAttachment, // Pass file attachment for multipart upload
                          );
                          if (result) {
                            print('✅ Course created successfully, refreshing data...');
                            
                            // Close modal first for smooth UX
                            Get.back();
                            
                            // Wait a moment for the server to process the new course
                            await Future.delayed(const Duration(milliseconds: 500));
                            
                            // Refresh the data from server to get complete course information
                            await Get.find<_CourseDataProvider>().forceRefresh();
                            
                            // Show success message
                            Get.find<_CourseDataProvider>()._showSuccessToast('تم إنشاء الدورة بنجاح');
                          } else {
                            print('❌ Course creation failed');
                            Get.find<_CourseDataProvider>()._showErrorToast('فشل في إنشاء الدورة');
                          }
                        } catch (e) {
                          print('💥 Error creating course: $e');
                          // Handle any errors
                          Get.find<_CourseDataProvider>()._showErrorToast('خطأ في إنشاء الدورة: ${e.toString()}');
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
        builder: (BuildContext context, StateSetter setFormState) {
          // Load specializations when form is first built
          if (isLoadingSpecializations && specializations.isEmpty) {
            loadSpecializations().then((_) {
              setFormState(() {});
            });
          }

          return Container(

            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              minHeight: 500,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Information Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
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
                                'معلومات الدورة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Course Code Field
                          OutBorderTextFormField(
                            labelText: 'كود الدورة *',
                            hintText: 'أدخل كود الدورة (مثل: CS101)',
                            controller: codeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كود الدورة';
                              }
                              if (value.length > 50) {
                                return 'كود الدورة يجب أن يكون أقل من 50 حرف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Title Field
                          OutBorderTextFormField(
                            labelText: 'عنوان الدورة *',
                            hintText: 'أدخل عنوان الدورة',
                            controller: titleController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال عنوان الدورة';
                              }
                              if (value.length > 255) {
                                return 'عنوان الدورة يجب أن يكون أقل من 255 حرف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Description Field
                          OutBorderTextFormField(
                            labelText: 'وصف الدورة',
                            hintText: 'أدخل وصف الدورة (اختياري)',
                            controller: descriptionController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          
                          // Specialization Dropdown Field
                          isLoadingSpecializations 
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التخصص *', style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التخصص *', style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Specialization>(
                                        value: selectedSpecialization,
                                        isExpanded: true,
                                        hint: Text('اختر التخصص'),
                                        items: specializations.map((Specialization specialization) {
                                          return DropdownMenuItem<Specialization>(
                                            value: specialization,
                                            child: Text(specialization.name),
                                          );
                                        }).toList(),
                                        onChanged: (Specialization? newValue) {
                                          if (newValue != null) {
                                            selectedSpecialization = newValue;
                                            specializationIdController.text = newValue.id.toString();
                                            setFormState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  if (specializationIdController.text.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'يرجى اختيار التخصص',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // File Attachment Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مرفقات الدورة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Center(
                            child: CourseFileUpload(
                              width: 400,
                              height: 150,
                              onFileChanged: (String? base64File) {
                                selectedFileBase64 = base64File;
                              },
                              onFileAttachmentChanged: (PlatformFile? fileAttachment) {
                                selectedFileAttachment = fileAttachment;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditCourseForm(BuildContext context, Course course, _CourseDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: course.code);
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description);
    final specializationIdController = TextEditingController(text: course.specializationId.toString());
    String? selectedFileBase64 = course.fileAttachment; // Initialize with existing file (for display)
    PlatformFile? selectedFileAttachment; // Store new file attachment (for upload)
    
    // Loading state for form submission
    bool isSubmitting = false;
    // State for specializations dropdown
    List<Specialization> specializations = [];
    Specialization? selectedSpecialization;
    bool isLoadingSpecializations = true;

    // Load specializations when form opens
    Future<void> loadSpecializations() async {
      try {
        final specs = await SpecializationService.getSpecializations(context);
        specializations = specs;
        // Find and select the current course's specialization
        selectedSpecialization = specs.firstWhere(
          (spec) => spec.id == course.specializationId,
          orElse: () => specs.isNotEmpty ? specs.first : Specialization(
            id: course.specializationId,
            name: 'Unknown',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
        if (selectedSpecialization != null) {
          specializationIdController.text = selectedSpecialization!.id.toString();
        }
      } catch (e) {
        print('Error loading specializations: $e');
      } finally {
        isLoadingSpecializations = false;
      }
    }

    ModalDialog.show(
      context: context,
      title: 'تعديل الدورة',
      showTitle: true,
      modalType: ModalType.large,
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
                    btnText: 'إلغاء',
                    onTap: () => Get.back(),
                    type: ButtonType.normal.type,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: isSubmitting ? 'جاري التحديث...' : 'حفظ',
                    onTap: isSubmitting ? null : () async {
                      if (formKey.currentState!.validate()) {
                        // Set loading state
                        setFooterState(() {
                          isSubmitting = true;
                        });
                       
                        try {
                          // Create updated course
                          final updatedCourse = Course(
                            id: course.id,
                            specializationId: int.parse(specializationIdController.text.trim()),
                            code: codeController.text.trim(),
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            fileAttachment: null, // Don't send base64 in request when using multipart
                            createdAt: course.createdAt,
                            updatedAt: DateTime.now().toIso8601String(),
                            specialization: course.specialization,
                          );
                          
                          // Update course via API
                          final result = await CourseService.updateCourse(
                            context, 
                            updatedCourse,
                            fileAttachment: selectedFileAttachment, // Pass file attachment for multipart upload
                          );
                          if (result) {
                            // Close modal first for smooth UX
                            Get.back();
                            // Update course in local array for instant table update
                            provider.updateCourse(updatedCourse);
                          }
                        } catch (e) {
                          // Handle any errors
                          Get.find<_CourseDataProvider>()._showErrorToast('خطأ في تحديث الدورة: ${e.toString()}');
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
        builder: (BuildContext context, StateSetter setFormState) {
          // Load specializations when form is first built
          if (isLoadingSpecializations && specializations.isEmpty) {
            loadSpecializations().then((_) {
              setFormState(() {});
            });
          }

          return Container(

            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              minHeight: 500,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Information Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
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
                                'معلومات الدورة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Course Code Field
                          OutBorderTextFormField(
                            labelText: 'كود الدورة *',
                            hintText: 'أدخل كود الدورة (مثل: CS101)',
                            controller: codeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كود الدورة';
                              }
                              if (value.length > 50) {
                                return 'كود الدورة يجب أن يكون أقل من 50 حرف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Title Field
                          OutBorderTextFormField(
                            labelText: 'عنوان الدورة *',
                            hintText: 'أدخل عنوان الدورة',
                            controller: titleController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال عنوان الدورة';
                              }
                              if (value.length > 255) {
                                return 'عنوان الدورة يجب أن يكون أقل من 255 حرف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Description Field
                          OutBorderTextFormField(
                            labelText: 'وصف الدورة',
                            hintText: 'أدخل وصف الدورة (اختياري)',
                            controller: descriptionController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          
                          // Specialization Dropdown Field
                          isLoadingSpecializations 
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التخصص *', style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التخصص *', style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.maxFinite,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Specialization>(
                                        value: selectedSpecialization,
                                        isExpanded: true,
                                        hint: Text('اختر التخصص'),
                                        items: specializations.map((Specialization specialization) {
                                          return DropdownMenuItem<Specialization>(
                                            value: specialization,
                                            child: Text(specialization.name),
                                          );
                                        }).toList(),
                                        onChanged: (Specialization? newValue) {
                                          if (newValue != null) {
                                            selectedSpecialization = newValue;
                                            specializationIdController.text = newValue.id.toString();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  if (specializationIdController.text.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'يرجى اختيار التخصص',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // File Attachment Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مرفقات الدورة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          Center(
                            child: CourseFileUpload(
                              width: 400,
                              height: 150,
                              initialFile: course.fileAttachment,
                              onFileChanged: (String? base64File) {
                                selectedFileBase64 = base64File;
                              },
                              onFileAttachmentChanged: (PlatformFile? fileAttachment) {
                                selectedFileAttachment = fileAttachment;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCourseDetails(BuildContext context, Course course) {
    ModalDialog.show(
      context: context,
      title: 'Course Details',
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
                  // Course Information Section
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
                              'Course Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Course ID', course.id?.toString() ?? 'Not available'),
                        _buildDetailRow('Title', course.title),
                        _buildDetailRow('Description', course.descriptionDisplay),
                        _buildDetailRow('Specialization', course.specializationDisplayName),
                        _buildDetailRow('Specialization ID', course.specializationId.toString()),
                        _buildDetailRow('Creator', course.createdByText),
                        _buildDetailRow('Attachments', course.hasFileAttachment 
                            ? '${course.fileAttachmentExtension} - ${course.fileAttachmentName}'
                            : 'No attachments'),
                        if (course.specialization != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Specialization Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow('Name', course.specialization!.name),
                          _buildDetailRow('Description', course.specialization!.description ?? 'Not available'),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        _buildDetailRow('Created At', course.formattedCreatedAt),
                        _buildDetailRow('Last Updated', course.formattedUpdatedAt),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12, // Reduced from 14 to 12
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12, // Reduced from 14 to 12
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseDataProvider extends GetxController {
  final _courses = <Course>[].obs;
  final _isLoading = false.obs;
  final _specializations = <Specialization>[].obs;
  final _isLoadingSpecializations = false.obs;
  final _selectedSpecializationFilter = 'all'.obs;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading.value;
  List<Specialization> get specializations => _specializations;
  bool get isLoadingSpecializations => _isLoadingSpecializations.value;
  String get selectedSpecializationFilter => _selectedSpecializationFilter.value;
  
  List<Course> get filteredCourses {
    if (selectedSpecializationFilter == 'all') {
      return _courses;
    }
    return _courses.where((course) => 
      course.specializationId.toString() == selectedSpecializationFilter
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadSpecializations();
  }

  Future<List<Course>> loadData() async {
    _isLoading.value = true;
    try {
      print('📚 Loading courses from server...');
      final courses = await CourseService.getAllCourses(Get.context!);
      print('✅ Loaded ${courses.length} courses from server');
      
      _courses.value = courses;
      
      // Enrich course data with specialization information
      await _enrichCourseData(courses);
      
      update(); // Notify GetX that data has changed
      return courses;
    } catch (e) {
      print('💥 Error loading courses: $e');
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshData() {
    print('🔄 Refreshing course data...');
    loadData();
  }

  Future<void> loadSpecializations() async {
    _isLoadingSpecializations.value = true;
    try {
      final specializations = await SpecializationService.getSpecializations(Get.context!);
      _specializations.value = specializations;
    } catch (e) {
      print('Error loading specializations: $e');
    } finally {
      _isLoadingSpecializations.value = false;
    }
  }

  void setSelectedSpecializationFilter(String value) {
    _selectedSpecializationFilter.value = value;
    update();
  }

  /// Force refresh data and update UI
  Future<void> forceRefresh() async {
    print('🔄 Force refreshing course data...');
    _isLoading.value = true;
    update();
    
    try {
      await loadData();
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Add a new course to the local array
  void addCourse(Course newCourse) {
    _courses.add(newCourse);
    update(); // Notify GetX that data has changed
  }

  // Update an existing course in the local array
  void updateCourse(Course updatedCourse) {
    final index = _courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      update(); // Notify GetX that data has changed
    }
  }

  /// Shows a success toast notification for course operations in Arabic
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

  /// Shows an error toast notification for course operations in Arabic
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

  /// Shows an info toast notification for course operations in Arabic
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

  /// Enrich course data with specialization information
  Future<void> _enrichCourseData(List<Course> courses) async {
    try {
      print('🔍 Enriching course data for ${courses.length} courses...');
      
      // Get all specializations
      final specializations = await SpecializationService.getSpecializations(Get.context!);
      print('📚 Loaded ${specializations.length} specializations');
      
      // Create a map for quick lookup
      final specializationMap = <int, Specialization>{};
      for (final spec in specializations) {
        if (spec.id != null) {
          specializationMap[spec.id!] = spec;
          print('📋 Specialization: ID=${spec.id}, Name=${spec.name}');
        }
      }
      
      // Enrich each course with specialization data
      int enrichedCount = 0;
      for (final course in courses) {
        print('🔍 Course: ${course.title}, Specialization ID: ${course.specializationId}, Has Spec: ${course.specialization != null}');
        
        if (course.specialization == null && specializationMap.containsKey(course.specializationId)) {
          print('✅ Enriching course ${course.title} with specialization: ${specializationMap[course.specializationId]!.name}');
          
          // Create a new course object with specialization data
          final enrichedCourse = course.copyWith(
            specialization: specializationMap[course.specializationId],
          );
          
          // Update the course in the list
          final index = _courses.indexWhere((c) => c.id == course.id);
          if (index != -1) {
            _courses[index] = enrichedCourse;
            enrichedCount++;
          }
        } else if (course.specialization == null && !specializationMap.containsKey(course.specializationId)) {
          print('⚠️ Course ${course.title} has specialization ID ${course.specializationId} but specialization not found');
        }
      }
      
      print('✅ Enriched $enrichedCount courses with specialization data');
      update(); // Notify GetX that data has changed
    } catch (e) {
      print('💥 Error enriching course data: $e');
    }
  }
}
