// Training Need Management Models - Based on Training Need API Documentation
import 'package:flutter/material.dart';

// Training Need model for training need management operations
class TrainingNeed {
  final int? id;
  final int companyId;
  final int courseId;
  final int individualNeed;
  final int managementNeed;
  final int jobNeed;
  final int departmentNeed;
  final int numberOfParticipants;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final Company? company;
  final Course? course;

  TrainingNeed({
    this.id,
    required this.companyId,
    required this.courseId,
    required this.individualNeed,
    required this.managementNeed,
    required this.jobNeed,
    required this.departmentNeed,
    required this.numberOfParticipants,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.company,
    this.course,
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

  factory TrainingNeed.fromJson(Map<String, dynamic> json) {
    final individualNeed = _toInt(json['individual_need']);
    final managementNeed = _toInt(json['management_need']);
    final jobNeed = _toInt(json['job_need']);
    final departmentNeed = _toInt(json['department_need']);
    
    return TrainingNeed(
      id: _toIntNullable(json['id']),
      companyId: _toInt(json['company_id']),
      courseId: _toInt(json['course_id']),
      individualNeed: individualNeed,
      managementNeed: managementNeed,
      jobNeed: jobNeed,
      departmentNeed: departmentNeed,
      numberOfParticipants: _toInt(
        json['number_of_participants'], 
        defaultValue: individualNeed + managementNeed + jobNeed + departmentNeed
      ),
      status: json['status'] ?? 'pending',
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'company_id': companyId,
      'course_id': courseId,
      'individual_need': individualNeed,
      'management_need': managementNeed,
      'job_need': jobNeed,
      'department_need': departmentNeed,
      'number_of_participants': numberOfParticipants,
      'status': status,
    };
    
    if (id != null) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    
    return data;
  }

  TrainingNeed copyWith({
    int? id,
    int? companyId,
    int? courseId,
    int? individualNeed,
    int? managementNeed,
    int? jobNeed,
    int? departmentNeed,
    int? numberOfParticipants,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Company? company,
    Course? course,
  }) {
    return TrainingNeed(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      courseId: courseId ?? this.courseId,
      individualNeed: individualNeed ?? this.individualNeed,
      managementNeed: managementNeed ?? this.managementNeed,
      jobNeed: jobNeed ?? this.jobNeed,
      departmentNeed: departmentNeed ?? this.departmentNeed,
      numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      course: course ?? this.course,
    );
  }

  // Helper methods for status values
  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
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
      case 'draft':
        return Colors.grey;
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

  // Display properties
  String get companyName => company?.name ?? 'Unknown Company';
  String get courseName => course?.title ?? 'Unknown Course';
  String get courseDescription => course?.description ?? '';

  @override
  String toString() {
    return 'TrainingNeed(id: $id, companyId: $companyId, courseId: $courseId, individualNeed: $individualNeed, managementNeed: $managementNeed, jobNeed: $jobNeed, departmentNeed: $departmentNeed, numberOfParticipants: $numberOfParticipants, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingNeed &&
        other.id == id &&
        other.companyId == companyId &&
        other.courseId == courseId &&
        other.individualNeed == individualNeed &&
        other.managementNeed == managementNeed &&
        other.jobNeed == jobNeed &&
        other.departmentNeed == departmentNeed &&
        other.numberOfParticipants == numberOfParticipants &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           companyId.hashCode ^ 
           courseId.hashCode ^ 
           individualNeed.hashCode ^
           managementNeed.hashCode ^
           jobNeed.hashCode ^
           departmentNeed.hashCode ^
           numberOfParticipants.hashCode ^ 
           status.hashCode;
  }
}

// Company model for related data
class Company {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: TrainingNeed._toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    };
  }
}

// Course model for related data
class Course {
  final int id;
  final String title;
  final String? description;
  final int? specializationId;
  final Specialization? specialization;

  Course({
    required this.id,
    required this.title,
    this.description,
    this.specializationId,
    this.specialization,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: TrainingNeed._toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      specializationId: TrainingNeed._toIntNullable(json['specialization_id']),
      specialization: json['specialization'] != null 
          ? Specialization.fromJson(json['specialization']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (specializationId != null) 'specialization_id': specializationId,
    };
  }
}

// Specialization model for related data
class Specialization {
  final int id;
  final String name;
  final String? description;

  Specialization({
    required this.id,
    required this.name,
    this.description,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: TrainingNeed._toInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

// Training Need Create Request model
class TrainingNeedCreateRequest {
  final int companyId;
  final int courseId;
  final int specializationId;
  final int individualNeed;
  final int managementNeed;
  final int jobNeed;
  final int departmentNeed;
  final int numberOfParticipants;

  TrainingNeedCreateRequest({
    required this.companyId,
    required this.courseId,
    required this.specializationId,
    required this.individualNeed,
    required this.managementNeed,
    required this.jobNeed,
    required this.departmentNeed,
    required this.numberOfParticipants,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'course_id': courseId,
      'specialization_id': specializationId,
      'individual_need': individualNeed,
      'management_need': managementNeed,
      'job_need': jobNeed,
      'department_need': departmentNeed,
      'number_of_participants': numberOfParticipants,
    };
  }
}

// Training Need Update Request model
class TrainingNeedUpdateRequest {
  final int id;
  final int? companyId;
  final int? courseId;
  final int? specializationId;
  final int? individualNeed;
  final int? managementNeed;
  final int? jobNeed;
  final int? departmentNeed;
  final int? numberOfParticipants;

  TrainingNeedUpdateRequest({
    required this.id,
    this.companyId,
    this.courseId,
    this.specializationId,
    this.individualNeed,
    this.managementNeed,
    this.jobNeed,
    this.departmentNeed,
    this.numberOfParticipants,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (companyId != null) data['company_id'] = companyId;
    if (courseId != null) data['course_id'] = courseId;
    if (specializationId != null) data['specialization_id'] = specializationId;
    if (individualNeed != null) data['individual_need'] = individualNeed;
    if (managementNeed != null) data['management_need'] = managementNeed;
    if (jobNeed != null) data['job_need'] = jobNeed;
    if (departmentNeed != null) data['department_need'] = departmentNeed;
    if (numberOfParticipants != null) data['number_of_participants'] = numberOfParticipants;
    
    return data;
  }
}

// Get Training Needs By Status Request model
class GetTrainingNeedsByStatusRequest {
  final String status;

  GetTrainingNeedsByStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

// Approve Training Need Request model
class ApproveTrainingNeedRequest {
  final int id;

  ApproveTrainingNeedRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

// Reject Training Need Request model
class RejectTrainingNeedRequest {
  final int id;
  final String rejection_reason;

  RejectTrainingNeedRequest({required this.id, required this.rejection_reason});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rejection_reason': rejection_reason,
    };
  }
}

// Training Need List Response model
class TrainingNeedListResponse {
  final List<TrainingNeed> data;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;

  TrainingNeedListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    this.statusCode,
  });

  factory TrainingNeedListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingNeedListResponse(
      data: (json['data'] as List?)
              ?.map((item) => TrainingNeed.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: TrainingNeed._toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200;
}

// Training Need Response model
class TrainingNeedResponse {
  final TrainingNeed? data;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;

  TrainingNeedResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    this.statusCode,
  });

  factory TrainingNeedResponse.fromJson(Map<String, dynamic> json) {
    return TrainingNeedResponse(
      data: json['data'] != null ? TrainingNeed.fromJson(json['data']) : null,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: TrainingNeed._toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
}

// Request model for forwarding training needs
class ForwardTrainingNeedRequest {
  final int id;

  ForwardTrainingNeedRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}