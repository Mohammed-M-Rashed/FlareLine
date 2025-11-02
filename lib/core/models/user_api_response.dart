import 'package:flareline/core/models/auth_model.dart';
import 'package:flareline/core/models/company_model.dart';
import 'package:flareline/core/models/user_model.dart';

// User API Response Models - Matching the API documentation
class UserApiResponse<T> {
  final bool success;
  final T? data;
  final ApiMessage message;
  final int statusCode;

  UserApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });

  factory UserApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return UserApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: ApiMessage.fromJson(json['message']),
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class ApiMessage {
  final String ar;
  final String en;

  ApiMessage({
    required this.ar,
    required this.en,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> json) {
    return ApiMessage(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }
}

class UserApiData {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? companyId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Company? company;
  final List<Role> roles;

  UserApiData({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.companyId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.company,
    required this.roles,
  });

  factory UserApiData.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert dynamic value to int
    int _toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    // Helper function to safely convert dynamic value to int?
    int? _toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Handle roles array
    List<Role> roles = [];
    if (json['roles'] != null && json['roles'] is List) {
      roles = (json['roles'] as List)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList();
    }

    return UserApiData(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      companyId: _toIntNullable(json['company_id']),
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'company_id': companyId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'company': company?.toJson(),
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class UserCreateRequest {
  final String name;
  final String email;
  final String password;
  final String role;
  final int? companyId;
  final String status;

  UserCreateRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.companyId,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
    };
    
    if (companyId != null) data['company_id'] = companyId;
    
    return data;
  }
}

class UserUpdateRequest {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String? role;
  final int? companyId;
  final String? status;

  UserUpdateRequest({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.role,
    this.companyId,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
    };
    
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    if (companyId != null) data['company_id'] = companyId;
    if (status != null) data['status'] = status;
    
    return data;
  }
}

class UserStatusRequest {
  final int userId;

  UserStatusRequest({
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}
