// Training Center Management Models - Based on New API Documentation
import 'package:flutter/material.dart';

// Training Center model for training center management operations
class TrainingCenter {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? website;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainingCenter({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    return TrainingCenter(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      website: json['website'],
      description: json['description'],
      status: json['status'] ?? 'pending',
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
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
    };
    
    if (id != null) data['id'] = id;
    if (website != null) data['website'] = website;
    if (description != null) data['description'] = description;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    
    return data;
  }

  TrainingCenter copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? website,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for new status values
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

  @override
  String toString() {
    return 'TrainingCenter(id: $id, name: $name, email: $email, phone: $phone, address: $address, website: $website, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingCenter &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address &&
        other.website == website &&
        other.description == description &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           email.hashCode ^ 
           phone.hashCode ^ 
           address.hashCode ^ 
           (website?.hashCode ?? 0) ^ 
           (description?.hashCode ?? 0) ^ 
           status.hashCode;
  }
}

// Training Center Create Request model
class TrainingCenterCreateRequest {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? website;
  final String? description;
  final String? status;

  TrainingCenterCreateRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    this.description,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
    
    if (website != null) data['website'] = website;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    
    return data;
  }
}

// Training Center Update Request model
class TrainingCenterUpdateRequest {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? website;
  final String? description;
  final String? status;

  TrainingCenterUpdateRequest({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.website,
    this.description,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (website != null) data['website'] = website;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    
    return data;
  }
}

// Training Center List Response model
class TrainingCenterListResponse {
  final List<TrainingCenter> data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterListResponse({
    required this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterListResponse(
      data: (json['data'] as List?)
              ?.map((item) => TrainingCenter.fromJson(item))
              .toList() ??
          [],
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }

  bool get success => statusCode == 200;
  String get messageAr => mAr ?? 'تم جلب مراكز التدريب بنجاح';
  String get messageEn => mEn ?? 'Training centers retrieved successfully';
}

// Training Center Response model
class TrainingCenterResponse {
  final TrainingCenter? data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterResponse({
    this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterResponse(
      data: json['data'] != null ? TrainingCenter.fromJson(json['data']) : null,
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
  String get messageAr => mAr ?? 'تم تنفيذ العملية بنجاح';
  String get messageEn => mEn ?? 'Operation completed successfully';
}
