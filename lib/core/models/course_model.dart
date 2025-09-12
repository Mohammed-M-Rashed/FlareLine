// Course Management Models
import 'package:flutter/material.dart';
import 'package:flareline/core/models/specialization_model.dart';

// Course model for course management operations
class Course {
  final int? id;
  final int specializationId;
  final String code;
  final String title;
  final String description;
  final String? createdBy;
  final String? fileAttachment;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Specialization? specialization;

  Course({
    this.id,
    required this.specializationId,
    required this.code,
    required this.title,
    required this.description,
    this.createdBy,
    this.fileAttachment,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.specialization,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      specializationId: json['specialization_id'] ?? 0,
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['created_by'],
      fileAttachment: json['file_attachment'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      specialization: json['specialization'] != null 
          ? Specialization.fromJson(json['specialization']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'specialization_id': specializationId,
      'code': code,
      'title': title,
      'description': description,
      'status': status,
    };
    
    if (id != null) data['id'] = id;
    if (createdBy != null) data['created_by'] = createdBy;
    if (fileAttachment != null) data['file_attachment'] = fileAttachment;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    
    return data;
  }

  Course copyWith({
    int? id,
    int? specializationId,
    String? code,
    String? title,
    String? description,
    String? createdBy,
    String? fileAttachment,
    String? status,
    String? createdAt,
    String? updatedAt,
    Specialization? specialization,
  }) {
    return Course(
      id: id ?? this.id,
      specializationId: specializationId ?? this.specializationId,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      fileAttachment: fileAttachment ?? this.fileAttachment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialization: specialization ?? this.specialization,
    );
  }

  // Helper methods
  String get createdByText {
    switch (createdBy?.toLowerCase() ?? '') {
      case 'admin':
        return 'مدير النظام';
      case 'company':
        return 'شركة';
      case 'user':
        return 'مستخدم';
      case 'trainer':
        return 'مدرب';
      default:
        return createdBy ?? 'غير محدد';
    }
  }
  
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  String get formattedCreatedAt {
    if (createdAt == null) return 'غير محدد';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }

  String get formattedUpdatedAt {
    if (updatedAt == null) return 'غير محدد';
    try {
      final date = DateTime.parse(updatedAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return updatedAt!;
    }
  }

  bool get hasFileAttachment => fileAttachment != null && fileAttachment!.isNotEmpty;
  
  String get fileAttachmentName {
    if (!hasFileAttachment) return '';
    final parts = fileAttachment!.split('/');
    return parts.last;
  }

  String get fileAttachmentExtension {
    if (!hasFileAttachment) return '';
    final parts = fileAttachmentName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  IconData get fileAttachmentIcon {
    switch (fileAttachmentExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.attach_file;
    }
  }

  Color get fileAttachmentColor {
    switch (fileAttachmentExtension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get a meaningful specialization display name
  String get specializationDisplayName {
    if (specialization?.name != null && specialization!.name.isNotEmpty) {
      return specialization!.name;
    }
    
    if (specializationId > 0) {
      return 'تخصص #$specializationId';
    }
    
    return 'غير محدد';
  }

  /// Get a meaningful description display
  String get descriptionDisplay {
    if (description.isNotEmpty) {
      return description;
    }
    return 'لا يوجد وصف';
  }

  /// Check if course has complete information
  bool get isComplete {
    return code.isNotEmpty &&
           title.isNotEmpty && 
           specializationId > 0 && 
           description.isNotEmpty;
  }

  /// Status getters
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Status display properties
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
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

  String get statusDisplayText {
    switch (status) {
      case 'active':
        return 'نشط';
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

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

// API Response models for course management
class CourseListResponse {
  final List<Course> data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  CourseListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    return CourseListResponse(
      data: (json['data'] as List?)
              ?.map((course) => Course.fromJson(course))
              .toList() ??
          [],
      messageAr: json['m_ar'],
      messageEn: json['m_en'],
      statusCode: json['status_code'] ?? 200,
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
  String get message {
    if (messageAr != null && messageAr!.isNotEmpty) {
      return messageAr!;
    }
    if (messageEn != null && messageEn!.isNotEmpty) {
      return messageEn!;
    }
    return 'No message';
  }
}

class CourseResponse {
  final Course? data;
  final String? messageAr;
  final String? messageEn;
  final int statusCode;

  CourseResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    required this.statusCode,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      data: json['data'] != null ? Course.fromJson(json['data']) : null,
      messageAr: json['m_ar'],
      messageEn: json['m_en'],
      statusCode: json['status_code'] ?? 200,
    );
  }

  bool get success => statusCode >= 200 && statusCode < 300;
  String get message {
    if (messageAr != null && messageAr!.isNotEmpty) {
      return messageAr!;
    }
    if (messageEn != null && messageEn!.isNotEmpty) {
      return messageEn!;
    }
    return 'No message';
  }
}

// Request models for course operations
class CourseCreateRequest {
  final int specializationId;
  final String code;
  final String title;
  final String description;
  final String? createdBy;
  final String? fileAttachment;

  CourseCreateRequest({
    required this.specializationId,
    required this.code,
    required this.title,
    required this.description,
    this.createdBy,
    this.fileAttachment,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'specialization_id': specializationId,
      'code': code,
      'title': title,
      'description': description,
      'created_by': createdBy ?? 'admin', // Always include created_by, default to 'admin'
    };
    
    if (fileAttachment != null) data['file_attachment'] = fileAttachment;
    
    return data;
  }
}

class CourseUpdateRequest {
  final int id;
  final int? specializationId;
  final String? code;
  final String? title;
  final String? description;
  final String? createdBy;
  final String? fileAttachment;

  CourseUpdateRequest({
    required this.id,
    this.specializationId,
    this.code,
    this.title,
    this.description,
    this.createdBy,
    this.fileAttachment,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (specializationId != null) data['specialization_id'] = specializationId;
    if (code != null) data['code'] = code;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (createdBy != null) data['created_by'] = createdBy;
    if (fileAttachment != null) data['file_attachment'] = fileAttachment;
    
    return data;
  }
}

class CourseFilterRequest {
  final int? specializationId;

  CourseFilterRequest({this.specializationId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (specializationId != null) data['specialization_id'] = specializationId;
    
    return data;
  }
}

class CourseSearchRequest {
  final String searchTerm;

  CourseSearchRequest({required this.searchTerm});

  Map<String, dynamic> toJson() {
    return {
      'search_term': searchTerm,
    };
  }
}

class CourseByCodeRequest {
  final String code;

  CourseByCodeRequest({required this.code});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}

class CourseByStatusRequest {
  final String status;

  CourseByStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
