// Training Center Management Models - Based on API Documentation
import 'package:flutter/material.dart';

// Training Center model for training center management operations
class TrainingCenter {
  final int? id;
  final String name;
  final int specializationId;
  final String address;
  final String phone;
  final String status;
  final String? filePath;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Specialization? specialization;

  TrainingCenter({
    this.id,
    required this.name,
    required this.specializationId,
    required this.address,
    required this.phone,
    required this.status,
    this.filePath,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
    this.specialization,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    return TrainingCenter(
      id: json['id'],
      name: json['name'] ?? '',
      specializationId: json['specialization_id'] ?? 0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'pending',
      filePath: json['file_path'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      specialization: json['specialization'] != null 
          ? Specialization.fromJson(json['specialization']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'specialization_id': specializationId,
      'address': address,
      'phone': phone,
      'status': status,
    };
    
    if (id != null) data['id'] = id;
    if (filePath != null) data['file_path'] = filePath;
    if (fileName != null) data['file_name'] = fileName;
    if (fileType != null) data['file_type'] = fileType;
    if (fileSize != null) data['file_size'] = fileSize;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    if (specialization != null) data['specialization'] = specialization!.toJson();
    
    return data;
  }

  TrainingCenter copyWith({
    int? id,
    String? name,
    int? specializationId,
    String? address,
    String? phone,
    String? status,
    String? filePath,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    Specialization? specialization,
  }) {
    return TrainingCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      specializationId: specializationId ?? this.specializationId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialization: specialization ?? this.specialization,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasFile => filePath != null && filePath!.isNotEmpty;
  
  String get fileSizeHuman {
    if (fileSize == null) return 'N/A';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSize!.toDouble();
    int unit = 0;
    
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unit]}';
  }

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
}

// Specialization model for training center management
class Specialization {
  final int? id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Specialization({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
    };
    
    if (id != null) data['id'] = id;
    if (description != null) data['description'] = description;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    
    return data;
  }
}

// Training Center List Response model
class TrainingCenterListResponse {
  final bool success;
  final List<TrainingCenter> data;
  final String? message;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterListResponse({
    required this.success,
    required this.data,
    this.message,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((item) => TrainingCenter.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }
}

// Training Center Response model
class TrainingCenterResponse {
  final bool success;
  final TrainingCenter? data;
  final String? message;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterResponse({
    required this.success,
    this.data,
    this.message,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? TrainingCenter.fromJson(json['data']) : null,
      message: json['message'],
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }
}
