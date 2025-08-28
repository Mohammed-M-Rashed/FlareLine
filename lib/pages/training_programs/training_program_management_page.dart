import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/services/training_program_service.dart';
import 'package:flareline/core/models/training_program_model.dart';
import 'package:get/get.dart';

class TrainingProgramManagementPage extends LayoutWidget {
  const TrainingProgramManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Training Program Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        TrainingProgramManagementWidget(),
      ],
    );
  }
}

class TrainingProgramManagementWidget extends StatelessWidget {
  const TrainingProgramManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<_TrainingProgramDataProvider>(
          init: _TrainingProgramDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, _TrainingProgramDataProvider provider) {
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
                            'Training Program Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage system training programs, courses, and specializations',
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
                          width: 170,
                          child: ButtonWidget(
                            btnText: 'Add Training Program',
                            type: 'primary',
                            onTap: () {
                              _showAddTrainingProgramForm(context, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Main content with proper loading and data handling
              Obx(() {
                if (provider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const LoadingWidget(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading training programs...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'خطأ في تحميل برامج التدريب',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ButtonWidget(
                            btnText: 'Retry',
                            type: 'primary',
                            onTap: () {
                              provider.refreshData();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final trainingPrograms = provider.trainingPrograms;

                if (trainingPrograms.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'لا توجد برامج تدريب',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Get started by adding your first training program',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ButtonWidget(
                            btnText: 'Add First Training Program',
                            type: 'primary',
                            onTap: () {
                              _showAddTrainingProgramForm(context, provider);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Training Program count and summary
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
                            '${trainingPrograms.length} training program${trainingPrograms.length == 1 ? '' : 's'} found',
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            dividerThickness: 0.5,
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
                                    'Program Name',
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
                                    'Seats',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Start Date',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'End Date',
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
                                    'Actions',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                numeric: false,
                              ),
                            ],
                            rows: trainingPrograms
                                .map((trainingProgram) => DataRow(
                                      onSelectChanged: (selected) {},
                                      cells: [
                                        // Program Name
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 150,
                                              maxWidth: 200,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Icon(
                                                    Icons.school,
                                                    size: 16,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        trainingProgram.title,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (trainingProgram.id != null)
                                                        Text(
                                                          'ID: ${trainingProgram.id}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey[600],
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Course
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 120,
                                              maxWidth: 150,
                                            ),
                                            child: Text(
                                              trainingProgram.course?.title ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Training Center
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 120,
                                              maxWidth: 150,
                                            ),
                                            child: Text(
                                              trainingProgram.trainingCenter?.name ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Specialization
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 120,
                                              maxWidth: 150,
                                            ),
                                            child: Text(
                                              trainingProgram.specialization?.name ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Seats
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 60,
                                              maxWidth: 80,
                                            ),
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.shade50,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.purple.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${trainingProgram.seats}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                    color: Colors.purple.shade700,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Start Date
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 80,
                                              maxWidth: 100,
                                            ),
                                            child: Text(
                                              trainingProgram.formattedStartDate,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // End Date
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 80,
                                              maxWidth: 100,
                                            ),
                                            child: Text(
                                              trainingProgram.formattedEndDate,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Status
                                        DataCell(
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                color: trainingProgram.statusColor.withOpacity(0.1),
                                                border: Border.all(
                                                  color: trainingProgram.statusColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                trainingProgram.statusDisplay,
                                                style: TextStyle(
                                                  color: trainingProgram.statusColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        DataCell(
                                          Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 200,
                                              maxWidth: 250,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 22,
                                                  ),
                                                  onPressed: () {
                                                    _showEditTrainingProgramForm(context, trainingProgram, provider);
                                                  },
                                                  tooltip: 'Edit Training Program',
                                                  style: IconButton.styleFrom(
                                                    backgroundColor: Colors.blue.shade50,
                                                    foregroundColor: Colors.blue.shade700,
                                                    padding: const EdgeInsets.all(8),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.visibility,
                                                    size: 22,
                                                  ),
                                                  onPressed: () {
                                                    _showTrainingProgramDetails(context, trainingProgram);
                                                  },
                                                  tooltip: 'View Details',
                                                  style: IconButton.styleFrom(
                                                    backgroundColor: Colors.green.shade50,
                                                    foregroundColor: Colors.green.shade700,
                                                    padding: const EdgeInsets.all(8),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

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
                    
                    // Pagination controls (if needed)
                    const SizedBox(height: 16),
                    // Add pagination here if needed
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddTrainingProgramForm(BuildContext context, _TrainingProgramDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final courseIdController = TextEditingController();
    final trainingCenterIdController = TextEditingController();
    final specializationIdController = TextEditingController();
    final seatsController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final statusController = TextEditingController();

    ModalDialog.show(
      context: context,
      title: 'Add Training Program',
      showTitle: true,
      modalType: ModalType.large,
      child: Container(
        width: 600,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutBorderTextFormField(
                labelText: 'Title',
                hintText: 'Enter training program title',
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  if (value.length > 255) {
                    return 'Title cannot exceed 255 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Course ID',
                hintText: 'Enter course ID',
                controller: courseIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Course ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Training Center ID',
                hintText: 'Enter training center ID',
                controller: trainingCenterIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Training Center ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Specialization ID',
                hintText: 'Enter specialization ID',
                controller: specializationIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Specialization ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Seats',
                hintText: 'Enter number of seats',
                controller: seatsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seats cannot be empty';
                  }
                  final seats = int.tryParse(value);
                  if (seats == null || seats < 1) {
                    return 'Please enter a valid number of seats (minimum 1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Start Date',
                hintText: 'Enter start date (YYYY-MM-DD)',
                controller: startDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Start date cannot be empty';
                  }
                  final date = DateTime.tryParse(value);
                  if (date == null) {
                    return 'Please enter a valid date format (YYYY-MM-DD)';
                  }
                  if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    return 'Start date must be after today';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'End Date',
                hintText: 'Enter end date (YYYY-MM-DD)',
                controller: endDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'End date cannot be empty';
                  }
                  final endDate = DateTime.tryParse(value);
                  final startDate = DateTime.tryParse(startDateController.text);
                  if (endDate == null) {
                    return 'Please enter a valid date format (YYYY-MM-DD)';
                  }
                  if (startDate != null && endDate.isBefore(startDate)) {
                    return 'End date must be after start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: statusController.text.isEmpty ? 'open' : statusController.text,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    statusController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status cannot be empty';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      footer: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 120,
              child: ButtonWidget(
                btnText: 'Save',
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    final trainingProgram = TrainingProgram(
                      title: titleController.text,
                      courseId: int.tryParse(courseIdController.text) ?? 0,
                      trainingCenterId: int.tryParse(trainingCenterIdController.text) ?? 0,
                      specializationId: int.tryParse(specializationIdController.text) ?? 0,
                      seats: int.tryParse(seatsController.text) ?? 0,
                      startDate: startDateController.text,
                      endDate: endDateController.text,
                      status: statusController.text,
                      createdBy: 1, // TODO: Get from current user
                    );
                    provider.addTrainingProgram(trainingProgram);
                    Get.back();
                  }
                },
                type: 'primary',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTrainingProgramForm(BuildContext context, TrainingProgram trainingProgram, _TrainingProgramDataProvider provider) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: trainingProgram.title);
    final courseIdController = TextEditingController(text: trainingProgram.courseId.toString());
    final trainingCenterIdController = TextEditingController(text: trainingProgram.trainingCenterId.toString());
    final specializationIdController = TextEditingController(text: trainingProgram.specializationId.toString());
    final seatsController = TextEditingController(text: trainingProgram.seats.toString());
    final startDateController = TextEditingController(text: trainingProgram.startDate.toString().substring(0, 10));
    final endDateController = TextEditingController(text: trainingProgram.endDate.toString().substring(0, 10));
    final statusController = TextEditingController(text: trainingProgram.status);

    ModalDialog.show(
      context: context,
      title: 'Edit Training Program',
      showTitle: true,
      modalType: ModalType.large,
      child: Container(
        width: 600,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutBorderTextFormField(
                labelText: 'Title',
                hintText: 'Enter training program title',
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  if (value.length > 255) {
                    return 'Title cannot exceed 255 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Course ID',
                hintText: 'Enter course ID',
                controller: courseIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Course ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Training Center ID',
                hintText: 'Enter training center ID',
                controller: trainingCenterIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Training Center ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Specialization ID',
                hintText: 'Enter specialization ID',
                controller: specializationIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Specialization ID cannot be empty';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Seats',
                hintText: 'Enter number of seats',
                controller: seatsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seats cannot be empty';
                  }
                  final seats = int.tryParse(value);
                  if (seats == null || seats < 1) {
                    return 'Please enter a valid number of seats (minimum 1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'Start Date',
                hintText: 'Enter start date (YYYY-MM-DD)',
                controller: startDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Start date cannot be empty';
                  }
                  final date = DateTime.tryParse(value);
                  if (date == null) {
                    return 'Please enter a valid date format (YYYY-MM-DD)';
                  }
                  if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    return 'Start date must be after today';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutBorderTextFormField(
                labelText: 'End Date',
                hintText: 'Enter end date (YYYY-MM-DD)',
                controller: endDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'End date cannot be empty';
                  }
                  final endDate = DateTime.tryParse(value);
                  final startDate = DateTime.tryParse(startDateController.text);
                  if (endDate == null) {
                    return 'Please enter a valid date format (YYYY-MM-DD)';
                  }
                  if (startDate != null && endDate.isBefore(startDate)) {
                    return 'End date must be after start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: statusController.text.isEmpty ? 'open' : statusController.text,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    statusController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status cannot be empty';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      footer: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 120,
              child: ButtonWidget(
                btnText: 'Update',
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    final updatedTrainingProgram = TrainingProgram(
                      id: trainingProgram.id,
                      title: titleController.text,
                      courseId: int.tryParse(courseIdController.text) ?? 0,
                      trainingCenterId: int.tryParse(trainingCenterIdController.text) ?? 0,
                      specializationId: int.tryParse(specializationIdController.text) ?? 0,
                      seats: int.tryParse(seatsController.text) ?? 0,
                      startDate: startDateController.text,
                      endDate: endDateController.text,
                      status: statusController.text,
                      createdBy: trainingProgram.createdBy,
                    );
                    provider.updateTrainingProgram(updatedTrainingProgram);
                    Get.back();
                  }
                },
                type: 'primary',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingProgramDetails(BuildContext context, TrainingProgram trainingProgram) {
    ModalDialog.show(
      context: context,
      title: 'Training Program Details',
      showTitle: true,
      modalType: ModalType.medium,
      child: Container(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Title', trainingProgram.title),
            _buildDetailRow('Course', trainingProgram.course?.title ?? 'N/A'),
            _buildDetailRow('Training Center', trainingProgram.trainingCenter?.name ?? 'N/A'),
            _buildDetailRow('Specialization', trainingProgram.specialization?.name ?? 'N/A'),
            _buildDetailRow('Seats', trainingProgram.seats.toString()),
            _buildDetailRow('Start Date', trainingProgram.formattedStartDate),
            _buildDetailRow('End Date', trainingProgram.formattedEndDate),
            _buildDetailRow('Status', trainingProgram.statusDisplay),
            _buildDetailRow('Created By', trainingProgram.createdByUser?.name ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrainingProgram trainingProgram, _TrainingProgramDataProvider provider) {
    ModalDialog.show(
      context: context,
      title: 'Delete Training Program',
      showTitle: true,
      modalType: ModalType.small,
      child: Container(
        width: 400,
        child: Text(
          'Are you sure you want to delete this training program? This action cannot be undone.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ),
      footer: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'Cancel',
                onTap: () {
                  Get.back();
                },
                type: 'secondary',
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'Delete',
                onTap: () async {
                  Get.back();
                  if (trainingProgram.id != null) {
                    await provider.deleteTrainingProgram(trainingProgram.id!);
                  }
                },
                type: 'danger',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingProgramDataProvider extends GetxController {
  final RxList<TrainingProgram> _trainingPrograms = RxList<TrainingProgram>();
  final RxBool _isLoading = RxBool(true);
  final RxString _errorMessage = RxString('');

  _TrainingProgramDataProvider() {
    refreshData();
  }

  List<TrainingProgram> get trainingPrograms => _trainingPrograms;
  bool get isLoading => _isLoading.value;
  bool get hasError => _errorMessage.value.isNotEmpty;
  String get errorMessage => _errorMessage.value;

  Future<void> refreshData() async {
    _isLoading.value = true;
    _errorMessage.value = ''; // Clear previous errors
    try {
      final programs = await TrainingProgramService.getAllTrainingPrograms();
      _trainingPrograms.assignAll(programs);
      update(); // Notify GetX that data has changed
    } catch (e) {
      _errorMessage.value = e.toString();
      // Use Get.snackbar instead of SnackbarUtil to avoid scope issues
      Get.snackbar(
        'خطأ',
        'فشل في جلب برامج التدريب: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      update(); // Notify GetX that error state has changed
    } finally {
      _isLoading.value = false;
      update(); // Notify GetX that loading state has changed
    }
  }

  Future<void> addTrainingProgram(TrainingProgram trainingProgram) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      update();
      
      // Convert TrainingProgram to Map<String, dynamic> for the service
      final programData = trainingProgram.toJson();
      final newTrainingProgram = await TrainingProgramService.createTrainingProgram(programData);
      _trainingPrograms.add(newTrainingProgram);
      
      Get.snackbar(
        'Success',
        'Training program created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      update(); // Notify GetX that data has changed
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في إضافة برنامج التدريب: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      update(); // Notify GetX that error state has changed
    } finally {
      _isLoading.value = false;
      update(); // Notify GetX that loading state has changed
    }
  }

  Future<void> updateTrainingProgram(TrainingProgram trainingProgram) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      update();
      
      // Convert TrainingProgram to Map<String, dynamic> for the service
      final programData = trainingProgram.toJson();
      final updatedTrainingProgram = await TrainingProgramService.updateTrainingProgram(programData);
      final index = _trainingPrograms.indexWhere((p) => p.id == trainingProgram.id);
      if (index != -1) {
        _trainingPrograms[index] = updatedTrainingProgram;
      }
      
      Get.snackbar(
        'Success',
        'Training program updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      update(); // Notify GetX that data has changed
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحديث برنامج التدريب: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      update(); // Notify GetX that error state has changed
    } finally {
      _isLoading.value = false;
      update(); // Notify GetX that loading state has changed
    }
  }

  Future<void> deleteTrainingProgram(int trainingProgramId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      update();
      
      // Remove from local list first for immediate UI update
      _trainingPrograms.removeWhere((p) => p.id == trainingProgramId);
      update();
      
      // TODO: Implement delete API call when available
      // await TrainingProgramService.deleteTrainingProgram(trainingProgramId);
      
      Get.snackbar(
        'Success',
        'Training program deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في حذف برنامج التدريب: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Refresh data to restore the deleted item if deletion failed
      await refreshData();
    } finally {
      _isLoading.value = false;
      update();
    }
  }
}
