// Special Course Request Management Models - Based on Actual API Documentation
import 'package:flutter/material.dart';

// Special Course Request model for special course request management operations
class SpecialCourseRequest {
  final int? id;
  final int companyId;
  final String title;
  final String description;
  final String? fileAttachment;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final Company? company;

  SpecialCourseRequest({
    this.id,
    required this.companyId,
    required this.title,
    required this.description,
    this.fileAttachment,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.company,
  });

  factory SpecialCourseRequest.fromJson(Map<String, dynamic> json) {
    return SpecialCourseRequest(
      id: json['id'],
      companyId: json['company_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileAttachment: json['file_attachment'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'file_attachment': fileAttachment,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (company != null) 'company': company!.toJson(),
    };
  }

  // Getters for UI convenience
  String get companyName => company?.name ?? 'Unknown Company';
  
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  bool get canBeEdited => isPending;
  bool get hasFileAttachment => fileAttachment != null && fileAttachment!.isNotEmpty;

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

// Request models for API operations
class SpecialCourseRequestCreateRequest {
  final int companyId;
  final String title;
  final String description;
  final String? fileAttachment;
  final String? status;
  final String? createdBy;

  SpecialCourseRequestCreateRequest({
    required this.companyId,
    required this.title,
    required this.description,
    this.fileAttachment,
    this.status,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'title': title,
      'description': description,
      if (fileAttachment != null) 'file_attachment': fileAttachment,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class SpecialCourseRequestUpdateRequest {
  final int id;
  final int? companyId;
  final String? title;
  final String? description;
  final String? fileAttachment;
  final String? status;
  final String? createdBy;

  SpecialCourseRequestUpdateRequest({
    required this.id,
    this.companyId,
    this.title,
    this.description,
    this.fileAttachment,
    this.status,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (fileAttachment != null) 'file_attachment': fileAttachment,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class SpecialCourseRequestByStatusRequest {
  final String status;

  SpecialCourseRequestByStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class SpecialCourseRequestApproveRequest {
  final int id;

  SpecialCourseRequestApproveRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class SpecialCourseRequestRejectRequest {
  final int id;

  SpecialCourseRequestRejectRequest({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      statusCode: json['status_code'] ?? 200,
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
      statusCode: json['status_code'] ?? 200,
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
}