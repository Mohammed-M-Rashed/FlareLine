class Nomination {
  final int? id;
  final String employeeName;
  final String employeeNumber; // Changed from jobNumber to match API
  final String? phone; // Changed from phoneNumber to match API
  final String? email;
  final String? specialization;
  final String? department;
  final int? experienceYears; // Changed from yearsOfExperience to match API
  final int? planCourseAssignmentId; // New field for API integration
  final String? companyName;
  final String? trainingPlanName;
  final String? courseName;
  final String? status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Legacy fields for backward compatibility
  final String? jobNumber;
  final String? phoneNumber;
  final String? englishName;
  final int? companyId;
  final int? trainingPlanId;
  final int? courseId;
  final int? yearsOfExperience;

  Nomination({
    this.id,
    required this.employeeName,
    required this.employeeNumber,
    this.phone,
    this.email,
    this.specialization,
    this.department,
    this.experienceYears,
    this.planCourseAssignmentId,
    this.companyName,
    this.trainingPlanName,
    this.courseName,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    // Legacy fields
    this.jobNumber,
    this.phoneNumber,
    this.englishName,
    this.companyId,
    this.trainingPlanId,
    this.courseId,
    this.yearsOfExperience,
  });

  // Helper function to safely convert dynamic to int?
  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper function to safely convert dynamic to int (non-nullable)
  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  factory Nomination.fromJson(Map<String, dynamic> json) {
    return Nomination(
      id: _toIntNullable(json['id']),
      employeeName: json['employee_name'] ?? '',
      employeeNumber: json['employee_number'] ?? json['job_number'] ?? '',
      phone: json['phone'] ?? json['phone_number'],
      email: json['email'],
      specialization: json['specialization'],
      department: json['department'],
      experienceYears: _toIntNullable(json['experience_years'] ?? json['years_of_experience']),
      planCourseAssignmentId: _toIntNullable(json['plan_course_assignment_id']),
      companyName: json['company_name'],
      trainingPlanName: json['training_plan_name'],
      courseName: json['course_name'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      // Legacy fields for backward compatibility
      jobNumber: json['job_number'],
      phoneNumber: json['phone_number'],
      englishName: json['english_name'],
      companyId: _toIntNullable(json['company_id']),
      trainingPlanId: _toIntNullable(json['training_plan_id']),
      courseId: _toIntNullable(json['course_id']),
      yearsOfExperience: _toIntNullable(json['years_of_experience']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_name': employeeName,
      'employee_number': employeeNumber,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'department': department,
      'experience_years': experienceYears,
      'plan_course_assignment_id': planCourseAssignmentId,
      'company_name': companyName,
      'training_plan_name': trainingPlanName,
      'course_name': courseName,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // Legacy fields for backward compatibility
      'job_number': jobNumber,
      'phone_number': phoneNumber,
      'english_name': englishName,
      'company_id': companyId,
      'training_plan_id': trainingPlanId,
      'course_id': courseId,
      'years_of_experience': yearsOfExperience,
    };
  }

  Nomination copyWith({
    int? id,
    String? employeeName,
    String? employeeNumber,
    String? phone,
    String? email,
    String? specialization,
    String? department,
    int? experienceYears,
    int? planCourseAssignmentId,
    String? companyName,
    String? trainingPlanName,
    String? courseName,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Legacy fields
    String? jobNumber,
    String? phoneNumber,
    String? englishName,
    int? companyId,
    int? trainingPlanId,
    int? courseId,
    int? yearsOfExperience,
  }) {
    return Nomination(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      department: department ?? this.department,
      experienceYears: experienceYears ?? this.experienceYears,
      planCourseAssignmentId: planCourseAssignmentId ?? this.planCourseAssignmentId,
      companyName: companyName ?? this.companyName,
      trainingPlanName: trainingPlanName ?? this.trainingPlanName,
      courseName: courseName ?? this.courseName,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Legacy fields
      jobNumber: jobNumber ?? this.jobNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      englishName: englishName ?? this.englishName,
      companyId: companyId ?? this.companyId,
      trainingPlanId: trainingPlanId ?? this.trainingPlanId,
      courseId: courseId ?? this.courseId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'submitted':
        return 'Submitted';
      case 'draft':
        return 'Draft';
      default:
        return 'Unknown';
    }
  }

  // Helper method to create nomination for API submission
  Map<String, dynamic> toApiJson() {
    return {
      'employee_name': employeeName,
      'employee_number': employeeNumber,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'department': department,
      'experience_years': experienceYears,
    };
  }

  // Helper method to get display name for employee number
  String get employeeNumberDisplay => employeeNumber.isNotEmpty ? employeeNumber : (jobNumber ?? '');
  
  // Helper method to get display name for phone
  String get phoneDisplay => phone ?? phoneNumber ?? '';
  
  // Helper method to get display name for experience years
  int get experienceYearsDisplay => experienceYears ?? yearsOfExperience ?? 0;
}

