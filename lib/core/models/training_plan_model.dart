// Training Plan Management Models - Based on Actual API Documentation
import 'package:flutter/material.dart';

// Training Plan model for training plan management operations
class TrainingPlan {
  final int? id;
  final int year;
  final String title;
  final String? description;
  final int createdBy;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final User? creator;
  final List<PlanCourseAssignment>? planCourseAssignments;
  final List<Company>? companies;
  final List<Course>? courses;

  TrainingPlan({
    this.id,
    required this.year,
    required this.title,
    this.description,
    required this.createdBy,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.creator,
    this.planCourseAssignments,
    this.companies,
    this.courses,
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

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: _toIntNullable(json['id']),
      year: _toInt(json['year'], defaultValue: DateTime.now().year),
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: _toInt(json['created_by']),
      status: json['status'] ?? 'draft',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      creator: json['creator'] != null 
          ? User.fromJson(json['creator']) 
          : null,
      planCourseAssignments: json['plan_course_assignments'] != null
          ? (json['plan_course_assignments'] as List)
              .map((item) => PlanCourseAssignment.fromJson(item))
              .toList()
          : null,
      companies: json['companies'] != null
          ? (json['companies'] as List)
              .map((item) => Company.fromJson(item))
              .toList()
          : null,
      courses: json['courses'] != null
          ? (json['courses'] as List)
              .map((item) => Course.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (creator != null) 'creator': creator!.toJson(),
      if (planCourseAssignments != null) 
        'plan_course_assignments': planCourseAssignments!.map((e) => e.toJson()).toList(),
      if (companies != null) 
        'companies': companies!.map((e) => e.toJson()).toList(),
      if (courses != null) 
        'courses': courses!.map((e) => e.toJson()).toList(),
    };
  }

  // Getters for UI convenience
  String get creatorName => creator?.name ?? 'Unknown User';
  
  // Status check methods
  bool get isDraft => status == 'draft';
  bool get isPlanPreparation => status == 'plan_preparation';
  bool get isTrainingGeneralManagerApproval => status == 'training_general_manager_approval';
  bool get isBoardChairmanApproval => status == 'board_chairman_approval';
  bool get isApproved => status == 'approved';
  
  // Workflow permission methods
  bool get canBeEdited => isDraft;
  bool get canBeSubmitted => isDraft; // For backward compatibility
  bool get canBeMovedToPlanPreparation => isDraft;
  bool get canBeMovedToTrainingGeneralManagerApproval => isPlanPreparation;
  bool get canBeMovedToBoardChairmanApproval => isTrainingGeneralManagerApproval;
  bool get canBeApproved => isBoardChairmanApproval;
  
  // Role-based action permissions
  bool get canBeViewedByAdmin => true; // Admin can view all
  bool get canBeViewedByGeneralManager => isTrainingGeneralManagerApproval;
  bool get canBeViewedByBoardChairman => isBoardChairmanApproval;
  bool get canBeViewedByCompany => !isDraft; // Company cannot view draft plans
  
  // Status display properties
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'plan_preparation':
        return 'Plan Preparation';
      case 'training_general_manager_approval':
        return 'Training General Manager Approval';
      case 'board_chairman_approval':
        return 'Board Chairman Approval';
      case 'approved':
        return 'Approved';
      default:
        return status;
    }
  }
  
  String get statusDisplayAr {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'plan_preparation':
        return 'إعداد الخطة';
      case 'training_general_manager_approval':
        return 'موافقة المدير العام للتدريب';
      case 'board_chairman_approval':
        return 'موافقة رئيس مجلس الإدارة';
      case 'approved':
        return 'موافق عليه';
      default:
        return status;
    }
  }
  
  Color get statusColor {
    switch (status) {
      case 'draft':
        return Colors.grey.shade600;
      case 'plan_preparation':
        return Colors.blue.shade600;
      case 'training_general_manager_approval':
        return Colors.orange.shade600;
      case 'board_chairman_approval':
        return Colors.purple.shade600;
      case 'approved':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade400;
    }
  }
  
  IconData get statusIcon {
    switch (status) {
      case 'draft':
        return Icons.edit;
      case 'plan_preparation':
        return Icons.build;
      case 'training_general_manager_approval':
        return Icons.person;
      case 'board_chairman_approval':
        return Icons.groups;
      case 'approved':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

// User model for creator relationship
class User {
  final int id;
  final String name;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: TrainingPlan._toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Company model for related company data
class Company {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: TrainingPlan._toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Course model for course relationship
class Course {
  final int id;
  final String title;
  final String? description;
  final Specialization? specialization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.title,
    this.description,
    this.specialization,
    this.createdAt,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: TrainingPlan._toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      specialization: json['specialization'] != null 
          ? Specialization.fromJson(json['specialization']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (specialization != null) 'specialization': specialization!.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Specialization model for course specialization
class Specialization {
  final int id;
  final String name;

  Specialization({
    required this.id,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: TrainingPlan._toInt(json['id']),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Plan Course Assignment model for pivot relationship
class PlanCourseAssignment {
  final int id;
  final int trainingPlanId;
  final int companyId;
  final int courseId;
  final int trainingCenterBranchId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? seats;
  final Company? company;
  final Course? course;
  final TrainingCenterBranch? trainingCenterBranch;

  PlanCourseAssignment({
    required this.id,
    required this.trainingPlanId,
    required this.companyId,
    required this.courseId,
    required this.trainingCenterBranchId,
    this.startDate,
    this.endDate,
    this.seats,
    this.company,
    this.course,
    this.trainingCenterBranch,
  });

  factory PlanCourseAssignment.fromJson(Map<String, dynamic> json) {
    return PlanCourseAssignment(
      id: TrainingPlan._toInt(json['id']),
      trainingPlanId: TrainingPlan._toInt(json['training_plan_id']),
      companyId: TrainingPlan._toInt(json['company_id']),
      courseId: TrainingPlan._toInt(json['course_id']),
      trainingCenterBranchId: TrainingPlan._toInt(json['training_center_branch_id']),
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      seats: TrainingPlan._toIntNullable(json['seats']),
      company: json['company'] != null 
          ? Company.fromJson(json['company']) 
          : null,
      course: json['course'] != null 
          ? Course.fromJson(json['course']) 
          : null,
      trainingCenterBranch: json['training_center_branch'] != null 
          ? TrainingCenterBranch.fromJson(json['training_center_branch']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_plan_id': trainingPlanId,
      'company_id': companyId,
      'course_id': courseId,
      'training_center_branch_id': trainingCenterBranchId,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'seats': seats,
      if (company != null) 'company': company!.toJson(),
      if (course != null) 'course': course!.toJson(),
      if (trainingCenterBranch != null) 'training_center_branch': trainingCenterBranch!.toJson(),
    };
  }
}

// Training Center Branch model
class TrainingCenterBranch {
  final int id;
  final String name;
  final TrainingCenter? trainingCenter;

  TrainingCenterBranch({
    required this.id,
    required this.name,
    this.trainingCenter,
  });

  factory TrainingCenterBranch.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranch(
      id: TrainingPlan._toInt(json['id']),
      name: json['name'] ?? '',
      trainingCenter: json['training_center'] != null 
          ? TrainingCenter.fromJson(json['training_center']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (trainingCenter != null) 'training_center': trainingCenter!.toJson(),
    };
  }
}

// Training Center model
class TrainingCenter {
  final int id;
  final String name;

  TrainingCenter({
    required this.id,
    required this.name,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    return TrainingCenter(
      id: TrainingPlan._toInt(json['id']),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Request models for API operations
class TrainingPlanCreateRequest {
  final int year;
  final String title;
  final String? description;
  final int? createdBy;
  final String? status;

  TrainingPlanCreateRequest({
    required this.year,
    required this.title,
    this.description,
    this.createdBy,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'title': title,
      if (description != null) 'description': description,
      if (createdBy != null) 'created_by': createdBy,
      if (status != null) 'status': status,
    };
  }
}

class TrainingPlanUpdateRequest {
  final int id;
  final int? year;
  final String? title;
  final String? description;
  final int? createdBy;
  final String? status;

  TrainingPlanUpdateRequest({
    required this.id,
    this.year,
    this.title,
    this.description,
    this.createdBy,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (year != null) 'year': year,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdBy != null) 'created_by': createdBy,
      if (status != null) 'status': status,
    };
  }
}

class TrainingPlanShowRequest {
  final int id;

  TrainingPlanShowRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class TrainingPlanByStatusRequest {
  final String status;

  TrainingPlanByStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class TrainingPlanByYearRequest {
  final int year;

  TrainingPlanByYearRequest({
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
    };
  }
}


class TrainingPlanApproveRequest {
  final int id;

  TrainingPlanApproveRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class TrainingPlanRejectRequest {
  final int id;

  TrainingPlanRejectRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class TrainingPlanByCompanyRequest {
  final int companyId;

  TrainingPlanByCompanyRequest({
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
    };
  }
}

// Response models
class TrainingPlanResponse {
  final TrainingPlan? data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;
  final bool success;

  TrainingPlanResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
    required this.success,
  });

  factory TrainingPlanResponse.fromJson(Map<String, dynamic> json) {
    return TrainingPlanResponse(
      data: json['data'] != null ? TrainingPlan.fromJson(json['data']) : null,
      messageAr: json['m_ar'],
      messageEn: json['m_en'],
      statusCode: TrainingPlan._toInt(json['status_code'], defaultValue: 200),
      success: json['success'] ?? false,
    );
  }
}

class TrainingPlanListResponse {
  final List<TrainingPlan> data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;
  final bool success;

  TrainingPlanListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
    required this.success,
  });

  factory TrainingPlanListResponse.fromJson(Map<String, dynamic> json) {
    List<TrainingPlan> plans = [];
    if (json['data'] is List) {
      plans = (json['data'] as List)
          .map((item) => TrainingPlan.fromJson(item))
          .toList();
    }

    return TrainingPlanListResponse(
      data: plans,
      messageAr: json['m_ar'],
      messageEn: json['m_en'],
      statusCode: TrainingPlan._toInt(json['status_code'], defaultValue: 200),
      success: json['success'] ?? false,
    );
  }
}

// Model for approved training plans with company courses
class ApprovedTrainingPlanWithCourses {
  final int id;
  final int year;
  final String title;
  final String? description;
  final String status;
  final int createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? creator;
  final List<PlanCourseAssignmentWithCourse> planCourseAssignments;

  ApprovedTrainingPlanWithCourses({
    required this.id,
    required this.year,
    required this.title,
    this.description,
    required this.status,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.creator,
    required this.planCourseAssignments,
  });

  factory ApprovedTrainingPlanWithCourses.fromJson(Map<String, dynamic> json) {
    return ApprovedTrainingPlanWithCourses(
      id: TrainingPlan._toInt(json['id']),
      year: TrainingPlan._toInt(json['year'], defaultValue: DateTime.now().year),
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'approved',
      createdBy: TrainingPlan._toInt(json['created_by']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      creator: json['creator'] != null 
          ? User.fromJson(json['creator']) 
          : null,
      planCourseAssignments: (json['plan_course_assignments'] as List<dynamic>?)
          ?.map((assignment) => PlanCourseAssignmentWithCourse.fromJson(assignment))
          .toList() ?? [],
    );
  }
}

// Model for plan course assignment with course details
class PlanCourseAssignmentWithCourse {
  final int id;
  final int trainingPlanId;
  final int companyId;
  final int courseId;
  final int trainingCenterBranchId;
  final DateTime startDate;
  final DateTime endDate;
  final int seats;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Company? company;
  final Course? course;

  PlanCourseAssignmentWithCourse({
    required this.id,
    required this.trainingPlanId,
    required this.companyId,
    required this.courseId,
    required this.trainingCenterBranchId,
    required this.startDate,
    required this.endDate,
    required this.seats,
    this.createdAt,
    this.updatedAt,
    this.company,
    this.course,
  });

  factory PlanCourseAssignmentWithCourse.fromJson(Map<String, dynamic> json) {
    return PlanCourseAssignmentWithCourse(
      id: TrainingPlan._toInt(json['id']),
      trainingPlanId: TrainingPlan._toInt(json['training_plan_id']),
      companyId: TrainingPlan._toInt(json['company_id']),
      courseId: TrainingPlan._toInt(json['course_id']),
      trainingCenterBranchId: TrainingPlan._toInt(json['training_center_branch_id']),
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now(),
      seats: TrainingPlan._toInt(json['seats']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      company: json['company'] != null 
          ? Company.fromJson(json['company']) 
          : null,
      course: json['course'] != null 
          ? Course.fromJson(json['course']) 
          : null,
    );
  }
}

// Response model for approved training plans with courses
class ApprovedTrainingPlansWithCoursesResponse {
  final bool success;
  final List<ApprovedTrainingPlanWithCourses> data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  ApprovedTrainingPlansWithCoursesResponse({
    required this.success,
    required this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory ApprovedTrainingPlansWithCoursesResponse.fromJson(Map<String, dynamic> json) {
    return ApprovedTrainingPlansWithCoursesResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((plan) => ApprovedTrainingPlanWithCourses.fromJson(plan))
          .toList() ?? [],
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: TrainingPlan._toInt(json['status_code'], defaultValue: 200),
    );
  }
}