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
  final String? rejectionReason;
  final int? countryId;
  final int? cityId;
  final String? countryName;
  final String? cityName;
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
    this.rejectionReason,
    this.countryId,
    this.cityId,
    this.countryName,
    this.cityName,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    int? _toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    return TrainingCenter(
      id: _toIntNullable(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      website: json['website'],
      description: json['description'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      countryId: _toIntNullable(json['country_id']),
      cityId: _toIntNullable(json['city_id']),
      countryName: json['country']?['name'],
      cityName: json['city']?['name'],
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
    if (rejectionReason != null) data['rejection_reason'] = rejectionReason;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
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
    String? rejectionReason,
    int? countryId,
    int? cityId,
    String? countryName,
    String? cityName,
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
      rejectionReason: rejectionReason ?? this.rejectionReason,
      countryId: countryId ?? this.countryId,
      cityId: cityId ?? this.cityId,
      countryName: countryName ?? this.countryName,
      cityName: cityName ?? this.cityName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        return Colors.amber; // More yellow than orange
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
  final String? status; // Optional: approved or rejected
  final int? countryId;
  final int? cityId;

  TrainingCenterCreateRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    this.description,
    this.status,
    this.countryId,
    this.cityId,
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
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    if (status != null) {
      // Validate status values according to API documentation
      if (status == 'pending' || status == 'approved' || status == 'rejected') {
        data['status'] = status;
      } else {
        throw ArgumentError('Status must be "pending", "approved", or "rejected"');
      }
    }
    
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
  final String? status; // Only 'approved' or 'rejected' allowed
  final String? rejectionReason; // Required if status is 'rejected'
  final int? countryId;
  final int? cityId;

  TrainingCenterUpdateRequest({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.website,
    this.description,
    this.status,
    this.rejectionReason,
    this.countryId,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (website != null) data['website'] = website;
    if (description != null) data['description'] = description;
    if (status != null) {
      // Validate status values according to API documentation
      if (status == 'pending' || status == 'approved' || status == 'rejected') {
        data['status'] = status;
      } else {
        throw ArgumentError('Status must be "pending", "approved", or "rejected"');
      }
    }
    if (rejectionReason != null) data['rejection_reason'] = rejectionReason;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    
    return data;
  }
}

// Accept Training Center Request model
class AcceptTrainingCenterRequest {
  final int id;

  AcceptTrainingCenterRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

// Reject Training Center Request model
class RejectTrainingCenterRequest {
  final int id;
  final String rejectionReason;

  RejectTrainingCenterRequest({
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

// Get Training Centers By Status Request model
class GetTrainingCentersByStatusRequest {
  final String status;

  GetTrainingCentersByStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

// Training Center List Response model
class TrainingCenterListResponse {
  final List<TrainingCenter> data;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;

  TrainingCenterListResponse({
    required this.data,
    this.messageAr,
    this.messageEn,
    this.statusCode,
  });

  factory TrainingCenterListResponse.fromJson(Map<String, dynamic> json) {
    int? _toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    return TrainingCenterListResponse(
      data: (json['data'] as List?)
              ?.map((item) => TrainingCenter.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: _toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200;
  String get messageArText => messageAr ?? 'تم جلب مراكز التدريب بنجاح';
  String get messageEnText => messageEn ?? 'Training centers retrieved successfully';
}

// Training Center Response model
class TrainingCenterResponse {
  final TrainingCenter? data;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;

  TrainingCenterResponse({
    this.data,
    this.messageAr,
    this.messageEn,
    this.statusCode,
  });

  factory TrainingCenterResponse.fromJson(Map<String, dynamic> json) {
    int? _toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    return TrainingCenterResponse(
      data: json['data'] != null ? TrainingCenter.fromJson(json['data']) : null,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: _toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
  String get messageArText => messageAr ?? 'تم تنفيذ العملية بنجاح';
  String get messageEnText => messageEn ?? 'Operation completed successfully';
}
