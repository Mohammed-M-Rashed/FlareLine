// Plan Course Assignment Management Models - Based on Special Course Request Structure
import 'package:flutter/material.dart';

// Plan Course Assignment model for plan course assignment management operations
class PlanCourseAssignment {
  final int? id;
  final int companyId;
  final int courseId;
  final int trainingCenterBranchId;
  final DateTime startDate;
  final DateTime endDate;
  final int seats;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final Company? company;
  final Course? course;
  final TrainingCenterBranch? trainingCenterBranch;

  PlanCourseAssignment({
    this.id,
    required this.companyId,
    required this.courseId,
    required this.trainingCenterBranchId,
    required this.startDate,
    required this.endDate,
    required this.seats,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.company,
    this.course,
    this.trainingCenterBranch,
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

  factory PlanCourseAssignment.fromJson(Map<String, dynamic> json) {
    return PlanCourseAssignment(
      id: _toIntNullable(json['id']),
      companyId: _toInt(json['company_id']),
      courseId: _toInt(json['course_id']),
      trainingCenterBranchId: _toInt(json['training_center_branch_id']),
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now(),
      seats: _toInt(json['seats']),
      status: json['status'] ?? 'pending',
      createdBy: json['created_by'],
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
      trainingCenterBranch: json['training_center_branch'] != null 
          ? TrainingCenterBranch.fromJson(json['training_center_branch']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'course_id': courseId,
      'training_center_branch_id': trainingCenterBranchId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'seats': seats,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (company != null) 'company': company!.toJson(),
      if (course != null) 'course': course!.toJson(),
      if (trainingCenterBranch != null) 'training_center_branch': trainingCenterBranch!.toJson(),
    };
  }

  // Getters for UI convenience
  String get companyName => company?.name ?? 'Unknown Company';
  String get courseName => course?.title ?? 'Unknown Course';
  String get branchName => trainingCenterBranch?.name ?? 'Unknown Branch';
  
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  bool get canBeEdited => isPending;
  bool get hasValidDates => endDate.isAfter(startDate);

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
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
      case 'pending':
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
      case 'pending':
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
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String get dateRangeDisplay {
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
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
      id: PlanCourseAssignment._toInt(json['id']),
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

// Course model for related course data
class Course {
  final int id;
  final String title;
  final String? description;
  final int? specializationId;
  final String? specializationName;
  final Specialization? specialization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.title,
    this.description,
    this.specializationId,
    this.specializationName,
    this.specialization,
    this.createdAt,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: PlanCourseAssignment._toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      specializationId: PlanCourseAssignment._toIntNullable(json['specialization_id']),
      specializationName: json['specialization_name'],
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
      'specialization_id': specializationId,
      'specialization_name': specializationName,
      'specialization': specialization?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Specialization model for related specialization data
class Specialization {
  final int id;
  final String name;
  final String? description;
  final int? createdBy;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Specialization({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: PlanCourseAssignment._toInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      createdBy: PlanCourseAssignment._toIntNullable(json['created_by']),
      status: json['status'],
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
      'description': description,
      'created_by': createdBy,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Training Center Branch model for related branch data
class TrainingCenterBranch {
  final int id;
  final String name;
  final String? address;
  final int? trainingCenterId;
  final String? trainingCenterName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainingCenterBranch({
    required this.id,
    required this.name,
    this.address,
    this.trainingCenterId,
    this.trainingCenterName,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingCenterBranch.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranch(
      id: PlanCourseAssignment._toInt(json['id']),
      name: json['name'] ?? '',
      address: json['address'],
      trainingCenterId: PlanCourseAssignment._toIntNullable(json['training_center_id']),
      trainingCenterName: json['training_center_name'],
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
      'address': address,
      'training_center_id': trainingCenterId,
      'training_center_name': trainingCenterName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Request models for API operations
class PlanCourseAssignmentCreateRequest {
  final int companyId;
  final int courseId;
  final int trainingCenterBranchId;
  final DateTime startDate;
  final DateTime endDate;
  final int seats;
  final String? status;
  final String? createdBy;

  PlanCourseAssignmentCreateRequest({
    required this.companyId,
    required this.courseId,
    required this.trainingCenterBranchId,
    required this.startDate,
    required this.endDate,
    required this.seats,
    this.status,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'course_id': courseId,
      'training_center_branch_id': trainingCenterBranchId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'seats': seats,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class PlanCourseAssignmentUpdateRequest {
  final int id;
  final int? companyId;
  final int? courseId;
  final int? trainingCenterBranchId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? seats;
  final String? status;
  final String? createdBy;

  PlanCourseAssignmentUpdateRequest({
    required this.id,
    this.companyId,
    this.courseId,
    this.trainingCenterBranchId,
    this.startDate,
    this.endDate,
    this.seats,
    this.status,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      if (courseId != null) 'course_id': courseId,
      if (trainingCenterBranchId != null) 'training_center_branch_id': trainingCenterBranchId,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (seats != null) 'seats': seats,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class GetPlanCourseAssignmentsByStatusRequest {
  final String status;

  GetPlanCourseAssignmentsByStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class ApprovePlanCourseAssignmentRequest {
  final int id;

  ApprovePlanCourseAssignmentRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class RejectPlanCourseAssignmentRequest {
  final int id;

  RejectPlanCourseAssignmentRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

// Response models
class PlanCourseAssignmentResponse {
  final PlanCourseAssignment? data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  PlanCourseAssignmentResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory PlanCourseAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return PlanCourseAssignmentResponse(
      data: json['data'] != null ? PlanCourseAssignment.fromJson(json['data']) : null,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: PlanCourseAssignment._toInt(json['status_code'], defaultValue: 200),
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
}

class PlanCourseAssignmentListResponse {
  final List<PlanCourseAssignment> data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  PlanCourseAssignmentListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory PlanCourseAssignmentListResponse.fromJson(Map<String, dynamic> json) {
    List<PlanCourseAssignment> assignments = [];
    if (json['data'] is List) {
      assignments = (json['data'] as List)
          .map((item) => PlanCourseAssignment.fromJson(item))
          .toList();
    }

    return PlanCourseAssignmentListResponse(
      data: assignments,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: PlanCourseAssignment._toInt(json['status_code'], defaultValue: 200),
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
}
