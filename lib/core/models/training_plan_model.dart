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

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      year: json['year'] ?? DateTime.now().year,
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: json['created_by'] ?? 0,
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
  
  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  bool get canBeEdited => isDraft || isRejected;
  bool get canBeSubmitted => isDraft || isRejected;
  bool get canBeApproved => isSubmitted;
  bool get canBeRejected => isSubmitted;

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
        return 'Submitted';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'draft':
        return Icons.edit;
      case 'submitted':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String get statusDisplayText {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'submitted':
        return 'مُرسل';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
      trainingPlanId: json['training_plan_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      trainingCenterBranchId: json['training_center_branch_id'] ?? 0,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      seats: json['seats'],
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
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

class TrainingPlanSubmitRequest {
  final int id;

  TrainingPlanSubmitRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      statusCode: json['status_code'] ?? 200,
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
      statusCode: json['status_code'] ?? 200,
      success: json['success'] ?? false,
    );
  }
}