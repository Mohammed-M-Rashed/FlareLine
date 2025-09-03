// Training Need Management Models - Based on Training Need API Documentation
import 'package:flutter/material.dart';

// Training Need model for training need management operations
class TrainingNeed {
  final int? id;
  final int companyId;
  final int courseId;
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
    required this.numberOfParticipants,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.company,
    this.course,
  });

  factory TrainingNeed.fromJson(Map<String, dynamic> json) {
    return TrainingNeed(
      id: json['id'],
      companyId: json['company_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      numberOfParticipants: json['number_of_participants'] ?? 0,
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
      numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      course: course ?? this.course,
    );
  }

  // Helper methods for status values
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
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

  // Display properties
  String get companyName => company?.name ?? 'Unknown Company';
  String get courseName => course?.title ?? 'Unknown Course';
  String get courseDescription => course?.description ?? '';

  @override
  String toString() {
    return 'TrainingNeed(id: $id, companyId: $companyId, courseId: $courseId, numberOfParticipants: $numberOfParticipants, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingNeed &&
        other.id == id &&
        other.companyId == companyId &&
        other.courseId == courseId &&
        other.numberOfParticipants == numberOfParticipants &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           companyId.hashCode ^ 
           courseId.hashCode ^ 
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      specializationId: json['specialization_id'],
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
      id: json['id'] ?? 0,
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
  final int numberOfParticipants;

  TrainingNeedCreateRequest({
    required this.companyId,
    required this.courseId,
    required this.numberOfParticipants,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'course_id': courseId,
      'number_of_participants': numberOfParticipants,
    };
  }
}

// Training Need Update Request model
class TrainingNeedUpdateRequest {
  final int id;
  final int? companyId;
  final int? courseId;
  final int? numberOfParticipants;

  TrainingNeedUpdateRequest({
    required this.id,
    this.companyId,
    this.courseId,
    this.numberOfParticipants,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (companyId != null) data['company_id'] = companyId;
    if (courseId != null) data['course_id'] = courseId;
    if (numberOfParticipants != null) data['number_of_participants'] = numberOfParticipants;
    
    return data;
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
      statusCode: json['status_code'],
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
      statusCode: json['status_code'],
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
}
