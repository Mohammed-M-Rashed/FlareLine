// Trainer Management Models - Based on API Documentation Specification
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Trainer model for trainer management operations
class Trainer {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? bio;
  final String? qualifications;
  final int? yearsExperience;
  final List<String> specializations;
  final List<String>? certifications;
  final String status;
  final String? rejectionReason;
  final String? address;
  final int? countryId;
  final int? cityId;
  final String? countryName;
  final String? cityName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Trainer({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.bio,
    this.qualifications,
    this.yearsExperience,
    required this.specializations,
    this.certifications,
    required this.status,
    this.rejectionReason,
    this.address,
    this.countryId,
    this.cityId,
    this.countryName,
    this.cityName,
    this.createdAt,
    this.updatedAt,
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

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: _toIntNullable(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'],
      qualifications: json['qualifications'],
      yearsExperience: _toIntNullable(json['years_experience']),
      specializations: (json['specializations'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      certifications: (json['certifications'] as List?)
              ?.map((item) => item.toString())
              .toList(),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      address: json['address'],
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
      'specializations': specializations,
      'status': status,
    };
    
    if (id != null) data['id'] = id;
    if (bio != null) data['bio'] = bio;
    if (qualifications != null) data['qualifications'] = qualifications;
    if (yearsExperience != null) data['years_experience'] = yearsExperience;
    if (certifications != null) data['certifications'] = certifications;
    if (rejectionReason != null) data['rejection_reason'] = rejectionReason;
    if (address != null) data['address'] = address;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    
    return data;
  }

  Trainer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? qualifications,
    int? yearsExperience,
    List<String>? specializations,
    List<String>? certifications,
    String? status,
    String? rejectionReason,
    String? address,
    int? countryId,
    int? cityId,
    String? countryName,
    String? cityName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trainer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      qualifications: qualifications ?? this.qualifications,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      specializations: specializations ?? this.specializations,
      certifications: certifications ?? this.certifications,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      address: address ?? this.address,
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
    return 'Trainer(id: $id, name: $name, email: $email, phone: $phone, specializations: $specializations, status: $status, rejectionReason: $rejectionReason, address: $address, countryId: $countryId, cityId: $cityId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trainer &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.bio == bio &&
        other.qualifications == qualifications &&
        other.yearsExperience == yearsExperience &&
        listEquals(other.specializations, specializations) &&
        listEquals(other.certifications, certifications) &&
        other.status == status &&
        other.rejectionReason == rejectionReason &&
        other.address == address &&
        other.countryId == countryId &&
        other.cityId == cityId &&
        other.countryName == countryName &&
        other.cityName == cityName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           email.hashCode ^ 
           phone.hashCode ^ 
           (bio?.hashCode ?? 0) ^
           (qualifications?.hashCode ?? 0) ^
           (yearsExperience?.hashCode ?? 0) ^
           specializations.hashCode ^
           (certifications?.hashCode ?? 0) ^
           status.hashCode ^
           (rejectionReason?.hashCode ?? 0) ^
           (address?.hashCode ?? 0) ^
           (countryId?.hashCode ?? 0) ^
           (cityId?.hashCode ?? 0) ^
           (countryName?.hashCode ?? 0) ^
           (cityName?.hashCode ?? 0);
  }
}

// Trainer Status Request model
class TrainerStatusRequest {
  final int id;

  TrainerStatusRequest({required this.id});

  factory TrainerStatusRequest.fromJson(Map<String, dynamic> json) {
    return TrainerStatusRequest(
      id: Trainer._toInt(json['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

// Accept Trainer Request model
class AcceptTrainerRequest {
  final int id;

  AcceptTrainerRequest({required this.id});

  factory AcceptTrainerRequest.fromJson(Map<String, dynamic> json) {
    return AcceptTrainerRequest(
      id: Trainer._toInt(json['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

// Reject Trainer Request model
class RejectTrainerRequest {
  final int id;
  final String rejectionReason;

  RejectTrainerRequest({
    required this.id,
    required this.rejectionReason,
  });

  factory RejectTrainerRequest.fromJson(Map<String, dynamic> json) {
    return RejectTrainerRequest(
      id: Trainer._toInt(json['id']),
      rejectionReason: json['rejection_reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rejection_reason': rejectionReason,
    };
  }
}

// Get Trainers By Status Request model
class GetTrainersByStatusRequest {
  final String status;

  GetTrainersByStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

// Trainer Create Request model
class TrainerCreateRequest {
  final String name;
  final String email;
  final String phone;
  final String? bio;
  final String? qualifications;
  final int? yearsExperience;
  final List<String> specializations;
  final List<String>? certifications;
  final String? address;
  final int? countryId;
  final int? cityId;

  TrainerCreateRequest({
    required this.name,
    required this.email,
    required this.phone,
    this.bio,
    this.qualifications,
    this.yearsExperience,
    required this.specializations,
    this.certifications,
    this.address,
    this.countryId,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone': phone,
      'specializations': specializations,
    };
    
    if (bio != null) data['bio'] = bio;
    if (qualifications != null) data['qualifications'] = qualifications;
    if (yearsExperience != null) data['years_experience'] = yearsExperience;
    if (certifications != null) data['certifications'] = certifications;
    if (address != null) data['address'] = address;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    
    return data;
  }
}

// Trainer Update Request model
class TrainerUpdateRequest {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? qualifications;
  final int? yearsExperience;
  final List<String>? specializations;
  final List<String>? certifications;
  final String? address;
  final int? countryId;
  final int? cityId;

  TrainerUpdateRequest({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.qualifications,
    this.yearsExperience,
    this.specializations,
    this.certifications,
    this.address,
    this.countryId,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (qualifications != null) data['qualifications'] = qualifications;
    if (yearsExperience != null) data['years_experience'] = yearsExperience;
    if (specializations != null) data['specializations'] = specializations;
    if (certifications != null) data['certifications'] = certifications;
    if (address != null) data['address'] = address;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    
    return data;
  }
}

// Trainer List Response model
class TrainerListResponse {
  final List<Trainer> data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainerListResponse({
    required this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainerListResponse.fromJson(Map<String, dynamic> json) {
    return TrainerListResponse(
      data: (json['data'] as List?)
              ?.map((item) => Trainer.fromJson(item))
              .toList() ??
          [],
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: Trainer._toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200;
  String get messageAr => mAr ?? 'تم جلب المدربين بنجاح';
  String get messageEn => mEn ?? 'Trainers retrieved successfully';
}

// Trainer Response model
class TrainerResponse {
  final Trainer? data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainerResponse({
    this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainerResponse.fromJson(Map<String, dynamic> json) {
    return TrainerResponse(
      data: json['data'] != null ? Trainer.fromJson(json['data']) : null,
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: Trainer._toIntNullable(json['status_code']),
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
  String get messageAr => mAr ?? 'تم تنفيذ العملية بنجاح';
  String get messageEn => mEn ?? 'Operation completed successfully';
}
