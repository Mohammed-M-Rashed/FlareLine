// Training Center Branch Management Models - Based on New API Documentation
import 'package:flutter/material.dart';

// Training Center Branch model for branch management operations
class TrainingCenterBranch {
  final int? id;
  final String name;
  final int trainingCenterId;
  final String trainingCenterName;
  final String address;
  final String phone;
  final double? lat;
  final double? long;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainingCenterBranch({
    this.id,
    required this.name,
    required this.trainingCenterId,
    required this.trainingCenterName,
    required this.address,
    required this.phone,
    this.lat,
    this.long,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingCenterBranch.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranch(
      id: json['id'],
      name: json['name'] ?? '',
      trainingCenterId: json['training_center_id'] ?? 0,
      trainingCenterName: json['training_center']?['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      long: json['long'] != null ? double.tryParse(json['long'].toString()) : null,
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
      'training_center_id': trainingCenterId,
      'address': address,
      'phone': phone,
    };
    
    if (id != null) data['id'] = id;
    if (lat != null) data['lat'] = lat;
    if (long != null) data['long'] = long;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    
    return data;
  }

  TrainingCenterBranch copyWith({
    int? id,
    String? name,
    int? trainingCenterId,
    String? trainingCenterName,
    String? address,
    String? phone,
    double? lat,
    double? long,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingCenterBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      trainingCenterId: trainingCenterId ?? this.trainingCenterId,
      trainingCenterName: trainingCenterName ?? this.trainingCenterName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get full address with coordinates if available
  String get fullAddress {
    if (lat != null && long != null) {
      return '$address (${lat!.toStringAsFixed(7)}, ${long!.toStringAsFixed(7)})';
    }
    return address;
  }

  // Check if branch has coordinates
  bool get hasCoordinates => lat != null && long != null;

  @override
  String toString() {
    return 'TrainingCenterBranch(id: $id, name: $name, trainingCenterId: $trainingCenterId, trainingCenterName: $trainingCenterName, address: $address, phone: $phone, lat: $lat, long: $long)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingCenterBranch &&
        other.id == id &&
        other.name == name &&
        other.trainingCenterId == trainingCenterId &&
        other.trainingCenterName == trainingCenterName &&
        other.address == address &&
        other.phone == phone &&
        other.lat == lat &&
        other.long == long;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           trainingCenterId.hashCode ^ 
           trainingCenterName.hashCode ^ 
           address.hashCode ^ 
           phone.hashCode ^
           lat.hashCode ^
           long.hashCode;
  }
}

// Training Center Branch Create Request model
class TrainingCenterBranchCreateRequest {
  final String name;
  final int trainingCenterId;
  final String address;
  final String phone;
  final double? lat;
  final double? long;

  TrainingCenterBranchCreateRequest({
    required this.name,
    required this.trainingCenterId,
    required this.address,
    required this.phone,
    this.lat,
    this.long,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'training_center_id': trainingCenterId,
      'address': address,
      'phone': phone,
    };
    
    if (lat != null) data['lat'] = lat;
    if (long != null) data['long'] = long;
    
    return data;
  }
}

// Training Center Branch Update Request model
class TrainingCenterBranchUpdateRequest {
  final int id;
  final String? name;
  final int? trainingCenterId;
  final String? address;
  final String? phone;
  final double? lat;
  final double? long;

  TrainingCenterBranchUpdateRequest({
    required this.id,
    this.name,
    this.trainingCenterId,
    this.address,
    this.phone,
    this.lat,
    this.long,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (name != null) data['name'] = name;
    if (trainingCenterId != null) data['training_center_id'] = trainingCenterId;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (lat != null) data['lat'] = lat;
    if (long != null) data['long'] = long;
    
    return data;
  }
}

// Get Training Center Branches Request model
class GetTrainingCenterBranchesRequest {
  final int? centerId;

  GetTrainingCenterBranchesRequest({this.centerId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (centerId != null) data['center_id'] = centerId;
    return data;
  }
}

// Training Center Branch List Response model
class TrainingCenterBranchListResponse {
  final List<TrainingCenterBranch> data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterBranchListResponse({
    required this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterBranchListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranchListResponse(
      data: (json['data'] as List?)
              ?.map((item) => TrainingCenterBranch.fromJson(item))
              .toList() ??
          [],
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }

  bool get success => statusCode == 200;
  String get messageAr => mAr ?? 'تم جلب فروع مراكز التدريب بنجاح';
  String get messageEn => mEn ?? 'Training center branches retrieved successfully';
}

// Training Center Branch Response model
class TrainingCenterBranchResponse {
  final TrainingCenterBranch? data;
  final String? mAr;
  final String? mEn;
  final int? statusCode;

  TrainingCenterBranchResponse({
    this.data,
    this.mAr,
    this.mEn,
    this.statusCode,
  });

  factory TrainingCenterBranchResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranchResponse(
      data: json['data'] != null ? TrainingCenterBranch.fromJson(json['data']) : null,
      mAr: json['m_ar'],
      mEn: json['m_en'],
      statusCode: json['status_code'],
    );
  }

  bool get success => statusCode == 200 || statusCode == 201;
  String get messageAr => mAr ?? 'تم تنفيذ العملية بنجاح';
  String get messageEn => mEn ?? 'Operation completed successfully';
}
