import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/plan_course_assignment_model.dart' as pca_model;
import 'package:flareline/core/services/plan_course_assignment_service.dart';
import 'package:flareline/core/models/company_model.dart' as company_model;
import 'package:flareline/core/services/company_service.dart';
import 'package:flareline/core/models/course_model.dart' as course_model;
import 'package:flareline/core/services/course_service.dart';
import 'package:flareline/core/models/training_center_branch_model.dart' as branch_model;
import 'package:flareline/core/services/training_center_branch_service.dart';
import 'package:flareline/core/services/specialization_service.dart';
import 'package:flareline/core/models/training_center_model.dart';
import 'package:flareline/core/services/training_center_service.dart';
import 'package:flareline/core/models/training_plan_model.dart' as training_plan_model;
import 'package:flareline/core/services/training_plan_service.dart';
import 'package:toastification/toastification.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:flareline/core/auth/auth_provider.dart';

import 'package:get/get.dart';
import 'dart:typed_data'; // Added for Uint8List
import 'dart:async';

import '../../core/config/api_endpoints.dart'; // Added for Completer

// Model class for course assignment entries
class CourseAssignmentEntry {
  final String id;
  final String trainingName;
  final String companyName;
  final String specializationName;
  final String courseName;
  final String trainingCenterName;
  final String branchName;
  final DateTime startDate;
  final DateTime endDate;
  final int seats;
  
  // ID fields for API submission (not displayed in table)
  final int? trainingId;
  final int? companyId;
  final int? specializationId;
  final int? courseId;
  final int? trainingCenterId;
  final int? branchId;

  CourseAssignmentEntry({
    required this.id,
    required this.trainingName,
    required this.companyName,
    required this.specializationName,
    required this.courseName,
    required this.trainingCenterName,
    required this.branchName,
    required this.startDate,
    required this.endDate,
    required this.seats,
    this.trainingId,
    this.companyId,
    this.specializationId,
    this.courseId,
    this.trainingCenterId,
    this.branchId,
  });
}

class PlanCourseAssignmentManagementPage extends LayoutWidget {
  const PlanCourseAssignmentManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Plan Course Assignment Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        PlanCourseAssignmentManagementWidget(),
      ],
    );
  }
}

class PlanCourseAssignmentManagementWidget extends StatefulWidget {
  const PlanCourseAssignmentManagementWidget({super.key});

  @override
  State<PlanCourseAssignmentManagementWidget> createState() => _PlanCourseAssignmentManagementWidgetState();
}

class _PlanCourseAssignmentManagementWidgetState extends State<PlanCourseAssignmentManagementWidget> {
  // State for training selection
  int? _selectedTrainingId;
  List<training_plan_model.TrainingPlan> _trainings = [];
  bool _isLoadingTrainings = false;
  
  // State for company selection
  int? _selectedCompanyId;
  
  // State for specialization and course selection
  int? _selectedSpecializationId;
  int? _selectedCourseId;
  List<pca_model.Specialization> _specializations = [];
  List<course_model.Course> _courses = [];
  bool _isLoadingSpecializations = false;
  bool _isLoadingCourses = false;
  
  // State for training center and branch selection
  int? _selectedTrainingCenterId;
  int? _selectedBranchId;
  List<TrainingCenter> _trainingCenters = [];
  List<branch_model.TrainingCenterBranch> _branches = [];
  bool _isLoadingTrainingCenters = false;
  bool _isLoadingBranches = false;
  
  // State for date and seats
  DateTime? _startDate;
  DateTime? _endDate;
  int _seats = 1;
  final TextEditingController _seatsController = TextEditingController(text: '1');
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  // State for course assignments table
  List<CourseAssignmentEntry> _courseAssignments = [];
  
  // State for filtering
  String? _selectedFilterCompany;
  
  // State for pagination
  int _currentPage = 0;
  int _itemsPerPage = 10;
  
  // Flag to prevent dropdown data reloading after form submission
  bool _isFormSubmitted = false;
  
  // Reset form submission flag (useful for starting fresh)
  void _resetFormSubmissionFlag() {
    setState(() {
      _isFormSubmitted = false;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Check authentication status on page load
    print('🔐 ===== PAGE INITIALIZATION AUTH CHECK =====');
    if (!_checkAuthenticationStatus()) {
      _handleAuthenticationError('Page initialization');
    }
    print('============================================');
    
    _loadTrainings();
    _loadSpecializations();
    _loadTrainingCenters();
    _loadCompanies();
    
    // Add listener to seats controller
    _seatsController.addListener(() {
      setState(() {
        _seats = int.tryParse(_seatsController.text) ?? 1;
      });
    });
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<PlanCourseAssignmentDataProvider>(
          init: PlanCourseAssignmentDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, PlanCourseAssignmentDataProvider provider) {
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
                            'Plan Course Assignment Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage plan course assignments and their information',
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
                                _showSuccessToast('Plan course assignments data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('خطأ في تحديث بيانات تخصيصات دورات الخطة: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Course Assignment Form Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact header
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Course Assignment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Compact grid layout for dropdowns
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
                          // Mobile layout - single column
                          return Column(
                            children: [
                              _buildTrainingDropdown(),
                              const SizedBox(height: 12),
                              _buildCompanyDropdown(),
                              const SizedBox(height: 12),
                              _buildSpecializationDropdown(),
                              const SizedBox(height: 12),
                              _buildCourseDropdown(),
                              const SizedBox(height: 12),
                              _buildTrainingCenterDropdown(),
                              const SizedBox(height: 12),
                              _buildBranchDropdown(),
                              const SizedBox(height: 12),
                              // Date and seats row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'Start Date',
                                      controller: _startDateController,
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'End Date',
                                      controller: _endDateController,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSeatsField(),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Desktop layout - two columns
                          return Column(
                            children: [
                              // First row - Training and Company
                              Row(
                                children: [
                                  Expanded(child: _buildTrainingDropdown()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildCompanyDropdown()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Second row - Specialization and Course
                              Row(
                                children: [
                                  Expanded(child: _buildSpecializationDropdown()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildCourseDropdown()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Third row - Training Center and Branch
                              Row(
                                children: [
                                  Expanded(child: _buildTrainingCenterDropdown()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildBranchDropdown()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Fourth row - Dates and Seats
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'Start Date',
                                      controller: _startDateController,
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDateField(
                                      label: 'End Date',
                                      controller: _endDateController,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSeatsField(),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Assign Course button
                    SizedBox(
                      width: double.infinity,
                      child: ButtonWidget(
                        btnText: 'Assign Course',
                        type: 'primary',
                        onTap: () {
                          _addCourseAssignment();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Course Assignments Table
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
                          Icons.table_chart,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Course Assignments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            'IDs stored for API',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Course Assignments count and summary
                    CountSummaryWidgetEn(
                      count: _courseAssignments.length,
                      itemName: 'assignment',
                      itemNamePlural: 'assignments',
                      icon: Icons.assignment_turned_in,
                      color: Colors.purple,
                      filteredCount: _filteredCourseAssignments.length,
                      showFilteredCount: _selectedFilterCompany != null && _selectedFilterCompany != 'All',
                    ),
                    const SizedBox(height: 16),
                    _buildFilterSection(),
                    const SizedBox(height: 16),
                    _buildCourseAssignmentsTable(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Save Button Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            btnText: 'Save to Training Plan',
                            type: 'primary',
                            onTap: _courseAssignments.isNotEmpty ? _saveAssignments : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              
            ],
          ),
        );
      },
    );
  }













  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Save assignments to training plan
  Future<void> _saveAssignments() async {
    if (_selectedTrainingId == null) {
      _showErrorToast('Please select a training plan first');
      return;
    }

    if (_courseAssignments.isEmpty) {
      _showErrorToast('No assignments to save');
      return;
    }

    try {
      // Pre-save authentication check
      if (!_checkAuthenticationStatus()) {
        _handleAuthenticationError('Pre-save authentication check');
        return;
      }

      print('🌐 ===== SAVE PROCESS ENDPOINT TRACKING =====');
      print('🌐 Starting save process for training plan: $_selectedTrainingId');
      print('🌐 Number of assignments to save: ${_courseAssignments.length}');
      print('🌐 ===========================================');

      _showLoadingToast('Saving assignments...');

      // Debug: Check the state of required lists
      final provider = Get.find<PlanCourseAssignmentDataProvider>();
      print('🔍 Debug - List states before processing:');
      print('   Companies count: ${provider.companies.length}');
      print('   Courses count: ${_courses.length}');
      print('   Branches count: ${_branches.length}');
      print('   Course assignments count: ${_courseAssignments.length}');

      // Load required data if lists are empty
      if (_courses.isEmpty || _branches.isEmpty) {
        print('🔄 Loading required data for save operation...');
        print('🌐 ===== DATA LOADING ENDPOINTS =====');
        
        if (_courses.isEmpty) {
          print('🌐 📚 Loading courses from API...');
          await _loadAllCourses();
          print('🌐 📚 Courses loaded: ${_courses.length} items');
        }
        
        if (_branches.isEmpty) {
          print('🌐 🏢 Loading branches from API...');
          await _loadAllBranches();
          print('🌐 🏢 Branches loaded: ${_branches.length} items');
        }
        
        print('🌐 ================================');
        print('   ✅ Data loaded - Courses: ${_courses.length}, Branches: ${_branches.length}');
        
        // Debug: Show some sample data
        if (_courses.isNotEmpty) {
          print('   Sample courses: ${_courses.take(3).map((c) => c.title).toList()}');
        }
        if (_branches.isNotEmpty) {
          print('   Sample branches: ${_branches.take(3).map((b) => b.name).toList()}');
        }
      }

      // Convert course assignments to API format using stored IDs
      final List<Map<String, dynamic>> assignments = [];
      for (int i = 0; i < _courseAssignments.length; i++) {
        final assignment = _courseAssignments[i];
        try {
          print('🔄 Processing assignment ${i + 1}/${_courseAssignments.length}:');
          print('   Company: ${assignment.companyName} (ID: ${assignment.companyId})');
          print('   Course: ${assignment.courseName} (ID: ${assignment.courseId})');
          print('   Branch: ${assignment.branchName} (ID: ${assignment.branchId})');
          
          // Validate that all required IDs are present
          if (assignment.companyId == null) {
            throw Exception('Company ID is missing for assignment ${i + 1}');
          }
          if (assignment.courseId == null) {
            throw Exception('Course ID is missing for assignment ${i + 1}');
          }
          if (assignment.branchId == null) {
            throw Exception('Branch ID is missing for assignment ${i + 1}');
          }
          
          final assignmentData = {
            'company_id': assignment.companyId,
            'course_id': assignment.courseId,
            'training_center_branch_id': assignment.branchId,
            'start_date': assignment.startDate.toIso8601String().split('T')[0],
            'end_date': assignment.endDate.toIso8601String().split('T')[0],
            'seats': assignment.seats,
          };
          
          assignments.add(assignmentData);
          print('   ✅ Assignment ${i + 1} processed successfully with stored IDs');
        } catch (e) {
          print('   ❌ Error processing assignment ${i + 1}: $e');
          throw Exception('Failed to process assignment ${i + 1}: $e');
        }
      }

      // Log the complete request body being sent to server
      final requestBody = {
        'training_plan_id': _selectedTrainingId,
        'assignments': assignments,
      };
      
      print('📤 ===== REQUEST BODY DEBUG =====');
      print('   Training Plan ID: $_selectedTrainingId');
      print('   Number of assignments: ${assignments.length}');
      print('   Complete Request Body:');
      print('   ${requestBody.toString()}');
      print('   ');
      print('   Individual Assignment Details:');
      for (int i = 0; i < assignments.length; i++) {
        print('     Assignment ${i + 1}:');
        assignments[i].forEach((key, value) {
          print('       $key: $value (${value.runtimeType})');
        });
        print('     ---');
      }
      print('   ');
      print('   JSON String representation:');
      print('   ${jsonEncode(requestBody)}');
      print('================================');

      // Final authentication check before API call
      if (!_checkAuthenticationStatus()) {
        _handleAuthenticationError('Final authentication check before API call');
        return;
      }

      print('🌐 ===== MAIN SAVE ENDPOINT =====');
      print('🌐 🚀 Calling PlanCourseAssignmentService.replacePlanCourseAssignments');
      print('🌐 📍 Endpoint: ${ApiEndpoints.storePlanCourseAssignments}');
      print('🌐 📊 Request data:');
      print('🌐   - Training Plan ID: $_selectedTrainingId');
      print('🌐   - Assignments count: ${assignments.length}');
      print('🌐   - Request body size: ${jsonEncode(assignments).length} characters');
      print('🌐 ===============================');

      final response = await PlanCourseAssignmentService.replacePlanCourseAssignments(
        trainingPlanId: _selectedTrainingId!,
        assignments: assignments,
      );

      print('🌐 ===== SAVE ENDPOINT RESPONSE =====');
      print('🌐 ✅ Save endpoint completed');
      print('🌐 📊 Response details:');
      print('🌐   - Status Code: ${response.statusCode}');
      print('🌐   - Success: ${response.statusCode == 200}');
      print('🌐   - Message (EN): ${response.messageEn}');
      print('🌐   - Message (AR): ${response.messageAr}');
      print('🌐 ===================================');

      // Log the response received from server
      print('📥 Response received from server:');
      print('   Status Code: ${response.statusCode}');
      print('   Message (EN): ${response.messageEn}');
      print('   Message (AR): ${response.messageAr}');
      print('   Full Response: ${response.toString()}');

      if (response.statusCode == 200) {
        _showSuccessToast('Assignments saved successfully');
        print('✅ Assignments saved successfully');
        
        // Print summary of all endpoints executed
        print('🌐 ===== ENDPOINT EXECUTION SUMMARY =====');
        print('🌐 📋 All endpoints executed during save process:');
        print('🌐   1. Authentication check (local)');
        if (_courses.isEmpty) {
          print('🌐   2. 📚 CourseService.getAllCourses - ${ApiEndpoints.selectCourses}');
        }
        if (_branches.isEmpty) {
          print('🌐   3. 🏢 TrainingCenterBranchService.getAllTrainingCenterBranches - ${ApiEndpoints.getAllTrainingCenterBranches}');
        }
        print('🌐   4. 🚀 PlanCourseAssignmentService.replacePlanCourseAssignments - ${ApiEndpoints.storePlanCourseAssignments}');
        print('🌐 📊 Total API calls made: ${(_courses.isEmpty ? 1 : 0) + (_branches.isEmpty ? 1 : 0) + 1}');
        print('🌐 ✅ All endpoints completed successfully');
        print('🌐 ======================================');
        
        // Optionally clear the assignments after saving
        // setState(() {
        //   _courseAssignments.clear();
        // });
      } else {
        print('❌ Server error saving assignments:');
        print('   Status Code: ${response.statusCode}');
        print('   Message (EN): ${response.messageEn}');
        print('   Message (AR): ${response.messageAr}');
        print('   Full Response: ${response.toString()}');
        _showErrorToast('Failed to save assignments: ${response.messageEn}');
      }
    } catch (e) {
      print('❌ ===== EXCEPTION DEBUG =====');
      print('   Exception Type: ${e.runtimeType}');
      print('   Exception Message: ${e.toString()}');
      print('   Stack Trace:');
      print('   ${StackTrace.current}');
      print('   ');
      print('   Current State:');
      print('   - Selected Training ID: $_selectedTrainingId');
      print('   - Course Assignments Count: ${_courseAssignments.length}');
      print('   - Courses Count: ${_courses.length}');
      print('   - Branches Count: ${_branches.length}');
      print('   - Companies Count: ${Get.find<PlanCourseAssignmentDataProvider>().companies.length}');
      print('=============================');
      
      // Print endpoint execution summary even on error
      print('🌐 ===== ENDPOINT EXECUTION SUMMARY (ERROR) =====');
      print('🌐 📋 Endpoints attempted during save process:');
      print('🌐   1. Authentication check (local)');
      if (_courses.isEmpty) {
        print('🌐   2. 📚 CourseService.getAllCourses - ${ApiEndpoints.selectCourses}');
      }
      if (_branches.isEmpty) {
        print('🌐   3. 🏢 TrainingCenterBranchService.getAllTrainingCenterBranches - ${ApiEndpoints.getAllTrainingCenterBranches}');
      }
      print('🌐   4. 🚀 PlanCourseAssignmentService.replacePlanCourseAssignments - ${ApiEndpoints.storePlanCourseAssignments}');
      print('🌐 ❌ Process failed before completion');
      print('🌐 ===========================================');
      
      _showErrorToast('Error saving assignments: ${e.toString()}');
    }
  }

  // Check authentication status
  bool _checkAuthenticationStatus() {
    try {
      final authController = Get.find<AuthController>();
      print('🔐 ===== AUTHENTICATION STATUS CHECK =====');
      print('   isAuthenticated: ${authController.isAuthenticated}');
      print('   isLoggedIn: ${authController.isLoggedIn()}');
      print('   hasValidToken: ${authController.hasValidToken()}');
      print('   userEmail: ${authController.userEmail}');
      print('   tokenLength: ${authController.userToken.length}');
      print('=========================================');
      
      if (!authController.isAuthenticated || !authController.hasValidToken()) {
        print('❌ Authentication check failed');
        return false;
      }
      
      print('✅ Authentication check passed');
      return true;
    } catch (e) {
      print('❌ Exception during authentication check: $e');
      return false;
    }
  }

  // Handle authentication error
  void _handleAuthenticationError(String context) {
    print('🔐 ===== AUTHENTICATION ERROR HANDLER =====');
    print('   Context: $context');
    print('   Time: ${DateTime.now()}');
    print('   User should be redirected to login');
    print('==========================================');
    
    _showErrorToast('Authentication error, please log in again');
    
    // Optionally, you could trigger a logout or redirect to login page here
    // For example:
    // Get.find<AuthController>().signOut();
    // Get.offAllNamed('/login');
  }

  // Helper methods to get IDs by name
  int _getCompanyIdByName(String companyName) {
    final provider = Get.find<PlanCourseAssignmentDataProvider>();
    try {
      final company = provider.companies.firstWhere((c) => c.name == companyName);
      return company.id!;
    } catch (e) {
      print('❌ Company not found: $companyName');
      print('   Available companies: ${provider.companies.map((c) => c.name).toList()}');
      throw Exception('Company "$companyName" not found in the list');
    }
  }

  int _getCourseIdByName(String courseName) {
    try {
      final course = _courses.firstWhere((c) => c.title == courseName);
      return course.id!;
    } catch (e) {
      print('❌ Course not found: $courseName');
      print('   Available courses: ${_courses.map((c) => c.title).toList()}');
      throw Exception('Course "$courseName" not found in the list');
    }
  }

  int _getBranchIdByName(String branchName) {
    try {
      final branch = _branches.firstWhere((b) => b.name == branchName);
      return branch.id!;
    } catch (e) {
      print('❌ Branch not found: $branchName');
      print('   Available branches: ${_branches.map((b) => b.name).toList()}');
      throw Exception('Branch "$branchName" not found in the list');
    }
  }

  // Add course assignment to the table
  void _addCourseAssignment() {
    // Validate all required fields
    if (_selectedTrainingId == null) {
      _showErrorToast('Please select a training');
      return;
    }
    if (_selectedCompanyId == null) {
      _showErrorToast('Please select a company');
      return;
    }
    if (_selectedSpecializationId == null) {
      _showErrorToast('Please select a specialization');
      return;
    }
    if (_selectedCourseId == null) {
      _showErrorToast('Please select a course');
      return;
    }
    if (_selectedTrainingCenterId == null) {
      _showErrorToast('Please select a training center');
      return;
    }
    if (_selectedBranchId == null) {
      _showErrorToast('Please select a branch');
      return;
    }
    if (_startDate == null) {
      _showErrorToast('Please select a start date');
      return;
    }
    if (_endDate == null) {
      _showErrorToast('Please select an end date');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showErrorToast('End date must be after start date');
      return;
    }

    // Get the selected data
    final training = _trainings
        .firstWhere((t) => t.id == _selectedTrainingId);
    
    final company = Get.find<PlanCourseAssignmentDataProvider>()
        .companies
        .firstWhere((c) => c.id == _selectedCompanyId);
    
    final pca_model.Specialization specialization = _specializations
        .firstWhere((s) => s.id == _selectedSpecializationId);
    
    final course = _courses
        .firstWhere((c) => c.id == _selectedCourseId);
    
    final trainingCenter = _trainingCenters
        .firstWhere((tc) => tc.id == _selectedTrainingCenterId);
    
    final branch = _branches
        .firstWhere((b) => b.id == _selectedBranchId);

    // Create new assignment entry with IDs
    final newAssignment = CourseAssignmentEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainingName: training.title,
      companyName: company.name,
      specializationName: specialization.name,
      courseName: course.title,
      trainingCenterName: trainingCenter.name,
      branchName: branch.name,
      startDate: _startDate!,
      endDate: _endDate!,
      seats: _seats,
      // Store IDs for API submission
      trainingId: _selectedTrainingId,
      companyId: _selectedCompanyId,
      specializationId: _selectedSpecializationId,
      courseId: _selectedCourseId,
      trainingCenterId: _selectedTrainingCenterId,
      branchId: _selectedBranchId,
    );

    // Add to the list
    setState(() {
      _courseAssignments.add(newAssignment);
    });

    // Debug: Print stored IDs
    print('✅ Course assignment added with stored IDs:');
    print('   Training ID: ${newAssignment.trainingId}');
    print('   Company ID: ${newAssignment.companyId}');
    print('   Specialization ID: ${newAssignment.specializationId}');
    print('   Course ID: ${newAssignment.courseId}');
    print('   Training Center ID: ${newAssignment.trainingCenterId}');
    print('   Branch ID: ${newAssignment.branchId}');

    // Clear the form
    _clearForm();

    _showSuccessToast('Course assignment added successfully');
  }

  // Get filtered course assignments based on company name
  List<CourseAssignmentEntry> get _filteredCourseAssignments {
    if (_selectedFilterCompany == null || _selectedFilterCompany == 'All') {
      return _courseAssignments;
    }
    return _courseAssignments.where((assignment) {
      return assignment.companyName == _selectedFilterCompany;
    }).toList();
  }

  // Get unique company names from assignments
  List<String> get _availableCompanyNames {
    final companyNames = _courseAssignments.map((assignment) => assignment.companyName).toSet().toList();
    companyNames.sort();
    return ['All', ...companyNames];
  }

  // Get paginated course assignments
  List<CourseAssignmentEntry> get _paginatedCourseAssignments {
    final filteredAssignments = _filteredCourseAssignments;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredAssignments.length);
    return filteredAssignments.sublist(startIndex, endIndex);
  }

  // Get total number of pages
  int get _totalPages {
    final filteredAssignments = _filteredCourseAssignments;
    if (filteredAssignments.isEmpty) return 1;
    return (filteredAssignments.length / _itemsPerPage).ceil();
  }

  // Get total items count
  int get _totalItems {
    return _filteredCourseAssignments.length;
  }

  // Pagination methods
  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _setItemsPerPage(int itemsPerPage) {
    setState(() {
      _itemsPerPage = itemsPerPage;
      _currentPage = 0; // Reset to first page
    });
  }

  // Clear the form after adding an assignment
  void _clearForm() {
    setState(() {
      // Keep the selected training plan - don't reset _selectedTrainingId
      _selectedCompanyId = null;
      _selectedSpecializationId = null;
      _selectedCourseId = null;
      _selectedTrainingCenterId = null;
      _selectedBranchId = null;
      _startDate = null;
      _endDate = null;
      _seats = 1;
      _seatsController.text = '1';
      _startDateController.clear();
      _endDateController.clear();
      
      // Don't clear _courses and _branches to prevent dropdown data reload
      // This allows users to add multiple assignments without reloading dropdown data
      // _courses.clear();
      // _branches.clear();
      
      // Set flag to prevent dropdown data reloading on subsequent selections
      _isFormSubmitted = true;
    });
  }

  // Build the filter section
  Widget _buildFilterSection() {
    return Container(
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
            'Filter by Company:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilterCompany,
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
              hint: const Text('Select Company'),
              items: _availableCompanyNames.map((String company) {
                return DropdownMenuItem<String>(
                  value: company,
                  child: Text(
                    company,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
               onChanged: (String? newValue) {
                 setState(() {
                   _selectedFilterCompany = newValue;
                   _currentPage = 0; // Reset to first page when filter changes
                 });
               },
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedFilterCompany != null && _selectedFilterCompany != 'All')
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                setState(() {
                  _selectedFilterCompany = null;
                });
              },
              tooltip: 'Clear Filter',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  // Build the course assignments table
  Widget _buildCourseAssignmentsTable() {
    final paginatedAssignments = _paginatedCourseAssignments;
    final filteredAssignments = _filteredCourseAssignments;
    
    if (_courseAssignments.isEmpty) {
      return Container(
        width: double.infinity,
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
              'No Course Assignments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add course assignments using the form above to see them here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (filteredAssignments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Matching Assignments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No course assignments found for "${_selectedFilterCompany}". Try selecting a different company.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
                'Training',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
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
                'Branch',
                textAlign: TextAlign.start,
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
                'Actions',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
        ],
         rows: paginatedAssignments.map((assignment) => DataRow(
          onSelectChanged: (selected) {},
          cells: [
            DataCell(_buildTrainingCell(assignment)),
            DataCell(_buildCompanyCell(assignment)),
            DataCell(_buildSpecializationCell(assignment)),
            DataCell(_buildCourseCell(assignment)),
            DataCell(_buildTrainingCenterCell(assignment)),
            DataCell(_buildBranchCell(assignment)),
            DataCell(_buildDateCell(assignment.startDate)),
            DataCell(_buildDateCell(assignment.endDate)),
            DataCell(_buildSeatsCell(assignment.seats)),
            DataCell(_buildActionsCell(assignment)),
          ],
         )).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pagination
        _buildPagination(),
      ],
    );
  }

  // Build pagination controls
  Widget _buildPagination() {
    if (_filteredCourseAssignments.isEmpty) {
      return const SizedBox.shrink();
    }

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
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          tooltip: 'Previous page',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
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
                      'Total: $_totalItems',
                      style: const TextStyle(fontSize: 12),
                    ),
                    DropdownButton<int>(
                      value: _itemsPerPage,
                      items: const [10, 20, 50]
                          .map((n) => DropdownMenuItem<int>(
                                value: n,
                                child: Text('$n per page', style: TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _setItemsPerPage(value);
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
                      'Showing ${(_currentPage * _itemsPerPage) + 1} to ${_currentPage * _itemsPerPage + _paginatedCourseAssignments.length} of $_totalItems entries',
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
                          value: _itemsPerPage,
                          items: const [10, 20, 50]
                              .map((n) => DropdownMenuItem<int>(
                                    value: n,
                                    child: Text('$n', style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) _setItemsPerPage(value);
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Page ${_currentPage + 1} of $_totalPages',
                          style: const TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          tooltip: 'Previous page',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
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

  // Table cell builders
  Widget _buildTrainingCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.trainingName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCompanyCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.companyName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSpecializationCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.specializationName,
        style: const TextStyle(
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCourseCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.courseName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTrainingCenterCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.trainingCenterName,
        style: const TextStyle(
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBranchCell(CourseAssignmentEntry assignment) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        assignment.branchName,
        style: const TextStyle(
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateCell(DateTime date) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 100,
      ),
      child: Text(
        _formatDate(date),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSeatsCell(int seats) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 80,
      ),
      child: Text(
        seats.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionsCell(CourseAssignmentEntry assignment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Delete button
        IconButton(
          icon: const Icon(
            Icons.delete,
            size: 18,
          ),
          onPressed: () {
            _deleteCourseAssignment(assignment);
          },
          tooltip: 'Delete Assignment',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }


  // Delete course assignment
  void _deleteCourseAssignment(CourseAssignmentEntry assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this course assignment for ${assignment.companyName} - ${assignment.courseName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _courseAssignments.removeWhere((a) => a.id == assignment.id);
              });
              Navigator.of(context).pop();
              _showSuccessToast('Course assignment deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper method for compact dropdowns
  Widget _buildCompactDropdown<T>({
    required String label,
    required T? value,
    required String hintText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
          ),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTrainingDropdown() {
    return _buildCompactDropdown<int>(
      label: 'Training',
      value: _selectedTrainingId,
      hintText: _isLoadingTrainings ? 'Loading...' : 'Select training',
      icon: Icons.school,
      items: _trainings.map<DropdownMenuItem<int>>((training) {
        return DropdownMenuItem<int>(
          value: training.id,
          child: Text(
            training.title,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isLoadingTrainings ? null : (value) {
        setState(() {
          _selectedTrainingId = value;
        });
        if (value != null) {
          _loadAssignmentsForTrainingPlan(value);
        }
      },
    );
  }

  Widget _buildCompanyDropdown() {
    return GetBuilder<PlanCourseAssignmentDataProvider>(
      builder: (provider) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<int>(
                    value: _selectedCompanyId,
                    decoration: InputDecoration(
                      hintText: provider.companies.isEmpty 
                          ? 'Loading...' 
                          : 'Select company',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: Icon(Icons.business, color: Colors.blue.shade600, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                    ),
                    items: provider.companies.map<DropdownMenuItem<int>>((company) {
                      return DropdownMenuItem<int>(
                        value: company.id,
                        child: Text(
                          company.name,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: provider.companies.isEmpty ? null : (value) {
                      setState(() {
                        _selectedCompanyId = value;
                      });
                    },
                    style: const TextStyle(fontSize: 13),
                  )),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: () {
                    _loadCompanies();
                  },
                  tooltip: 'Refresh',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCourseAssignmentDialog(BuildContext context) {
    if (_selectedCompanyId == null) {
      _showErrorToast('Please select a company first');
      return;
    }

    final selectedCompany = Get.find<PlanCourseAssignmentDataProvider>()
        .companies
        .firstWhere((c) => c.id == _selectedCompanyId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Courses to ${selectedCompany.name}'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: _buildCourseAssignmentForm(selectedCompany),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessToast('Course assignments will be implemented');
            },
            child: const Text('Save Assignments'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseAssignmentForm(company_model.Company company) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.business, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      company.address,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Course selection
        Text(
          'Select Courses to Assign:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        
        // Mock courses list
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              final courses = [
                'أساسيات البرمجة',
                'إدارة قواعد البيانات',
                'أمن المعلومات',
                'تطوير تطبيقات الويب',
                'الذكاء الاصطناعي',
                'إدارة المشاريع التقنية',
              ];
              
              return CheckboxListTile(
                title: Text(
                  courses[index],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Specialization: تطوير البرمجيات - Duration: ${(index + 1) * 10} hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                value: false, // This would be managed by state
                onChanged: (value) {
                  // Handle course selection
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Additional fields
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Seats',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                initialValue: '1',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddPlanCourseAssignmentForm(BuildContext context) {
    // This will be implemented in the next part
    _showSuccessToast('Add form will be implemented');
  }

  void _showEditPlanCourseAssignmentForm(BuildContext context, pca_model.PlanCourseAssignment planCourseAssignment) {
    // This will be implemented in the next part
    _showSuccessToast('Edit form will be implemented');
  }

  // Load assignments for selected training plan
  Future<void> _loadAssignmentsForTrainingPlan(int trainingPlanId) async {
    try {
      _showLoadingToast('Loading assignments...');

      final response = await PlanCourseAssignmentService.getPlanCourseAssignmentsByTrainingPlan(
        trainingPlanId: trainingPlanId,
      );

      if (response.statusCode == 200) {
        // Convert API assignments to local CourseAssignmentEntry format with IDs
        final List<CourseAssignmentEntry> assignments = response.data.map((assignment) {
          // Get training name from the selected training
          final selectedTraining = _trainings.isNotEmpty 
              ? _trainings.firstWhere(
                  (t) => t.id == _selectedTrainingId,
                  orElse: () => _trainings.first,
                )
              : null;
          
          return CourseAssignmentEntry(
            id: assignment.id.toString(),
            trainingName: selectedTraining?.title ?? 'Unknown Training',
            companyName: assignment.company?.name ?? 'Unknown Company',
            specializationName: assignment.course?.specializationName ?? 'Unknown Specialization',
            courseName: assignment.course?.title ?? 'Unknown Course',
            trainingCenterName: assignment.trainingCenterBranch?.trainingCenterName ?? 'Unknown Center',
            branchName: assignment.trainingCenterBranch?.name ?? 'Unknown Branch',
            startDate: assignment.startDate,
            endDate: assignment.endDate,
            seats: assignment.seats,
            // Store IDs from API response
            trainingId: _selectedTrainingId,
            companyId: assignment.company?.id,
            specializationId: assignment.course?.specializationId,
            courseId: assignment.course?.id,
            trainingCenterId: assignment.trainingCenterBranch?.trainingCenterId,
            branchId: assignment.trainingCenterBranch?.id,
          );
        }).toList();

        setState(() {
          _courseAssignments = assignments;
        });

        print('✅ Assignments loaded successfully for training plan $trainingPlanId');
        print('   Loaded ${assignments.length} assignments');
        _showSuccessToast('Assignments loaded successfully');
      } else {
        print('❌ Server error loading assignments:');
        print('   Training Plan ID: $trainingPlanId');
        print('   Status Code: ${response.statusCode}');
        print('   Message (EN): ${response.messageEn}');
        print('   Message (AR): ${response.messageAr}');
        print('   Full Response: ${response.toString()}');
        _showErrorToast('Failed to load assignments: ${response.messageEn}');
        setState(() {
          _courseAssignments = [];
        });
      }
    } catch (e) {
      print('❌ Exception loading assignments for training plan $trainingPlanId:');
      print('   Exception: ${e.toString()}');
      print('   Exception type: ${e.runtimeType}');
      _showErrorToast('Error loading assignments: ${e.toString()}');
      setState(() {
        _courseAssignments = [];
      });
    }
  }

  // Load trainings with plan_preparation status using admin API
  Future<void> _loadTrainings() async {
    setState(() {
      _isLoadingTrainings = true;
    });

    try {
      final response = await TrainingPlanService.adminGetTrainingPlansPlanPreparation();
      if (response.success) {
        setState(() {
          _trainings = response.data;
          _isLoadingTrainings = false;
        });
      } else {
        setState(() {
          _isLoadingTrainings = false;
        });
        _showErrorToast('Failed to load trainings: ${response.messageEn ?? response.messageAr ?? 'Unknown error'}');
      }
    } catch (e) {
      setState(() {
        _isLoadingTrainings = false;
      });
      _showErrorToast('Error loading trainings: ${e.toString()}');
    }
  }

  // Load specializations
  Future<void> _loadSpecializations() async {
    setState(() {
      _isLoadingSpecializations = true;
    });

    try {
      final oldSpecializations = await SpecializationService.getSpecializations(context);
      // Convert old Specialization model to new pca_model.Specialization
      final specializations = oldSpecializations.map((oldSpec) => pca_model.Specialization(
        id: oldSpec.id ?? 0,
        name: oldSpec.name,
        description: oldSpec.description,
        createdBy: null,
        status: null,
        createdAt: oldSpec.createdAt.isNotEmpty ? DateTime.tryParse(oldSpec.createdAt) : null,
        updatedAt: oldSpec.updatedAt.isNotEmpty ? DateTime.tryParse(oldSpec.updatedAt) : null,
      )).toList();
      
      setState(() {
        _specializations = specializations;
        _isLoadingSpecializations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSpecializations = false;
      });
      _showErrorToast('Failed to load specializations: $e');
    }
  }

  // Load all courses without filter (for save operation)
  Future<void> _loadAllCourses() async {
    try {
      print('🌐 📚 ===== LOADING COURSES ENDPOINT =====');
      print('🌐 📚 Calling CourseService.getAllCourses');
      print('🌐 📚 Endpoint: ${ApiEndpoints.selectCourses}');
      print('🌐 📚 ====================================');
      
      final courses = await CourseService.getAllCourses(context);
      
      print('🌐 📚 ===== COURSES ENDPOINT RESPONSE =====');
      print('🌐 📚 ✅ Courses loaded successfully');
      print('🌐 📚 📊 Response data:');
      print('🌐 📚   - Courses count: ${courses.length}');
      print('🌐 📚   - Sample courses: ${courses.take(3).map((c) => c.title).toList()}');
      print('🌐 📚 ====================================');
      
      setState(() {
        _courses = courses;
      });
      print('✅ Loaded ${_courses.length} courses for save operation');
    } catch (e) {
      print('🌐 📚 ===== COURSES ENDPOINT ERROR =====');
      print('🌐 📚 ❌ Error loading courses: $e');
      print('🌐 📚 =================================');
    }
  }

  // Load all branches without filter (for save operation)
  Future<void> _loadAllBranches() async {
    try {
      print('🌐 🏢 ===== LOADING BRANCHES ENDPOINT =====');
      print('🌐 🏢 Calling TrainingCenterBranchService.getAllTrainingCenterBranches');
      print('🌐 🏢 Endpoint: ${ApiEndpoints.getAllTrainingCenterBranches}');
      print('🌐 🏢 =====================================');
      
      final response = await TrainingCenterBranchService.getAllTrainingCenterBranches();
      
      print('🌐 🏢 ===== BRANCHES ENDPOINT RESPONSE =====');
      print('🌐 🏢 📊 Response details:');
      print('🌐 🏢   - Status Code: ${response.statusCode}');
      print('🌐 🏢   - Success: ${response.statusCode == 200}');
      print('🌐 🏢   - Message (EN): ${response.messageEn}');
      print('🌐 🏢   - Message (AR): ${response.messageAr}');
      print('🌐 🏢   - Data count: ${response.data.length}');
      print('🌐 🏢   - Sample branches: ${response.data.take(3).map((b) => b.name).toList()}');
      print('🌐 🏢 =====================================');
      
      if (response.statusCode == 200) {
        setState(() {
          _branches = response.data;
        });
        print('✅ Loaded ${_branches.length} branches for save operation');
      } else {
        print('❌ Failed to load branches: ${response.messageEn}');
      }
    } catch (e) {
      print('🌐 🏢 ===== BRANCHES ENDPOINT ERROR =====');
      print('🌐 🏢 ❌ Error loading branches: $e');
      print('🌐 🏢 ==================================');
    }
  }

  // Load courses based on selected specialization using admin API
  Future<void> _loadCourses(int? specializationId) async {
    setState(() {
      _isLoadingCourses = true;
      // Only clear courses if this is the initial load (form not submitted yet)
      if (!_isFormSubmitted) {
        _courses.clear();
      }
      _selectedCourseId = null;
    });

    if (specializationId == null) {
      setState(() {
        _isLoadingCourses = false;
      });
      return;
    }

    try {
      final courses = await SpecializationService.adminGetCoursesBySpecialization(context, specializationId);
      setState(() {
        _courses = courses;
        _isLoadingCourses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      _showErrorToast('Failed to load courses: $e');
    }
  }

  // Build specialization dropdown
  Widget _buildSpecializationDropdown() {
    return _buildCompactDropdown<int>(
      label: 'Specialization',
      value: _selectedSpecializationId,
      hintText: _isLoadingSpecializations ? 'Loading...' : 'Select specialization',
      icon: Icons.category,
      items: _specializations.map<DropdownMenuItem<int>>((specialization) {
        return DropdownMenuItem<int>(
          value: specialization.id,
          child: Text(
            specialization.name,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSpecializationId = value;
        });
        // Load courses for the selected specialization
        _loadCourses(value);
      },
    );
  }

  // Build course dropdown
  Widget _buildCourseDropdown() {
    return _buildCompactDropdown<int>(
      label: 'Course',
      value: _selectedCourseId,
      hintText: _isLoadingCourses 
          ? 'Loading...' 
          : _selectedSpecializationId == null 
              ? 'Select specialization first'
              : 'Select course',
      icon: Icons.school,
      items: _courses.map<DropdownMenuItem<int>>((course) {
        return DropdownMenuItem<int>(
          value: course.id,
          child: Text(
            course.title,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _selectedSpecializationId == null ? null : (value) {
        setState(() {
          _selectedCourseId = value;
        });
      },
    );
  }

  // Load training centers using admin API
  Future<void> _loadTrainingCenters() async {
    setState(() {
      _isLoadingTrainingCenters = true;
    });

    try {
      final response = await TrainingCenterService.adminGetAllTrainingCenters();
      setState(() {
        _trainingCenters = response.data;
        _isLoadingTrainingCenters = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrainingCenters = false;
      });
      _showErrorToast('Failed to load training centers: $e');
    }
  }

  // Load companies using admin API
  Future<void> _loadCompanies() async {
    try {
      final response = await CompanyService.adminGetAllCompanies();
      if (response.success) {
        // Update the provider's companies list
        final provider = Get.find<PlanCourseAssignmentDataProvider>();
        provider.setCompanies(response.data);
        print('Loaded ${response.data.length} companies in widget');
      } else {
        print('Failed to load companies in widget: ${response.messageEn}');
        _showErrorToast('Failed to load companies: ${response.messageEn}');
      }
    } catch (e) {
      print('Error loading companies in widget: $e');
      _showErrorToast('Failed to load companies: $e');
    }
  }

  // Load branches based on selected training center using admin API
  Future<void> _loadBranches(int? trainingCenterId) async {
    setState(() {
      _isLoadingBranches = true;
      // Only clear branches if this is the initial load (form not submitted yet)
      if (!_isFormSubmitted) {
        _branches.clear();
      }
      _selectedBranchId = null;
    });

    if (trainingCenterId == null) {
      setState(() {
        _isLoadingBranches = false;
      });
      return;
    }

    try {
      final response = await TrainingCenterBranchService.adminGetTrainingCenterBranches(trainingCenterId);
      setState(() {
        _branches = response.data;
        _isLoadingBranches = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBranches = false;
      });
      _showErrorToast('Failed to load branches: $e');
    }
  }

  // Build training center dropdown
  Widget _buildTrainingCenterDropdown() {
    return _buildCompactDropdown<int>(
      label: 'Training Center',
      value: _selectedTrainingCenterId,
      hintText: _isLoadingTrainingCenters ? 'Loading...' : 'Select training center',
      icon: Icons.business_center,
      items: _trainingCenters.map<DropdownMenuItem<int>>((center) {
        return DropdownMenuItem<int>(
          value: center.id,
          child: Text(
            center.name,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTrainingCenterId = value;
        });
        // Load branches for the selected training center
        _loadBranches(value);
      },
    );
  }

  // Build branch dropdown
  Widget _buildBranchDropdown() {
    return _buildCompactDropdown<int>(
      label: 'Branch',
      value: _selectedBranchId,
      hintText: _isLoadingBranches 
          ? 'Loading...' 
          : _selectedTrainingCenterId == null 
              ? 'Select training center first'
              : 'Select branch',
      icon: Icons.location_on,
      items: _branches.map<DropdownMenuItem<int>>((branch) {
        return DropdownMenuItem<int>(
          value: branch.id,
          child: Text(
            branch.name,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _selectedTrainingCenterId == null ? null : (value) {
        setState(() {
          _selectedBranchId = value;
        });
      },
    );
  }

  // Build date field
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: OutBorderTextFormField(
            controller: controller,
            hintText: 'Select date',
            enabled: false,
            icon: Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 18),
          ),
        ),
      ],
    );
  }

  // Build seats field
  Widget _buildSeatsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seats',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        OutBorderTextFormField(
          controller: _seatsController,
          hintText: 'Enter seats',
          keyboardType: TextInputType.number,
          icon: Icon(Icons.people, color: Colors.blue.shade600, size: 18),
        ),
      ],
    );
  }

  // Select date method
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now()) 
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }


  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
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
      context: context,
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

  void _showLoadingToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text('جاري التحميل', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
      icon: const Icon(Icons.hourglass_empty, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }
}class PlanCourseAssignmentDataProvider extends GetxController {
  final _planCourseAssignments = <pca_model.PlanCourseAssignment>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;
  final _selectedStatusFilter = 'all'.obs;
  final _selectedCompanyFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  final _companies = <company_model.Company>[].obs;
  
  // Controllers
  final searchController = TextEditingController();

  List<pca_model.PlanCourseAssignment> get planCourseAssignments => _planCourseAssignments;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  String get selectedStatusFilter => _selectedStatusFilter.value;
  String get selectedCompanyFilter => _selectedCompanyFilter.value;
  String get searchQuery => _searchQuery.value;
  List<company_model.Company> get companies => _companies;
  void setCompanies(List<company_model.Company> value) => _companies.value = value;
  int get totalItems => filteredPlanCourseAssignments.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  
  List<pca_model.PlanCourseAssignment> get filteredPlanCourseAssignments {
    var filtered = _planCourseAssignments.toList();
    
    // Filter by status
    if (_selectedStatusFilter.value != 'all') {
      filtered = filtered.where((pca) => pca.status == _selectedStatusFilter.value).toList();
    }
    
    // Filter by company
    if (_selectedCompanyFilter.value != 'all') {
      filtered = filtered.where((pca) => pca.companyId.toString() == _selectedCompanyFilter.value).toList();
    }
    
    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((pca) =>
        pca.companyName.toLowerCase().contains(query) ||
        pca.courseName.toLowerCase().contains(query) ||
        pca.branchName.toLowerCase().contains(query) ||
        (pca.company?.email?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  }
  
  List<pca_model.PlanCourseAssignment> get pagedPlanCourseAssignments {
    if (totalItems == 0) return const <pca_model.PlanCourseAssignment>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      // Snap back to last valid page
      _currentPage.value = totalPages - 1;
      return pagedPlanCourseAssignments;
    }
    if (end > totalItems) end = totalItems;
    return filteredPlanCourseAssignments.sublist(start, end);
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

  Future<List<pca_model.PlanCourseAssignment>> loadData() async {
    try {
      _isLoading.value = true;
      
      // Load companies for filter
      try {
        final companiesResponse = await CompanyService.getAllCompanies();
        if (companiesResponse.statusCode == 200) {
          _companies.value = companiesResponse.data;
          print('Loaded ${companiesResponse.data.length} companies');
        } else {
          print('Failed to load companies: ${companiesResponse.messageEn}');
        }
      } catch (e) {
        print('Error loading companies for filter: $e');
        // Don't fail the whole operation if companies can't be loaded
      }
      
      // Note: Plan course assignments are now loaded by training plan selection only
      // using getPlanCourseAssignmentsByTrainingPlan API
      _planCourseAssignments.value = [];
      _currentPage.value = 0;
      return [];
    } catch (e) {
      _planCourseAssignments.clear();
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


