// Special Course Request Management Models - Based on Actual API Documentation
import 'package:flutter/material.dart';

// Special Course Request model for special course request management operations
class SpecialCourseRequest {
  final int? id;
  final int companyId;
  final int specializationId;
  final String title;
  final String description;
  final String? fileAttachment;
  final String status;
  final String? rejectionReason;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final Company? company;

  SpecialCourseRequest({
    this.id,
    required this.companyId,
    required this.specializationId,
    required this.title,
    required this.description,
    this.fileAttachment,
    required this.status,
    this.rejectionReason,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.company,
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

  factory SpecialCourseRequest.fromJson(Map<String, dynamic> json) {
    return SpecialCourseRequest(
      id: _toIntNullable(json['id']),
      companyId: _toInt(json['company_id']),
      specializationId: _toInt(json['specialization_id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileAttachment: json['file_attachment'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdBy: _toIntNullable(json['created_by']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      company: json['company'] != null 
          ? Company.fromJson(json['company']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'specialization_id': specializationId,
      'title': title,
      'description': description,
      'file_attachment': fileAttachment,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (company != null) 'company': company!.toJson(),
    };
  }

  // Getters for UI convenience
  String get companyName => company?.name ?? 'Unknown Company';
  
  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  bool get canBeEdited => isPending;
  bool get hasFileAttachment => fileAttachment != null && fileAttachment!.isNotEmpty;

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
        return Colors.grey.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade500;
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
      id: SpecialCourseRequest._toInt(json['id']),
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

// Request models for API operations
class SpecialCourseRequestCreateRequest {
  final int companyId;
  final int specializationId;
  final String title;
  final String description;
  final String? fileAttachment;
  final String? status;

  SpecialCourseRequestCreateRequest({
    required this.companyId,
    required this.specializationId,
    required this.title,
    required this.description,
    this.fileAttachment,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'specialization_id': specializationId,
      'title': title,
      'description': description,
      if (fileAttachment != null) 'file_attachment': fileAttachment,
      if (status != null) 'status': status,
    };
  }
}

class SpecialCourseRequestUpdateRequest {
  final int id;
  final int? companyId;
  final int? specializationId;
  final String? title;
  final String? description;
  final String? fileAttachment;
  final String? status;

  SpecialCourseRequestUpdateRequest({
    required this.id,
    this.companyId,
    this.specializationId,
    this.title,
    this.description,
    this.fileAttachment,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      if (specializationId != null) 'specialization_id': specializationId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (fileAttachment != null) 'file_attachment': fileAttachment,
      if (status != null) 'status': status,
    };
  }
}


class ApproveSpecialCourseRequestRequest {
  final int id;

  ApproveSpecialCourseRequestRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class RejectSpecialCourseRequestRequest {
  final int id;
  final String rejectionReason;

  RejectSpecialCourseRequestRequest({
    required this.id,
    required this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rejection_reason': rejectionReason,
    };
  }
}

// Response models
class SpecialCourseRequestResponse {
  final SpecialCourseRequest? data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  SpecialCourseRequestResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory SpecialCourseRequestResponse.fromJson(Map<String, dynamic> json) {
    return SpecialCourseRequestResponse(
      data: json['data'] != null ? SpecialCourseRequest.fromJson(json['data']) : null,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: SpecialCourseRequest._toInt(json['status_code'], defaultValue: 200),
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
}

class SpecialCourseRequestListResponse {
  final List<SpecialCourseRequest> data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  SpecialCourseRequestListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory SpecialCourseRequestListResponse.fromJson(Map<String, dynamic> json) {
    List<SpecialCourseRequest> requests = [];
    if (json['data'] is List) {
      requests = (json['data'] as List)
          .map((item) => SpecialCourseRequest.fromJson(item))
          .toList();
    }

    return SpecialCourseRequestListResponse(
      data: requests,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: SpecialCourseRequest._toInt(json['status_code'], defaultValue: 200),
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
}

class ForwardSpecialCourseRequestRequest {
  final int id;

  ForwardSpecialCourseRequestRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}